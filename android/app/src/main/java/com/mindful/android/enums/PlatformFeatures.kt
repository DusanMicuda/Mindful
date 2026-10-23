package com.mindful.android.enums

/**
 * Enum representing platform's features which are used for blocking them
 */
enum class PlatformFeatures {
    INSTAGRAM_REELS,
    INSTAGRAM_EXPLORE,
    SNAPCHAT_SPOTLIGHT,
    SNAPCHAT_DISCOVER,
    FACEBOOK_REELS,
    REDDIT_SHORTS,
    YOUTUBE_SHORTS,
    INSTAGRAM_HOME_FEED,
    FACEBOOK_HOME_FEED;

    companion object {
        fun fromName(name: String): PlatformFeatures? {
            return when (name) {
                "instagramReels" -> INSTAGRAM_REELS
                "instagramExplore" -> INSTAGRAM_EXPLORE
                "snapchatSpotlight" -> SNAPCHAT_SPOTLIGHT
                "snapchatDiscover" -> SNAPCHAT_DISCOVER
                "facebookReels" -> FACEBOOK_REELS
                "redditShorts" -> REDDIT_SHORTS
                "youtubeShorts" -> YOUTUBE_SHORTS
                "instagramHomeFeed" -> INSTAGRAM_HOME_FEED
                "facebookHomeFeed" -> FACEBOOK_HOME_FEED
                else -> null
            }
        }
    }
}
