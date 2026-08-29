import 'locales.dart';

/// Every piece of interface text, in all four languages.
///
/// Each getter reads `_pick(arabic, pashto, persian, english)`, so a
/// translation sits beside its siblings and a missing one is impossible to
/// overlook. Counted nouns are handled per language rather than by string
/// interpolation, because Arabic agreement (singular / dual / plural /
/// accusative) has no equivalent in the other three.
class Strings {
  const Strings(this.locale);

  final AppLocale locale;

  String _pick(String ar, String ps, String fa, String en) => switch (locale) {
    AppLocale.ar => ar,
    AppLocale.ps => ps,
    AppLocale.fa => fa,
    AppLocale.en => en,
  };

  String n(int value) => locale.number(value);

  // ------------------------------------------------------------- identity
  String get appName => _pick(
    'قاموس المعاني',
    'د معناګانو قاموس',
    'فرهنگ معانی',
    'Qamus al-Maani',
  );

  String get tagline => _pick(
    'معجم عربي — عربي بين يديك، دون اتصال',
    'عربي – عربي قاموس، بې انټرنټه ستاسو په لاس کې',
    'فرهنگ عربی — عربی، بدون نیاز به اینترنت',
    'An Arabic–Arabic dictionary, offline and in your hand',
  );

  // ---------------------------------------------------------- onboarding
  String get chooseLanguage => _pick(
    'اختر لغة التطبيق',
    'د اپلیکیشن ژبه وټاکئ',
    'زبان برنامه را انتخاب کنید',
    'Choose your language',
  );

  String get chooseLanguageDetail => _pick(
    'يمكنك تغييرها لاحقًا من الإعدادات',
    'وروسته یې له تنظیماتو بدلولی شئ',
    'بعداً می‌توانید از تنظیمات تغییرش دهید',
    'You can change this later in settings',
  );

  String get continueLabel =>
      _pick('متابعة', 'دوام ورکړئ', 'ادامه', 'Continue');
  String get skip => _pick('تخطّي', 'پرېښودل', 'رد کردن', 'Skip');
  String get next => _pick('التالي', 'بل', 'بعدی', 'Next');
  String get start => _pick('لنبدأ', 'پیل وکړئ', 'شروع کنیم', 'Get started');

  String get introTitle1 => _pick(
    'ستّة معاجم في جيبك',
    'شپږ معاجم ستاسو په جیب کې',
    'شش فرهنگ در جیب شما',
    'Six lexicons in your pocket',
  );
  String get introBody1 => _pick(
    'الوسيط والرائد والغني والقاموس المحيط ومعجم اللغة المعاصرة ومعجم المرادفات والأضداد — كلّها في مكان واحد، بلا إنترنت.',
    'الوسيط، الرائد، الغني، القاموس المحيط، د معاصرې ژبې معجم او د مرادفاتو معجم — ټول په یو ځای کې، بې انټرنټه.',
    'الوسيط، الرائد، الغني، القاموس المحيط، فرهنگ زبان معاصر و فرهنگ مترادف‌ها — همه در یک جا، بدون اینترنت.',
    'Al-Wasit, Al-Ra\'id, Al-Ghani, Al-Qamus al-Muhit, the Contemporary Arabic lexicon and a thesaurus — all offline, in one place.',
  );

  String get introTitle2 => _pick(
    'ابحث كما تشاء',
    'څنګه چې غواړئ ولټوئ',
    'هرگونه که بخواهید جستجو کنید',
    'Search any way you like',
  );
  String get introBody2 => _pick(
    'ابحث بأوّل الكلمة أو بآخرها — اكتب «يب» لترى كل ما ينتهي بها — أو بالجذر، أو داخل نصّ الشروح نفسها.',
    'د کلمې له پیل یا له پای څخه ولټوئ — «يب» ولیکئ او هغه ټولې کلمې وګورئ چې پرې پای ته رسېږي — یا په جذر، یا د شرحو په متن کې.',
    'از آغاز واژه یا از پایان آن جستجو کنید — «يب» را بنویسید تا هرچه به آن ختم می‌شود ببینید — یا با ریشه، یا درون متن شرح‌ها.',
    'Search by how a word starts or how it ends — type "يب" to see everything ending in it — or by root, or inside the definitions themselves.',
  );

  String get introTitle3 => _pick(
    'كلّ كلمة تقودك إلى أختها',
    'هره کلمه تاسو خپلې خویندې ته رسوي',
    'هر واژه شما را به خواهرش می‌رساند',
    'Every word leads to its kin',
  );
  String get introBody3 => _pick(
    'تحت كل مدخل تجد مشتقّات جذره والكلمات القريبة منه، تنتقل بينها بلمسة واحدة.',
    'د هر مدخل لاندې د هغه د جذر مشتقات او نږدې کلمې دي، په یوه ټوکه ورمنځ ته لاړ شئ.',
    'زیر هر مدخل، مشتق‌های ریشه و واژه‌های نزدیک آن را می‌یابید و با یک لمس میانشان جابه‌جا می‌شوید.',
    'Under every entry sit its root\'s derivations and its nearest neighbours, one tap away.',
  );

  String get introTitle4 => _pick(
    'صنعه واحد، لكم جميعًا',
    'یو تن جوړ کړ، تاسو ټولو لپاره',
    'یکی ساخت، برای همهٔ شما',
    'Made by one, for all of you',
  );
  String get introBody4 => _pick(
    'م. الیاس عمر — مطوّر تطبيقات لأندرويد و iOS وويندوز، وأستاذ. صُنع هذا '
        'المعجم ليفتح بلا انتظار ويعمل بلا إنترنت. تجد وسائل التواصل في '
        'صفحة «عن المطوّر».',
    'م. الیاس عمر — د اندروید، iOS او وینډوز لپاره د اپلیکیشنونو ډولوپر او '
        'استاد. دا قاموس داسې جوړ شو چې بې انتظاره پرانیځي او بې انټرنټه کار '
        'وکړي. د اړیکې لارې د «پروګرامر په اړه» پاڼه کې دي.',
    'م. الیاس عمر — توسعه‌دهندهٔ برنامه برای اندروید، iOS و ویندوز، و استاد. '
        'این فرهنگ چنان ساخته شد که بی‌درنگ باز شود و بی‌اینترنت کار کند. '
        'راه‌های تماس در صفحهٔ «دربارهٔ برنامه‌نویس» است.',
    'M. Elyas Omar — an app developer for Android, iOS and Windows, and a '
        'teacher. This dictionary was made to open without waiting and work '
        'without a network. The contact details are on the "About the '
        'developer" page.',
  );

  // ----------------------------------------------------------- bottom nav
  String get navHome => _pick('الرئيسية', 'کورپاڼه', 'خانه', 'Home');
  String get navFavourites =>
      _pick('المفضّلة', 'خوښ شوي', 'برگزیده‌ها', 'Favourites');
  String get navRecent =>
      _pick('آخر ما قرأت', 'وروستي کتل شوي', 'اخیراً دیده‌شده', 'Recent');
  String get navSettings =>
      _pick('الإعدادات', 'تنظیمات', 'تنظیمات', 'Settings');

  // --------------------------------------------------------------- search
  String get searchHint => _pick(
    'ابحث عن كلمة…',
    'کلمه ولټوئ…',
    'واژه‌ای جستجو کنید…',
    'Search for a word…',
  );
  String get clear => _pick('مسح', 'پاکول', 'پاک کردن', 'Clear');

  String get modeStarts =>
      _pick('يبدأ بـ', 'پیل کیږي په', 'آغاز با', 'Starts with');
  String get modeEnds =>
      _pick('ينتهي بـ', 'پای ته رسېږي په', 'پایان با', 'Ends with');
  String get modeContains => _pick('يحتوي على', 'لري', 'شامل', 'Contains');
  String get modeExact =>
      _pick('مطابق تمامًا', 'بشپړ سم', 'دقیقاً برابر', 'Exact match');
  String get modeRoot => _pick('الجذر', 'جذر', 'ریشه', 'Root');

  String get allBooks =>
      _pick('كل المعاجم', 'ټول معاجم', 'همهٔ فرهنگ‌ها', 'All lexicons');
  String get noResults => _pick(
    'لا توجد نتائج',
    'پایله ونه موندل شوه',
    'نتیجه‌ای یافت نشد',
    'No results',
  );
  String get noResultsDetail => _pick(
    'جرّب نمط بحث آخر، أو وسّع نطاق المعاجم المحدّدة',
    'بل ډول لټون وازمویئ، یا نور معاجم فعال کړئ',
    'شیوهٔ دیگری از جستجو را بیازمایید، یا فرهنگ‌های بیشتری را فعال کنید',
    'Try another search mode, or widen the selected lexicons',
  );
  String get searchingLabel =>
      _pick('جارٍ البحث…', 'لټون روان دی…', 'در حال جستجو…', 'Searching…');

  String get browseRoots =>
      _pick('تصفّح الجذور', 'د جذرونو تصفح', 'مرور ریشه‌ها', 'Browse roots');
  String get browseRootsDetail => _pick(
    'ادخل إلى المعجم من جذوره',
    'له جذرونو څخه قاموس ته ننوځئ',
    'از ریشه‌ها وارد فرهنگ شوید',
    'Enter the lexicon through its roots',
  );

  String get deepSearch => _pick(
    'بحث في المعاني',
    'په شرحو کې لټون',
    'جستجو در معناها',
    'Search definitions',
  );
  String get deepSearchDetail => _pick(
    'فتّش داخل نصّ الشروح كلّها',
    'د ټولو شرحو په متن کې وپلټئ',
    'درون متن همهٔ شرح‌ها بگردید',
    'Look inside the full text of every definition',
  );

  String get treasures => _pick(
    'من كنوز اللغة',
    'د ژبې له خزانو',
    'از گنجینه‌های زبان',
    'Treasures of the language',
  );
  String get recentSearches => _pick(
    'آخر ما بحثت عنه',
    'وروستي لټونونه',
    'آخرین جستجوهای شما',
    'Your recent searches',
  );
  String get saved => _pick('المحفوظة', 'خوندي شوي', 'ذخیره‌شده‌ها', 'Saved');

