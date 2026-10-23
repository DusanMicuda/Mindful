package com.mindful.android.services.accessibility

import android.accessibilityservice.AccessibilityService
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Rect
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.TextView
import com.mindful.android.AppConstants.FACEBOOK_PACKAGE
import com.mindful.android.AppConstants.INSTAGRAM_PACKAGE
import com.mindful.android.R
import com.mindful.android.enums.PlatformFeatures
import com.mindful.android.models.Wellbeing
import com.mindful.android.utils.ThreadUtils
import java.util.concurrent.atomic.AtomicLong

class FeedOverlayManager(private val service: AccessibilityService) {

    // Ticket for ordering show/hide requests coming from multiple executor threads
    private val seq = AtomicLong()

    // Main-thread only state
    private var view: TextView? = null
    private var lastRect: Rect? = null
    private var lastPackage: String? = null
    private var lastApplied = 0L
    private var destroyed = false

    /** Shows or hides the home-feed overlay according to the active window [node]. */
    fun onEvent(node: AccessibilityNodeInfo, wellbeing: () -> Wellbeing) {
        val s = seq.incrementAndGet()
        val blockedFeatures = wellbeing().blockedFeatures
        val packageName = node.packageName?.toString() ?: return

        // Walked at most once per event, and only when the FB rule asks for it.
        val homeTab by lazy { node.findSelectedDescPrefix(FB_HOME_TAB_PREFIXES) }

        val cover = shouldCoverFeed(
            packageName = packageName,
            blockedFeatures = blockedFeatures,
            hasId = { id -> node.findAccessibilityNodeInfosByViewId(id).isNotEmpty() },
            hasSelectedId = { id ->
                node.findAccessibilityNodeInfosByViewId(id).any { tab ->
                    tab.isSelected || tab.findAccessibilityNodeInfosByViewId(IG_TAB_ICON_ID)
                        .any { it.isSelected }
                }
            },
            hasSelectedDescPrefix = { prefixes ->
                if (prefixes == FB_HOME_TAB_PREFIXES) homeTab != null
                else node.hasSelectedDescPrefix(prefixes)
            },
        )
        if (!cover) return hide(s)

        val isInstagram = packageName == INSTAGRAM_PACKAGE
        val listId = if (isInstagram) IG_FEED_LIST_ID else FB_FEED_LIST_ID
        val feed = node.findAccessibilityNodeInfosByViewId(listId).firstOrNull() ?: return hide(s)
        val rect = Rect()
        feed.getBoundsInScreen(rect)
        if (rect.isEmpty) return hide(s)

        val chromeBottoms = mutableListOf<Int>()
        var bottomBarTop: Int? = null
        if (isInstagram) {
            for (id in listOf(IG_ACTION_BAR_ID, IG_STORIES_TRAY_ID, IG_ACTION_BAR_LAYOUT_ID)) {
                node.findAccessibilityNodeInfosByViewId(id).firstOrNull { it.isVisibleToUser }
                    ?.let { chromeBottoms.add(boundsOf(it).bottom) }
            }
            bottomBarTop = node.findAccessibilityNodeInfosByViewId(IG_TAB_BAR_ID)
                .firstOrNull { it.isVisibleToUser }?.let { boundsOf(it).top }
        } else {
            val children = (0 until feed.childCount).mapNotNull { feed.getChild(it) }
                .filter { it.isVisibleToUser }
            children.firstOrNull()?.let { chromeBottoms.add(boundsOf(it).top) }
            // ponytail: heuristic, stories = RecyclerView-holding child at index 0, or index 1 (after the composer) only while the list is scrolled to top. Upgrade: match the "Panel príbehov" desc.
            val atTop = feed.getChild(0)?.isVisibleToUser == true
            children.take(2).withIndex().firstOrNull { (i, c) ->
                (i == 0 || atTop) &&
                        c.findVisibleNode { it.className?.endsWith("RecyclerView") == true } != null
            }?.let { chromeBottoms.add(boundsOf(it.value).bottom) }
            homeTab?.parent?.let {
                val bar = boundsOf(it)
                if (bar.top > rect.centerY()) bottomBarTop = bar.top else chromeBottoms.add(bar.bottom)
            }
        }

        val (top, bottom) = coverBounds(rect.top, rect.bottom, chromeBottoms, bottomBarTop)
            ?: return hide(s)
        show(s, packageName, Rect(rect.left, top, rect.right, bottom))
    }

    private fun boundsOf(n: AccessibilityNodeInfo) = Rect().also { n.getBoundsInScreen(it) }


    /** Removes the overlay if present, superseding any in-flight show request. */
    fun hide() = hide(seq.incrementAndGet())

    /** Removes the overlay and permanently disables further shows. */
    fun destroy() {
        if (Looper.myLooper() == Looper.getMainLooper()) destroyNow()
        else ThreadUtils.runOnMainThread { destroyNow() }
    }

    private fun destroyNow() {
        destroyed = true
        removeView()
    }

    private fun hide(s: Long) {
        ThreadUtils.runOnMainThread {
            if (destroyed || s < lastApplied) return@runOnMainThread
            lastApplied = s
            removeView()
        }
    }

