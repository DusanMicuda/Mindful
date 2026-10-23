package com.mindful.android.services.accessibility

import com.mindful.android.services.accessibility.ShortsPlatformManager.Companion.isFacebookReelsOpen
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ShortsPlatformManagerTest {
    private fun open(texts: Set<String> = emptySet(), selected: Set<String> = emptySet()) =
        isFacebookReelsOpen(
            { it in texts },
            { prefixes -> prefixes.any { p -> selected.any { it.startsWith(p) } } },
        )

    private fun open(vararg texts: String) = open(texts = texts.toSet())

    @Test
    fun addAComment_isOpen() {
        assertTrue(open("Add a comment"))
    }

    @Test
    fun writeAComment_ellipsis_isOpen() {
        assertTrue(open("Write a comment\u2026"))
    }

    @Test
    fun hindi_isOpen() {
        assertTrue(open("कमेंट जोड़ें…"))
    }

    @Test
    fun slovak_ellipsis_isOpen() {
        assertTrue(open("Napíšte komentár\u2026"))
    }

    @Test
    fun noTexts_isNotOpen() {
        assertFalse(open())
    }

    @Test
    fun selectedReelsTab_isOpen() {
        assertTrue(open(selected = setOf("Reels, karta 2 z 6")))
    }

    @Test
    fun slovakReelsDetails_isOpen() {
        assertTrue(open("Podrobnosti karty s reelmi"))
    }

    @Test
    fun goToReelsProfile_isOpen() {
        assertTrue(open("Go to your Reels profile"))
    }

    @Test
    fun selectedHomeTabOnly_isNotOpen() {
        assertFalse(open(selected = setOf("Domov, karta 1 z 6")))
    }
}