  String get suffixTip => _pick(
    'نمط «ينتهي بـ» يجد القوافي والأوزان: اكتب «يب» لترى كل ما ينتهي بها.',
    'د «پای ته رسېږي» ډول قافیې او وزنونه مومي: «يب» ولیکئ او ټول یې وګورئ.',
    'شیوهٔ «پایان با» قافیه‌ها و وزن‌ها را می‌یابد: «يب» را بنویسید تا همه را ببینید.',
    'The "ends with" mode finds rhymes and patterns: type "يب" to see them all.',
  );

  // ---------------------------------------------------------------- books
  String get lexicons => _pick('المعاجم', 'معاجم', 'فرهنگ‌ها', 'Lexicons');
  String get lexiconsDetail => _pick(
    'يقتصر البحث على المعاجم المحدّدة فقط',
    'لټون یوازې په ټاکل شویو معاجمو کې کیږي',
    'جستجو تنها در فرهنگ‌های انتخاب‌شده انجام می‌شود',
    'Search is limited to the selected lexicons',
  );
  String get selectAll =>
      _pick('تحديد الكل', 'ټول ټاکل', 'انتخاب همه', 'Select all');
  String get thesaurus => _pick(
    'مرادفات وأضداد',
    'مترادف او متضاد',
    'مترادف و متضاد',
    'Synonyms & antonyms',
  );
  String get definitions => _pick(
    'شروح ومعانٍ',
    'شرحې او معناګانې',
    'شرح‌ها و معناها',
    'Definitions',
  );

  // ---------------------------------------------------------------- entry
  String rootOf(String root) =>
      _pick('جذر $root', '$root جذر', 'ریشهٔ $root', 'Root $root');
  String get fromRoot => _pick(
    'من نفس الجذر',
    'له همدې جذر څخه',
    'از همین ریشه',
    'From the same root',
  );

  /// Shown under a plural or conjugation whose definition lives elsewhere.
  String resolvesTo(String head) =>
      _pick('انظر $head', '$head وګورئ', 'نگاه کنید به $head', 'see $head');

  /// A lookup form can explain several headwords at once — مهاب reaches five.
  String explainsCount(int count) => _pick(
    'يشرح ${n(count)} مداخل',
    '${n(count)} سرلیکونه شرحوي',
    '${n(count)} سرمدخل را شرح می‌دهد',
    'explains ${n(count)} headwords',
  );

  String get similarWords =>
      _pick('كلمات مشابهة', 'ورته کلمې', 'واژه‌های مشابه', 'Similar words');
  String get copyEntry =>
      _pick('نسخ المدخل', 'مدخل کاپي کړئ', 'رونوشت مدخل', 'Copy entry');
  String get copied => _pick(
    'نُسخ المدخل إلى الحافظة',
    'مدخل کاپي شو',
    'مدخل رونوشت شد',
    'Entry copied to the clipboard',
  );
  String get saveWord => _pick('حفظ', 'خوندي کول', 'ذخیره', 'Save');
  String get unsaveWord => _pick(
    'إزالة من المحفوظات',
    'له خوندي شویو لرې کول',
    'حذف از ذخیره‌شده‌ها',
    'Remove from saved',
  );
  String get showAll =>
      _pick('إظهار الكل', 'ټول ښکاره کړئ', 'نمایش همه', 'Show all');
  String get notFound => _pick(
    'لم يُعثر على هذا المدخل',
    'دا مدخل ونه موندل شو',
    'این مدخل یافت نشد',
    'This entry was not found',
  );
  String get noDefinition => _pick(
    'لا يوجد شرح مسجّل',
    'شرح نه دی ثبت شوی',
    'شرحی ثبت نشده است',
    'No definition recorded',
  );

  // ---------------------------------------------------------------- roots
  String get rootsTitle => _pick('الجذور', 'جذرونه', 'ریشه‌ها', 'Roots');
  String get rootHint => _pick(
    'اكتب أوّل حروف الجذر…',
    'د جذر لومړي حروف ولیکئ…',
    'نخستین حروف ریشه را بنویسید…',
    'Type the first letters of a root…',
  );
  String get chooseRoot =>
      _pick('اختر جذرًا', 'یو جذر وټاکئ', 'ریشه‌ای برگزینید', 'Choose a root');
  String get chooseRootDetail => _pick(
    'ستظهر هنا كل الكلمات المشتقّة منه',
    'دلته به یې ټولې مشتق شوې کلمې راښکاره شي',
    'همهٔ واژه‌های مشتق از آن اینجا نمایان می‌شوند',
    'Every word derived from it will appear here',
  );
  String get noRoots => _pick(
    'لا جذور مطابقة',
    'ورته جذر نشته',
    'ریشهٔ مطابقی نیست',
    'No matching roots',
  );
  String derivativesOf(String root) => _pick(
    'مشتقّات «$root»',
    'د «$root» مشتقات',
    'مشتق‌های «$root»',
    'Derivations of "$root"',
  );

  // ---------------------------------------------------------- deep search
  String get deepSearchHint => _pick(
    'كلمة أو عبارة داخل الشروح…',
    'د شرحو دننه کلمه یا عبارت…',
    'واژه یا عبارتی درون شرح‌ها…',
    'A word or phrase inside the definitions…',
  );
  String get deepSearchEmpty => _pick(
    'ابحث داخل نصّ المعاجم',
    'د معاجمو په متن کې ولټوئ',
    'درون متن فرهنگ‌ها بگردید',
    'Search inside the lexicon text',
  );
  String get deepSearchEmptyDetail => _pick(
    'اعثر على الكلمة ولو لم تكن هي المدخل، بل ورَدت في شرحه',
    'کلمه ومومئ که څه هم مدخل نه وي، بلکې د هغه په شرح کې راغلې وي',
    'واژه را بیابید حتی اگر مدخل نباشد، بلکه در شرح آن آمده باشد',
    'Find a word even when it is not the headword, but appears in its definition',
  );
  String get deepSearchRunning => _pick(
    'جارٍ التفتيش في الشروح…',
    'په شرحو کې پلټنه روانه ده…',
    'در حال گشتن میان شرح‌ها…',
    'Searching through the definitions…',
  );
  String get deepSearchRunningDetail => _pick(
    'يُفكّ ضغط الشروح ويُفتَّش فيها مقطعًا بعد مقطع',
    'شرحې له کمپریشن څخه راوځي او بلاک په بلاک پلټل کیږي',
    'شرح‌ها از فشرده‌سازی بیرون می‌آیند و بلوک به بلوک جستجو می‌شوند',
    'Definitions are inflated and searched, block by block',
  );
  String get stop => _pick('إيقاف', 'ودرول', 'توقف', 'Stop');
  String get search => _pick('ابحث', 'ولټوئ', 'جستجو', 'Search');

  // -------------------------------------------------------------- library
  String get noFavourites => _pick(
    'لا كلمات محفوظة بعد',
    'تر اوسه کوم لغت نه دی خوندي شوی',
    'هنوز واژه‌ای ذخیره نشده',
    'No saved words yet',
  );
  String get noFavouritesDetail => _pick(
    'اضغط على أيقونة الحفظ في صفحة أي كلمة',
    'د هرې کلمې په پاڼه کې د خوندي کولو نښان کېکاږئ',
    'در صفحهٔ هر واژه، نشان ذخیره را بفشارید',
    'Tap the bookmark on any word\'s page',
  );
  String get noHistory => _pick(
    'السجلّ فارغ',
    'تاریخچه تشه ده',
    'تاریخچه خالی است',
    'Nothing here yet',
  );
  String get noHistoryDetail => _pick(
    'كل كلمة تفتحها تُسجَّل هنا',
    'هره کلمه چې پرانیځئ دلته ثبتیږي',
    'هر واژه‌ای که باز کنید اینجا ثبت می‌شود',
    'Every word you open is recorded here',
  );
  String get clearHistory => _pick(
    'مسح السجلّ',
    'تاریخچه پاکه کړئ',
    'پاک کردن تاریخچه',
    'Clear history',
  );

  // ------------------------------------------------------------- settings
  String get appearance => _pick('المظهر', 'بڼه', 'ظاهر', 'Appearance');
  String get themeLight => _pick('فاتح', 'روښانه', 'روشن', 'Light');
  String get themeSystem => _pick('تلقائي', 'اتوماتیک', 'خودکار', 'Auto');
  String get themeDark => _pick('داكن', 'تیاره', 'تاریک', 'Dark');

  String get reading => _pick('القراءة', 'لوستل', 'خواندن', 'Reading');
  String get textSize => _pick(
    'حجم نصّ الشروح',
    'د شرحو د متن اندازه',
    'اندازهٔ متن شرح‌ها',
    'Definition text size',
  );
  String get showVowels => _pick(
    'إظهار التشكيل',
    'تشکیل ښکاره کول',
    'نمایش اِعراب',
    'Show diacritics',
  );
  String get showVowelsDetail => _pick(
    'أخفِ الحركات إذا كنت تفضّل نصًّا مجرّدًا',
    'که ساده متن غواړئ، حرکتونه پټ کړئ',
    'اگر متن ساده را می‌پسندید، حرکت‌ها را پنهان کنید',
    'Hide the marks if you prefer bare text',
  );
  String get sampleVowelled => 'الْعِلْمُ نُورٌ يَهْدِي صَاحِبَهُ';
  String get sampleBare => 'العلم نور يهدي صاحبه';

  String get language => _pick('اللغة', 'ژبه', 'زبان', 'Language');
  String get languageDetail => _pick(
    'لغة واجهة التطبيق — أمّا مواد المعاجم فهي بالعربية دائمًا',
    'د اپلیکیشن د مخ ژبه — د معاجمو مواد تل په عربي دي',
    'زبان رابط برنامه — مواد فرهنگ‌ها همیشه عربی است',
    'The interface language — the lexicon content is always Arabic',
  );

  String get sources => _pick('المصادر', 'سرچینې', 'منابع', 'Sources');
  String get activeLexicons => _pick(
    'المعاجم المفعّلة',
    'فعال معاجم',
    'فرهنگ‌های فعال',
    'Active lexicons',
  );
  String get allSix => _pick(
    'جميع المعاجم الستّة',
    'ټول شپږ معاجم',
    'هر شش فرهنگ',
    'All six lexicons',
  );

