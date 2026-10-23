package com.mindful.android.enums

import org.junit.Assert.assertEquals
import org.junit.Test

class PlatformFeaturesTest {
    @Test
    fun fromName_instagramHomeFeed_returnsInstagramHomeFeed() {
        assertEquals(
            PlatformFeatures.INSTAGRAM_HOME_FEED,
            PlatformFeatures.fromName("instagramHomeFeed")
        )
    }

    @Test
    fun fromName_facebookHomeFeed_returnsFacebookHomeFeed() {
        assertEquals(
            PlatformFeatures.FACEBOOK_HOME_FEED,
            PlatformFeatures.fromName("facebookHomeFeed")
        )
    }

    @Test
    fun fromName_instagramReels_unchanged() {
        assertEquals(
            PlatformFeatures.INSTAGRAM_REELS,
            PlatformFeatures.fromName("instagramReels")
        )
    }
}
