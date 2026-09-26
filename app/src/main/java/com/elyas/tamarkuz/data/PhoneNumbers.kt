package com.elyas.tamarkuz.data

object PhoneNumbers {
    /** Numbers match on their last nine digits, so 0701234567 and +93701234567 are the same line. */
    private const val SIGNIFICANT = 9

    fun digits(raw: String): String = raw.filter { it.isDigit() }

    fun same(a: String, b: String): Boolean {
        val da = digits(a)
        val db = digits(b)
        if (da.isEmpty() || db.isEmpty()) return false
        if (da.length < 7 || db.length < 7) return da == db
        return da.takeLast(SIGNIFICANT) == db.takeLast(SIGNIFICANT)
    }

    /** Hidden and empty numbers are never on the whitelist. */
    fun isAllowed(number: String?, whitelist: List<WhitelistEntry>): Boolean {
        if (number.isNullOrBlank()) return false
        return whitelist.any { same(it.number, number) }
    }
}
