package com.anexon.ethio_cal

import java.util.Calendar

object EthiopianCalendarHelper {

    data class EthiopianDate(
        val year: Int,
        val month: Int,
        val day: Int,
        val weekday: Int // 1=Monday .. 7=Sunday
    ) {
        val monthName: String get() = monthNames.getOrElse(month) { "" }
        val weekdayName: String get() = weekdayNames.getOrElse(weekday) { "" }
        val formattedDate: String get() = "$monthName $day $year"
        val dayOnly: String get() = weekdayName
        val dayNumber: String get() = day.toString()
    }

    private val monthNames = arrayOf(
        "", "መስከረም", "ጥቅምት", "ኅዳር", "ታህሳስ", "ጥር", "የካቲት",
        "መጋቢት", "ሚያዝያ", "ግንቦት", "ሰኔ", "ሐምሌ", "ነሀሴ", "ጳጉሜ"
    )

    private val weekdayNames = arrayOf(
        "", "ሰኞ", "ማክሰኞ", "ረቡዕ", "ሐሙስ", "ዓርብ", "ቅዳሜ", "እሁድ"
    )

    private val monthlySaints = arrayOf(
        "",
        "ልደታ", "ታዴዎስ ሐዋርያ", "በዓታ ማርያም", "ዮሐንስ ወልደ ነጎድጓድ", "ጴጥሮስ ወጳውሎስ",
        "ኢየሱስ", "ሥላሴ", "ማቴዎስ", "ቶማስ ሐዋርያ", "በዓለ መስቀሉ ለእግዚእነ",
        "ሃና ወኢያቄም", "ቅዱስ ሚካኤል", "እግዚአብሔር አብ", "አባ አረጋዊ", "ቂርቆስና ኢየሉጣ",
        "ኪዳነ ምሕረት", "ቅዱስ እስጢፋኖስ", "ፊልጶስ ሐዋርያ", "ቅዱስ ገብርኤል", "ጽንሰታ ለማርያም",
        "በዓለ እግዝእትነ ማርያም", "ቅዱስ ዑራኤል", "ቅዱስ ጊዮርጊስ", "አቡነ ተክለ ሃይማኖት", "መርቆሬዎስ",
        "ሆሴዕ ነቢይ", "መድኃኔዓለም", "አማኑኤል", "በዓለ ወልድ", "ማርቆስ ወንጌላዊ"
    )

    private val pagumenSaints = arrayOf(
        "",
        "ቅዱስ ዮሐንስ መጥምቅ", "ቅዱስ ዮሐንስ ወንጌላዊ", "ቅዱስ ሩፋኤል ሊቀ መላእክት",
        "ቅዱስ ሰርጊስ", "ቅድስት ድንግል ማርያም", "ዕርገተ ሄኖክ"
    )

    fun getSaint(month: Int, day: Int): String {
        return if (month == 13) {
            pagumenSaints.getOrElse(day) { "ጳጉሜ" }
        } else {
            monthlySaints.getOrElse(day) { "" }
        }
    }

    fun now(): EthiopianDate {
        val cal = Calendar.getInstance()
        return fromGregorian(
            cal.get(Calendar.YEAR),
            cal.get(Calendar.MONTH) + 1,
            cal.get(Calendar.DAY_OF_MONTH),
            cal.get(Calendar.DAY_OF_WEEK)
        )
    }

    fun fromGregorian(gYear: Int, gMonth: Int, gDay: Int, gDayOfWeek: Int): EthiopianDate {
        val isPreLeap = gYear % 4 == 3
        val isLeap = gYear % 4 == 0
        var ethYear = gYear - 8
        var ethMonth = 1
        var ethDay = 1

        when (gMonth) {
            1 -> { // January
                if (isLeap) {
                    ethMonth = if (gDay < 10) 4 else 5
                    ethDay = gDay + (if (gDay < 10) 21 else -9)
                } else {
                    ethMonth = if (gDay < 9) 4 else 5
                    ethDay = gDay + (if (gDay < 9) 22 else -8)
                }
            }
            2 -> { // February
                if (isLeap) {
                    ethMonth = if (gDay < 9) 5 else 6
                    ethDay = gDay + (if (gDay < 9) 22 else -8)
                } else {
                    ethMonth = if (gDay < 8) 5 else 6
                    ethDay = gDay + (if (gDay < 8) 23 else -7)
                }
            }
            3 -> { // March
                ethMonth = if (gDay < 10) 6 else 7
                ethDay = gDay + (if (gDay < 10) 21 else -9)
            }
            4 -> { // April
                ethMonth = if (gDay < 9) 7 else 8
                ethDay = gDay + (if (gDay < 9) 22 else -8)
            }
            5 -> { // May
                ethMonth = if (gDay < 9) 8 else 9
                ethDay = gDay + (if (gDay < 9) 22 else -8)
            }
            6 -> { // June
                ethMonth = if (gDay < 8) 9 else 10
                ethDay = gDay + (if (gDay < 8) 23 else -7)
            }
            7 -> { // July
                ethMonth = if (gDay < 8) 10 else 11
                ethDay = gDay + (if (gDay < 8) 23 else -7)
            }
            8 -> { // August
                ethMonth = if (gDay < 7) 11 else 12
                ethDay = gDay + (if (gDay < 7) 24 else -6)
            }
            9 -> { // September
                if (gDay < 6) {
                    ethMonth = 12
                    ethDay = gDay + 25
                } else if (isPreLeap) {
                    ethMonth = if (gDay < 12) 13 else 1
                    ethDay = gDay + (if (gDay < 12) -5 else -11)
                    ethYear = gYear - (if (gDay < 12) 8 else 7)
                } else {
                    ethMonth = if (gDay < 11) 13 else 1
                    ethDay = gDay + (if (gDay < 11) -5 else -10)
                    ethYear = gYear - (if (gDay < 11) 8 else 7)
                }
            }
            10 -> { // October
                if (isPreLeap) {
                    ethMonth = if (gDay < 12) 1 else 2
                    ethDay = gDay + (if (gDay < 12) 19 else -11)
                } else {
                    ethMonth = if (gDay < 11) 1 else 2
                    ethDay = gDay + (if (gDay < 11) 20 else -10)
                }
                ethYear = gYear - 7
            }
            11 -> { // November
                if (isPreLeap) {
                    ethMonth = if (gDay < 11) 2 else 3
                    ethDay = gDay + (if (gDay < 11) 20 else -10)
                } else {
                    ethMonth = if (gDay < 10) 2 else 3
                    ethDay = gDay + (if (gDay < 10) 21 else -9)
                }
                ethYear = gYear - 7
            }
            12 -> { // December
                if (isPreLeap) {
                    ethMonth = if (gDay < 11) 3 else 4
                    ethDay = gDay + (if (gDay < 11) 20 else -10)
                } else {
                    ethMonth = if (gDay < 10) 3 else 4
                    ethDay = gDay + (if (gDay < 10) 21 else -9)
                }
                ethYear = gYear - 7
            }
        }

        val ethWeekday = when (gDayOfWeek) {
            Calendar.MONDAY -> 1
            Calendar.TUESDAY -> 2
            Calendar.WEDNESDAY -> 3
            Calendar.THURSDAY -> 4
            Calendar.FRIDAY -> 5
            Calendar.SATURDAY -> 6
            Calendar.SUNDAY -> 7
            else -> 1
        }

        return EthiopianDate(ethYear, ethMonth, ethDay, ethWeekday)
    }
}
