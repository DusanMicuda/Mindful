package com.mindful.android.models

import org.junit.Assert.assertEquals
import org.junit.Test

class AppRestrictionTest {
    @Test
    fun givenJsonWithSessionInterval_whenFromJson_thenSessionIntervalSecParsed() {
        // ARRANGE
        val json = """{"appPackage":"a","sessionIntervalSec":600}"""

        // ACTION
        val restriction = AppRestriction.fromJson(json)

        // CHECK
        assertEquals(600, restriction.sessionIntervalSec)
    }

    @Test
    fun givenJsonWithoutSessionInterval_whenFromJson_thenSessionIntervalSecIsZero() {
        // ARRANGE
        val json = """{"appPackage":"a"}"""

        // ACTION
        val restriction = AppRestriction.fromJson(json)

        // CHECK
        assertEquals(0, restriction.sessionIntervalSec)
    }
}
