class MahallaData {
  // Viloyatlar
  static const List<String> regions = [
    'Toshkent shahri',
  ];

  // Tumanlar (Toshkent shahri uchun)
  static const Map<String, List<String>> districts = {
    'Toshkent shahri': [
      'Yunusobod tumani',
    ],
  };

  // Mahallalar (Yunusobod tumani uchun)
  static const Map<String, List<String>> mahallas = {
    'Yunusobod tumani': [
      'Oqtepa mahallasi',
      'Yunusobod mahallasi',
      'Qoratosh mahallasi',
      'Shota Rustaveli mahallasi',
      'Bog\'ishamol mahallasi',
    ],
  };

  // Get districts by region
  static List<String> getDistricts(String region) {
    return districts[region] ?? [];
  }

  // Get mahallas by district
  static List<String> getMahallas(String district) {
    return mahallas[district] ?? [];
  }
}