  // ---------------------------------------------------------------- about
  String get about =>
      _pick('عن التطبيق', 'د اپلیکیشن په اړه', 'دربارهٔ برنامه', 'About');
  String get aboutProgram => _pick(
    'عن البرنامج',
    'د پروګرام په اړه',
    'دربارهٔ برنامه',
    'About the app',
  );
  String get aboutDeveloper => _pick(
    'عن المطوّر',
    'د پروګرامر په اړه',
    'دربارهٔ برنامه‌نویس',
    'About the developer',
  );
  String get howItWorks =>
      _pick('كيف يعمل', 'څنګه کار کوي', 'چگونه کار می‌کند', 'How it works');
  String get licenses => _pick('التراخيص', 'جوازونه', 'مجوزها', 'Licences');
  String get fontLicenses => _pick(
    'تراخيص الخطوط',
    'د خطونو جوازونه',
    'مجوزهای قلم‌ها',
    'Font licences',
  );
  String get copyDbPath => _pick(
    'نسخ مسار قاعدة البيانات',
    'د ډیټابیس مسیر کاپي کړئ',
    'رونوشت مسیر پایگاه داده',
    'Copy database path',
  );
  String get pathCopied =>
      _pick('نُسخ المسار', 'مسیر کاپي شو', 'مسیر رونوشت شد', 'Path copied');
  String get version => _pick('الإصدار', 'نسخه', 'نسخه', 'Version');

  String aboutProgramBody(String entries, String books) => _pick(
    'معجم عربي عربي يعمل دون اتصال بالإنترنت، مبنيّ على $entries مدخلًا من $books معاجم، مضغوطة كلّها في ملف واحد داخل التطبيق. لا يرسل شيئًا ولا يطلب أذونات.',
    'عربي – عربي قاموس چې بې انټرنټه کار کوي، پر $entries مدخلونو جوړ شوی چې له $books معاجمو راټول شوي او ټول په یوه فایل کې کمپرس شوي دي. هېڅ شی نه لېږي او هېڅ اجازه نه غواړي.',
    'فرهنگ عربی – عربی که بدون اینترنت کار می‌کند، بر پایهٔ $entries مدخل از $books فرهنگ، همه فشرده در یک فایل درون برنامه. چیزی نمی‌فرستد و اجازه‌ای نمی‌خواهد.',
    'An Arabic–Arabic dictionary that works with no network at all, built from $entries entries across $books lexicons, packed into a single file inside the app. It sends nothing and asks for no permissions.',
  );

  String get aboutDeveloperBody => _pick(
    'صُنع هذا التطبيق ليكون معجمًا يفتح بسرعة، ويعمل في كل مكان، ولا يحتاج إلى اتصال. الشيفرة مفتوحة، والمساهمات مرحّب بها.',
    'دا اپلیکیشن ځکه جوړ شو چې یو داسې قاموس وي چې ژر پرانیځي، هر ځای کار کوي او انټرنټ ته اړتیا نه لري. کوډ یې خلاص دی او ونډې ته هرکلی ویل کیږي.',
    'این برنامه ساخته شد تا فرهنگی باشد که زود باز شود، همه‌جا کار کند و به اینترنت نیاز نداشته باشد. کد آن باز است و مشارکت خوش‌آمد است.',
    'This app was made to be a dictionary that opens instantly, works anywhere, and needs no connection. The source is open and contributions are welcome.',
  );

  String get howItWorksBody => _pick(
    'تُخزَّن الشروح في كتل مضغوطة من ٥١٢ مدخلًا، فيكفي فكّ كتلة واحدة لعرض كلمة. ومفتاح البحث يُجرَّد من التشكيل وصور الهمزة، فتجد الكلمة كما تكتبها. أمّا البحث بآخر الكلمة فيتمّ على مفتاح معكوس، ولذلك هو سريع كالبحث بأوّلها.',
    'شرحې د ۵۱۲ مدخلونو په کمپرس شویو بلاکونو کې خوندي دي، نو د یوې کلمې لپاره یوازې یو بلاک پرانیستل کافي دي. د لټون کلید له تشکیل او د همزې له بڼو پاکیږي، نو کلمه هماغسې مومئ لکه څنګه یې چې لیکئ. د پای لټون پر معکوس کلید کیږي، نو د پیل د لټون هومره ګړندی دی.',
    'شرح‌ها در بلوک‌های فشردهٔ ۵۱۲ مدخلی نگهداری می‌شوند، پس برای یک واژه تنها یک بلوک باز می‌شود. کلید جستجو از اِعراب و شکل‌های همزه پیراسته می‌شود، پس واژه را همان‌گونه که می‌نویسید می‌یابید. جستجوی پایانی روی کلید وارونه انجام می‌شود و به همان سرعت جستجوی آغازین است.',
    'Definitions are stored in compressed blocks of 512 entries, so showing a word inflates just one block. The search key is stripped of diacritics and hamza seats, so you find a word however you type it. "Ends with" runs over a reversed key, which is why it is as fast as "starts with".',
  );

  // ------------------------------------------------------------- bootstrap
  String get preparing =>
      _pick('لحظة من فضلك', 'یوه شېبه', 'لحظه‌ای صبر کنید', 'One moment');
  String get unpacking => _pick(
    'جارٍ فكّ ضغط المعجم',
    'قاموس له کمپریشن راوځي',
    'در حال باز کردن فرهنگ',
    'Unpacking the lexicon',
  );
  String get writingDb => _pick(
    'جارٍ تجهيز قاعدة البيانات',
    'ډیټابیس چمتو کیږي',
    'در حال آماده‌سازی پایگاه داده',
    'Preparing the database',
  );
  String get indexing => _pick(
    'جارٍ بناء فهارس البحث',
    'د لټون فهرستونه جوړیږي',
    'در حال ساخت نمایه‌های جستجو',
    'Building the search indexes',
  );
  String get ready => _pick('جاهز', 'چمتو', 'آماده', 'Ready');
  String get setupFailed => _pick(
    'تعذّر تجهيز المعجم',
    'د قاموس چمتو کول ونه شول',
    'آماده‌سازی فرهنگ ناکام ماند',
    'Could not prepare the lexicon',
  );
  String get retry =>
      _pick('إعادة المحاولة', 'بیا هڅه وکړئ', 'تلاش دوباره', 'Try again');
  String get onceOnly => _pick(
    'يحدث هذا مرّة واحدة فقط',
    'دا یوازې یو ځل پېښیږي',
    'این تنها یک بار رخ می‌دهد',
    'This happens only once',
  );

  // ----------------------------------------------------------- the author
  String get developerRole => _pick(
    'مطوّر تطبيقات لأندرويد و iOS وويندوز',
    'د اندروید، iOS او وینډوز لپاره د اپلیکیشنونو ډولوپر',
    'توسعه‌دهندهٔ برنامه برای اندروید، iOS و ویندوز',
    'App developer for Android, iOS and Windows',
  );

  String get developerTeacher =>
      _pick('وأستاذ', 'او استاد', 'و استاد', 'and a teacher');

  String get developerBio => _pick(
    'إلى جانب كتابة البرامج، يُدرّس ما يعرفه. وهذا المعجم ثمرة الأمرين معًا: '
        'صُنع ليكون سريعًا في يد القارئ، وواضحًا في يد المتعلّم — يفتح بلا '
        'انتظار، ويعمل بلا إنترنت، ويشرح نفسه لمن لم يمسك هاتفًا ذكيًّا من قبل.',
    'د پروګرام له لیکلو سره سره، هغه څه چې پوهیږي نورو ته هم ورزده کوي. دا '
        'قاموس د همدې دواړو مېوه ده: داسې جوړ شوی چې د لوستونکي په لاس کې '
        'ګړندی وي او د زده‌کوونکي په لاس کې څرګند — بې انتظاره پرانیځي، بې '
        'انټرنټه کار کوي، او هغه چا ته هم ځان تشریح کوي چې تر اوسه یې سمارټ '
        'ټیلیفون نه دی نیولی.',
    'در کنار نوشتن برنامه، آنچه می‌داند آموزش می‌دهد. این فرهنگ میوهٔ همین دو '
        'است: چنان ساخته شده که در دست خواننده تند باشد و در دست آموزنده روشن '
        '— بی‌درنگ باز می‌شود، بی‌اینترنت کار می‌کند، و خود را برای کسی که تا '
        'کنون گوشی هوشمند به دست نگرفته نیز شرح می‌دهد.',
    'Alongside writing software, he teaches what he knows. This dictionary is '
        'the fruit of both: built to be quick in a reader\'s hand and clear in '
        'a learner\'s — it opens without waiting, works without a network, and '
        'explains itself to someone who has never held a smartphone before.',
  );

  String get contactTitle => _pick('للتواصل', 'اړیکه', 'تماس', 'Get in touch');
  String get contactDetail => _pick(
    'اضغط لفتح التطبيق، أو المسه مطوّلًا لنسخ العنوان',
    'د پرانیستلو لپاره کېکاږئ، د کاپي کولو لپاره یې اوږد ونیسئ',
    'برای باز کردن بفشارید، برای رونوشت نگه دارید',
    'Tap to open, press and hold to copy',
  );

  String get whatsappLabel => _pick('واتساب', 'واټساپ', 'واتساپ', 'WhatsApp');
  String get telegramLabel => _pick('تيليغرام', 'ټلګرام', 'تلگرام', 'Telegram');
  String get emailLabel =>
      _pick('البريد الإلكتروني', 'بریښنالیک', 'رایانامه', 'Email');

  String get platformsTitle =>
      _pick('يبني لـ', 'جوړوي یې لپاره', 'می‌سازد برای', 'Builds for');
  String get teachesTitle =>
      _pick('ويُدرّس', 'او ښوونه کوي', 'و می‌آموزد', 'And teaches');

  String get copyLabel => _pick('نسخ', 'کاپي', 'رونوشت', 'Copy');
  String get copiedToClipboard => _pick(
    'نُسخ إلى الحافظة',
    'کاپي شو',
    'رونوشت شد',
    'Copied to the clipboard',
  );
  String get couldNotOpen => _pick(
    'تعذّر فتح التطبيق — نُسخ العنوان بدلًا من ذلك',
    'اپلیکیشن پرانیستل ونه شو — پرځای یې پته کاپي شوه',
    'برنامه باز نشد — به‌جایش نشانی رونوشت شد',
    'Could not open the app — the address was copied instead',
  );

