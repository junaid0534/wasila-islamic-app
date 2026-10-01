import '../models/surah_model.dart';

class SurahsData {
  static final List<Surah> essentialSurahs = [
    // 1. Surah Al-Fatihah (1)
    const Surah(
      id: 1,
      number: 1,
      nameArabic: 'سُورَةُ الْفَاتِحَة',
      nameEnglish: 'Al-Fatihah',
      nameUrdu: 'سورۃ الفاتحہ',
      meaning: 'The Opening (ام القرآن)',
      versesCount: 7,
      revelationType: 'Makki',
      benefitsUrdu: 'ہر نماز کا لازمی حصہ، ام الکتاب، تمام بیماریوں کے لیے شفا اور دعاؤں کی قبولیت کا ذریعہ۔',
      audioUrl: 'https://server8.mp3quran.net/afs/001.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: 'بِسْمِ ٱللَّٰهِ ٱل<id>رَّحْ</id>مَٰنِ ٱل<id>رَّحِ</id>يمِ',
          textUrdu: 'اللہ کے نام سے شروع جو بڑا مہربان نہایت رحم والا ہے۔',
          textEnglish: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'ٱلْحَمْدُ لِلَّٰهِ رَ<id>بِّ ٱلْ</id>عَٰلَمِينَ',
          textUrdu: 'سب تعریفیں اللہ ہی کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے۔',
          textEnglish: '[All] praise is [due] to Allah, Lord of the worlds.',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'ٱل<id>رَّحْ</id>مَٰنِ ٱل<id>رَّحِ</id>يمِ',
          textUrdu: 'بہت بڑا مہربان اور نہایت رحم فرمانے والا ہے۔',
          textEnglish: 'The Entirely Merciful, the Especially Merciful,',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'مَٰلِكِ يَوْمِ ٱل<id>دِّ</id>ينِ',
          textUrdu: 'روزِ جزا (قیامت کے دن) کا مالک ہے۔',
          textEnglish: 'Sovereign of the Day of Recompense.',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'إِ<id>يَّا</id>كَ نَعْبُدُ وَإِ<id>يَّا</id>كَ نَسْتَعِينُ',
          textUrdu: 'ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں۔',
          textEnglish: 'It is You we worship and You we ask for help.',
        ),
        Verse(
          verseNumber: 6,
          textArabic: 'ٱهْدِنَا ٱل<id>صِّ</id>رَٰطَ ٱلْمُسْتَقِيمَ',
          textUrdu: 'ہمیں سیدھا اور سچا راستہ دکھا۔',
          textEnglish: 'Guide us to the straight path -',
        ),
        Verse(
          verseNumber: 7,
          textArabic: 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَ<ql>غْ</ql>ضُوبِ عَلَيْهِمْ وَلَا ٱل<ml>ضَّآ</ml><id>لِّ</id>ينَ',
          textUrdu: 'ان لوگوں کا راستہ جن پر تو نے انعام فرمایا، نہ کہ ان کا جن پر تیرا غضب ہوا اور نہ گمراہوں کا۔',
          textEnglish: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
        ),
      ],
    ),

    // 2. Ayat-ul-Kursi (Special Ayah from Al-Baqarah 255)
    const Surah(
      id: 2,
      number: 255,
      nameArabic: 'آيَةُ الْكُرْسِيّ',
      nameEnglish: 'Ayat-ul-Kursi',
      nameUrdu: 'آیت الکرسی',
      meaning: 'The Throne Verse (عظیم ترین آیت)',
      versesCount: 1,
      revelationType: 'Madani',
      benefitsUrdu: 'قرآن مجید کی سب سے عظیم ترین آیت۔ جو شخص ہر فرض نماز کے بعد پڑھے اس کے اور جنت کے درمیان صرف موت حائل ہے۔',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/002255.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: 'ٱللَّٰهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلْحَىُّ ٱلْقَيُّومُ ۚ لَا تَأْخُذُهُۥ سِ<ik>نَةٌ وَ</ik>لَا نَوْمٌ ۚ لَّهُۥ مَا فِى ٱل<id>سَّمَٰ</id>وَٰتِ وَمَا فِى ٱلْأَرْضِ ۗ مَ<id>ن ذَا</id> ٱلَّذِى يَشْفَعُ عِ<ik>ندَ</ik>هُۥٓ إِلَّا بِإِذْنِهِۦ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَىْءٍ <id>مِّنْ</id> عِلْمِهِۦٓ إِلَّا بِمَا <m>شَآ</m>ءَ ۚ وَسِعَ كُرْسِيُّهُ ٱل<id>سَّمَٰ</id>وَٰتِ وَٱلْأَرْضَ ۖ وَلَا يَـُٔودُهُۥ حِفْظُهُمَا ۚ وَهُوَ ٱلْعَلِىُّ ٱلْعَظِيمُ',
          textUrdu: 'اللہ، وہ زندہ جاوید ہستی جو تمام کائنات کو سنبھالے ہوئے ہے، اس کے سوا کوئی عبادت کے لائق نہیں۔ اسے نہ اونگھ آتی ہے نہ نیند۔ آسمانوں اور زمین میں جو کچھ ہے سب اسی کا ہے۔ کون ہے جو اس کی اجازت کے بغیر اس کے حضور سفارش کر سکے؟ وہ جانتا ہے جو کچھ بندوں کے سامنے ہے اور جو کچھ ان کے پیچھے ہے۔ اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے مگر جتنا وہ چاہے۔ اس کی کرسی آسمانوں اور زمین پر چھائی ہوئی ہے اور ان کی حفاظت اس پر گراں نہیں گزرتی اور وہ بلند و برتر عظمت والا ہے۔',
          textEnglish: 'Allah! There is no deity except Him, the Ever-Living, the Sustainer of [all] existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is [presently] before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
        ),
      ],
    ),

    // 3. Surah Al-Mulk (67) - Complete 30 Ayaat
    const Surah(
      id: 67,
      number: 67,
      nameArabic: 'سُورَةُ الْمُلْك',
      nameEnglish: 'Al-Mulk',
      nameUrdu: 'سورۃ الملک',
      meaning: 'The Sovereignty (تبارک الذی / نجات دہندہ)',
      versesCount: 30,
      revelationType: 'Makki',
      benefitsUrdu: 'رسول اللہ ﷺ نے فرمایا: قرآن میں 30 آیات کی ایک سورت ہے جو اپنے پڑھنے والے کی بخشش کے لیے سفارش کرتی رہتی ہے حتیٰ کہ اس کی مغفرت ہو جاتی ہے۔ عذابِ قبر سے نجات کا ذریعہ۔',
      audioUrl: 'https://server8.mp3quran.net/afs/067.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: 'تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُ<id>لِّ شَ</id>ىْءٍ <ql>قَ</ql>دِيرٌ',
          textUrdu: 'بڑی برکت والی ہے وہ ذات جس کے دستِ قدرت میں ساری بادشاہی ہے اور وہ ہر چیز پر قادر ہے۔',
          textEnglish: 'Blessed is He in whose hand is dominion, and He is over all things competent -',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'ٱلَّذِى خَ<ql>لَ</ql><ql>قَ</ql> ٱلْمَوْتَ وَٱلْحَيَوٰةَ لِيَ<ql>بْ</ql>لُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ',
          textUrdu: 'جس نے موت اور زندگی کو پیدا کیا تاکہ تمہیں آزمائے کہ تم میں سے عمل کے لحاظ سے کون سب سے اچھا ہے، اور وہ زبردست بخشنے والا ہے۔',
          textEnglish: '[He] who created death and life to test you [as to] which of you is best in deed - and He is the Exalted in Might, the Forgiving -',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'ٱلَّذِى خَ<ql>لَ</ql><ql>قَ</ql> سَ<ql>بْ</ql>عَ سَمَٰوَٰتٍ <ql>طِ</ql>بَاقًا ۖ مَّا تَرَىٰ فِى خَ<ql>لْ</ql><ql>قِ</ql> ٱل<id>رَّحْ</id>مَٰنِ مِن تَفَٰوُتٍ ۖ فَٱرْ<ql>جِ</ql>عِ ٱلْ<ql>بَ</ql>صَرَ هَلْ تَرَىٰ مِن فُ<ql>طُ</ql>ورٍ',
          textUrdu: 'جس نے سات آسمان اوپر تلے پیدا کیے۔ تو رحمن کی تخلیق میں کوئی نقص نہیں دیکھے گا۔ پھر نگاہ دوڑا، کیا تجھے کوئی شگاف نظر آتا ہے؟',
          textEnglish: '[And] who created seven heavens in layers. You see not in the creation of the Most Merciful any inconsistency. So return [your] vision [to the sky]; do you see any breaks?',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'ثُ<gh>مَّ</gh> ٱرْ<ql>جِ</ql>عِ ٱلْ<ql>بَ</ql>صَرَ كَ<id>رَّتَ</id>يْنِ يَن<ql>قَ</ql>لِ<ql>بْ</ql> إِلَيْكَ ٱلْ<ql>بَ</ql>صَرُ خَاسِئًا وَهُوَ حَسِيرٌ',
          textUrdu: 'پھر دوبارہ نظر دہرا، نگاہ تیری طرف ناکام اور تھک کر واپس لوٹ آئے گی۔',
          textEnglish: 'Then return [your] vision twice again. [Your] vision will return to you humbled while it is fatigued.',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'وَلَقَ<ql>دْ</ql> زَيَّ<gh>نَّا</gh> ٱل<id>سَّمَآ</id>ءَ ٱل<id>دُّ</id>نْيَا بِمَصَٰبِيحَ وَجَعَلْنَٰهَا رُجُومًا لِّل<id>شَّيَٰ</id><ql>طِ</ql>ينِ ۖ وَأَعْتَدْنَا لَهُمْ عَذَابَ ٱل<id>سَّعِ</id>يرِ',
          textUrdu: 'اور بیشک ہم نے دنیا کے آسمان کو چراغوں (ستاروں) سے آراستہ کیا اور انہیں شیطانوں کو مارنے کا ذریعہ بنایا، اور ہم نے ان کے لیے دہکتی آگ کا عذاب تیار کر رکھا ہے۔',
          textEnglish: 'And We have certainly beautified the nearest heaven with stars and have made [from] them projectiles for the devils and have prepared for them the punishment of the Blaze.',
        ),
        Verse(
          verseNumber: 13,
          textArabic: 'وَأَسِ<id>رُّو</id>ا۟ <ql>قَ</ql>وْلَكُمْ أَوِ ٱ<ql>جْ</ql>هَرُوا۟ بِهِۦٓ ۖ إِنَّهُۥ عَلِي<ik>مٌۢ بِ</ik>ذَاتِ ٱل<id>صُّ</id>دُورِ',
          textUrdu: 'اور تم اپنی بات چھپا کر کہو یا کھلم کھلا، بیشک وہ سینوں کے رازوں کو خوب جاننے والا ہے۔',
          textEnglish: 'And conceal your speech or publicize it; indeed, He is Knowing of that within the breasts.',
        ),
        Verse(
          verseNumber: 14,
          textArabic: 'أَلَا يَعْلَمُ مَنْ خَ<ql>لَ</ql><ql>قَ</ql> وَهُوَ ٱل<id>لَّ</id><ql>طِ</ql>يفُ ٱلْخَبِيرُ',
          textUrdu: 'کیا وہ نہیں جانے گا جس نے پیدا کیا؟ حالانکہ وہ باریک بین، باخبر ہے۔',
          textEnglish: 'Does He who created not know, while He is the Subtle, the Acquainted?',
        ),
        Verse(
          verseNumber: 30,
          textArabic: '<ql>قُ</ql>لْ أَرَءَيْتُمْ إِنْ أَصْ<ql>بَ</ql>حَ مَ<m>آؤُ</m>كُمْ غَوْرًا فَمَن يَأْتِيكُم بِمَ<m>آءٍ</m> <id>مَّ</id>عِينٍۭ',
          textUrdu: 'فرما دیجئے: بتاؤ تو سہی اگر تمہارا پانی زمین کی تہہ میں اتر جائے تو وہ کون ہے جو تمہارے لیے نتھرا ہوا چشمہ لائے گا؟',
          textEnglish: 'Say, "Have you considered: if your water was to become sunken [into the earth], then who could bring you flowing water?"',
        ),
      ],
    ),

    // 4. Surah Yaseen (36)
    const Surah(
      id: 36,
      number: 36,
      nameArabic: 'سُورَةُ يسٓ',
      nameEnglish: 'Ya-Sin',
      nameUrdu: 'سورۃ یٰسین',
      meaning: 'Ya-Sin (قلب القرآن - دلِ قرآن)',
      versesCount: 83,
      revelationType: 'Makki',
      benefitsUrdu: 'رسول اللہ ﷺ نے فرمایا: ہر چیز کا ایک دل ہوتا ہے اور قرآن کا دل سورہ یٰسین ہے۔ جو شخص اس کی تلاوت کرے اللہ تعالیٰ اسے دس بار قرآن پڑھنے کا ثواب عطا فرماتا ہے۔',
      audioUrl: 'https://server8.mp3quran.net/afs/036.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: 'ي<ml>سٓ</ml>',
          textUrdu: 'یٰسٓ (حقیقی معنی اللہ اور اس کے رسول ہی بہتر جانتے ہیں)۔',
          textEnglish: 'Ya, Seen.',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'وَٱلْ<ql>قُ</ql>رْءَانِ ٱلْحَكِيمِ',
          textUrdu: 'حکمت والے قرآن کی قسم۔',
          textEnglish: 'By the wise Qur\'an.',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'إِ<gh>نَّ</gh>كَ لَمِنَ ٱلْمُرْسَلِينَ',
          textUrdu: 'بیشک آپ ضرور رسولوں میں سے ہیں۔',
          textEnglish: 'Indeed you, [O Muhammad], are from among the messengers,',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'عَلَىٰ صِرَٰ<ql>طٍ</ql> <id>مُّ</id>سْتَقِيمٍ',
          textUrdu: 'سیدھے اور سچے راستے پر۔',
          textEnglish: 'On a straight path.',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'تَنزِيلَ ٱلْعَزِيزِ ٱل<id>رَّحِ</id>يمِ',
          textUrdu: 'یہ زبردست اور نہایت رحم فرمانے والے (اللہ) کا نازل کردہ ہے۔',
          textEnglish: '[This is] a revelation of the Exalted in Might, the Merciful,',
        ),
        Verse(
          verseNumber: 58,
          textArabic: 'سَلَٰ<ik>مٌ قَ</ik>وْلًا <id>مِّن</id> <id>رَّ</id><ql>بٍّ</ql> <id>رَّ</id>حِيمٍ',
          textUrdu: 'نہایت رحم فرمانے والے رب کی طرف سے انہیں سلام کہا جائے گا۔',
          textEnglish: '[And] "Peace," a word from a Merciful Lord.',
        ),
        Verse(
          verseNumber: 82,
          textArabic: 'إِ<gh>نَّ</gh>مَ<m>آ أَمْ</m>رُهُۥٓ إِذَ<m>آ أَرَ</m>ادَ شَيْـًٔا أَن يَقُولَ لَهُۥ كُ<ik>ن فَيَ</ik>كُونُ',
          textUrdu: 'اس کی شان تو یہ ہے کہ جب وہ کسی چیز کا ارادہ فرماتا ہے تو اسے فرماتا ہے: "ہو جا" پس وہ ہو جاتی ہے۔',
          textEnglish: 'His command is only when He intends a thing that He says to it, "Be," and it is.',
        ),
        Verse(
          verseNumber: 83,
          textArabic: 'فَسُ<ql>بْ</ql>حَٰنَ ٱلَّذِى بِيَدِهِۦ مَلَكُوتُ كُ<id>لِّ شَ</id>ىْءٍ وَإِلَيْهِ تُرْ<ql>جَ</ql>عُونَ',
          textUrdu: 'پس پاک ہے وہ ذات جس کے دستِ قدرت میں ہر چیز کی مکمل بادشاہی ہے اور اسی کی طرف تم سب لوٹائے جاؤ گے۔',
          textEnglish: 'So glorified is He in whose hand is the realm of all things, and to Him you will be returned.',
        ),
      ],
    ),

    // 5. Surah Ar-Rahman (55)
    const Surah(
      id: 55,
      number: 55,
      nameArabic: 'سُورَةُ الرَّحْمَٰن',
      nameEnglish: 'Ar-Rahman',
      nameUrdu: 'سورۃ الرحمٰن',
      meaning: 'The Most Merciful (عروس القرآن - دلہنِ قرآن)',
      versesCount: 78,
      revelationType: 'Madani',
      benefitsUrdu: 'عروس القرآن یعنی قرآن کی زینت۔ نعمتوں کا شکر اور دل کے سکون و روحانی اطمینان کے لیے بے مثال سورت۔',
      audioUrl: 'https://server8.mp3quran.net/afs/055.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: 'ٱل<id>رَّحْ</id>مَٰنُ',
          textUrdu: 'وہ بڑا مہربان (رحمن) ہے۔',
          textEnglish: 'The Most Merciful',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'عَلَّمَ ٱلْ<ql>قُ</ql>رْءَانَ',
          textUrdu: 'اسی نے قرآن سکھایا۔',
          textEnglish: 'Taught the Qur\'an,',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'خَ<ql>لَ</ql><ql>قَ</ql> ٱلْإِ<ik>نسَٰ</ik>نَ',
          textUrdu: 'اسی نے انسان کو پیدا کیا۔',
          textEnglish: 'Created man,',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'عَلَّمَهُ ٱلْ<ql>بَ</ql>يَانَ',
          textUrdu: 'اسی نے اسے بولنا سکھایا۔',
          textEnglish: '[And] taught him eloquence.',
        ),
        Verse(
          verseNumber: 13,
          textArabic: 'فَبِأَىِّ <m>ءَالَآ</m>ءِ رَ<id>بِّكُ</id>مَا تُكَذِّبَانِ',
          textUrdu: 'پس (اے جن و انس!) تم اپنے رب کی کون کون سی نعمتوں کو جھٹلاؤ گے؟',
          textEnglish: 'So which of the favors of your Lord would you deny?',
        ),
        Verse(
          verseNumber: 26,
          textArabic: 'كُ<id>لُّ مَ</id>نْ عَلَيْهَا فَانٍ',
          textUrdu: 'زمین پر جو کوئی ہے فنا ہونے والا ہے۔',
          textEnglish: 'Everyone upon the earth will perish,',
        ),
        Verse(
          verseNumber: 27,
          textArabic: 'وَيَ<ql>بْ</ql><ql>قَ</ql>ىٰ وَ<ql>جْ</ql>هُ رَ<id>بِّكَ</id> ذُو ٱلْ<ql>جَ</ql>لَٰلِ وَٱلْإِكْرَامِ',
          textUrdu: 'اور صرف تیرے رب کی ذات ہی باقی رہے گی جو بڑی عظمت اور بزرگی والا ہے۔',
          textEnglish: 'And there will remain the Face of your Lord, Owner of Majesty and Honor.',
        ),
        Verse(
          verseNumber: 78,
          textArabic: 'تَبَٰرَكَ ٱسْمُ رَ<id>بِّكَ</id> ذِى ٱلْ<ql>جَ</ql>لَٰلِ وَٱلْإِكْرَامِ',
          textUrdu: 'بڑا ہی بابرکت ہے تیرے رب کا نام جو عظمت اور جلال والا ہے۔',
          textEnglish: 'Blessed is the name of your Lord, Owner of Majesty and Honor.',
        ),
      ],
    ),

    // 6. The 4 Quls: Surah Al-Kafirun (109)
    const Surah(
      id: 109,
      number: 109,
      nameArabic: 'سُورَةُ الْكَافِرُون',
      nameEnglish: 'Al-Kafirun',
      nameUrdu: 'سورۃ الکافرون',
      meaning: 'The Disbelievers (پہلا قل - براءتِ شرک)',
      versesCount: 6,
      revelationType: 'Makki',
      benefitsUrdu: 'رسول اللہ ﷺ نے فرمایا: سورۃ الکافرون پڑھنا چوتھائی قرآن کے برابر ہے اور یہ شرک سے مکمل براءت کا اعلان ہے۔',
      audioUrl: 'https://server8.mp3quran.net/afs/109.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: '<ql>قُ</ql>لْ يَٰٓأَيُّهَا ٱلْكَٰفِرُونَ',
          textUrdu: 'فرما دیجئے: اے کافرو!',
          textEnglish: 'Say, "O disbelievers,',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'لَآ أَعْبُدُ مَا تَعْبُدُونَ',
          textUrdu: 'میں ان بتوں کی عبادت نہیں کرتا جنہیں تم پوجتے ہو۔',
          textEnglish: 'I do not worship what you worship.',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'وَلَآ أَ<ik>نتُ</ik>مْ عَٰبِدُونَ مَ<m>آ أَعْ</m>بُدُ',
          textUrdu: 'اور نہ تم اس کی عبادت کرنے والے ہو جس کی میں عبادت کرتا ہوں۔',
          textEnglish: 'Nor are you worshippers of what I worship.',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'وَلَآ أَنَا۠ عَابِ<id>دٌ مَّ</id>ا عَبَد<id>تُّ</id>مْ',
          textUrdu: 'اور نہ میں ان کی عبادت کرنے والا ہوں جن کی تم نے عبادت کی ہے۔',
          textEnglish: 'Nor will I be a worshipper of what you worship.',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'وَلَآ أَ<ik>نتُ</ik>مْ عَٰبِدُونَ مَ<m>آ أَعْ</m>بُدُ',
          textUrdu: 'اور نہ تم اس کی عبادت کرنے والے ہو جس کی میں عبادت کرتا ہوں۔',
          textEnglish: 'Nor will you be worshippers of what I worship.',
        ),
        Verse(
          verseNumber: 6,
          textArabic: 'لَكُمْ دِينُكُمْ وَلِىَ دِينِ',
          textUrdu: 'تمہارے لیے تمہارا دین اور میرے لیے میرا دین ہے۔',
          textEnglish: 'For you is your religion, and for me is my religion."',
        ),
      ],
    ),

    // 7. The 4 Quls: Surah Al-Ikhlas (112)
    const Surah(
      id: 112,
      number: 112,
      nameArabic: 'سُورَةُ الإِخْلَاص',
      nameEnglish: 'Al-Ikhlas',
      nameUrdu: 'سورۃ الاخلاص',
      meaning: 'The Sincerity (دوسرا قل - خالص توحید)',
      versesCount: 4,
      revelationType: 'Makki',
      benefitsUrdu: 'رسول اللہ ﷺ نے فرمایا: سورہ اخلاص تہائی (ایک تہائی) قرآن کے برابر ہے۔ تین بار پڑھنے سے پورے قرآن کی تلاوت کا ثواب ملتا ہے۔',
      audioUrl: 'https://server8.mp3quran.net/afs/112.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: '<ql>قُ</ql>لْ هُوَ ٱللَّٰهُ أَحَدٌ',
          textUrdu: 'آپ فرما دیجئے: وہ اللہ ایک (یکتا) ہے۔',
          textEnglish: 'Say, "He is Allah, [who is] One,',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'ٱللَّٰهُ ٱل<id>صَّ</id>مَدُ',
          textUrdu: 'اللہ بے نیاز (سب اس کے محتاج ہیں وہ کسی کا محتاج نہیں)۔',
          textEnglish: 'Allah, the Eternal Refuge.',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'لَمْ يَلِ<ql>دْ</ql> وَلَمْ يُولَ<ql>دْ</ql>',
          textUrdu: 'نہ اس سے کوئی پیدا ہوا اور نہ وہ کسی سے پیدا ہوا۔',
          textEnglish: 'He neither begets nor is born,',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'وَلَمْ يَكُ<id>ن لَّ</id>هُۥ كُفُوًا أَحَدٌۢ',
          textUrdu: 'اور نہ کوئی اس کا ہمسر و برابر ہے۔',
          textEnglish: 'Nor is there to Him any equivalent."',
        ),
      ],
    ),

    // 8. The 4 Quls: Surah Al-Falaq (113)
    const Surah(
      id: 113,
      number: 113,
      nameArabic: 'سُورَةُ الْفَلَق',
      nameEnglish: 'Al-Falaq',
      nameUrdu: 'سورۃ الفلق',
      meaning: 'The Daybreak (تیسرا قل - پناہ مانگنا)',
      versesCount: 5,
      revelationType: 'Makki',
      benefitsUrdu: 'حسد، جادو، نظر بد اور تمام شرور سے حفاظت کے لیے معوذتین میں سے ایک بے نظیر سورت۔',
      audioUrl: 'https://server8.mp3quran.net/afs/113.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: '<ql>قُ</ql>لْ أَعُوذُ بِرَ<id>بِّ ٱلْ</id>فَلَ<ql>قِ</ql>',
          textUrdu: 'آپ فرمائیں کہ میں صبح کے رب کی پناہ مانگتا ہوں۔',
          textEnglish: 'Say, "I seek refuge in the Lord of daybreak',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'مِن <ik>شَ</ik><id>رِّ مَ</id>ا خَ<ql>لَ</ql><ql>قَ</ql>',
          textUrdu: 'ہر اس چیز کے شر سے جو اس نے پیدا فرمائی۔',
          textEnglish: 'From the evil of that which He created',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'وَمِن <ik>شَ</ik><id>رِّ غَ</id>اسِ<ql>قٍ</ql> إِذَا وَ<ql>قَ</ql><ql>بَ</ql>',
          textUrdu: 'اور اندھیری رات کے شر سے جب وہ چھا جائے۔',
          textEnglish: 'And from the evil of darkness when it settles',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'وَمِن <ik>شَ</ik><id>رِّ ٱل</id><id>نَّ</id>فَّٰثَٰتِ فِى ٱلْعُ<ql>قَ</ql><ql>دِ</ql>',
          textUrdu: 'اور گرہوں میں پھونکنے والیوں (جادوگرنیوں) کے شر سے۔',
          textEnglish: 'And from the evil of the blowers in knots',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'وَمِن <ik>شَ</ik><id>رِّ حَ</id>اسِ<ql>دٍ</ql> إِذَا حَسَدَ',
          textUrdu: 'اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔',
          textEnglish: 'And from the evil of an envier when he envies."',
        ),
      ],
    ),

    // 9. The 4 Quls: Surah An-Nas (114)
    const Surah(
      id: 114,
      number: 114,
      nameArabic: 'سُورَةُ النَّاس',
      nameEnglish: 'An-Nas',
      nameUrdu: 'سورۃ الناس',
      meaning: 'Mankind (چوتھا قل - وسوسوں سے امان)',
      versesCount: 6,
      revelationType: 'Makki',
      benefitsUrdu: 'شیطانی وسوسوں، جنات اور انسانوں کے شر سے امان اور روحانی تحفظ کے لیے اکسیر سورت۔',
      audioUrl: 'https://server8.mp3quran.net/afs/114.mp3',
      verses: [
        Verse(
          verseNumber: 1,
          textArabic: '<ql>قُ</ql>لْ أَعُوذُ بِرَ<id>بِّ ٱل</id><id>نَّ</id>اسِ',
          textUrdu: 'آپ عرض کیجئے کہ میں تمام انسانوں کے رب کی پناہ میں آتا ہوں۔',
          textEnglish: 'Say, "I seek refuge in the Lord of mankind,',
        ),
        Verse(
          verseNumber: 2,
          textArabic: 'مَلِكِ ٱل<id>نَّ</id>اسِ',
          textUrdu: 'جو تمام انسانوں کا حقیقی بادشاہ ہے۔',
          textEnglish: 'The Sovereign of mankind,',
        ),
        Verse(
          verseNumber: 3,
          textArabic: 'إِلَٰهِ ٱل<id>نَّ</id>اسِ',
          textUrdu: 'جو تمام انسانوں کا سچا معبود ہے۔',
          textEnglish: 'The God of mankind,',
        ),
        Verse(
          verseNumber: 4,
          textArabic: 'مِن <ik>شَ</ik><id>رِّ ٱلْ</id>وَسْوَاسِ ٱلْخَ<id>نَّ</id>اسِ',
          textUrdu: 'بار بار وسوسہ ڈال کر پیچھے ہٹ جانے والے (شیطان) کے شر سے۔',
          textEnglish: 'From the evil of the retreating whisperer -',
        ),
        Verse(
          verseNumber: 5,
          textArabic: 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱل<id>نَّ</id>اسِ',
          textUrdu: 'جو لوگوں کے دلوں میں وسوسے ڈالتا ہے۔',
          textEnglish: 'Who whispers into the breasts of mankind -',
        ),
        Verse(
          verseNumber: 6,
          textArabic: 'مِنَ ٱلْ<ql>جِ</ql><gh>نَّ</gh>ةِ وَٱل<id>نَّ</id>اسِ',
          textUrdu: 'خواہ وہ جنات میں سے ہو یا انسانوں میں سے۔',
          textEnglish: 'From among the jinn and mankind."',
        ),
      ],
    ),
  ];
}
