// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsPlayback => 'Wiedergabe';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsNetwork => 'Netzwerk';

  @override
  String get settingsAutoPlay => 'Automatisch abspielen';

  @override
  String get settingsAutoPlayDesc => 'Nächstes Video automatisch abspielen';

  @override
  String get settingsHwDecode => 'Hardware-Dekodierung';

  @override
  String get settingsHwDecodeDesc => 'GPU zur Videodekodierung verwenden';

  @override
  String get settingsDefaultVolume => 'Standardlautstärke';

  @override
  String get settingsDefaultVolumeDesc => 'Lautstärke beim Start';

  @override
  String get settingsDynamicColor => 'Dynamische Farbe';

  @override
  String get settingsDynamicColorDesc => 'Hintergrundbild-Farbe als Thema';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'System';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutTitle => 'Über Syncro';

  @override
  String get settingsAboutDesc => 'Version und Open-Source-Link';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsAboutOpenSource => 'Open Source';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsAutoDiscover => 'Räume automatisch finden';

  @override
  String get settingsAutoDiscoverDesc => 'Verfügbare Räume im LAN suchen';

  @override
  String get navRoom => 'Räume';

  @override
  String get navProfile => 'Profil';

  @override
  String get playerStyle => 'Stil';

  @override
  String get chatRoom => 'Chat';

  @override
  String get roomCreated => 'Raum erstellt. Warten auf Teilnehmer...';

  @override
  String playlistUpdated(int count) {
    return 'Wiedergabeliste aktualisiert ($count Videos)';
  }

  @override
  String get chatHint => 'Nachricht eingeben...';

  @override
  String get homeCreateRoom => 'Raum erstellen';

  @override
  String get homeJoinRoom => 'Raum beitreten';

  @override
  String get homeRoomCode => 'Raumcode';

  @override
  String get homeRoomCodeHint => 'Code eingeben';

  @override
  String get homeNickname => 'Spitzname';

  @override
  String get homeNicknameHint => 'Spitznamen eingeben';

  @override
  String get homeSelectVideo => 'Video auswählen';

  @override
  String get homeNoVideo => 'Kein Video';

  @override
  String get homeStart => 'Starten';

  @override
  String get homeCancel => 'Abbrechen';

  @override
  String get homeConfirm => 'Bestätigen';

  @override
  String get playerPlay => 'Abspielen';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerSubtitle => 'Untertitel';

  @override
  String get playerAudioTrack => 'Audiospur';

  @override
  String get playerNoSubtitle => 'Kein Untertitel';

  @override
  String get playerExternalSubtitle => 'Externer Untertitel';

  @override
  String get playerDanmaku => 'Kommentare';

  @override
  String get playerDanmakuHint => 'Kommentar senden...';

  @override
  String get playerDanmakuSend => 'Senden';

  @override
  String get playlistTitle => 'Wiedergabeliste';

  @override
  String get playlistAdd => 'Video hinzufügen';

  @override
  String get playlistClear => 'Liste leeren';

  @override
  String get playlistClearConfirm =>
      'Alle Videos löschen? Nicht rückgängig zu machen.';

  @override
  String get playlistEmpty => 'Liste ist leer';

  @override
  String roomMemberCount(int count) {
    return '$count online';
  }

  @override
  String get roomHost => 'Gastgeber';

  @override
  String get roomMember => 'Mitglied';

  @override
  String get roomLeave => 'Raum verlassen';

  @override
  String get roomLeaveConfirm => 'Möchten Sie wirklich verlassen?';

  @override
  String get roomDisbandConfirm =>
      'Sie sind der Gastgeber. Verlassen löst den Raum auf. Fortfahren?';

  @override
  String get errorNetworkFailed => 'Netzwerkfehler';

  @override
  String get errorFileNotFound => 'Datei nicht gefunden';

  @override
  String get errorSubtitleExtractFailed =>
      'Untertitel-Extraktion fehlgeschlagen';

  @override
  String get errorRoomNotFound => 'Raum nicht gefunden';

  @override
  String get errorNicknameEmpty => 'Spitzname darf nicht leer sein';

  @override
  String get successJoinRoom => 'Erfolgreich beigetreten';

  @override
  String get successSubtitleLoaded => 'Untertitel geladen';

  @override
  String get loadingHostVideo => 'Lade geteiltes Video des Hosts...';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get volume => 'Lautstärke';

  @override
  String get sendDanmaku => 'Kommentar senden...';

  @override
  String get hideChat => 'Chat ausblenden';

  @override
  String get showChat => 'Chat anzeigen';

  @override
  String get openVideo => 'Video öffnen';

  @override
  String get fullscreen => 'Vollbild';

  @override
  String get playbackError => 'Wiedergabefehler';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get selectOtherVideo => 'Anderes Video auswählen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get noVideo => 'Kein Video';

  @override
  String get tapFolderIconSelectVideo =>
      'Tippen Sie auf das Ordnersymbol oben, um Videodateien auszuwählen';

  @override
  String get selectVideo => 'Video auswählen';

  @override
  String get createPlaylistFailed =>
      'Erstellung der Wiedergabeliste fehlgeschlagen';

  @override
  String get addVideoFailed => 'Hinzufügen des Videos fehlgeschlagen';

  @override
  String get selectVideoFailed => 'Auswählen des Videos fehlgeschlagen';

  @override
  String get shareRoomIp => 'Raum-IP teilen';

  @override
  String get dissolveRoom => 'Raum auflösen';

  @override
  String get leaveRoom => 'Raum verlassen';

  @override
  String get shareRoom => 'Raum teilen';

  @override
  String get otherUsersCanJoinRoom =>
      'Andere Benutzer können den Raum mit folgenden Informationen beitreten:';

  @override
  String get close => 'Schließen';

  @override
  String get exitRoom => 'Raum verlassen';

  @override
  String get confirmExitCurrentRoom =>
      'Möchten Sie den aktuellen Raum wirklich verlassen?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get exit => 'Verlassen';

  @override
  String get confirmLeaveCurrentRoom =>
      'Möchten Sie den aktuellen Raum wirklich verlassen?';

  @override
  String get leave => 'Verlassen';

  @override
  String get endRoom => 'Raum beenden';

  @override
  String get confirmEndRoom => 'Möchten Sie den Raum wirklich beenden?';

  @override
  String get roomHasOtherUsersDisconnect => 'Es gibt';

  @override
  String get users => 'andere Benutzer im Raum, die getrennt werden.';

  @override
  String get cannotOpenLink => 'Link kann nicht geöffnet werden';

  @override
  String get openLinkFailed => 'Öffnen des Links fehlgeschlagen';

  @override
  String get currentLatestVersion => 'Sie verwenden die neueste Version';

  @override
  String get appDescription =>
      'Syncro ist eine plattformübergreifende Video-Sync-Playback-App, die multiuser-Online-synchronisierte Video-Wiedergabe unterstützt. Egal wie weit Sie und Ihre Freunde voneinander entfernt sind, können Sie gemeinsam eine synchronisierte Wiedergabeerfahrung genießen.';

  @override
  String get checkUpdate => 'Auf Updates prüfen';

  @override
  String get checkForNewVersion => 'Prüfen, ob eine neue Version verfügbar ist';

  @override
  String get githubOpenSourceUrl => 'GitHub Open-Source-URL';

  @override
  String get openSourceLicenseStatement => 'Open-Source-Lizenz-Erklärung';

  @override
  String get viewUsedOpenSourceLibraries =>
      'Verwendete Open-Source-Bibliotheken anzeigen';

  @override
  String get playerNotInitialized => 'Player nicht initialisiert';

  @override
  String get noAvailableAudioTracks => 'Keine verfügbaren Audiospuren';

  @override
  String get audioTrack => 'Audiospur';

  @override
  String get embeddedSubtitles => 'Integrierte Untertitel';

  @override
  String get restoreSubtitle => 'Untertitel wiederherstellen';

  @override
  String get disableSubtitle => 'Untertitel deaktivieren';

  @override
  String get noEmbeddedSubtitles => 'Keine integrierten Untertitel';

  @override
  String get externalSubtitlesHostOnly => 'Externer Untertitel (nur Host)';

  @override
  String get loadExternalSubtitle => 'Externen Untertitel laden';

  @override
  String get externalSubtitleSyncedToAllMembers =>
      'Externer Untertitel auf alle Mitglieder synchronisiert';

  @override
  String get subtitle => 'Untertitel';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String get showBackground => 'Hintergrund anzeigen';

  @override
  String get opacity => 'Deckkraft';

  @override
  String get restoreDefault => 'Standard zurücksetzen';

  @override
  String get fontColor => 'Schriftfarbe';

  @override
  String get previewEffect => 'Vorschau-Effekt';

  @override
  String get subtitlePreviewEffect => 'Untertitel-Vorschau-Effekt';

  @override
  String get videoList => 'Videoliste';

  @override
  String get loaded => 'Geladen';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      'Alle Raummitglieder laden diesen Untertitel automatisch';

  @override
  String get canSelectSrtOrAssSubtitleFiles =>
      'Sie können .srt- oder .ass-Untertiteldateien auswählen';

  @override
  String get hostHasNotLoadedExternalSubtitles =>
      'Host hat keinen externen Untertitel geladen';

  @override
  String get clearSubtitle => 'Untertitel löschen';

  @override
  String get addSubtitle => 'Untertitel hinzufügen';

  @override
  String get clearPlaylist => 'Wiedergabeliste leeren';

  @override
  String get confirmClearAllVideos =>
      'Möchten Sie wirklich alle Videos löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get clear => 'Löschen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get clearList => 'Liste leeren';

  @override
  String get playlist => 'Wiedergabeliste';

  @override
  String get addVideo => 'Video hinzufügen';

  @override
  String get externalSubtitles => 'Externe Untertitel';

  @override
  String get style => 'Stil';

  @override
  String get scanningLan => '正在扫描局域网...';

  @override
  String get noRoomsFound => '未发现房间';

  @override
  String get profileTitle => '我的';

  @override
  String get profileEditNickname => '编辑昵称';

  @override
  String get profileChangeAvatar => '点击头像更换';

  @override
  String get profileWatchTime => '观看时长';

  @override
  String get profileWatchTimeUnit => '分钟';

  @override
  String get profileJoinCount => '加入房间';

  @override
  String get profileWatchCount => '观看视频';

  @override
  String get profileWatchUnit => '个';

  @override
  String get profileRecentActivity => '最近活动';

  @override
  String get profileClearActivity => '清除';

  @override
  String profileCreatedRoom(String name) {
    return '创建了房间 \"$name\"';
  }

  @override
  String profileJoinedRoom(String name) {
    return '加入了房间 \"$name\"';
  }

  @override
  String get aboutAppName => '应用名称';

  @override
  String get aboutPackageName => '包名';

  @override
  String get aboutVersionNumber => '版本号';

  @override
  String get aboutBuildNumber => '构建号';

  @override
  String get aboutCopyright => '© 2024 Syncro Team';

  @override
  String get aboutMadeWith => 'Made with ❤️ using Flutter';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String memberJoined(String name) {
    return '$name 加入了房间';
  }

  @override
  String memberLeft(String name) {
    return '$name 离开了房间';
  }

  @override
  String get scanningStopped => '扫描已停止';

  @override
  String get roomsFound => '发现的房间';

  @override
  String get scanError => '扫描出错';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get joinRoom => '加入房间';

  @override
  String get createRoomTitle => '创建房间';

  @override
  String get roomNameHint => '房间名称';

  @override
  String get roomNamePlaceholder => '输入房间名称';

  @override
  String get portNumber => '端口号';

  @override
  String get portNumberPlaceholder => '默认 37670';

  @override
  String get selectVideoFiles => '选择视频文件';

  @override
  String selectedVideosCount(int count) {
    return '已选择 $count 个视频';
  }

  @override
  String get optionalMultiSelect => '可选，支持多选';

  @override
  String get manualConnect => '手动连接';

  @override
  String get ipAddress => 'IP地址';

  @override
  String get ipAddressPlaceholder => '例如: 192.168.1.100';

  @override
  String get connecting => '正在连接...';

  @override
  String get connectionTimeout => '连接超时，请检查IP地址和网络连接';

  @override
  String get connectionFailed => '连接失败';

  @override
  String connectionException(String error) {
    return '连接异常: $error';
  }

  @override
  String get connect => '连接';

  @override
  String get enterNickname => '输入昵称';

  @override
  String get nicknameUpdated => '昵称已保存';

  @override
  String get avatarUpdated => '头像已更新';

  @override
  String selectAvatarFailed(String error) {
    return '选择头像失败: $error';
  }

  @override
  String get noActivityRecords => '暂无活动记录';

  @override
  String get clearStatistics => '清除统计数据';

  @override
  String get confirmClearStatistics => '确定要清除所有统计数据吗？此操作不可撤销。';

  @override
  String get confirm => '确定';

  @override
  String get save => '保存';

  @override
  String get join => '加入';

  @override
  String get create => '创建';
}