  // ---------------------------------------------------------------- entry
  String get copySense => _pick(
    'نسخ هذا الشرح',
    'دا شرح کاپي کړئ',
    'رونوشت این شرح',
    'Copy this definition',
  );
  String get senseCopied => _pick(
    'نُسخ الشرح مع اسم معجمه',
    'شرح د خپل معجم له نامه سره کاپي شو',
    'شرح همراه نام فرهنگش رونوشت شد',
    'Definition copied, with its lexicon',
  );

  // --------------------------------------------------------------- shell
  String get menuLabel => _pick('القائمة', 'مینو', 'فهرست', 'Menu');
  String get searchModeLabel =>
      _pick('نمط البحث', 'د لټون ډول', 'شیوهٔ جستجو', 'Search mode');

  // ---------------------------------------------------------------- guide
  String get guide => _pick(
    'دليل الاستخدام',
    'د کارونې لارښود',
    'راهنمای کاربرد',
    'How to use it',
  );
  String get guideDetail => _pick(
    'شرح كل زرّ بلغة بسيطة، مع صورته',
    'د هر تڼۍ ساده تشریح، د خپلې بڼې سره',
    'شرح هر دکمه به زبان ساده، همراه شکلش',
    'Every button explained in plain words, with its picture',
  );
  String get guideIntro => _pick(
    'لا يلزمك أن تعرف شيئًا عن الحواسيب لتستعمل هذا المعجم. '
        'في كل بابٍ هنا ترى الزرّ كما هو في التطبيق تمامًا، وتحته ما يفعله، '
        'ومثالٌ تجرّبه بنفسك.',
    'د دې قاموس کارولو لپاره پر کمپیوټر پوهېدل اړین نه دي. دلته په هر باب کې '
        'تڼۍ هماغسې ګورئ لکه په اپلیکیشن کې چې ده، لاندې یې دا چې څه کوي، '
        'او یو مثال چې پخپله یې وازمویئ.',
    'برای به‌کار بردن این فرهنگ لازم نیست چیزی از رایانه بدانید. در هر بخش '
        'اینجا دکمه را همان‌گونه که در برنامه است می‌بینید، زیر آن کاری که '
        'می‌کند، و نمونه‌ای که خودتان بیازمایید.',
    'You need to know nothing about computers to use this dictionary. In every '
        'section here you see the button exactly as it appears in the app, what '
        'it does underneath, and an example to try yourself.',
  );
  String get guideExampleLabel =>
      _pick('جرّب', 'وازمویئ یې', 'بیازمایید', 'Try it');
  String get guideOpenIt => _pick(
    'افتحه الآن',
    'اوس یې پرانیځئ',
    'همین حالا باز کنید',
    'Open it now',
  );

  String get guideChapterEntry =>
      _pick('صفحة الكلمة', 'د کلمې پاڼه', 'صفحهٔ واژه', 'A word\'s page');
  String get guideChapterOffline =>
      _pick('بلا إنترنت', 'بې انټرنټه', 'بدون اینترنت', 'With no internet');

  String get guideChapterSearch =>
      _pick('صندوق البحث', 'د لټون بکس', 'جعبهٔ جستجو', 'The search box');
  String get guideSearchBody => _pick(
    'اكتب الكلمة هنا بأصابعك، حرفًا حرفًا. ومع كل حرف تكتبه يبدأ المعجم '
        'يعرض عليك ما وجده — لا تحتاج أن تضغط شيئًا بعدها. ولا يهمّك التشكيل: '
        'اكتب «شي» تجد «شَيْء»، واكتب «ذيب» تجد «ذِئْب».',
    'کلمه دلته په ګوتو ولیکئ، حرف په حرف. له هر حرف سره قاموس هغه څه درښیي '
        'چې موندلي یې دي — وروسته څه کېکاږلو ته اړتیا نشته. تشکیل مو هم پروا '
        'نه‌کوي: «شي» ولیکئ، «شَيْء» مومئ؛ «ذيب» ولیکئ، «ذِئْب» مومئ.',
    'واژه را اینجا با انگشتان بنویسید، حرف به حرف. با هر حرف، فرهنگ آنچه یافته '
        'نشانتان می‌دهد — پس از آن نیازی به فشردن چیزی نیست. اِعراب هم مهم '
        'نیست: «شي» بنویسید، «شَيْء» می‌یابید؛ «ذيب» بنویسید، «ذِئْب».',
    'Type the word here, letter by letter. With every letter the dictionary '
        'shows you what it has found — you need press nothing afterwards. Nor do '
        'the marks matter: type "شي" and you find "شَيْء"; type "ذيب" and you '
        'find "ذِئْب".',
  );

  String get guideStartsBody => _pick(
    'هذا هو المعتاد: تكتب أوّل الكلمة، فيأتيك كل ما يبدأ به. '
        'كمن ينادي على باب الدار باسمٍ، فيخرج إليه كل من كان اسمه يبدأ بذلك.',
    'دا هماغه معمول ډول دی: د کلمې پیل لیکئ، هر څه چې پرې پیلیږي راځي. '
        'لکه څوک چې د کور په دروازه یو نوم غږ کړي، نو هر څوک چې نوم یې پرې '
        'پیلیږي راووځي.',
    'این همان شیوهٔ معمول است: آغاز واژه را می‌نویسید و هرچه با آن آغاز '
        'می‌شود می‌آید. چون کسی که بر در خانه نامی صدا کند و هر که نامش با آن '
        'آغاز شود بیرون آید.',
    'This is the ordinary way: you type the start of a word and everything '
        'beginning with it comes to you. Like calling a name at the door of a '
        'house, and out comes everyone whose name begins that way.',
  );
  String get guideStartsExample => _pick(
    'اكتب «رحم» — يأتيك رَحيم ورَحْمة ورَحِم ومَرْحَمة.',
    '«رحم» ولیکئ — رَحيم، رَحْمة، رَحِم او مَرْحَمة راځي.',
    '«رحم» بنویسید — رَحيم، رَحْمة، رَحِم و مَرْحَمة می‌آید.',
    'Type "رحم" — you get رَحيم, رَحْمة, رَحِم and مَرْحَمة.',
  );

  String get guideEndsBody => _pick(
    'هذا باب الشعراء. تكتب آخر الكلمة لا أوّلها، فيأتيك كل ما ينتهي بها — '
        'وهكذا تُجمع القوافي في لحظة، وما كان يُجمع قديمًا في دفترٍ وعمر.',
    'دا د شاعرانو دروازه ده. د کلمې پای لیکئ، نه پیل یې، نو هر څه چې پرې پای '
        'ته رسیږي راځي — قافیې په یوه شېبه راټولیږي، هغه څه چې پخوا په یوه '
        'کتابچه او یو عمر راټولېدې.',
    'این درِ شاعران است. پایان واژه را می‌نویسید نه آغازش، و هرچه به آن ختم '
        'می‌شود می‌آید — قافیه‌ها در یک لحظه گرد می‌آیند، همان که دیرزمانی در '
        'دفتری و عمری گرد می‌آمد.',
    'This is the poets\' door. You type the end of a word rather than its '
        'start, and everything ending that way arrives — rhymes gathered in a '
        'moment that once took a notebook and a lifetime.',
  );
  String get guideEndsExample => _pick(
    'اكتب «يب» — يأتيك حَبيب وطَبيب وغَريب وقَريب.',
    '«يب» ولیکئ — حَبيب، طَبيب، غَريب او قَريب راځي.',
    '«يب» بنویسید — حَبيب، طَبيب، غَريب و قَريب می‌آید.',
    'Type "يب" — you get حَبيب, طَبيب, غَريب and قَريب.',
  );

  String get guideContainsBody => _pick(
    'حين لا تذكر إلا شيئًا من وسط الكلمة. يبحث عن حروفك أينما وقعت — '
        'كمن يفتّش عن خرزةٍ في عقد، لا يدري في أوّله هي أم في آخره.',
    'کله چې یوازې د کلمې منځ درپه‌یاد وي. ستاسو حروف هر چېرې چې وي لټوي — '
        'لکه څوک چې په یوه غاړکۍ کې یوه دانه لټوي او نه پوهیږي په سر کې ده '
        'که په پای کې.',
    'آنگاه که تنها میانهٔ واژه در یادتان مانده. حروف شما را هرجا که باشد '
        'می‌جوید — چون کسی که در گردنبندی مهره‌ای می‌جوید و نمی‌داند در آغاز '
        'است یا در پایان.',
    'For when you remember only something from the middle. It looks for your '
        'letters wherever they fall — like hunting for one bead on a necklace, '
        'not knowing whether it sits at the start or the end.',
  );
  String get guideContainsExample => _pick(
    'اكتب «سلم» — يأتيك مُسْلِم وتَسْليم واسْتِسْلام.',
    '«سلم» ولیکئ — مُسْلِم، تَسْليم او اسْتِسْلام راځي.',
    '«سلم» بنویسید — مُسْلِم، تَسْليم و اسْتِسْلام می‌آید.',
    'Type "سلم" — you get مُسْلِم, تَسْليم and اسْتِسْلام.',
  );

  String get guideExactBody => _pick(
    'الكلمة نفسها لا غير. إذا كنت واثقًا ممّا تريد ولا تريد أن يزاحمها شيء، '
        'فهذا بابك.',
    'یوازې هماغه کلمه، بس. که پر خپل مطلب ډاډه یاست او نه غواړئ بل څه ورسره '
        'ګډ شي، نو دا ستاسو دروازه ده.',
    'خودِ همان واژه و بس. اگر به آنچه می‌خواهید مطمئن‌اید و نمی‌خواهید چیزی '
        'با آن بیامیزد، این درِ شماست.',
    'The word itself and nothing more. If you are sure what you want and want '
        'nothing crowding it, this is your door.',
  );
  String get guideExactExample => _pick(
    'اكتب «قلب» — يأتيك قَلْب وحده، لا انْقِلاب ولا تَقَلُّب.',
    '«قلب» ولیکئ — یوازې قَلْب راځي، نه انْقِلاب او نه تَقَلُّب.',
    '«قلب» بنویسید — تنها قَلْب می‌آید، نه انْقِلاب و نه تَقَلُّب.',
    'Type "قلب" — you get قَلْب alone, not انْقِلاب nor تَقَلُّب.',
  );