    private fun removeView() {
        val v = view ?: return
        try {
            service.getSystemService(WindowManager::class.java).removeView(v)
        } catch (e: Exception) {
            Log.e(TAG, "removeView: Failed to remove feed overlay", e)
        }
        view = null
        lastRect = null
        lastPackage = null
    }

    private fun show(s: Long, packageName: String, rect: Rect) {
        ThreadUtils.runOnMainThread {
            if (destroyed || s < lastApplied) return@runOnMainThread
            lastApplied = s
            val wm = service.getSystemService(WindowManager::class.java)
            val existing = view
            try {
                if (existing == null) {
                    val v = createView(packageName)
                    wm.addView(v, createParams(rect))
                    view = v
                } else {
                    if (lastPackage != packageName) existing.setText(messageFor(packageName))
                    if (lastRect != rect) wm.updateViewLayout(existing, createParams(rect))
                }
                lastRect = Rect(rect)
                lastPackage = packageName
            } catch (e: Exception) {
                Log.e(TAG, "show: Failed to show feed overlay", e)
                if (existing != null) runCatching { wm.removeView(existing) }
                view = null
                lastRect = null
                lastPackage = null
            }
        }
    }

    private fun messageFor(packageName: String) =
        if (packageName == INSTAGRAM_PACKAGE) R.string.feed_hidden_instagram
        else R.string.feed_hidden_facebook

    private fun createParams(rect: Rect) = WindowManager.LayoutParams(
        rect.width(),
        rect.height(),
        rect.left,
        rect.top,
        WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
        WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
        PixelFormat.OPAQUE
    ).apply { gravity = Gravity.TOP or Gravity.START }

    // ponytail: plain TextView, no layout XML/theme, add a styled layout when design asks.
    private fun createView(packageName: String): TextView {
        val dark = (service.resources.configuration.uiMode and
                Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        val pad = (32 * service.resources.displayMetrics.density).toInt()
        return TextView(service).apply {
            setBackgroundColor(if (dark) Color.BLACK else Color.WHITE)
            setTextColor(if (dark) Color.WHITE else Color.BLACK)
            gravity = Gravity.CENTER
            setPadding(pad, pad, pad, pad)
            setText(messageFor(packageName))
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
        }
    }

    companion object {
        private const val TAG = "Mindful.FeedOverlayManager"

        internal const val IG_FEED_LIST_ID = "android:id/list"
        internal const val FB_FEED_LIST_ID = "android:id/list"

        internal const val IG_FEED_TAB_ID = "com.instagram.android:id/feed_tab"
        internal const val IG_TAB_ICON_ID = "com.instagram.android:id/tab_icon"
        internal const val IG_CONTEXT_MENU_ID = "com.instagram.android:id/context_menu"

        // ponytail: bottom-sheet/context-menu exclusion list is the observed set; extend when another IG sheet over Home gets covered.
        internal const val IG_BOTTOM_SHEET_ID =
            "com.instagram.android:id/layout_container_bottom_sheet"

        // ponytail: flat label list across languages, any match counts. New language = append its prefix here + a test case. Per-locale map only when two languages' labels collide.
        internal val FB_HOME_TAB_PREFIXES = listOf("Domov,", "Home,")

        internal const val IG_ACTION_BAR_ID = "com.instagram.android:id/main_feed_action_bar"
        internal const val IG_STORIES_TRAY_ID =
            "com.instagram.android:id/overlay_stories_tray_container"
        internal const val IG_ACTION_BAR_LAYOUT_ID =
            "com.instagram.android:id/action_bar_LinearLayout"
        internal const val IG_TAB_BAR_ID = "com.instagram.android:id/tab_bar"

        /** Whether the home-feed overlay should cover the current screen. */
        internal fun shouldCoverFeed(
            packageName: String,
            blockedFeatures: Set<PlatformFeatures>,
            hasId: (String) -> Boolean,
            hasSelectedId: (String) -> Boolean,
            hasSelectedDescPrefix: (List<String>) -> Boolean,
        ): Boolean = when (packageName) {
            INSTAGRAM_PACKAGE ->
                PlatformFeatures.INSTAGRAM_HOME_FEED in blockedFeatures &&
                        hasId(IG_FEED_LIST_ID) &&
                        hasSelectedId(IG_FEED_TAB_ID) &&
                        !hasId(IG_CONTEXT_MENU_ID) &&
                        !hasId(IG_BOTTOM_SHEET_ID)

            FACEBOOK_PACKAGE ->
                PlatformFeatures.FACEBOOK_HOME_FEED in blockedFeatures &&
                        hasId(FB_FEED_LIST_ID) &&
                        hasSelectedDescPrefix(FB_HOME_TAB_PREFIXES)

            else -> false
        }

        /** Vertical span to cover below the chrome and above the bottom bar, or null if empty. */
        internal fun coverBounds(
            listTop: Int,
            listBottom: Int,
            chromeBottoms: List<Int>,
            bottomBarTop: Int?,
        ): Pair<Int, Int>? {
            val top = maxOf(listTop, chromeBottoms.maxOrNull() ?: listTop)
            val bottom = minOf(listBottom, bottomBarTop ?: listBottom)
            return if (top >= bottom) null else top to bottom
        }
    }
}
