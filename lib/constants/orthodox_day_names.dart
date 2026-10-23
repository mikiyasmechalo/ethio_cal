class OrthodoxDayNames {
  /// Monthly saint commemorations for days 1 to 30 of every Ethiopian month.
  static const Map<int, List<String>> monthlySaints = {
    1: ['ልደታ', 'ራጉኤል', 'ኤልያስ'],
    2: ['ታዴዎስ ሐዋርያ', 'ኢዮብ ጻድቅ'],
    3: ['በዓታ ማርያም', 'ዜና ማርቆስ', 'ነአኩቶ ለአብ'],
    4: ['ዮሐንስ ወልደ ነጎድጓድ'],
    5: ['ጴጥሮስ ወጳውሎስ', 'አቡነ ገብረ መንፈስ ቅዱስ'],
    6: ['ኢየሱስ', 'ቁስቋም', 'አርሴማ ቅድስት'],
    7: ['ሥላሴ', 'ፊሊሞን', 'አብላንዮስ'],
    8: ['ማቴዎስ', 'ዮልያኖስ', 'አባ ኪሮስ'],
    9: ['ቶማስ ሐዋርያ', 'እንድርያስ ሐዋርያ', 'አውሳብዮስ', 'አርባ ሰማዕታት'],
    10: ['በዓለ መስቀሉ ለእግዚእነ'],
    11: ['ሃና ወኢያቄም', 'ቅዱስ ፋሲለደስ ሰማዕት'],
    12: ['ቅዱስ ሚካኤል', 'ክርስቶስ ሠምራ'],
    13: ['እግዚአብሔር አብ', 'ቅዱስ ሩፋኤል ሊቀ መላእክት'],
    14: ['አባ አረጋዊ', 'አባ ገብረ ክርስቶስ', 'ድምጥያኖስ ሰማዕት'],
    15: ['ቂርቆስና ኢየሉጣ', 'ስልፋኮስ'],
    16: ['ኪዳነ ምሕረት', 'ሚካኤል ጳጳስ'],
    17: ['ቅዱስ እስጢፋኖስ', 'ሉቃስ ዘዓምደ ብርሃን'],
    18: ['ፊልጶስ ሐዋርያ', 'ኤስድሮስ ሰማዕት', 'ኤዎስጣጤዎስ ሰማዕት'],
    19: ['ቅዱስ ገብርኤል', 'አርቃዲዎስ'],
    20: ['ጽንሰታ ለማርያም', 'ነቢዩ ኤልሳ', 'ሐጌ ነቢይ', 'አባ ሰላማ መተርጉም'],
    21: ['በዓለ እግዝእትነ ማርያም'],
    22: ['ቅዱስ ዑራኤል', 'ደቅስዮስ'],
    23: ['ቅዱስ ጊዮርጊስ', 'ለጊኖስ ሰማዕት'],
    24: ['አቡነ ተክለ ሃይማኖት'],
    25: ['መርቆሬዎስ', 'አኒፍኖስ'],
    26: ['ሆሴዕ ነቢይ', 'ሳዶቅ ሰማዕት'],
    27: ['መድኃኔዓለም', 'ሕዝቅያስ ነቢይ', 'አባ ዮሐንስ'],
    28: ['አማኑኤል', 'ቆስጠንጢኖስ', 'አብርሃም'],
    29: ['በዓለ ወልድ', 'ሳሙኤል ዘወገግ'],
    30: ['ማርቆስ ወንጌላዊ'],
  };

  /// Pagumen daily commemorations (Month 13).
  static const Map<int, List<String>> pagumenSaints = {
    1: ['ቅዱስ ዮሐንስ መጥምቅ'],
    2: ['ቅዱስ ዮሐንስ ወንጌላዊ'],
    3: ['ቅዱስ ሩፋኤል ሊቀ መላእክት'],
    4: ['ቅዱስ ሰርጊስ'],
    5: ['ቅድስት ድንግል ማርያም', 'ቅዱስ ጴጥሮስ ወጳውሎስ'],
    6: ['ዕርገተ ሄኖክ (በዘመነ ዮሐንስ)'],
  };

  /// Returns the list of commemorated saints for a specific Ethiopian month and day.
  static List<String> getSaintsForDay(int month, int day) {
    if (month == 13) {
      return pagumenSaints[day] ?? ['ጳጉሜ'];
    }
    return monthlySaints[day] ?? [];
  }

  /// Returns primary saint name as a single display string.
  static String getPrimarySaint(int month, int day) {
    final list = getSaintsForDay(month, day);
    return list.isNotEmpty ? list.first : '';
  }

  /// Returns all saints comma-separated.
  static String getAllSaintsFormatted(int month, int day) {
    final list = getSaintsForDay(month, day);
    return list.join('፣ ');
  }
}
