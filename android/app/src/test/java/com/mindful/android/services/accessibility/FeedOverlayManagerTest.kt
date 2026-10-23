package com.mindful.android.services.accessibility

import com.mindful.android.AppConstants
import com.mindful.android.enums.PlatformFeatures
import com.mindful.android.services.accessibility.FeedOverlayManager.Companion.coverBounds
import com.mindful.android.services.accessibility.FeedOverlayManager.Companion.shouldCoverFeed
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class FeedOverlayManagerTest {
    private val ig = AppConstants.INSTAGRAM_PACKAGE
    private val fb = AppConstants.FACEBOOK_PACKAGE
    private val igOn = setOf(PlatformFeatures.INSTAGRAM_HOME_FEED)
    private val fbOn = setOf(PlatformFeatures.FACEBOOK_HOME_FEED)
    private val list = "android:id/list"
    private val feedTab = "com.instagram.android:id/feed_tab"
    private val contextMenu = "com.instagram.android:id/context_menu"
    private val bottomSheet = "com.instagram.android:id/layout_container_bottom_sheet"
    private val fbHomeSk = "Domov, karta 1 z 6"
    private val fbHomeEn = "Home, tab 1 of 6"
    private val fbReelsSk = "Reels, karta 2 z 6"

    private fun cover(
        pkg: String,
        features: Set<PlatformFeatures>,
        ids: Set<String> = emptySet(),
        selectedIds: Set<String> = emptySet(),
        selectedDescs: Set<String> = emptySet(),
    ) = shouldCoverFeed(
        pkg,
        features,
        { it in ids },
        { it in selectedIds },
        { prefixes -> prefixes.any { p -> selectedDescs.any { it.startsWith(p) } } },
    )

    private val igSelected = setOf(feedTab)

    @Test
    fun instagram_listAndFeedTabSelected_covers() {
        assertTrue(cover(ig, igOn, ids = setOf(list), selectedIds = igSelected))
    }

    @Test
    fun instagram_featureOff_doesNotCover() {
        assertFalse(cover(ig, emptySet(), ids = setOf(list), selectedIds = igSelected))
    }

    @Test
    fun instagram_listMissing_doesNotCover() {
        assertFalse(cover(ig, igOn, selectedIds = igSelected))
    }

    @Test
    fun instagram_feedTabNotSelected_doesNotCover() {
        assertFalse(cover(ig, igOn, ids = setOf(list)))
    }

    @Test
    fun instagram_contextMenuPresent_doesNotCover() {
        assertFalse(
            cover(ig, igOn, ids = setOf(list, contextMenu), selectedIds = igSelected)
        )
    }

    @Test
    fun instagram_bottomSheetPresent_doesNotCover() {
        assertFalse(
            cover(ig, igOn, ids = setOf(list, bottomSheet), selectedIds = igSelected)
        )
    }

    @Test
    fun instagramPackage_onlyFacebookFeatureOn_doesNotCover() {
        assertFalse(cover(ig, fbOn, ids = setOf(list), selectedIds = igSelected))
    }

    @Test
    fun facebook_slovakHomeTabSelectedAndList_covers() {
        assertTrue(cover(fb, fbOn, ids = setOf(list), selectedDescs = setOf(fbHomeSk)))
    }

    @Test
    fun facebook_englishHomeTabSelectedAndList_covers() {
        assertTrue(cover(fb, fbOn, ids = setOf(list), selectedDescs = setOf(fbHomeEn)))
    }

    @Test
    fun facebook_reelsTabSelected_doesNotCover() {
        assertFalse(cover(fb, fbOn, ids = setOf(list), selectedDescs = setOf(fbReelsSk)))
    }

    @Test
    fun facebook_listMissing_doesNotCover() {
        assertFalse(cover(fb, fbOn, selectedDescs = setOf(fbHomeSk)))
    }

    @Test
    fun facebook_noTabSelected_doesNotCover() {
        assertFalse(cover(fb, fbOn, ids = setOf(list)))
    }

    @Test
    fun facebook_featureOff_doesNotCover() {
        assertFalse(
            cover(fb, emptySet(), ids = setOf(list), selectedDescs = setOf(fbHomeSk))
        )
    }

    @Test
    fun facebookPackage_onlyInstagramFeatureOn_doesNotCover() {
        assertFalse(
            cover(
                fb,
                igOn,
                ids = setOf(list),
                selectedIds = igSelected,
                selectedDescs = setOf(fbHomeSk),
            )
        )
    }

    @Test
    fun otherPackage_doesNotCover() {
        assertFalse(
            cover(
                "com.other.app",
                igOn + fbOn,
                ids = setOf(list),
                selectedIds = igSelected,
                selectedDescs = setOf(fbHomeSk),
            )
        )
    }

    @Test
    fun coverBounds_instagramHome() {
        assertEquals(675 to 2235, coverBounds(152, 2235, listOf(299, 675, 675), 2235))
    }

    @Test
    fun coverBounds_instagramScrolledNoChrome() {
        assertEquals(152 to 2235, coverBounds(152, 2235, emptyList(), 2235))
    }

    @Test
    fun coverBounds_facebookHome() {
        assertEquals(1074 to 2214, coverBounds(152, 2424, listOf(268, 1074), 2214))
    }

    @Test
    fun coverBounds_facebookScrolled() {
        assertEquals(268 to 2214, coverBounds(152, 2424, listOf(268), 2214))
    }

    @Test
    fun coverBounds_noBottomBar_usesListBottom() {
        assertEquals(268 to 2424, coverBounds(152, 2424, listOf(268), null))
    }

    @Test
    fun coverBounds_chromeCoversAll_null() {
        assertNull(coverBounds(152, 2235, listOf(2235), 2235))
    }

    @Test
    fun coverBounds_bottomBarAboveTop_null() {
        assertNull(coverBounds(152, 2424, listOf(268), 100))
    }
}
