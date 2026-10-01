import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/name_model.dart';

class NamesService {
  static Future<List<IslamicNameModel>> loadAllahNames() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/99_names_allah.json');
      final List<dynamic> data = json.decode(jsonString);
      if (data.isNotEmpty) {
        return data.map((e) => IslamicNameModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return defaultAllahNames;
  }

  static Future<List<IslamicNameModel>> loadProphetNames() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/99_names_prophet.json');
      final List<dynamic> data = json.decode(jsonString);
      if (data.isNotEmpty) {
        return data.map((e) => IslamicNameModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return defaultProphetNames;
  }

  static List<IslamicNameModel> get defaultAllahNames => [
    IslamicNameModel(id: 1, arabic: 'الرَّحْمَنُ', transliteration: 'Ar-Rahman', englishMeaning: 'The Most Gracious', urduMeaning: 'بہت زیادہ رحم کرنے والا', benefits: 'روزانہ 100 بار پڑھنے سے دل سے غفلت اور وسوسے دور ہوتے ہیں۔'),
    IslamicNameModel(id: 2, arabic: 'الرَّحِيمُ', transliteration: 'Ar-Raheem', englishMeaning: 'The Most Merciful', urduMeaning: 'نہایت مہربان', benefits: 'ہر نماز کے بعد 100 بار پڑھنے سے ہر آفت و بلا سے حفاظت رہتی ہے۔'),
    IslamicNameModel(id: 3, arabic: 'الْمَلِكُ', transliteration: 'Al-Malik', englishMeaning: 'The Supreme Sovereign', urduMeaning: 'حقیقی بادشاہ', benefits: 'زوال کے وقت بکثرت پڑھنے سے دل غنی ہوتا ہے۔'),
    IslamicNameModel(id: 4, arabic: 'الْقُدُّوسُ', transliteration: 'Al-Quddus', englishMeaning: 'The Most Pure', urduMeaning: 'ہر عیب سے پاک', benefits: 'روحانی و باطنی بیماریوں سے نجات کے لیے کثرت سے پڑھیں۔'),
    IslamicNameModel(id: 5, arabic: 'السَّلَامُ', transliteration: 'As-Salam', englishMeaning: 'The Source of Peace', urduMeaning: 'سلامتی دینے والا', benefits: 'مریض پر 115 بار پڑھ کر دم کرنے سے شفا ملتی ہے۔'),
    IslamicNameModel(id: 6, arabic: 'الْمُؤْمِنُ', transliteration: 'Al-Mu\'min', englishMeaning: 'The Bestower of Faith', urduMeaning: 'امن و امان دینے والا', benefits: 'خوف اور گھبراہٹ کے وقت کثرت سے پڑھنے سے امن نصیب ہوتا ہے۔'),
    IslamicNameModel(id: 7, arabic: 'الْمُهَيْمِنُ', transliteration: 'Al-Muhaymin', englishMeaning: 'The Guardian / Overseer', urduMeaning: 'نگہبان و محافظ', benefits: 'غسل کے بعد 115 بار پڑھنے سے باطنی نور نصیب ہوتا ہے۔'),
    IslamicNameModel(id: 8, arabic: 'الْعَزِيزُ', transliteration: 'Al-Aziz', englishMeaning: 'The Almighty', urduMeaning: 'سب پر غالب اور زبردست', benefits: 'فجر کے بعد 41 بار پڑھنے سے محتاجی دور اور عزت حاصل ہوتی ہے۔'),
    IslamicNameModel(id: 9, arabic: 'الْجَبَّارُ', transliteration: 'Al-Jabbar', englishMeaning: 'The Irresistible / Restorer', urduMeaning: 'زبردست اور ٹوٹے دلوں کو جوڑنے والا', benefits: 'ظلم سے بچنے کے لیے صبح و شام 226 بار پڑھیں۔'),
    IslamicNameModel(id: 10, arabic: 'الْمُتَكَبِّرُ', transliteration: 'Al-Mutakabbir', englishMeaning: 'The Supreme Majestic', urduMeaning: 'سب سے بڑی بڑائی والا', benefits: 'ہر جائز کام سے پہلے پڑھنے سے کامیابی نصیب ہوتی ہے۔'),
    IslamicNameModel(id: 11, arabic: 'الْخَالِقُ', transliteration: 'Al-Khaliq', englishMeaning: 'The Creator', urduMeaning: 'پیدا فرمانے والا', benefits: 'رات کے وقت کثرت سے پڑھنے والے کے لیے فرشتے مقرر ہوتے ہیں۔'),
    IslamicNameModel(id: 12, arabic: 'الْبَارِئُ', transliteration: 'Al-Bari\'', englishMeaning: 'The Originator', urduMeaning: 'عدم سے وجود میں لانے والا', benefits: 'مصیبتوں سے نجات کے لیے پڑھیں۔'),
    IslamicNameModel(id: 13, arabic: 'الْمُصَوِّرُ', transliteration: 'Al-Musawwir', englishMeaning: 'The Fashioner', urduMeaning: 'صورتیں بنانے والا', benefits: 'اولاد کے لیے 7 دن روزانہ 21 بار پڑھیں۔'),
    IslamicNameModel(id: 14, arabic: 'الْغَفَّارُ', transliteration: 'Al-Ghaffar', englishMeaning: 'The All-Forgiving', urduMeaning: 'بہت بخشنے والا', benefits: 'جمعہ کے بعد 100 بار پڑھنے سے مغفرت حاصل ہوتی ہے۔'),
    IslamicNameModel(id: 15, arabic: 'الْقَهَّارُ', transliteration: 'Al-Qahhar', englishMeaning: 'The Subduer', urduMeaning: 'سب کو قابو میں رکھنے والا', benefits: 'نفس کو قابو کرنے کے لیے پڑھیں۔'),
    IslamicNameModel(id: 16, arabic: 'الْوَهَّابُ', transliteration: 'Al-Wahhab', englishMeaning: 'The Giver of All Gifts', urduMeaning: 'بے غرض عطا فرمانے والا', benefits: 'سجدے میں 14 بار پڑھنے سے حاجات پوری ہوتی ہیں۔'),
    IslamicNameModel(id: 17, arabic: 'الرَّزَّاقُ', transliteration: 'Ar-Razzaq', englishMeaning: 'The Total Provider', urduMeaning: 'روزی دینے والا', benefits: 'صبح فجر سے پہلے گھر کے چاروں کونوں میں پڑھیں۔'),
    IslamicNameModel(id: 18, arabic: 'الْفَتَّاحُ', transliteration: 'Al-Fattah', englishMeaning: 'The Supreme Opener', urduMeaning: 'بند راستے کھولنے والا', benefits: 'فجر کے بعد سینے پر ہاتھ رکھ کر 71 بار پڑھیں۔'),
    IslamicNameModel(id: 19, arabic: 'الْعَلِيمُ', transliteration: 'Al-Aleem', englishMeaning: 'The All-Knowing', urduMeaning: 'سب کچھ جاننے والا', benefits: 'علم و حکمت میں اضافے کے لیے ورد کریں۔'),
    IslamicNameModel(id: 20, arabic: 'الْقَابِضُ', transliteration: 'Al-Qabid', englishMeaning: 'The Restrainer', urduMeaning: 'تنگی کرنے والا', benefits: 'خوف اور تنگی کے وقت پڑھیں۔'),
    IslamicNameModel(id: 21, arabic: 'الْبَاسِطُ', transliteration: 'Al-Basit', englishMeaning: 'The Expander', urduMeaning: 'فراخی اور کشادگی دینے والا', benefits: 'چاشت کے وقت 10 بار پڑھنے سے رزق میں برکت ہوتی ہے۔'),
    IslamicNameModel(id: 22, arabic: 'الْخَافِضُ', transliteration: 'Al-Khafid', englishMeaning: 'The Abaser', urduMeaning: 'پست کرنے والا', benefits: 'دشمن کے شر سے حفاظت کے لیے پڑھیں۔'),
    IslamicNameModel(id: 23, arabic: 'الرَّافِعُ', transliteration: 'Ar-Rafi\'', englishMeaning: 'The Exalter', urduMeaning: 'بلند کرنے والا', benefits: 'عزت اور بلندی نصیب ہوتی ہے۔'),
    IslamicNameModel(id: 24, arabic: 'الْمُعِزُّ', transliteration: 'Al-Mu\'izz', englishMeaning: 'The Bestower of Honour', urduMeaning: 'عزت بخشنے والا', benefits: 'لوگوں میں عزت اور محبت پیدا ہوتی ہے۔'),
    IslamicNameModel(id: 25, arabic: 'الْمُذِلُّ', transliteration: 'Al-Muzill', englishMeaning: 'The Dishonourer', urduMeaning: 'ذلیل و رسوا کرنے والا', benefits: 'ظالم کے شر سے پناہ کے لیے پڑھیں۔'),
    IslamicNameModel(id: 26, arabic: 'السَّمِيعُ', transliteration: 'As-Sami\'', englishMeaning: 'The All-Hearing', urduMeaning: 'سب کچھ سننے والا', benefits: 'دعاؤں کی قبولیت کے لیے 500 بار پڑھیں۔'),
    IslamicNameModel(id: 27, arabic: 'الْبَصِيرُ', transliteration: 'Al-Baseer', englishMeaning: 'The All-Seeing', urduMeaning: 'سب کچھ دیکھنے والا', benefits: 'بینائی اور بصیرت تیز ہوتی ہے۔'),
    IslamicNameModel(id: 28, arabic: 'الْحَكَمُ', transliteration: 'Al-Hakam', englishMeaning: 'The Supreme Judge', urduMeaning: 'فیصلہ فرمانے والا', benefits: 'باطن کے راز کھلتے ہیں۔'),
    IslamicNameModel(id: 29, arabic: 'الْعَدْلُ', transliteration: 'Al-Adl', englishMeaning: 'The Utterly Just', urduMeaning: 'سراپا عدل و انصاف', benefits: 'دل اطاعت گزار ہوتا ہے۔'),
    IslamicNameModel(id: 30, arabic: 'اللَّطِيفُ', transliteration: 'Al-Lateef', englishMeaning: 'The Most Subtle / Kind', urduMeaning: 'نہایت باریک بین اور مہربان', benefits: 'مشکلات میں 133 بار پڑھنے سے تنگی دور ہوتی ہے۔'),
  ];

  static List<IslamicNameModel> get defaultProphetNames => [
    IslamicNameModel(id: 1, arabic: 'مُحَمَّدٌ ﷺ', transliteration: 'Muhammad', englishMeaning: 'The Praised One', urduMeaning: 'جس کی کثرت سے تعریف کی گئی ہو'),
    IslamicNameModel(id: 2, arabic: 'أَحْمَدُ ﷺ', transliteration: 'Ahmad', englishMeaning: 'The Most Commendable', urduMeaning: 'اللہ کی سب سے زیادہ تعریف کرنے والا'),
    IslamicNameModel(id: 3, arabic: 'حَامِدٌ ﷺ', transliteration: 'Hamid', englishMeaning: 'The Praiser of Allah', urduMeaning: 'اللہ کی حمد و ثنا بیان کرنے والا'),
    IslamicNameModel(id: 4, arabic: 'مَحْمُودٌ ﷺ', transliteration: 'Mahmood', englishMeaning: 'The Praised & Esteemed', urduMeaning: 'پسندیدہ اور قابلِ تعریف'),
    IslamicNameModel(id: 5, arabic: 'قَاسِمٌ ﷺ', transliteration: 'Qasim', englishMeaning: 'The Distributor of Blessings', urduMeaning: 'اللہ کی نعمتیں تقسیم فرمانے والا'),
    IslamicNameModel(id: 6, arabic: 'عَاقِبٌ ﷺ', transliteration: 'Aqib', englishMeaning: 'The Last in Succession', urduMeaning: 'سب سے آخر میں تشریف لانے والا (خاتم النبیین)'),
    IslamicNameModel(id: 7, arabic: 'فَاتِحٌ ﷺ', transliteration: 'Fatih', englishMeaning: 'The Opener / Victor', urduMeaning: 'رحمت اور ہدایت کے دروازے کھولنے والا'),
    IslamicNameModel(id: 8, arabic: 'خَاتَمٌ ﷺ', transliteration: 'Khatam', englishMeaning: 'The Seal of the Prophets', urduMeaning: 'سلسلہ نبوت کو مکمل فرمانے والا'),
    IslamicNameModel(id: 9, arabic: 'حَاشِرٌ ﷺ', transliteration: 'Hashir', englishMeaning: 'The Gatherer', urduMeaning: 'جس کے قدموں تلے میدانِ حشر میں لوگ جمع کیے جائیں گے'),
    IslamicNameModel(id: 10, arabic: 'مَاحِي ﷺ', transliteration: 'Mahi', englishMeaning: 'The Eraser of Disbelief', urduMeaning: 'کفر و شرک کو مٹانے والا'),
    IslamicNameModel(id: 11, arabic: 'نَبِيُّ الرَّحْمَةِ ﷺ', transliteration: 'Nabiyy-ur-Rahmah', englishMeaning: 'The Prophet of Mercy', urduMeaning: 'سراپا رحمت بنا کر بھیجا گیا نبی'),
    IslamicNameModel(id: 12, arabic: 'نَبِيُّ التَّوْبَةِ ﷺ', transliteration: 'Nabiyy-ut-Tawbah', englishMeaning: 'The Prophet of Repentance', urduMeaning: 'توبہ کی راہ دکھانے والا نبی'),
    IslamicNameModel(id: 13, arabic: 'نَبِيُّ الْمَلَاحِمِ ﷺ', transliteration: 'Nabiyy-ul-Malahim', englishMeaning: 'The Prophet of Struggles', urduMeaning: 'حق کے معرکوں کے قائد'),
    IslamicNameModel(id: 14, arabic: 'طٰهٰ ﷺ', transliteration: 'Ta-Ha', englishMeaning: 'Pure & Guiding', urduMeaning: 'اے پاکیزہ و کامل رہنما'),
    IslamicNameModel(id: 15, arabic: 'يٰسٓ ﷺ', transliteration: 'Ya-Seen', englishMeaning: 'Chief of Mankind', urduMeaning: 'اے کامل انسان و سردار'),
    IslamicNameModel(id: 16, arabic: 'مُزَّمِّلٌ ﷺ', transliteration: 'Muzzammil', englishMeaning: 'The Enfolded in Cloak', urduMeaning: 'کملی میں لپٹنے والا'),
    IslamicNameModel(id: 17, arabic: 'مُدَّثِّرٌ ﷺ', transliteration: 'Muddaththir', englishMeaning: 'The Cloaked One', urduMeaning: 'چادر اوڑھنے والا'),
    IslamicNameModel(id: 18, arabic: 'نَذِيرٌ ﷺ', transliteration: 'Nadheer', englishMeaning: 'The Warner', urduMeaning: 'عذابِ الٰہی سے ڈرانے والا'),
    IslamicNameModel(id: 19, arabic: 'بَشِيرٌ ﷺ', transliteration: 'Basheer', englishMeaning: 'The Bringer of Glad Tidings', urduMeaning: 'جنت کی خوشخبری دینے والا'),
    IslamicNameModel(id: 20, arabic: 'سِرَاجٌ مُنِيرٌ ﷺ', transliteration: 'Sirajum-Muneer', englishMeaning: 'The Illuminating Lamp', urduMeaning: 'روشن چراغ جو تاریکیاں مٹا دے'),
    IslamicNameModel(id: 21, arabic: 'صَادِقٌ ﷺ', transliteration: 'Sadiq', englishMeaning: 'The Truthful', urduMeaning: 'ہمیشہ سچ بولنے والا'),
    IslamicNameModel(id: 22, arabic: 'أَمِينٌ ﷺ', transliteration: 'Ameen', englishMeaning: 'The Trustworthy', urduMeaning: 'امانت دار اور بااعتماد'),
    IslamicNameModel(id: 23, arabic: 'رَءُوفٌ ﷺ', transliteration: 'Ra\'oof', englishMeaning: 'The Compassionate', urduMeaning: 'امت پر انتہائی شفقت فرمانے والا'),
    IslamicNameModel(id: 24, arabic: 'رَحِيمٌ ﷺ', transliteration: 'Raheem', englishMeaning: 'The Merciful', urduMeaning: 'مومنین پر بے پایاں رحم فرمانے والا'),
    IslamicNameModel(id: 25, arabic: 'مُصْطَفَىٰ ﷺ', transliteration: 'Mustafa', englishMeaning: 'The Preferred & Pure', urduMeaning: 'تمام کائنات میں سب سے چنیدہ ذات'),
  ];
}
