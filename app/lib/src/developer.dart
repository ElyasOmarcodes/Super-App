/// Who made this, and how to reach them.
///
/// Kept in one place so the splash screen, the drawer footer and the profile
/// page can never disagree about a phone number or a version.
class Developer {
  const Developer._();

  static const name = 'م. الیاس عمر';
  static const nameLatin = 'M. Elyas Omar';

  static const whatsappNumber = '+93766465848';
  static const telegramHandle = '@Elyas_Omar';
  static const email = 'ElyasOmar100@gmail.com';

  /// `wa.me` takes the number with no plus and no spaces.
  static Uri get whatsapp => Uri.parse(
    'https://wa.me/${whatsappNumber.replaceAll(RegExp(r'\D'), '')}',
  );

  static Uri get telegram =>
      Uri.parse('https://t.me/${telegramHandle.substring(1)}');

  static Uri get mail => Uri(scheme: 'mailto', path: email);

  /// Where the policy is published. Google Play needs a public URL, and the
  /// page inside the app links out to the very same document — the source of
  /// which is `docs/privacy-policy.html` in this repository.
  static final Uri privacyPolicy = Uri.parse(
    'https://sites.google.com/view/qamoos-arabi/privacy',
  );
}

/// The app's own version, shown on the splash screen and in the drawer.
///
/// Kept in step with `pubspec.yaml` by hand: reading it at runtime would mean
/// another plugin for a string that changes once a release.
const String kAppVersion = '1.2.0';
