class QuranEditions {
  static const String baseUrl = 'https://api.alquran.cloud';
  static const String audioEdition = 'ar.alafasy';

  static const String defaultEdition = 'en.sahih';

  static const Map<String, String> languageLabels = {
    'en': 'English',
    'ur': 'Urdu',
    'id': 'Indonesian',
    'bn': 'Bengali',
    'fa': 'Persian',
    'tr': 'Turkish',
    'hi': 'Hindi',
    'fr': 'French',
    'ru': 'Russian',
    'ha': 'Hausa',
    'sw': 'Swahili',
    'es': 'Spanish',
    'ms': 'Malay',
    'nl': 'Dutch',
    'de': 'German',
    'zh': 'Chinese',
    'bs': 'Bosnian',
    'sq': 'Albanian',
    'ml': 'Malayalam',
    'az': 'Azerbaijani',
    'cs': 'Czech',
    'dv': 'Divehi',
    'fi': 'Finnish',
    'gu': 'Gujarati',
    'he': 'Hebrew',
    'it': 'Italian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'ku': 'Kurdish',
    'mg': 'Malagasy',
    'no': 'Norwegian',
    'pl': 'Polish',
    'pt': 'Portuguese',
    'ro': 'Romanian',
    'si': 'Sinhala',
    'so': 'Somali',
    'tg': 'Tajik',
    'th': 'Thai',
    'tt': 'Tatar',
    'ug': 'Uyghur',
    'uz': 'Uzbek',
    'yo': 'Yoruba',
    'am': 'Amharic',
    'bg': 'Bulgarian',
    'ka': 'Georgian',
    'mk': 'Macedonian',
    'ps': 'Pashto',
    'ta': 'Tamil',
    'vi': 'Vietnamese',
    'pa': 'Punjabi',
    'sd': 'Sindhi',
    'kk': 'Kazakh',
    'om': 'Oromo',
    'my': 'Burmese',
    'ny': 'Chichewa',
    'lg': 'Luganda',
    'sv': 'Swedish',
    'ce': 'Chechen',
  };

  static const Map<String, String> defaultEditions = {
    'en': 'en.sahih',
    'ur': 'ur.junagarhi',
    'id': 'id.indonesian',
    'bn': 'bn.bengali',
    'fa': 'fa.makarem',
    'tr': 'tr.ates',
    'hi': 'hi.hindi',
    'fr': 'fr.hamidullah',
    'ru': 'ru.kuliev',
    'ha': 'ha.gumi',
    'sw': 'sw.barwani',
    'es': 'es.cortes',
    'ms': 'ms.basmeih',
    'nl': 'nl.keyzer',
    'de': 'de.bubenheim',
    'zh': 'zh.majian',
    'bs': 'bs.korkut',
    'sq': 'sq.nahi',
    'ml': 'ml.abdulhameed',
    'az': 'az.musayev',
    'cs': 'cs.hrbek',
    'dv': 'dv.divehi',
    'fi': 'fi.finnish',
    'gu': 'gu.rabilaalomari',
    'he': 'he.hebrew',
    'it': 'it.piccardo',
    'ja': 'ja.japanese',
    'ko': 'ko.korean',
    'ku': 'ku.asan',
    'mg': 'mg.malagasy',
    'no': 'no.berg',
    'pl': 'pl.bielawskiego',
    'pt': 'pt.elhayek',
    'ro': 'ro.grigore',
    'si': 'si.naseemismail',
    'so': 'so.abduh',
    'tg': 'tg.ayati',
    'th': 'th.thai',
    'tt': 'tt.nugman',
    'ug': 'ug.saleh',
    'uz': 'uz.sodik',
    'yo': 'yo.shaykhaburahima',
    'am': 'am.muhammedsadiqan',
    'bg': 'bg.theophanov',
    'ka': 'ka.georgian',
    'mk': 'mk.macedonianschol',
    'ps': 'ps.abdulwali',
    'ta': 'ta.tamil',
    'vi': 'vi.rwwad',
    'pa': 'pa.drmuhamadhabibb',
    'sd': 'sd.amroti',
    'kk': 'kk.khalifahaltai',
    'om': 'om.ghaliapapurapag',
    'my': 'my.ghazimohammadha',
    'ny': 'ny.alhajiyusufmuha',
    'lg': 'lg.fareeqmusa',
    'sv': 'sv.bernstrom',
    'ce': 'ce.magomedov',
  };

  static const Set<String> _rtlLanguages = {
    'ur', 'fa', 'he', 'ku', 'ps', 'ug', 'dv', 'sd', 'pa',
  };

  static bool isRtlEdition(String edition) {
    for (final entry in defaultEditions.entries) {
      if (entry.value == edition) {
        return _rtlLanguages.contains(entry.key);
      }
    }
    return false;
  }

  static String editionForLanguage(String langCode) {
    return defaultEditions[langCode] ?? defaultEdition;
  }

  static String labelForEdition(String edition) {
    for (final entry in defaultEditions.entries) {
      if (entry.value == edition) {
        return languageLabels[entry.key] ?? edition;
      }
    }
    return edition;
  }

  static String shortCodeForEdition(String edition) {
    for (final entry in defaultEditions.entries) {
      if (entry.value == edition) {
        return entry.key.toUpperCase();
      }
    }
    return edition.split('.').first.toUpperCase();
  }
}