  String get guideRootBody => _pick(
    'كل كلمة عربية لها أصل من ثلاثة حروف، ومنه تتفرّع أسرة كاملة. '
        'هذا الباب يجمع لك الأسرة كلّها من أصلها الواحد.',
    'هره عربي کلمه یو درې‌حرفي اصل لري او له همدې څخه یوه بشپړه کورنۍ '
        'راټوکیږي. دا دروازه ټوله کورنۍ له یوه اصله راټولوي.',
    'هر واژهٔ عربی ریشه‌ای سه‌حرفی دارد و از آن خانواده‌ای کامل می‌روید. '
        'این در، همهٔ خانواده را از یک ریشه گرد می‌آورد.',
    'Every Arabic word has a three-letter root, and from it a whole family '
        'grows. This door gathers the family from its one origin.',
  );
  String get guideRootExample => _pick(
    'اكتب «كتب» — يأتيك كاتِب ومَكْتوب وكِتاب ومَكْتَبة ومُكاتَبة.',
    '«کتب» ولیکئ — کاتِب، مَکْتوب، کِتاب، مَکْتَبة او مُکاتَبة راځي.',
    '«کتب» بنویسید — کاتِب، مَکْتوب، کِتاب، مَکْتَبة و مُکاتَبة می‌آید.',
    'Type "كتب" — you get كاتِب, مَكْتوب, كِتاب, مَكْتَبة and مُكاتَبة.',
  );

  String get guideBooksBody => _pick(
    'هذا المعجم ستّة معاجم في واحد. بهذا الزرّ تقول له: خذني إلى معجم بعينه، '
        'أو افتح لي الستّة جميعًا. وإذا غاب عنك شرحٌ تنتظره، فانظر هنا أوّلًا — '
        'لعلّ معجمه مطفأ.',
    'دا قاموس په یوه کې شپږ معاجم دي. په دې تڼۍ ورته وایاست: یوه معین معجم '
        'ته مې بوځه، یا ټول شپږ راته خلاص کړه. که کوم شرح چې تمه یې لرئ ونه '
        'ښکاره شي، لومړی دلته وګورئ — کېدای شي معجم یې مړ وي.',
    'این فرهنگ، شش فرهنگ در یکی است. با این دکمه به او می‌گویید: مرا به '
        'فرهنگی معیّن ببر، یا هر شش را برایم بگشا. اگر شرحی که چشم‌به‌راهش '
        'بودید نیامد، نخست اینجا را ببینید — شاید فرهنگش خاموش باشد.',
    'This dictionary is six lexicons in one. With this button you tell it: '
        'take me to one particular lexicon, or open all six. And if a definition '
        'you expected is missing, look here first — its lexicon may be switched '
        'off.',
  );

  String get guideDeepBody => _pick(
    'أحيانًا تعرف المعنى ولا تذكر الكلمة. هنا لا يبحث المعجم في المداخل، '
        'بل يقرأ الشروح كلّها حرفًا حرفًا حتى يجد ما وصفته. '
        'وهو أبطأ من إخوته لأنّه يقرأ كتابًا كاملًا لأجلك — فامنحه لحظة.',
    'کله کله معنا پېژنئ خو کلمه مو نه یادیږي. دلته قاموس په مدخلونو کې نه '
        'لټوي، بلکې ټولې شرحې حرف په حرف لولي ترڅو هغه ومومي چې تاسو یې '
        'انځور کړی. له خپلو وروڼو ورو دی، ځکه ستاسو لپاره یو بشپړ کتاب لولي '
        '— نو یوه شېبه ورکړئ.',
    'گاه معنا را می‌دانید و واژه را به یاد نمی‌آورید. اینجا فرهنگ در مدخل‌ها '
        'نمی‌گردد، بلکه همهٔ شرح‌ها را حرف به حرف می‌خواند تا آنچه وصف کرده‌اید '
        'بیابد. از برادرانش کندتر است، زیرا برای شما کتابی تمام می‌خواند — '
        'پس لحظه‌ای مهلتش دهید.',
    'Sometimes you know the meaning but not the word. Here the dictionary does '
        'not search the headwords; it reads every definition letter by letter '
        'until it finds what you described. It is slower than its brothers '
        'because it reads a whole book for you — so give it a moment.',
  );
  String get guideDeepExample => _pick(
    'اكتب «الأسد» — تأتيك كل كلمة ذُكر الأسد في شرحها، ولو لم تكن هي «أسد».',
    '«الأسد» ولیکئ — هره کلمه راځي چې زمری یې په شرح کې یاد شوی، که څه هم '
        'پخپله «أسد» نه وي.',
    '«الأسد» بنویسید — هر واژه‌ای می‌آید که شیر در شرحش یاد شده، هرچند خودش '
        '«أسد» نباشد.',
    'Type "الأسد" — every word whose definition mentions the lion arrives, '
        'even when the word itself is not "أسد".',
  );

  String get guideEntryBody => _pick(
    'حين تلمس كلمة تُفتح لك صفحتها. الشروح فيها مرقّمة: ١، ٢، ٣ — '
        'فتعرف كم شرحًا لهذه الكلمة، وأين أنت منها. وفوق كل مجموعة اسمُ '
        'المعجم الذي جاءت منه، ملوّنًا بلونه.',
    'کله چې یوه کلمه ولمسئ، پاڼه یې پرانیستل کیږي. شرحې پکې شمېرل شوې دي: '
        '۱، ۲، ۳ — نو پوهیږئ چې دې کلمې څو شرحې لري او تاسو په کومې کې یاست. '
        'د هرې ډلې پر سر د هغه معجم نوم دی چې ترې راغلې، په خپل رنګ رنګ شوی.',
    'چون واژه‌ای را لمس کنید، صفحه‌اش گشوده می‌شود. شرح‌ها در آن شماره '
        'خورده‌اند: ۱، ۲، ۳ — پس می‌دانید این واژه چند شرح دارد و شما کجای '
        'آن ایستاده‌اید. بالای هر دسته، نام فرهنگی است که از آن آمده، به رنگ خود.',
    'Touch a word and its page opens. The definitions there are numbered — 1, '
        '2, 3 — so you know how many this word has and where you stand among '
        'them. Above each group sits the name of the lexicon it came from, in '
        'its own colour.',
  );

  String get guideCopyBody => _pick(
    'بجانب كل شرحٍ زرٌّ صغير للنسخ. تضغطه فيُؤخذ الشرح كلّه — نصّه والكلمة '
        'واسم معجمه — إلى الحافظة، فتلصقه في رسالة أو دفتر أو بحث. '
        'وفي أعلى الصفحة زرٌّ ينسخ المدخل بأكمله دفعةً واحدة.',
    'د هرې شرحې څنګ ته یوه کوچنۍ د کاپي تڼۍ ده. کېکاږئ یې، نو ټوله شرح — '
        'متن یې، کلمه یې او د معجم نوم یې — کاپي کیږي، بیا یې په یو پیغام، '
        'کتابچه یا څېړنه کې پیسټ کړئ. د پاڼې پر سر یوه تڼۍ ده چې ټول مدخل '
        'په یوه ځل کاپي کوي.',
    'کنار هر شرح دکمه‌ای کوچک برای رونوشت است. آن را بفشارید تا همهٔ شرح — '
        'متنش، واژه‌اش و نام فرهنگش — رونوشت شود و در پیامی، دفتری یا پژوهشی '
        'بچسبانیدش. بالای صفحه نیز دکمه‌ای است که همهٔ مدخل را یکجا رونوشت می‌کند.',
    'Beside every definition is a small copy button. Press it and the whole '
        'definition — its text, its word and its lexicon\'s name — goes to the '
        'clipboard, ready to paste into a message, a notebook or an essay. At '
        'the top of the page one button copies the entire entry at once.',
  );

  String get guideSaveBody => _pick(
    'إذا أعجبتك كلمة فاحفظها بهذا الزرّ، تجدها بعدُ في «المفضّلة» ولو بعد شهر. '
        'وهي كأنّك تطوي ركن الصفحة في كتابٍ تحبّه.',
    'که کومه کلمه درخوښه شوه، په دې تڼۍ یې خوندي کړئ؛ بیا یې په «خوښ شوي» '
        'کې مومئ، که یوه میاشت هم تېره شي. دا داسې ده لکه د خوښې کتاب د پاڼې '
        'ګوټ چې راټول کړئ.',
    'اگر واژه‌ای را پسندیدید، با این دکمه ذخیره‌اش کنید؛ سپس در «برگزیده‌ها» '
        'می‌یابیدش، حتی پس از ماهی. چنان است که گوشهٔ صفحهٔ کتابی محبوب را تا کنید.',
    'If a word pleases you, save it with this button and you will find it in '
        '"Favourites" a month later. It is like folding the corner of a page in '
        'a book you love.',
  );

  String get guideRecentBody => _pick(
    'كل كلمة تفتحها تُسجَّل هنا وحدها، دون أن تطلب. فإذا ضاعت منك كلمة '
        'قرأتها البارحة، فهي في هذا الباب تنتظرك.',
    'هره کلمه چې پرانیځئ، پخپله دلته ثبتیږي، بې له دې چې وغواړئ. که کومه '
        'کلمه چې پرون مو لوستې وه ورکه شي، په همدې دروازه کې ستاسو په تمه ده.',
    'هر واژه‌ای که باز کنید، خودبه‌خود اینجا ثبت می‌شود، بی‌آنکه بخواهید. '
        'اگر واژه‌ای که دیروز خواندید گم شد، در همین در چشم‌به‌راه شماست.',
    'Every word you open is recorded here on its own, without your asking. If '
        'a word you read yesterday has slipped away, it waits for you behind '
        'this door.',
  );

