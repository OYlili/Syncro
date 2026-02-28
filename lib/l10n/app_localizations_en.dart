// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPlayback => 'Playback';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsNetwork => 'Network';

  @override
  String get settingsAutoPlay => 'Auto Play';

  @override
  String get settingsAutoPlayDesc => 'Automatically play next video';

  @override
  String get settingsHwDecode => 'Hardware Decoding';

  @override
  String get settingsHwDecodeDesc => 'Use GPU to accelerate video decoding';

  @override
  String get settingsDefaultVolume => 'Default Volume';

  @override
  String get settingsDefaultVolumeDesc => 'Default volume on startup';

  @override
  String get settingsDynamicColor => 'Dynamic Color';

  @override
  String get settingsDynamicColorDesc => 'Use wallpaper color as theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow System';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutTitle => 'About Syncro';

  @override
  String get settingsAboutDesc => 'Version info and open source link';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsAboutOpenSource => 'Open Source';

  @override
  String get settingsTheme => 'Dark Mode';

  @override
  String get settingsThemeSystem => 'Follow System Settings';

  @override
  String get settingsAutoDiscover => 'Auto Discover Rooms';

  @override
  String get settingsAutoDiscoverDesc => 'Auto search available rooms on LAN';

  @override
  String get navRoom => 'Rooms';

  @override
  String get navProfile => 'Profile';

  @override
  String get playerStyle => 'Style';

  @override
  String get chatRoom => 'Chat';

  @override
  String get roomCreated => 'Room created. Waiting for others to join...';

  @override
  String playlistUpdated(int count) {
    return 'Playlist updated ($count videos)';
  }

  @override
  String get chatHint => 'Type a message...';

  @override
  String get homeCreateRoom => 'Create Room';

  @override
  String get homeJoinRoom => 'Join Room';

  @override
  String get homeRoomCode => 'Room Code';

  @override
  String get homeRoomCodeHint => 'Enter room code';

  @override
  String get homeNickname => 'Nickname';

  @override
  String get homeNicknameHint => 'Enter your nickname';

  @override
  String get homeSelectVideo => 'Select Video';

  @override
  String get homeNoVideo => 'No Video Selected';

  @override
  String get homeStart => 'Start';

  @override
  String get homeCancel => 'Cancel';

  @override
  String get homeConfirm => 'Confirm';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerSubtitle => 'Subtitles';

  @override
  String get playerAudioTrack => 'Audio Track';

  @override
  String get playerNoSubtitle => 'No Subtitles';

  @override
  String get playerExternalSubtitle => 'External Subtitle';

  @override
  String get playerDanmaku => 'Danmaku';

  @override
  String get playerDanmakuHint => 'Send a comment...';

  @override
  String get playerDanmakuSend => 'Send';

  @override
  String get playlistTitle => 'Playlist';

  @override
  String get playlistAdd => 'Add Video';

  @override
  String get playlistClear => 'Clear Playlist';

  @override
  String get playlistClearConfirm => 'Clear all videos? This cannot be undone.';

  @override
  String get playlistEmpty => 'Playlist is empty';

  @override
  String roomMemberCount(int count) {
    return '$count online';
  }

  @override
  String get roomHost => 'Host';

  @override
  String get roomMember => 'Member';

  @override
  String get roomLeave => 'Leave Room';

  @override
  String get roomLeaveConfirm => 'Are you sure you want to leave?';

  @override
  String get roomDisbandConfirm =>
      'You are the host. Leaving will disband the room. Continue?';

  @override
  String get errorNetworkFailed => 'Network connection failed';

  @override
  String get errorFileNotFound => 'File not found';

  @override
  String get errorSubtitleExtractFailed => 'Subtitle extraction failed';

  @override
  String get errorRoomNotFound => 'Room not found';

  @override
  String get errorNicknameEmpty => 'Nickname cannot be empty';

  @override
  String get successJoinRoom => 'Successfully joined the room';

  @override
  String get successSubtitleLoaded => 'Subtitle loaded successfully';

  @override
  String get loadingHostVideo => 'Loading host\'s shared video...';

  @override
  String get brightness => 'Brightness';

  @override
  String get volume => 'Volume';

  @override
  String get sendDanmaku => 'Send danmaku...';

  @override
  String get hideChat => 'Hide Chat';

  @override
  String get showChat => 'Show Chat';

  @override
  String get openVideo => 'Open Video';

  @override
  String get fullscreen => 'Fullscreen';

  @override
  String get playbackError => 'Playback Error';

  @override
  String get unknownError => 'Unknown Error';

  @override
  String get selectOtherVideo => 'Select Other Video';

  @override
  String get retry => 'Retry';

  @override
  String get noVideo => 'No Video';

  @override
  String get tapFolderIconSelectVideo =>
      'Tap the folder icon above to select video files';

  @override
  String get selectVideo => 'Select Video';

  @override
  String get createPlaylistFailed => 'Failed to create playlist';

  @override
  String get addVideoFailed => 'Failed to add video';

  @override
  String get selectVideoFailed => 'Failed to select video';

  @override
  String get shareRoomIp => 'Share Room IP';

  @override
  String get dissolveRoom => 'Dissolve Room';

  @override
  String get leaveRoom => 'Leave Room';

  @override
  String get shareRoom => 'Share Room';

  @override
  String get otherUsersCanJoinRoom =>
      'Other users can join the room using the following information:';

  @override
  String get close => 'Close';

  @override
  String get exitRoom => 'Exit Room';

  @override
  String get confirmExitCurrentRoom =>
      'Are you sure you want to exit the current room?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get confirmLeaveCurrentRoom =>
      'Are you sure you want to leave the current room?';

  @override
  String get leave => 'Leave';

  @override
  String get endRoom => 'End Room';

  @override
  String get confirmEndRoom => 'Are you sure you want to end the room?';

  @override
  String get roomHasOtherUsersDisconnect => 'There are';

  @override
  String get users => 'other users in the room who will be disconnected.';

  @override
  String get cannotOpenLink => 'Cannot open link';

  @override
  String get openLinkFailed => 'Failed to open link';

  @override
  String get currentLatestVersion => 'You are using the latest version';

  @override
  String get appDescription =>
      'Syncro is a cross-platform video sync playback app that supports multi-user online synchronized video watching. No matter how far apart you and your friends are, you can enjoy synchronized viewing experience together.';

  @override
  String get checkUpdate => 'Check for Updates';

  @override
  String get checkForNewVersion => 'Check if there is a new version';

  @override
  String get githubOpenSourceUrl => 'GitHub Open Source URL';

  @override
  String get openSourceLicenseStatement => 'Open Source License Statement';

  @override
  String get viewUsedOpenSourceLibraries => 'View used open source libraries';

  @override
  String get playerNotInitialized => 'Player not initialized';

  @override
  String get noAvailableAudioTracks => 'No available audio tracks';

  @override
  String get audioTrack => 'Audio Track';

  @override
  String get embeddedSubtitles => 'Embedded Subtitles';

  @override
  String get restoreSubtitle => 'Restore Subtitle';

  @override
  String get disableSubtitle => 'Disable Subtitle';

  @override
  String get noEmbeddedSubtitles => 'No embedded subtitles';

  @override
  String get externalSubtitlesHostOnly => 'External Subtitle (Host Only)';

  @override
  String get loadExternalSubtitle => 'Load External Subtitle';

  @override
  String get externalSubtitleSyncedToAllMembers =>
      'External subtitle synced to all members';

  @override
  String get subtitle => 'Subtitle';

  @override
  String get fontSize => 'Font Size';

  @override
  String get showBackground => 'Show Background';

  @override
  String get opacity => 'Opacity';

  @override
  String get restoreDefault => 'Restore Default';

  @override
  String get fontColor => 'Font Color';

  @override
  String get previewEffect => 'Preview Effect';

  @override
  String get subtitlePreviewEffect => 'Subtitle Preview Effect';

  @override
  String get videoList => 'Video List';

  @override
  String get loaded => 'Loaded';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      'All room members will automatically load this subtitle';

  @override
  String get canSelectSrtOrAssSubtitleFiles =>
      'Can select .srt or .ass subtitle files';

  @override
  String get hostHasNotLoadedExternalSubtitles =>
      'Host has not loaded external subtitle';

  @override
  String get clearSubtitle => 'Clear Subtitle';

  @override
  String get addSubtitle => 'Add Subtitle';

  @override
  String get clearPlaylist => 'Clear Playlist';

  @override
  String get confirmClearAllVideos =>
      'Are you sure you want to clear all videos? This cannot be undone.';

  @override
  String get clear => 'Clear';

  @override
  String get add => 'Add';

  @override
  String get clearList => 'Clear List';

  @override
  String get playlist => 'Playlist';

  @override
  String get addVideo => 'Add Video';

  @override
  String get externalSubtitles => 'External Subtitles';

  @override
  String get style => 'Style';

  @override
  String get scanningLan => 'Scanning LAN...';

  @override
  String get noRoomsFound => 'No rooms found';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEditNickname => 'Edit Nickname';

  @override
  String get profileChangeAvatar => 'Tap to change avatar';

  @override
  String get profileWatchTime => 'Watch Time';

  @override
  String get profileWatchTimeUnit => 'min';

  @override
  String get profileJoinCount => 'Rooms Joined';

  @override
  String get profileWatchCount => 'Videos Watched';

  @override
  String get profileWatchUnit => '';

  @override
  String get profileRecentActivity => 'Recent Activity';

  @override
  String get profileClearActivity => 'Clear';

  @override
  String profileCreatedRoom(String name) {
    return 'Created room \"$name\"';
  }

  @override
  String profileJoinedRoom(String name) {
    return 'Joined room \"$name\"';
  }

  @override
  String get aboutAppName => 'App Name';

  @override
  String get aboutPackageName => 'Package Name';

  @override
  String get aboutVersionNumber => 'Version';

  @override
  String get aboutBuildNumber => 'Build';

  @override
  String get aboutCopyright => '© 2024 Syncro Team';

  @override
  String get aboutMadeWith => 'Made with ❤️ using Flutter';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'Follow System';

  @override
  String memberJoined(String name) {
    return '$name joined the room';
  }

  @override
  String memberLeft(String name) {
    return '$name left the room';
  }

  @override
  String get scanningStopped => 'Scanning stopped';

  @override
  String get roomsFound => 'Rooms found';

  @override
  String get scanError => 'Scan error';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get joinRoom => 'Join Room';

  @override
  String get createRoomTitle => 'Create Room';

  @override
  String get roomNameHint => 'Room Name';

  @override
  String get roomNamePlaceholder => 'Enter room name';

  @override
  String get portNumber => 'Port Number';

  @override
  String get portNumberPlaceholder => 'Default 37670';

  @override
  String get selectVideoFiles => 'Select Video Files';

  @override
  String selectedVideosCount(int count) {
    return '$count videos selected';
  }

  @override
  String get optionalMultiSelect => 'Optional, supports multi-select';

  @override
  String get manualConnect => 'Manual Connect';

  @override
  String get ipAddress => 'IP Address';

  @override
  String get ipAddressPlaceholder => 'e.g., 192.168.1.100';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connectionTimeout =>
      'Connection timeout. Please check IP address and network connection.';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String connectionException(String error) {
    return 'Connection exception: $error';
  }

  @override
  String get connect => 'Connect';

  @override
  String get enterNickname => 'Enter nickname';

  @override
  String get nicknameUpdated => 'Nickname saved';

  @override
  String get avatarUpdated => 'Avatar updated';

  @override
  String selectAvatarFailed(String error) {
    return 'Failed to select avatar: $error';
  }

  @override
  String get noActivityRecords => 'No activity records';

  @override
  String get clearStatistics => 'Clear statistics';

  @override
  String get confirmClearStatistics =>
      'Are you sure you want to clear all statistics? This action cannot be undone.';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get join => 'Join';

  @override
  String get create => 'Create';
}
