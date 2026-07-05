import 'package:get/get.dart';

class LanguageController extends GetxController {
  var selectedLanguage = 'English'.obs;

  final languages = [
    'English', // en
    'Arabic', // ar
    'Urdu', // ur
    'French', // fr
    'Dutch', // nl
    'Spanish', // es
    'Swedish', // sv
    'Norwegian', // no
    'Finnish', // fi
    'Pashto', // ps
    'Indonesian', // id (previously shown as 'Bahasa')
    'Turkish', // tr
    'German', // de
    'Bengali', // bn
    'Somali', // so
  ];

  void selectLanguage(String lang) {
    selectedLanguage.value = lang;
  }
}
