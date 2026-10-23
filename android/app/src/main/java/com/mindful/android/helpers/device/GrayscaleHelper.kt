package com.mindful.android.helpers.device

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.provider.Settings
import android.util.Log
import com.mindful.android.helpers.storage.SharedPrefsHelper

/**
 * Toggles the system grayscale (daltonizer) display setting, restoring only state Mindful applied.
 */
object GrayscaleHelper {
    private const val TAG = "Mindful.GrayscaleHelper"
    private const val KEY_ENABLED = "accessibility_display_daltonizer_enabled"
    private const val KEY_MODE = "accessibility_display_daltonizer"

    /**
     * Whether WRITE_SECURE_SETTINGS has been granted to this app.
     */
    fun hasPermission(context: Context): Boolean =
        context.checkSelfPermission(Manifest.permission.WRITE_SECURE_SETTINGS) ==
                PackageManager.PERMISSION_GRANTED

    private fun restoreSavedModeBestEffort(context: Context) {
        try {
            val saved = SharedPrefsHelper.getMindfulSavedDaltonizerMode(context)
            if (saved != -1) Settings.Secure.putInt(context.contentResolver, KEY_MODE, saved)
        } catch (e: Exception) {
            Log.e(TAG, "restoreSavedModeBestEffort failed", e)
        }
    }

    /**
     * Enables grayscale, or disables it only if Mindful enabled it. No-op without permission.
     */
    // ponytail: can't detect user enabling grayscale while Mindful owns it; add a ContentObserver if that matters.
    @Synchronized
    fun setGrayscale(context: Context, enabled: Boolean) {
        val applied = SharedPrefsHelper.getIsGrayscaleAppliedByMindful(context)
        if (enabled && applied) return
        if (!enabled && !applied) return
        if (!hasPermission(context)) return

        val resolver = context.contentResolver
        if (enabled) {
            try {
                // Already enabled by the user: leave it alone
                if (Settings.Secure.getInt(resolver, KEY_ENABLED, 0) == 1) return
                SharedPrefsHelper.setMindfulSavedDaltonizerMode(
                    context, Settings.Secure.getInt(resolver, KEY_MODE, -1)
                )
                // Flag first so a partial write is still recognised as ours
                SharedPrefsHelper.setIsGrayscaleAppliedByMindful(context, true)
                val ok = Settings.Secure.putInt(resolver, KEY_MODE, 0) &&
                        Settings.Secure.putInt(resolver, KEY_ENABLED, 1)
                if (!ok) {
                    restoreSavedModeBestEffort(context)
                    SharedPrefsHelper.setIsGrayscaleAppliedByMindful(context, false)
                }
            } catch (e: Exception) {
                Log.e(TAG, "setGrayscale: Secure settings write failed", e)
                restoreSavedModeBestEffort(context)
                SharedPrefsHelper.setIsGrayscaleAppliedByMindful(context, false)
            }
        } else {
            try {
                if (Settings.Secure.getInt(resolver, KEY_ENABLED, 0) == 0 ||
                    Settings.Secure.putInt(resolver, KEY_ENABLED, 0)
                ) {
                    val saved = SharedPrefsHelper.getMindfulSavedDaltonizerMode(context)
                    if (saved == -1 || Settings.Secure.putInt(resolver, KEY_MODE, saved)) {
                        SharedPrefsHelper.setIsGrayscaleAppliedByMindful(context, false)
                        SharedPrefsHelper.setMindfulSavedDaltonizerMode(context, -1)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "setGrayscale: Secure settings write failed", e)
            }
        }
    }
}
