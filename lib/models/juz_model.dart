class ParahInfo {
  final int number;
  final String arabicName;
  final String commonName;
  final int startSurah;
  final String startSurahName;
  final int startAyah;

  const ParahInfo({
    required this.number,
    required this.arabicName,
    required this.commonName,
    required this.startSurah,
    required this.startSurahName,
    required this.startAyah,
  });

  static const List<ParahInfo> all = [
    ParahInfo(number: 1,  arabicName: 'الم',                    commonName: 'Alif Lam Meem',      startSurah: 1,  startSurahName: 'Al-Fatiha',    startAyah: 1),
    ParahInfo(number: 2,  arabicName: 'سَيَقُولُ',              commonName: 'Sayaqool',           startSurah: 2,  startSurahName: 'Al-Baqara',    startAyah: 142),
    ParahInfo(number: 3,  arabicName: 'تِلْكَ الرُّسُلُ',      commonName: 'Tilkal Rusul',       startSurah: 2,  startSurahName: 'Al-Baqara',    startAyah: 253),
    ParahInfo(number: 4,  arabicName: 'لَنْ تَنَالُوا',        commonName: 'Lan Tanaloo',        startSurah: 3,  startSurahName: 'Aal-e-Imran',  startAyah: 92),
    ParahInfo(number: 5,  arabicName: 'وَالْمُحْصَنَاتُ',      commonName: 'Wal Muhsanat',       startSurah: 4,  startSurahName: 'An-Nisa',      startAyah: 24),
    ParahInfo(number: 6,  arabicName: 'لَا يُحِبُّ',           commonName: 'La Yuhibbullah',     startSurah: 4,  startSurahName: 'An-Nisa',      startAyah: 148),
    ParahInfo(number: 7,  arabicName: 'وَإِذَا سَمِعُوا',      commonName: 'Wa Iza Samiu',       startSurah: 5,  startSurahName: 'Al-Ma\'idah',  startAyah: 82),
    ParahInfo(number: 8,  arabicName: 'وَلَوْ أَنَّنَا',       commonName: 'Wa Lau Annana',      startSurah: 6,  startSurahName: 'Al-An\'am',    startAyah: 111),
    ParahInfo(number: 9,  arabicName: 'قَالَ الْمَلَأُ',       commonName: 'Qal Al Malao',       startSurah: 7,  startSurahName: 'Al-A\'raf',    startAyah: 88),
    ParahInfo(number: 10, arabicName: 'وَاعْلَمُوا',           commonName: 'Wa A\'lamu',         startSurah: 8,  startSurahName: 'Al-Anfal',     startAyah: 41),
    ParahInfo(number: 11, arabicName: 'يَعْتَذِرُونَ',         commonName: 'Ya\'tadhiruna',      startSurah: 9,  startSurahName: 'At-Tawbah',    startAyah: 93),
    ParahInfo(number: 12, arabicName: 'وَمَا مِنْ دَابَّةٍ',   commonName: 'Wa Ma Min Dabbah',   startSurah: 11, startSurahName: 'Hud',          startAyah: 6),
    ParahInfo(number: 13, arabicName: 'وَمَا أُبَرِّئُ',       commonName: 'Wa Ma Ubriyu',       startSurah: 12, startSurahName: 'Yusuf',        startAyah: 53),
    ParahInfo(number: 14, arabicName: 'رُبَمَا',               commonName: 'Rubama',             startSurah: 15, startSurahName: 'Al-Hijr',      startAyah: 1),
    ParahInfo(number: 15, arabicName: 'سُبْحَانَ الَّذِي',     commonName: 'Subhanalladhi',      startSurah: 17, startSurahName: 'Al-Isra',      startAyah: 1),
    ParahInfo(number: 16, arabicName: 'قَالَ أَلَمْ',          commonName: 'Qala Alam',          startSurah: 18, startSurahName: 'Al-Kahf',      startAyah: 75),
    ParahInfo(number: 17, arabicName: 'اقْتَرَبَ',             commonName: 'Iqtaraba',           startSurah: 21, startSurahName: 'Al-Anbiya',    startAyah: 1),
    ParahInfo(number: 18, arabicName: 'قَدْ أَفْلَحَ',         commonName: 'Qad Aflaha',         startSurah: 23, startSurahName: 'Al-Mu\'minun', startAyah: 1),
    ParahInfo(number: 19, arabicName: 'وَقَالَ الَّذِينَ',     commonName: 'Wa Qalalladhina',    startSurah: 25, startSurahName: 'Al-Furqan',    startAyah: 21),
    ParahInfo(number: 20, arabicName: 'أَمَّنْ خَلَقَ',        commonName: 'Amman Khalaqa',      startSurah: 27, startSurahName: 'An-Naml',      startAyah: 59),
    ParahInfo(number: 21, arabicName: 'اتْلُ مَا أُوحِيَ',    commonName: 'Utlu Ma Oohi Ya',    startSurah: 29, startSurahName: 'Al-Ankabut',   startAyah: 45),
    ParahInfo(number: 22, arabicName: 'وَمَنْ يَقْنُتْ',       commonName: 'Wa Man Yaqnut',      startSurah: 33, startSurahName: 'Al-Ahzab',     startAyah: 31),
    ParahInfo(number: 23, arabicName: 'وَمَالِيَ',             commonName: 'Wa Mali',            startSurah: 36, startSurahName: 'Ya-Sin',        startAyah: 28),
    ParahInfo(number: 24, arabicName: 'فَمَنْ أَظْلَمُ',       commonName: 'Faman Azlamu',       startSurah: 39, startSurahName: 'Az-Zumar',     startAyah: 32),
    ParahInfo(number: 25, arabicName: 'إِلَيْهِ يُرَدُّ',      commonName: 'Ilayhee Yuraddu',    startSurah: 41, startSurahName: 'Fussilat',     startAyah: 47),
    ParahInfo(number: 26, arabicName: 'حم',                    commonName: 'Ha Meem',            startSurah: 46, startSurahName: 'Al-Ahqaf',     startAyah: 1),
    ParahInfo(number: 27, arabicName: 'قَالَ فَمَا خَطْبُكُمْ', commonName: 'Qala Fama Khatbukum', startSurah: 51, startSurahName: 'Adh-Dhariyat', startAyah: 31),
    ParahInfo(number: 28, arabicName: 'قَدْ سَمِعَ اللَّهُ',   commonName: 'Qad Sami Allah',     startSurah: 58, startSurahName: 'Al-Mujadila',  startAyah: 1),
    ParahInfo(number: 29, arabicName: 'تَبَارَكَ الَّذِي',     commonName: 'Tabarakalladi',      startSurah: 67, startSurahName: 'Al-Mulk',      startAyah: 1),
    ParahInfo(number: 30, arabicName: 'عَمَّ',                 commonName: 'Amma',               startSurah: 78, startSurahName: 'An-Naba',      startAyah: 1),
  ];
}

class JuzVerse {
  final int globalNumber;
  final int numberInSurah;
  final int surahNumber;
  final String text;
  final String audio;
  final String translation;
  final String surahArabicName;
  final String surahEnglishName;

  const JuzVerse({
    required this.globalNumber,
    required this.numberInSurah,
    required this.surahNumber,
    required this.text,
    required this.audio,
    required this.translation,
    required this.surahArabicName,
    required this.surahEnglishName,
  });
}

class SurahSeparatorMarker {
  final int surahNumber;
  final String englishName;
  final String arabicName;

  const SurahSeparatorMarker({
    required this.surahNumber,
    required this.englishName,
    required this.arabicName,
  });
}
