package com.elyas.tamarkuz.data

/**
 * Social apps blocked out of the box. Each entry lists every package the app ships
 * under (main, lite, business and popular mods), so installing any variant later
 * is caught the moment it opens.
 */
object SocialCatalog {
    val defaults: List<BlockedApp> = listOf(
        app("whatsapp", "WhatsApp", 0xFF25D366, "com.whatsapp", "com.whatsapp.w4b", "com.gbwhatsapp", "com.yowhatsapp", "com.fmwhatsapp"),
        app("facebook", "Facebook", 0xFF1877F2, "com.facebook.katana", "com.facebook.lite"),
        app("messenger", "Messenger", 0xFF0084FF, "com.facebook.orca", "com.facebook.mlite"),
        app("instagram", "Instagram", 0xFFE1306C, "com.instagram.android", "com.instagram.lite"),
        app("tiktok", "TikTok", 0xFFFE2C55, "com.zhiliaoapp.musically", "com.ss.android.ugc.trill", "com.zhiliaoapp.musically.go", "com.ss.android.ugc.aweme.lite"),
        app("youtube", "YouTube", 0xFFFF0000, "com.google.android.youtube", "app.revanced.android.youtube", "com.vanced.android.youtube"),
        app("telegram", "Telegram", 0xFF229ED9, "org.telegram.messenger", "org.telegram.messenger.web", "org.thunderdog.challegram", "org.telegram.plus", "tw.nekomimi.nekogram"),
        app("snapchat", "Snapchat", 0xFFF7C600, "com.snapchat.android"),
        app("x", "X (Twitter)", 0xFF14171A, "com.twitter.android", "com.twitter.android.lite"),
        app("threads", "Threads", 0xFF3A3A3A, "com.instagram.barcelona"),
        app("imo", "imo", 0xFF0A84FF, "com.imo.android.imoim", "com.imo.android.imoimbeta", "com.imo.android.imoimhd"),
        app("viber", "Viber", 0xFF7360F2, "com.viber.voip"),
        app("signal", "Signal", 0xFF3A76F0, "org.thoughtcrime.securesms"),
        app("botim", "Botim", 0xFF1E88E5, "im.thebot.messenger"),
        app("linkedin", "LinkedIn", 0xFF0A66C2, "com.linkedin.android", "com.linkedin.android.lite"),
        app("pinterest", "Pinterest", 0xFFE60023, "com.pinterest"),
        app("reddit", "Reddit", 0xFFFF4500, "com.reddit.frontpage"),
        app("discord", "Discord", 0xFF5865F2, "com.discord"),
        app("likee", "Likee", 0xFFFF3D6E, "video.like", "video.like.lite"),
        app("kwai", "Kwai", 0xFFFF7E00, "com.kwai.video"),
        app("bigo", "BIGO LIVE", 0xFF00B2FF, "sg.bigo.live", "sg.bigo.live.lite"),
        app("wechat", "WeChat", 0xFF07C160, "com.tencent.mm"),
    )

    private fun app(id: String, label: String, color: Long, vararg packages: String) =
        BlockedApp(id, label, packages.toList(), BlockMode.ABSOLUTE, enabled = true, color = color)
}
