class MahallaData {
  // O'zbekiston viloyatlari
  static const List<String> regions = [
    'Toshkent shahri',
    'Toshkent viloyati',
    'Andijon viloyati',
    'Buxoro viloyati',
    'Farg\'ona viloyati',
    'Jizzax viloyati',
    'Xorazm viloyati',
    'Namangan viloyati',
    'Navoiy viloyati',
    'Qashqadaryo viloyati',
    'Qoraqalpog\'iston Respublikasi',
    'Samarqand viloyati',
    'Sirdaryo viloyati',
    'Surxondaryo viloyati',
  ];

  // Tumanlar (har bir viloyat uchun)
  static const Map<String, List<String>> districts = {
    'Toshkent shahri': [
      'Bektemir tumani',
      'Chilonzor tumani',
      'Mirobod tumani',
      'Mirzo Ulug\'bek tumani',
      'Olmazor tumani',
      'Sergeli tumani',
      'Shayxontohur tumani',
      'Uchtepa tumani',
      'Yakkasaroy tumani',
      'Yashnobod tumani',
      'Yunusobod tumani',
      'Yangi Hayot tumani',
    ],
    'Toshkent viloyati': [
      'Angren shahri',
      'Bekobod tumani',
      'Bo\'ka tumani',
      'Bo\'stonliq tumani',
      'Chinoz tumani',
      'Qibray tumani',
      'Oqqo\'rg\'on tumani',
      'Ohangaron tumani',
      'Parkent tumani',
      'Piskent tumani',
      'Quyichirchiq tumani',
      'O\'rtachirchiq tumani',
      'Yangiyo\'l tumani',
      'Yuqorichirchiq tumani',
      'Zangiota tumani',
    ],
    // Boshqa viloyatlar uchun placeholder
    'Andijon viloyati': ['Andijon shahri', 'Asaka tumani', 'Baliqchi tumani'],
    'Buxoro viloyati': ['Buxoro shahri', 'Kogon tumani', 'Olot tumani'],
    'Farg\'ona viloyati': ['Farg\'ona shahri', 'Marg\'ilon shahri', 'Qo\'qon shahri'],
    'Jizzax viloyati': ['Jizzax shahri', 'Arnasoy tumani', 'Baxmal tumani'],
    'Xorazm viloyati': ['Urganch shahri', 'Xiva tumani', 'Xonqa tumani'],
    'Namangan viloyati': ['Namangan shahri', 'Chortoq tumani', 'Chust tumani'],
    'Navoiy viloyati': ['Navoiy shahri', 'Zarafshon shahri', 'Karmana tumani'],
    'Qashqadaryo viloyati': ['Qarshi shahri', 'Shahrisabz tumani', 'Koson tumani'],
    'Qoraqalpog\'iston Respublikasi': ['Nukus shahri', 'Beruniy tumani', 'Qo\'ng\'irot tumani'],
    'Samarqand viloyati': ['Samarqand shahri', 'Bulung\'ur tumani', 'Jomboy tumani'],
    'Sirdaryo viloyati': ['Guliston shahri', 'Boyovut tumani', 'Mirzaobod tumani'],
    'Surxondaryo viloyati': ['Termiz shahri', 'Angor tumani', 'Boysun tumani'],
  };

  // Mahallalar (FAQAT Yunusobod tumani uchun)
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

  // Check if district has mahallas
  static bool hasMahallas(String district) {
    return mahallas.containsKey(district) && mahallas[district]!.isNotEmpty;
  }
}
