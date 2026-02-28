// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsPlayback => '播放设置';

  @override
  String get settingsAppearance => '外观设置';

  @override
  String get settingsNetwork => '网络设置';

  @override
  String get settingsAutoPlay => '自动播放';

  @override
  String get settingsAutoPlayDesc => '自动播放下一个视频';

  @override
  String get settingsHwDecode => '硬件解码';

  @override
  String get settingsHwDecodeDesc => '使用 GPU 加速视频解码';

  @override
  String get settingsDefaultVolume => '默认音量';

  @override
  String get settingsDefaultVolumeDesc => '启动时的默认音量';

  @override
  String get settingsDynamicColor => '动态色彩';

  @override
  String get settingsDynamicColorDesc => '使用系统壁纸颜色作为主题色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsAboutTitle => '关于 Syncro';

  @override
  String get settingsAboutDesc => '版本信息、开源地址';

  @override
  String get settingsAboutVersion => '版本';

  @override
  String get settingsAboutOpenSource => '开源地址';

  @override
  String get settingsTheme => '深色模式';

  @override
  String get settingsThemeSystem => '跟随系统设置';

  @override
  String get settingsAutoDiscover => '自动发现房间';

  @override
  String get settingsAutoDiscoverDesc => '局域网内自动搜索可用房间';

  @override
  String get navRoom => '房间';

  @override
  String get navProfile => '我的';

  @override
  String get playerStyle => '样式';

  @override
  String get chatRoom => '聊天室';

  @override
  String get roomCreated => '房间已创建，等待其他用户加入...';

  @override
  String playlistUpdated(int count) {
    return '播放列表已更新（$count 个视频）';
  }

  @override
  String get chatHint => '输入消息...';

  @override
  String get homeCreateRoom => '创建房间';

  @override
  String get homeJoinRoom => '加入房间';

  @override
  String get homeRoomCode => '房间码';

  @override
  String get homeRoomCodeHint => '请输入房间码';

  @override
  String get homeNickname => '昵称';

  @override
  String get homeNicknameHint => '请输入昵称';

  @override
  String get homeSelectVideo => '选择视频';

  @override
  String get homeNoVideo => '暂无视频';

  @override
  String get homeStart => '开始';

  @override
  String get homeCancel => '取消';

  @override
  String get homeConfirm => '确认';

  @override
  String get playerPlay => '播放';

  @override
  String get playerPause => '暂停';

  @override
  String get playerSubtitle => '字幕';

  @override
  String get playerAudioTrack => '音轨';

  @override
  String get playerNoSubtitle => '关闭字幕';

  @override
  String get playerExternalSubtitle => '外挂字幕';

  @override
  String get playerDanmaku => '弹幕';

  @override
  String get playerDanmakuHint => '发送弹幕...';

  @override
  String get playerDanmakuSend => '发送';

  @override
  String get playlistTitle => '播放列表';

  @override
  String get playlistAdd => '添加视频';

  @override
  String get playlistClear => '清除列表';

  @override
  String get playlistClearConfirm => '确定要清除全部视频吗？此操作不可恢复。';

  @override
  String get playlistEmpty => '播放列表为空';

  @override
  String roomMemberCount(int count) {
    return '$count 人在线';
  }

  @override
  String get roomHost => '房主';

  @override
  String get roomMember => '成员';

  @override
  String get roomLeave => '离开房间';

  @override
  String get roomLeaveConfirm => '确定要离开房间吗？';

  @override
  String get roomDisbandConfirm => '你是房主，离开将解散房间，确定吗？';

  @override
  String get errorNetworkFailed => '网络连接失败';

  @override
  String get errorFileNotFound => '文件未找到';

  @override
  String get errorSubtitleExtractFailed => '字幕提取失败';

  @override
  String get errorRoomNotFound => '房间不存在';

  @override
  String get errorNicknameEmpty => '昵称不能为空';

  @override
  String get successJoinRoom => '成功加入房间';

  @override
  String get successSubtitleLoaded => '字幕加载成功';

  @override
  String get loadingHostVideo => '正在加载房主分享的视频...';

  @override
  String get brightness => '亮度';

  @override
  String get volume => '音量';

  @override
  String get sendDanmaku => '发送弹幕...';

  @override
  String get hideChat => '隐藏聊天';

  @override
  String get showChat => '显示聊天';

  @override
  String get openVideo => '打开视频';

  @override
  String get fullscreen => '全屏';

  @override
  String get playbackError => '播放错误';

  @override
  String get unknownError => '未知错误';

  @override
  String get selectOtherVideo => '选择其他视频';

  @override
  String get retry => '重试';

  @override
  String get noVideo => '暂无视频';

  @override
  String get tapFolderIconSelectVideo => '点击上方文件夹图标选择视频文件';

  @override
  String get selectVideo => '选择视频';

  @override
  String get createPlaylistFailed => '创建播放列表失败';

  @override
  String get addVideoFailed => '添加视频失败';

  @override
  String get selectVideoFailed => '选择视频失败';

  @override
  String get shareRoomIp => '分享房间IP';

  @override
  String get dissolveRoom => '解散房间';

  @override
  String get leaveRoom => '离开房间';

  @override
  String get shareRoom => '分享房间';

  @override
  String get otherUsersCanJoinRoom => '其他用户可以通过以下信息加入房间：';

  @override
  String get close => '关闭';

  @override
  String get exitRoom => '退出房间';

  @override
  String get confirmExitCurrentRoom => '确定要退出当前房间吗？';

  @override
  String get cancel => '取消';

  @override
  String get exit => '退出';

  @override
  String get confirmLeaveCurrentRoom => '确定要离开当前房间吗？';

  @override
  String get leave => '离开';

  @override
  String get endRoom => '结束房间';

  @override
  String get confirmEndRoom => '确定要结束房间吗？';

  @override
  String get roomHasOtherUsersDisconnect => '房间内还有';

  @override
  String get users => '位其他用户将被断开连接。';

  @override
  String get cannotOpenLink => '无法打开链接';

  @override
  String get openLinkFailed => '打开链接失败';

  @override
  String get currentLatestVersion => '当前已是最新版本';

  @override
  String get appDescription =>
      'Syncro 是一款跨平台视频同步播放应用，支持多人在线同步观看视频。无论您和朋友相隔多远，都能一起享受同步的观影体验。';

  @override
  String get checkUpdate => '检查更新';

  @override
  String get checkForNewVersion => '检查是否有新版本';

  @override
  String get githubOpenSourceUrl => 'GitHub 开源地址';

  @override
  String get openSourceLicenseStatement => '开源协议声明';

  @override
  String get viewUsedOpenSourceLibraries => '查看使用的开源库';

  @override
  String get playerNotInitialized => '播放器未初始化';

  @override
  String get noAvailableAudioTracks => '暂无可用音轨';

  @override
  String get audioTrack => '音轨';

  @override
  String get embeddedSubtitles => '内嵌字幕';

  @override
  String get restoreSubtitle => '恢复字幕';

  @override
  String get disableSubtitle => '关闭字幕';

  @override
  String get noEmbeddedSubtitles => '暂无内嵌字幕';

  @override
  String get externalSubtitlesHostOnly => '外挂字幕（房主专属）';

  @override
  String get loadExternalSubtitle => '加载外挂字幕';

  @override
  String get externalSubtitleSyncedToAllMembers => '外挂字幕已同步到所有成员';

  @override
  String get subtitle => '字幕';

  @override
  String get fontSize => '字体大小';

  @override
  String get showBackground => '显示背景框';

  @override
  String get opacity => '不透明度';

  @override
  String get restoreDefault => '恢复默认';

  @override
  String get fontColor => '字体颜色';

  @override
  String get previewEffect => '预览效果';

  @override
  String get subtitlePreviewEffect => '字幕预览效果';

  @override
  String get videoList => '视频列表';

  @override
  String get loaded => '已加载';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      '所有房间成员将自动加载此字幕';

  @override
  String get canSelectSrtOrAssSubtitleFiles => '可选择 .srt 或 .ass 字幕文件';

  @override
  String get hostHasNotLoadedExternalSubtitles => '房主未加载外挂字幕';

  @override
  String get clearSubtitle => '清除字幕';

  @override
  String get addSubtitle => '添加字幕';

  @override
  String get clearPlaylist => '清除播放列表';

  @override
  String get confirmClearAllVideos => '确定要清除全部视频吗？此操作不可恢复。';

  @override
  String get clear => '清除';

  @override
  String get add => '添加';

  @override
  String get clearList => '清除列表';

  @override
  String get playlist => '播放列表';

  @override
  String get addVideo => '添加视频';

  @override
  String get externalSubtitles => '外挂字幕';

  @override
  String get style => '样式';

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