  String get guideSettingsBody => _pick(
    'هنا تُفصّل التطبيق على مقاسك: لغته، ولونه ليلًا ونهارًا، وحجم الخطّ '
        'إن ضعُف البصر، والتشكيل إن أردت النصّ مجرّدًا.',
    'دلته اپلیکیشن پر خپل اندازه جوړوئ: ژبه یې، د شپې او ورځې رنګ یې، د '
        'لیکنې کچه که سترګې کمزورې وي، او تشکیل که ساده متن غواړئ.',
    'اینجا برنامه را به اندازهٔ خود می‌دوزید: زبانش، رنگ شب و روزش، اندازهٔ '
        'خطش اگر چشم ناتوان است، و اِعراب اگر متن ساده می‌خواهید.',
    'Here you cut the app to your own measure: its language, its colour by day '
        'and night, the size of the type if the eyes are tired, and the marks if '
        'you would rather have bare text.',
  );
  String get guideLanguageBody => _pick(
    'تُترجَم كل كتابة في التطبيق إلى لغتك — عربية أو پښتو أو فارسية أو '
        'إنجليزية. أمّا شروح المعاجم فتبقى بالعربية دائمًا، لأنّها هي '
        'الكتب نفسها ولا تُترجَم.',
    'په اپلیکیشن کې هره لیکنه ستاسو ژبې ته ژباړل کیږي — عربي، پښتو، فارسي '
        'یا انګلیسي. خو د معاجمو شرحې تل په عربي پاتې کیږي، ځکه هغه پخپله '
        'کتابونه دي او نه ژباړل کیږي.',
    'هر نوشتهٔ برنامه به زبان شما برگردانده می‌شود — عربی، پشتو، فارسی یا '
        'انگلیسی. اما شرح‌های فرهنگ‌ها همیشه عربی می‌مانند، زیرا خودِ '
        'کتاب‌هایند و ترجمه نمی‌شوند.',
    'Every word of the interface is translated into your language — Arabic, '
        'Pashto, Persian or English. The lexicon definitions stay Arabic, '
        'because they are the books themselves and are not translated.',
  );
  String get guideOfflineBody => _pick(
    'المعجم كلّه في جهازك، لا في الإنترنت. يعمل في الطائرة، وفي القرية، '
        'وفي الجبل حيث لا شبكة. ولا يرسل عنك شيئًا إلى أحد.',
    'ټول قاموس ستاسو په وسیله کې دی، نه په انټرنټ کې. په الوتکه کې، په کلي '
        'کې او په غره کې کار کوي هلته چې شبکه نشته. او ستاسو په اړه هېڅ چا '
        'ته څه نه لېږي.',
    'همهٔ فرهنگ در دستگاه شماست، نه در اینترنت. در هواپیما، در روستا و در '
        'کوه که شبکه‌ای نیست کار می‌کند. و دربارهٔ شما چیزی به کسی نمی‌فرستد.',
    'The whole dictionary lives on your device, not on the internet. It works '
        'on an aeroplane, in a village, on a mountain with no signal. And it '
        'sends nothing about you to anyone.',
  );

  // -------------------------------------------------------- notifications
  String get dailyWord =>
      _pick('كلمة اليوم', 'د ورځې کلمه', 'واژهٔ روز', 'Word of the day');
  String get dailyWordDetail => _pick(
    'كلمة واحدة من المعجم، تصلك كل يوم',
    'له قاموسه یوه کلمه، هره ورځ درځي',
    'یک واژه از فرهنگ، هر روز به شما می‌رسد',
    'One word from the lexicon, delivered every day',
  );
  String get dailyWordAsk => _pick(
    'أتأذن لنا أن نوقظك بكلمة؟',
    'اجازه راکوئ چې په یوه کلمه مو راویښ کړو؟',
    'اجازه می‌دهید با واژه‌ای بیدارتان کنیم؟',
    'May we wake you with a word?',
  );
  String get dailyWordAskDetail => _pick(
    'كل صباح كلمة واحدة من المعاجم الستّة، بشرحها. لا شيء غيرها — '
        'ولا إعلان، ولا اتصال بالإنترنت.',
    'هر سهار له شپږو معاجمو یوه کلمه، له خپلې شرحې سره. بل هېڅ نه — '
        'نه اعلان، نه له انټرنټ سره اړیکه.',
    'هر بامداد یک واژه از شش فرهنگ، با شرحش. جز این هیچ — '
        'نه آگهی، نه اتصال به اینترنت.',
    'One word each morning from the six lexicons, with its meaning. Nothing '
        'else — no advertising, and no connection to the internet.',
  );
  String get allowNotifications => _pick(
    'نعم، أيقظني',
    'هو، راویښ مې کړئ',
    'بله، بیدارم کنید',
    'Yes, wake me',
  );
  String get notNow => _pick('ليس الآن', 'اوس نه', 'اکنون نه', 'Not now');
  String get notificationTime =>
      _pick('وقت الوصول', 'د رارسېدو وخت', 'زمان رسیدن', 'Delivery time');
  String get notificationsBlocked => _pick(
    'الإشعارات موقوفة من إعدادات النظام',
    'نایټوفیکشن د سیستم له تنظیماتو بند دی',
    'اعلان‌ها از تنظیمات سیستم بسته است',
    'Notifications are switched off in the system settings',
  );
  String get notificationsUnavailable => _pick(
    'لا تدعم هذه المنصّة الإشعارات',
    'دا پلیټفارم نایټوفیکشن نه مني',
    'این سکو اعلان‌ها را پشتیبانی نمی‌کند',
    'This platform does not support notifications',
  );
  String hourLabel(int hour) => _pick(
    '${n(hour)}:٠٠',
    '${n(hour)}:۰۰',
    '${n(hour)}:۰۰',
    '${hour.toString().padLeft(2, '0')}:00',
  );

  // ----------------------------------------------------------------- exit
  String get exitTitle => _pick(
    'أتغادر المعجم؟',
    'له قاموسه وځئ؟',
    'از فرهنگ بیرون می‌روید؟',
    'Leave the dictionary?',
  );
  String get exitDetail => _pick(
    'محفوظاتك وسجلّ قراءتك تبقى كما هي، والمعجم يفتح في اللحظة التي تعود فيها.',
    'ستاسو خوندي شوي او د لوستلو تاریخچه هماغسې پاتې کیږي، او قاموس هماغه '
        'شېبه پرانیځي چې بیرته راشئ.',
    'ذخیره‌ها و تاریخچهٔ خواندنتان همان‌گونه می‌ماند، و فرهنگ همان لحظه که '
        'بازگردید باز می‌شود.',
    'Your saved words and reading history stay exactly as they are, and the '
        'dictionary opens the moment you come back.',
  );
  String get exitConfirm => _pick('اخرج', 'وځه', 'بیرون', 'Leave');
  String get stay => _pick('ابقَ هنا', 'دلته پاتې شه', 'همین‌جا بمان', 'Stay');

  // --------------------------------------------------------------- policy
  String get privacy => _pick(
    'سياسة الخصوصية',
    'د محرمیت تګلاره',
    'سیاست حریم خصوصی',
    'Privacy policy',
  );
  String get privacyDetail => _pick(
    'ما الذي يعرفه هذا التطبيق عنك — ولماذا لا شيء',
    'دا اپلیکیشن ستاسو په اړه څه پوهیږي — او ولې هېڅ نه',
    'این برنامه دربارهٔ شما چه می‌داند — و چرا هیچ',
    'What this app knows about you — and why it is nothing',
  );
  String get privacyOnline => _pick(
    'افتح النسخة المنشورة',
    'خپره شوې بڼه پرانیځئ',
    'نسخهٔ منتشرشده را باز کنید',
    'Open the published copy',
  );

  String get privacyUpdated => _pick(
    'آخر تحديث',
    'وروستی تازه کول',
    'آخرین به‌روزرسانی',
    'Last updated',
  );

