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