  String get privacyHeading1 => _pick(
    'لا نجمع شيئًا',
    'هېڅ نه راټولوو',
    'هیچ گرد نمی‌آوریم',
    'We collect nothing',
  );
  String get privacyBody1 => _pick(
    'لا يجمع هذا التطبيق أيّ بيانات شخصية، ولا يُنشئ لك حسابًا، ولا يطلب '
        'اسمًا ولا بريدًا ولا رقمًا. لا يوجد خادم يتّصل به، لأنّه لا يوجد خادم.',
    'دا اپلیکیشن هېڅ شخصي معلومات نه راټولوي، تاسو ته حساب نه جوړوي، او نه '
        'نوم غواړي، نه بریښنالیک، نه شمېره. هېڅ سرور نشته چې ورسره اړیکه ونیسي، '
        'ځکه هېڅ سرور نشته.',
    'این برنامه هیچ داده‌ای شخصی گرد نمی‌آورد، برایتان حسابی نمی‌سازد، و نه '
        'نام می‌خواهد، نه رایانامه، نه شماره. سروری نیست که به آن وصل شود، '
        'زیرا سروری وجود ندارد.',
    'This app collects no personal data, creates no account for you, and asks '
        'for no name, no email and no number. There is no server it talks to, '
        'because there is no server.',
  );
  String get privacyHeading2 => _pick(
    'ما يبقى على جهازك',
    'څه چې ستاسو په وسیله کې پاتې کیږي',
    'آنچه در دستگاه شما می‌ماند',
    'What stays on your device',
  );
  String get privacyBody2 => _pick(
    'الكلمات التي تحفظها، وسجلّ ما قرأت، ولغة الواجهة ومظهرها، ووقت كلمة '
        'اليوم — كلّها تُخزَّن في جهازك وحده، ولا تغادره أبدًا. حذف التطبيق '
        'يمحوها معه.',
    'هغه کلمې چې خوندي کوئ، د لوستلو تاریخچه، د مخ ژبه او بڼه، او د ورځې د '
        'کلمې وخت — ټول یوازې ستاسو په وسیله کې خوندي کیږي او هېڅکله ترې نه '
        'وځي. د اپلیکیشن ړنګول یې ورسره پاکوي.',
    'واژه‌هایی که ذخیره می‌کنید، تاریخچهٔ خواندن، زبان و ظاهر رابط، و زمان '
        'واژهٔ روز — همه تنها در دستگاه شما نگهداری می‌شود و هرگز از آن بیرون '
        'نمی‌رود. پاک کردن برنامه آن را نیز پاک می‌کند.',
    'The words you save, what you have read, the interface language and theme, '
        'and the time of the daily word — all of it is stored on your device '
        'alone and never leaves it. Uninstalling the app erases it with them.',
  );
  String get privacyHeading3 =>
      _pick('الأذونات', 'اجازې', 'اجازه‌ها', 'Permissions');
  String get privacyBody3 => _pick(
    'الإذن الوحيد الذي نطلبه هو إرسال الإشعارات، ولا نطلبه إلّا لكلمة اليوم، '
        'ويمكنك رفضه أو سحبه في أي وقت دون أن يفقد التطبيق شيئًا. لا نطلب '
        'الموقع، ولا الكاميرا، ولا جهات الاتصال، ولا الملفّات.',
    'یوازینۍ اجازه چې غواړو د نایټوفیکشن لېږل دي، هغه هم یوازې د ورځې د کلمې '
        'لپاره، او هر وخت یې ردولی یا بیرته اخیستلی شئ بې له دې چې اپلیکیشن څه '
        'له لاسه ورکړي. نه موقعیت غواړو، نه کامره، نه اړیکې، نه فایلونه.',
    'تنها اجازه‌ای که می‌خواهیم فرستادن اعلان است، آن هم تنها برای واژهٔ روز، '
        'و هر زمان می‌توانید ردش کنید یا پس بگیرید بی‌آنکه برنامه چیزی از دست '
        'بدهد. نه مکان می‌خواهیم، نه دوربین، نه مخاطبان، نه پرونده‌ها.',
    'The only permission we ask for is to send notifications, and only for the '
        'word of the day. You may refuse it, or withdraw it later, and the app '
        'loses nothing. We do not ask for location, camera, contacts or files.',
  );
  String get privacyHeading4 => _pick(
    'لا إنترنت ولا إعلانات',
    'نه انټرنټ، نه اعلانونه',
    'نه اینترنت، نه آگهی',
    'No internet, no advertising',
  );
  String get privacyBody4 => _pick(
    'المعجم كلّه داخل التطبيق. لا إعلانات، ولا متتبّعات، ولا تحليلات، ولا '
        'مكتبات طرف ثالث تراقبك. ولا يتّصل التطبيق بالشبكة إلّا إذا ضغطتَ '
        'بنفسك على أحد روابط التواصل في صفحة المطوّر.',
    'ټول قاموس د اپلیکیشن دننه دی. نه اعلانونه، نه څارونکي، نه تحلیلونه، او '
        'نه د دریمې خوا کتابتونونه چې تاسو وڅاري. اپلیکیشن له شبکې سره اړیکه '
        'نه نیسي مګر دا چې پخپله د پروګرامر په پاڼه کې پر یوه اړیکه کلیک وکړئ.',
    'همهٔ فرهنگ درون برنامه است. نه آگهی، نه ردیاب، نه تحلیل، و نه کتابخانه‌ای '
        'از دیگران که شما را بپاید. برنامه به شبکه وصل نمی‌شود مگر آنکه خودتان '
        'در صفحهٔ برنامه‌نویس روی پیوندی بفشارید.',
    'The whole dictionary is inside the app. No advertising, no trackers, no '
        'analytics, and no third-party libraries watching you. The app touches '
        'the network only if you yourself tap a contact link on the author\'s '
        'page.',
  );
  String get privacyHeading5 =>
      _pick('حقوق المعاجم', 'د معاجمو حقوق', 'حقوق فرهنگ‌ها', 'The lexicons');
  String get privacyBody5 => _pick(
    'نصوص المعاجم الستّة ملك لناشريها، وتُعرض هنا للاطّلاع والدراسة. أمّا '
        'برمجة التطبيق فمن صنع المطوّر المذكور في صفحة «عن المطوّر».',
    'د شپږو معاجمو متنونه د خپلو خپرندویانو ملکیت دي او دلته د لوستلو او '
        'زده‌کړې لپاره ښودل کیږي. د اپلیکیشن پروګرام‌جوړونه د هغه پروګرامر کار '
        'دی چې د «پروګرامر په اړه» پاڼه کې یاد شوی.',
    'متن‌های شش فرهنگ از آنِ ناشرانشان است و اینجا برای خواندن و آموختن نشان '
        'داده می‌شود. برنامه‌نویسی برنامه کار همان کسی است که در صفحهٔ '
        '«دربارهٔ برنامه‌نویس» آمده است.',
    'The texts of the six lexicons belong to their publishers and are shown '
        'here for reading and study. The app itself is the work of the '
        'developer named on the "About the developer" page.',
  );
  String get privacyHeading6 =>
      _pick('المطوّر', 'ډولوپر', 'برنامه‌نویس', 'The developer');
  String privacyBody6(String app, String id, String name, String mail) => _pick(
    'هذا التطبيق «$app» (معرّفه $id) من تطوير $name، وهو مطوّر مستقلّ، لا شركة '
        'ولا مؤسسة. هو المسؤول الوحيد عن التطبيق وعن هذه السياسة، ويمكن '
        'مراسلته على $mail، وسيردّ خلال ثلاثين يومًا على أيّ سؤال أو طلب.',
    'دا اپلیکیشن «$app» (پېژندګلوی یې $id) د $name له خوا جوړ شوی، چې یو '
        'خپلواک ډولوپر دی، نه کومه شرکت او نه اداره. هغه یوازینی مسؤول دی د '
        'اپلیکیشن او د دې تګلارې لپاره، او په $mail یې لیکلی شئ؛ هرې پوښتنې '
        'یا غوښتنې ته به په دېرشو ورځو کې ځواب ورکړي.',
    'این برنامه «$app» (شناسه‌اش $id) ساختهٔ $name است، برنامه‌نویسی مستقل، '
        'نه شرکتی و نه سازمانی. او تنها مسئول برنامه و این سیاست است و '
        'می‌توانید به $mail بنویسید؛ به هر پرسش یا درخواستی در سی روز پاسخ '
        'می‌دهد.',
    'This app, "$app" (identifier $id), is developed by $name, an independent '
        'developer — not a company or an organisation. He is solely '
        'responsible for the app and for this policy, and can be written to at '
        '$mail; any question or request is answered within thirty days.',
  );

  String get privacyHeading7 => _pick(
    'ما الذي يُجمَع ويُستعمَل ويُشارَك — بالتفصيل',
    'څه راټولیږي، کارول کیږي او شریکیږي — په تفصیل',
    'چه گرد می‌آید، به کار می‌رود و هم‌رسانی می‌شود — به تفصیل',
    'What is accessed, collected, used and shared — precisely',
  );
  String get privacyBody7 => _pick(
    'الوصول: لا يصل التطبيق إلى جهات الاتصال ولا الموقع ولا الكاميرا ولا '
        'الميكروفون ولا الصور ولا ملفّات الجهاز ولا معرّف الإعلانات.\n\n'
        'الجمع: لا يُجمَع أيّ بيان شخصي أو حسّاس — لا اسم، ولا بريد، ولا رقم '
        'هاتف، ولا موقع، ولا معرّف جهاز، ولا بيانات استخدام أو أعطال.\n\n'
        'الاستعمال: ما تحفظه من كلمات، وما تفتحه منها، وتفضيلاتك (اللغة '
        'والمظهر وحجم الخطّ والتشكيل ووقت كلمة اليوم) يُستعمَل لغرض واحد فقط: '
        'أن يعرض لك التطبيق ما طلبتَه. لا يُستعمَل شيء منها للإعلان أو '
        'التحليل أو التوصية.\n\n'
        'المشاركة: لا شيء يُشارَك مع أحد — لا مع المطوّر، ولا مع طرف ثالث، '
        'ولا مع أيّ خدمة. لا يبيع التطبيق بياناتك لأنّه لا يملك منها شيئًا.',
    'لاسرسی: اپلیکیشن اړیکو، موقعیت، کامرې، مایکروفون، انځورونو، د وسیلې '
        'فایلونو یا د اعلاناتو پېژندګلوی ته لاسرسی نه لري.\n\n'
        'راټولول: هېڅ شخصي یا حساس معلومات نه راټولیږي — نه نوم، نه بریښنالیک، '
        'نه د تلیفون شمېره، نه موقعیت، نه د وسیلې پېژندګلوی، نه د کارونې یا د '
        'خرابۍ معلومات.\n\n'
        'کارول: هغه کلمې چې خوندي کوئ، هغه چې پرانیځئ یې، او ستاسو غوره‌توبونه '
        '(ژبه، بڼه، د لیکنې کچه، تشکیل، او د ورځې د کلمې وخت) یوازې د یوه '
        'مقصد لپاره کارول کیږي: چې اپلیکیشن هغه څه درښکاره کړي چې غوښتي مو دي. '
        'هېڅ یو یې د اعلان، تحلیل یا وړاندیز لپاره نه کارول کیږي.\n\n'
        'شریکول: هېڅ شی له چا سره نه شریکیږي — نه له ډولوپر سره، نه له دریمې '
        'خوا سره، نه له کومې خدمت سره. اپلیکیشن ستاسو معلومات نه پلوري ځکه چې '
        'له هغو یې هېڅ نه لري.',
    'دسترسی: برنامه به مخاطبان، مکان، دوربین، میکروفون، تصاویر، پرونده‌های '
        'دستگاه یا شناسهٔ تبلیغاتی دسترسی ندارد.\n\n'
        'گردآوری: هیچ دادهٔ شخصی یا حساسی گرد نمی‌آید — نه نام، نه رایانامه، '
        'نه شمارهٔ تلفن، نه مکان، نه شناسهٔ دستگاه، نه داده‌های کاربرد یا خطا.'
        '\n\nکاربرد: واژه‌هایی که ذخیره می‌کنید، آنچه می‌گشایید، و '
        'ترجیح‌هایتان (زبان، ظاهر، اندازهٔ خط، اِعراب و زمان واژهٔ روز) تنها '
        'برای یک هدف به کار می‌رود: اینکه برنامه همان را نشانتان دهد که خواسته‌اید. '
        'هیچ‌یک برای آگهی، تحلیل یا پیشنهاد به کار نمی‌رود.\n\n'
        'هم‌رسانی: هیچ چیز با کسی هم‌رسانی نمی‌شود — نه با برنامه‌نویس، نه با '
        'دیگری، نه با هیچ سرویسی. برنامه داده‌هایتان را نمی‌فروشد، زیرا هیچ '
        'یک از آنها را ندارد.',
    'Access: the app does not access contacts, location, camera, microphone, '
        'photos, device files or the advertising identifier.\n\n'
        'Collection: no personal or sensitive data is collected — no name, no '
        'email, no phone number, no location, no device identifier, and no '
        'usage or crash data.\n\n'
        'Use: the words you save, the words you open, and your preferences '
        '(language, theme, text size, diacritics and the time of the daily '
        'word) are used for one purpose only: to show you what you asked for. '
        'None of it is used for advertising, analytics or recommendation.\n\n'
        'Sharing: nothing is shared with anyone — not with the developer, not '
        'with a third party, not with any service. The app does not sell your '
        'data because it holds none of it.',
  );

  String get privacyHeading8 => _pick(
    'كيف تُحفَظ بأمان',
    'څنګه په خوندي توګه ساتل کیږي',
    'چگونه ایمن نگهداری می‌شود',
    'How it is kept safe',
  );
  String get privacyBody8 => _pick(
    'كل ما يحفظه التطبيق يبقى داخل مساحة التخزين الخاصّة به على جهازك، وهي '
        'مساحة يعزلها النظام عن بقيّة التطبيقات: على أندرويد ضمن مجلّد '
        'التطبيق الخاصّ، وعلى iOS داخل صندوق التطبيق (sandbox)، وعلى ويندوز '
        'في مجلّد بيانات المستخدم. ولأنّ شيئًا لا يُرسَل عبر الشبكة، فلا يوجد '
        'نقلٌ يمكن اعتراضه ولا خادمٌ يمكن اختراقه. أمّا حماية الجهاز نفسه — '
        'قفل الشاشة وتشفير التخزين — فهي من عمل نظامك، ونوصي بتفعيلهما.',
    'هرڅه چې اپلیکیشن خوندي کوي ستاسو په وسیله کې د هغه په خپله ذخیره کې '
        'پاتې کیږي، هغه ځای چې سیستم یې له نورو اپلیکیشنونو جلا ساتي: پر '
        'اندروید د اپلیکیشن په ځانګړي پوښه کې، پر iOS د اپلیکیشن په sandbox '
        'کې، او پر وینډوز د کارونکي د معلوماتو په پوښه کې. او ځکه چې هېڅ شی '
        'له شبکې نه لېږل کیږي، نو نه کوم لېږد شته چې مخه یې ونیول شي او نه '
        'کوم سرور چې مات شي. د وسیلې خپل ساتنه — د پردې کولپ او د ذخیرې '
        'کوډول — ستاسو د سیستم کار دی، او سپارښتنه کوو چې فعال یې کړئ.',
    'هرآنچه برنامه ذخیره می‌کند در فضای ذخیرهٔ خودش روی دستگاه شما می‌ماند، '
        'فضایی که سیستم آن را از دیگر برنامه‌ها جدا نگاه می‌دارد: در اندروید '
        'در پوشهٔ ویژهٔ برنامه، در iOS درون sandbox برنامه، و در ویندوز در '
        'پوشهٔ دادهٔ کاربر. و چون چیزی از شبکه فرستاده نمی‌شود، نه انتقالی '
        'هست که ربوده شود و نه سروری که شکسته شود. محافظت خودِ دستگاه — قفل '
        'صفحه و رمزگذاری حافظه — کار سیستم شماست و توصیه می‌کنیم روشنش کنید.',
    'Everything the app stores stays inside its own storage area on your '
        'device — the area the operating system keeps separate from every '
        'other app: an app-private directory on Android, the app sandbox on '
        'iOS, and the user data folder on Windows. And because nothing is sent '
        'over the network, there is no transmission to intercept and no server '
        'to breach. Protecting the device itself — a screen lock and storage '
        'encryption — is your operating system\'s job, and we recommend '
        'turning both on.',
  );

  String get privacyHeading9 => _pick(
    'مدّة الحفظ والحذف',
    'د ساتلو موده او ړنګول',
    'مدت نگهداری و حذف',
    'How long it is kept, and how to delete it',
  );
  String get privacyBody9 => _pick(
    'يبقى ما حفظتَه ما دام التطبيق على جهازك — لا مدّة محدّدة، لأنّ القرار '
        'قرارك لا قرارنا. ولك أن تمحوه متى شئتَ بثلاث طرق:\n\n'
        '• سجلّ القراءة: زرّ «مسح السجلّ» في صفحة آخر ما قرأت.\n'
        '• الكلمات المحفوظة: أزل الحفظ عن أيّ كلمة من صفحتها.\n'
        '• كل شيء دفعةً واحدة: احذف التطبيق، أو امسح بيانات التطبيق من '
        'إعدادات النظام؛ يُمحى كل شيء في الحال ولا تبقى منه نسخة في أيّ مكان، '
        'لأنّه لم يغادر جهازك أصلًا.\n\n'
        'ولأنّنا لا نجمع شيئًا، فليس لدينا ما نحذفه بالنيابة عنك، ولا حاجة '
        'إلى طلب حذف.',
    'هغه څه چې خوندي مو کړي تر هغې پاتې کیږي چې اپلیکیشن ستاسو په وسیله کې '
        'وي — کومه ټاکلې موده نشته، ځکه پرېکړه ستاسو ده نه زموږ. هر وخت یې په '
        'درې لارو پاکولی شئ:\n\n'
        '• د لوستلو تاریخچه: د «تاریخچه پاکه کړئ» تڼۍ د وروستي کتل شویو په پاڼه کې.\n'
        '• خوندي شوې کلمې: د هرې کلمې له پاڼې یې خوندي کول لرې کړئ.\n'
        '• ټول په یو ځل: اپلیکیشن ړنګ کړئ، یا د سیستم له تنظیماتو د اپلیکیشن '
        'معلومات پاک کړئ؛ هرڅه سمدستي پاکیږي او هېڅ چېرې یې کاپي نه پاتې کیږي، '
        'ځکه له سره ستاسو له وسیلې نه دي وتلي.\n\n'
        'او ځکه چې هېڅ نه راټولوو، نو زموږ سره هېڅ نشته چې ستاسو په استازیتوب '
        'یې ړنګ کړو، او د ړنګولو غوښتنې ته اړتیا نشته.',
    'آنچه ذخیره کرده‌اید تا زمانی می‌ماند که برنامه روی دستگاه شماست — مدتی '
        'معیّن نیست، زیرا تصمیم از آنِ شماست نه ما. هر زمان به سه راه '
        'می‌توانید پاکش کنید:\n\n'
        '• تاریخچهٔ خواندن: دکمهٔ «پاک کردن تاریخچه» در صفحهٔ اخیراً دیده‌شده.\n'
        '• واژه‌های ذخیره‌شده: از صفحهٔ هر واژه ذخیره را بردارید.\n'
        '• همه یکجا: برنامه را پاک کنید، یا از تنظیمات سیستم دادهٔ برنامه را '
        'بزدایید؛ همه‌چیز بی‌درنگ پاک می‌شود و هیچ نسخه‌ای جایی نمی‌ماند، '
        'چون از آغاز از دستگاه شما بیرون نرفته است.\n\n'
        'و چون چیزی گرد نمی‌آوریم، چیزی نداریم که به نیابت شما حذف کنیم، و '
        'نیازی به درخواست حذف نیست.',
    'What you have saved stays for as long as the app is on your device — '
        'there is no fixed period, because the decision is yours rather than '
        'ours. You can erase it whenever you like, three ways:\n\n'
        '• Reading history: the "Clear history" button on the Recent page.\n'
        '• Saved words: unsave any word from its own page.\n'
        '• Everything at once: uninstall the app, or clear the app\'s data '
        'from your system settings. It is all erased immediately, and no copy '
        'remains anywhere, because it never left your device in the first '
        'place.\n\n'
        'And since we collect nothing, we hold nothing to delete on your '
        'behalf, and there is no deletion request to make.',
  );

  String get privacyContact => _pick(
    'لأيّ سؤال عن الخصوصية، تجد وسائل التواصل في صفحة «عن المطوّر».',
    'د محرمیت په اړه هرې پوښتنې لپاره، د اړیکې لارې د «پروګرامر په اړه» پاڼه '
        'کې دي.',
    'برای هر پرسشی دربارهٔ حریم خصوصی، راه‌های تماس در صفحهٔ «دربارهٔ '
        'برنامه‌نویس» است.',
    'For any question about privacy, the contact details are on the "About the '
        'developer" page.',
  );

  // ------------------------------------------------------- counted nouns
  String _arabicCount(int n, String one, String two, String few, String many) =>
      switch (n) {
        1 => one,
        2 => two,
        >= 3 && <= 10 => '${n2(n)} $few',
        _ => '${n2(n)} $many',
      };

  String n2(int value) => locale.number(value);

  String entries(int count) => _pick(
    _arabicCount(count, 'مدخل واحد', 'مدخلان', 'مداخل', 'مدخلًا'),
    '${n(count)} مدخلونه',
    '${n(count)} مدخل',
    count == 1 ? '1 entry' : '${n(count)} entries',
  );

  String senses(int count) => _pick(
    _arabicCount(count, 'شرح واحد', 'شرحان', 'شروح', 'شرحًا'),
    '${n(count)} شرحې',
    '${n(count)} شرح',
    count == 1 ? '1 sense' : '${n(count)} senses',
  );

  String books(int count) => _pick(
    _arabicCount(count, 'معجم واحد', 'معجمان', 'معاجم', 'معجمًا'),
    '${n(count)} معاجم',
    '${n(count)} فرهنگ',
    count == 1 ? '1 lexicon' : '${n(count)} lexicons',
  );

  String results(int count) => _pick(
    _arabicCount(count, 'نتيجة واحدة', 'نتيجتان', 'نتائج', 'نتيجةً'),
    '${n(count)} پایلې',
    '${n(count)} نتیجه',
    count == 1 ? '1 result' : '${n(count)} results',
  );

  String words(int count) => _pick(
    _arabicCount(count, 'كلمة واحدة', 'كلمتان', 'كلمات', 'كلمةً'),
    '${n(count)} کلمې',
    '${n(count)} واژه',
    count == 1 ? '1 word' : '${n(count)} words',
  );

  String get entriesLabel => _pick('مدخلًا', 'مدخلونه', 'مدخل', 'entries');
  String get rootsLabel => _pick('جذرًا', 'جذرونه', 'ریشه', 'roots');
  String get lexiconsLabel => _pick('معجمًا', 'معاجم', 'فرهنگ', 'lexicons');

  String hiddenSenses(int count) => _pick(
    '${senses(count)} مخفيّة بسبب تصفية المعاجم',
    'د معاجمو د فلټر له امله ${n(count)} شرحې پټې دي',
    'به سبب پالایش فرهنگ‌ها ${n(count)} شرح پنهان است',
    '${senses(count)} hidden by the lexicon filter',
  );

  String resultHeader(int count, String mode, String query) => _pick(
    '${entries(count)} · $mode «$query»',
    '${entries(count)} · $mode «$query»',
    '${entries(count)} · $mode «$query»',
    '${entries(count)} · $mode "$query"',
  );
}
