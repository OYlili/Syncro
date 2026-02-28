import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
    Locale('fr'),
    Locale('de'),
    Locale('es'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'Syncro'**
  String get appName;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsPlayback.
  ///
  /// In zh, this message translates to:
  /// **'播放设置'**
  String get settingsPlayback;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观设置'**
  String get settingsAppearance;

  /// No description provided for @settingsNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络设置'**
  String get settingsNetwork;

  /// No description provided for @settingsAutoPlay.
  ///
  /// In zh, this message translates to:
  /// **'自动播放'**
  String get settingsAutoPlay;

  /// No description provided for @settingsAutoPlayDesc.
  ///
  /// In zh, this message translates to:
  /// **'自动播放下一个视频'**
  String get settingsAutoPlayDesc;

  /// No description provided for @settingsHwDecode.
  ///
  /// In zh, this message translates to:
  /// **'硬件解码'**
  String get settingsHwDecode;

  /// No description provided for @settingsHwDecodeDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用 GPU 加速视频解码'**
  String get settingsHwDecodeDesc;

  /// No description provided for @settingsDefaultVolume.
  ///
  /// In zh, this message translates to:
  /// **'默认音量'**
  String get settingsDefaultVolume;

  /// No description provided for @settingsDefaultVolumeDesc.
  ///
  /// In zh, this message translates to:
  /// **'启动时的默认音量'**
  String get settingsDefaultVolumeDesc;

  /// No description provided for @settingsDynamicColor.
  ///
  /// In zh, this message translates to:
  /// **'动态色彩'**
  String get settingsDynamicColor;

  /// No description provided for @settingsDynamicColorDesc.
  ///
  /// In zh, this message translates to:
  /// **'使用系统壁纸颜色作为主题色'**
  String get settingsDynamicColorDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于 Syncro'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In zh, this message translates to:
  /// **'版本信息、开源地址'**
  String get settingsAboutDesc;

  /// No description provided for @settingsAboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get settingsAboutVersion;

  /// No description provided for @settingsAboutOpenSource.
  ///
  /// In zh, this message translates to:
  /// **'开源地址'**
  String get settingsAboutOpenSource;

  /// No description provided for @settingsTheme.
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统设置'**
  String get settingsThemeSystem;

  /// No description provided for @settingsAutoDiscover.
  ///
  /// In zh, this message translates to:
  /// **'自动发现房间'**
  String get settingsAutoDiscover;

  /// No description provided for @settingsAutoDiscoverDesc.
  ///
  /// In zh, this message translates to:
  /// **'局域网内自动搜索可用房间'**
  String get settingsAutoDiscoverDesc;

  /// No description provided for @navRoom.
  ///
  /// In zh, this message translates to:
  /// **'房间'**
  String get navRoom;

  /// No description provided for @navProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get navProfile;

  /// No description provided for @playerStyle.
  ///
  /// In zh, this message translates to:
  /// **'样式'**
  String get playerStyle;

  /// No description provided for @chatRoom.
  ///
  /// In zh, this message translates to:
  /// **'聊天室'**
  String get chatRoom;

  /// No description provided for @roomCreated.
  ///
  /// In zh, this message translates to:
  /// **'房间已创建，等待其他用户加入...'**
  String get roomCreated;

  /// No description provided for @playlistUpdated.
  ///
  /// In zh, this message translates to:
  /// **'播放列表已更新（{count} 个视频）'**
  String playlistUpdated(int count);

  /// No description provided for @chatHint.
  ///
  /// In zh, this message translates to:
  /// **'输入消息...'**
  String get chatHint;

  /// No description provided for @homeCreateRoom.
  ///
  /// In zh, this message translates to:
  /// **'创建房间'**
  String get homeCreateRoom;

  /// No description provided for @homeJoinRoom.
  ///
  /// In zh, this message translates to:
  /// **'加入房间'**
  String get homeJoinRoom;

  /// No description provided for @homeRoomCode.
  ///
  /// In zh, this message translates to:
  /// **'房间码'**
  String get homeRoomCode;

  /// No description provided for @homeRoomCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入房间码'**
  String get homeRoomCodeHint;

  /// No description provided for @homeNickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get homeNickname;

  /// No description provided for @homeNicknameHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入昵称'**
  String get homeNicknameHint;

  /// No description provided for @homeSelectVideo.
  ///
  /// In zh, this message translates to:
  /// **'选择视频'**
  String get homeSelectVideo;

  /// No description provided for @homeNoVideo.
  ///
  /// In zh, this message translates to:
  /// **'暂无视频'**
  String get homeNoVideo;

  /// No description provided for @homeStart.
  ///
  /// In zh, this message translates to:
  /// **'开始'**
  String get homeStart;

  /// No description provided for @homeCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get homeCancel;

  /// No description provided for @homeConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get homeConfirm;

  /// No description provided for @playerPlay.
  ///
  /// In zh, this message translates to:
  /// **'播放'**
  String get playerPlay;

  /// No description provided for @playerPause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get playerPause;

  /// No description provided for @playerSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'字幕'**
  String get playerSubtitle;

  /// No description provided for @playerAudioTrack.
  ///
  /// In zh, this message translates to:
  /// **'音轨'**
  String get playerAudioTrack;

  /// No description provided for @playerNoSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭字幕'**
  String get playerNoSubtitle;

  /// No description provided for @playerExternalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'外挂字幕'**
  String get playerExternalSubtitle;

  /// No description provided for @playerDanmaku.
  ///
  /// In zh, this message translates to:
  /// **'弹幕'**
  String get playerDanmaku;

  /// No description provided for @playerDanmakuHint.
  ///
  /// In zh, this message translates to:
  /// **'发送弹幕...'**
  String get playerDanmakuHint;

  /// No description provided for @playerDanmakuSend.
  ///
  /// In zh, this message translates to:
  /// **'发送'**
  String get playerDanmakuSend;

  /// No description provided for @playlistTitle.
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlistTitle;

  /// No description provided for @playlistAdd.
  ///
  /// In zh, this message translates to:
  /// **'添加视频'**
  String get playlistAdd;

  /// No description provided for @playlistClear.
  ///
  /// In zh, this message translates to:
  /// **'清除列表'**
  String get playlistClear;

  /// No description provided for @playlistClearConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除全部视频吗？此操作不可恢复。'**
  String get playlistClearConfirm;

  /// No description provided for @playlistEmpty.
  ///
  /// In zh, this message translates to:
  /// **'播放列表为空'**
  String get playlistEmpty;

  /// No description provided for @roomMemberCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人在线'**
  String roomMemberCount(int count);

  /// No description provided for @roomHost.
  ///
  /// In zh, this message translates to:
  /// **'房主'**
  String get roomHost;

  /// No description provided for @roomMember.
  ///
  /// In zh, this message translates to:
  /// **'成员'**
  String get roomMember;

  /// No description provided for @roomLeave.
  ///
  /// In zh, this message translates to:
  /// **'离开房间'**
  String get roomLeave;

  /// No description provided for @roomLeaveConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确定要离开房间吗？'**
  String get roomLeaveConfirm;

  /// No description provided for @roomDisbandConfirm.
  ///
  /// In zh, this message translates to:
  /// **'你是房主，离开将解散房间，确定吗？'**
  String get roomDisbandConfirm;

  /// No description provided for @errorNetworkFailed.
  ///
  /// In zh, this message translates to:
  /// **'网络连接失败'**
  String get errorNetworkFailed;

  /// No description provided for @errorFileNotFound.
  ///
  /// In zh, this message translates to:
  /// **'文件未找到'**
  String get errorFileNotFound;

  /// No description provided for @errorSubtitleExtractFailed.
  ///
  /// In zh, this message translates to:
  /// **'字幕提取失败'**
  String get errorSubtitleExtractFailed;

  /// No description provided for @errorRoomNotFound.
  ///
  /// In zh, this message translates to:
  /// **'房间不存在'**
  String get errorRoomNotFound;

  /// No description provided for @errorNicknameEmpty.
  ///
  /// In zh, this message translates to:
  /// **'昵称不能为空'**
  String get errorNicknameEmpty;

  /// No description provided for @successJoinRoom.
  ///
  /// In zh, this message translates to:
  /// **'成功加入房间'**
  String get successJoinRoom;

  /// No description provided for @successSubtitleLoaded.
  ///
  /// In zh, this message translates to:
  /// **'字幕加载成功'**
  String get successSubtitleLoaded;

  /// No description provided for @loadingHostVideo.
  ///
  /// In zh, this message translates to:
  /// **'正在加载房主分享的视频...'**
  String get loadingHostVideo;

  /// No description provided for @brightness.
  ///
  /// In zh, this message translates to:
  /// **'亮度'**
  String get brightness;

  /// No description provided for @volume.
  ///
  /// In zh, this message translates to:
  /// **'音量'**
  String get volume;

  /// No description provided for @sendDanmaku.
  ///
  /// In zh, this message translates to:
  /// **'发送弹幕...'**
  String get sendDanmaku;

  /// No description provided for @hideChat.
  ///
  /// In zh, this message translates to:
  /// **'隐藏聊天'**
  String get hideChat;

  /// No description provided for @showChat.
  ///
  /// In zh, this message translates to:
  /// **'显示聊天'**
  String get showChat;

  /// No description provided for @openVideo.
  ///
  /// In zh, this message translates to:
  /// **'打开视频'**
  String get openVideo;

  /// No description provided for @fullscreen.
  ///
  /// In zh, this message translates to:
  /// **'全屏'**
  String get fullscreen;

  /// No description provided for @playbackError.
  ///
  /// In zh, this message translates to:
  /// **'播放错误'**
  String get playbackError;

  /// No description provided for @unknownError.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get unknownError;

  /// No description provided for @selectOtherVideo.
  ///
  /// In zh, this message translates to:
  /// **'选择其他视频'**
  String get selectOtherVideo;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @noVideo.
  ///
  /// In zh, this message translates to:
  /// **'暂无视频'**
  String get noVideo;

  /// No description provided for @tapFolderIconSelectVideo.
  ///
  /// In zh, this message translates to:
  /// **'点击上方文件夹图标选择视频文件'**
  String get tapFolderIconSelectVideo;

  /// No description provided for @selectVideo.
  ///
  /// In zh, this message translates to:
  /// **'选择视频'**
  String get selectVideo;

  /// No description provided for @createPlaylistFailed.
  ///
  /// In zh, this message translates to:
  /// **'创建播放列表失败'**
  String get createPlaylistFailed;

  /// No description provided for @addVideoFailed.
  ///
  /// In zh, this message translates to:
  /// **'添加视频失败'**
  String get addVideoFailed;

  /// No description provided for @selectVideoFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择视频失败'**
  String get selectVideoFailed;

  /// No description provided for @shareRoomIp.
  ///
  /// In zh, this message translates to:
  /// **'分享房间IP'**
  String get shareRoomIp;

  /// No description provided for @dissolveRoom.
  ///
  /// In zh, this message translates to:
  /// **'解散房间'**
  String get dissolveRoom;

  /// No description provided for @leaveRoom.
  ///
  /// In zh, this message translates to:
  /// **'离开房间'**
  String get leaveRoom;

  /// No description provided for @shareRoom.
  ///
  /// In zh, this message translates to:
  /// **'分享房间'**
  String get shareRoom;

  /// No description provided for @otherUsersCanJoinRoom.
  ///
  /// In zh, this message translates to:
  /// **'其他用户可以通过以下信息加入房间：'**
  String get otherUsersCanJoinRoom;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @exitRoom.
  ///
  /// In zh, this message translates to:
  /// **'退出房间'**
  String get exitRoom;

  /// No description provided for @confirmExitCurrentRoom.
  ///
  /// In zh, this message translates to:
  /// **'确定要退出当前房间吗？'**
  String get confirmExitCurrentRoom;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get exit;

  /// No description provided for @confirmLeaveCurrentRoom.
  ///
  /// In zh, this message translates to:
  /// **'确定要离开当前房间吗？'**
  String get confirmLeaveCurrentRoom;

  /// No description provided for @leave.
  ///
  /// In zh, this message translates to:
  /// **'离开'**
  String get leave;

  /// No description provided for @endRoom.
  ///
  /// In zh, this message translates to:
  /// **'结束房间'**
  String get endRoom;

  /// No description provided for @confirmEndRoom.
  ///
  /// In zh, this message translates to:
  /// **'确定要结束房间吗？'**
  String get confirmEndRoom;

  /// No description provided for @roomHasOtherUsersDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'房间内还有'**
  String get roomHasOtherUsersDisconnect;

  /// No description provided for @users.
  ///
  /// In zh, this message translates to:
  /// **'位其他用户将被断开连接。'**
  String get users;

  /// No description provided for @cannotOpenLink.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接'**
  String get cannotOpenLink;

  /// No description provided for @openLinkFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开链接失败'**
  String get openLinkFailed;

  /// No description provided for @currentLatestVersion.
  ///
  /// In zh, this message translates to:
  /// **'当前已是最新版本'**
  String get currentLatestVersion;

  /// No description provided for @appDescription.
  ///
  /// In zh, this message translates to:
  /// **'Syncro 是一款跨平台视频同步播放应用，支持多人在线同步观看视频。无论您和朋友相隔多远，都能一起享受同步的观影体验。'**
  String get appDescription;

  /// No description provided for @checkUpdate.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get checkUpdate;

  /// No description provided for @checkForNewVersion.
  ///
  /// In zh, this message translates to:
  /// **'检查是否有新版本'**
  String get checkForNewVersion;

  /// No description provided for @githubOpenSourceUrl.
  ///
  /// In zh, this message translates to:
  /// **'GitHub 开源地址'**
  String get githubOpenSourceUrl;

  /// No description provided for @openSourceLicenseStatement.
  ///
  /// In zh, this message translates to:
  /// **'开源协议声明'**
  String get openSourceLicenseStatement;

  /// No description provided for @viewUsedOpenSourceLibraries.
  ///
  /// In zh, this message translates to:
  /// **'查看使用的开源库'**
  String get viewUsedOpenSourceLibraries;

  /// No description provided for @playerNotInitialized.
  ///
  /// In zh, this message translates to:
  /// **'播放器未初始化'**
  String get playerNotInitialized;

  /// No description provided for @noAvailableAudioTracks.
  ///
  /// In zh, this message translates to:
  /// **'暂无可用音轨'**
  String get noAvailableAudioTracks;

  /// No description provided for @audioTrack.
  ///
  /// In zh, this message translates to:
  /// **'音轨'**
  String get audioTrack;

  /// No description provided for @embeddedSubtitles.
  ///
  /// In zh, this message translates to:
  /// **'内嵌字幕'**
  String get embeddedSubtitles;

  /// No description provided for @restoreSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复字幕'**
  String get restoreSubtitle;

  /// No description provided for @disableSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭字幕'**
  String get disableSubtitle;

  /// No description provided for @noEmbeddedSubtitles.
  ///
  /// In zh, this message translates to:
  /// **'暂无内嵌字幕'**
  String get noEmbeddedSubtitles;

  /// No description provided for @externalSubtitlesHostOnly.
  ///
  /// In zh, this message translates to:
  /// **'外挂字幕（房主专属）'**
  String get externalSubtitlesHostOnly;

  /// No description provided for @loadExternalSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'加载外挂字幕'**
  String get loadExternalSubtitle;

  /// No description provided for @externalSubtitleSyncedToAllMembers.
  ///
  /// In zh, this message translates to:
  /// **'外挂字幕已同步到所有成员'**
  String get externalSubtitleSyncedToAllMembers;

  /// No description provided for @subtitle.
  ///
  /// In zh, this message translates to:
  /// **'字幕'**
  String get subtitle;

  /// No description provided for @fontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get fontSize;

  /// No description provided for @showBackground.
  ///
  /// In zh, this message translates to:
  /// **'显示背景框'**
  String get showBackground;

  /// No description provided for @opacity.
  ///
  /// In zh, this message translates to:
  /// **'不透明度'**
  String get opacity;

  /// No description provided for @restoreDefault.
  ///
  /// In zh, this message translates to:
  /// **'恢复默认'**
  String get restoreDefault;

  /// No description provided for @fontColor.
  ///
  /// In zh, this message translates to:
  /// **'字体颜色'**
  String get fontColor;

  /// No description provided for @previewEffect.
  ///
  /// In zh, this message translates to:
  /// **'预览效果'**
  String get previewEffect;

  /// No description provided for @subtitlePreviewEffect.
  ///
  /// In zh, this message translates to:
  /// **'字幕预览效果'**
  String get subtitlePreviewEffect;

  /// No description provided for @videoList.
  ///
  /// In zh, this message translates to:
  /// **'视频列表'**
  String get videoList;

  /// No description provided for @loaded.
  ///
  /// In zh, this message translates to:
  /// **'已加载'**
  String get loaded;

  /// No description provided for @allRoomMembersWillAutomaticallyLoadThisSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'所有房间成员将自动加载此字幕'**
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle;

  /// No description provided for @canSelectSrtOrAssSubtitleFiles.
  ///
  /// In zh, this message translates to:
  /// **'可选择 .srt 或 .ass 字幕文件'**
  String get canSelectSrtOrAssSubtitleFiles;

  /// No description provided for @hostHasNotLoadedExternalSubtitles.
  ///
  /// In zh, this message translates to:
  /// **'房主未加载外挂字幕'**
  String get hostHasNotLoadedExternalSubtitles;

  /// No description provided for @clearSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'清除字幕'**
  String get clearSubtitle;

  /// No description provided for @addSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'添加字幕'**
  String get addSubtitle;

  /// No description provided for @clearPlaylist.
  ///
  /// In zh, this message translates to:
  /// **'清除播放列表'**
  String get clearPlaylist;

  /// No description provided for @confirmClearAllVideos.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除全部视频吗？此操作不可恢复。'**
  String get confirmClearAllVideos;

  /// No description provided for @clear.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get clear;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @clearList.
  ///
  /// In zh, this message translates to:
  /// **'清除列表'**
  String get clearList;

  /// No description provided for @playlist.
  ///
  /// In zh, this message translates to:
  /// **'播放列表'**
  String get playlist;

  /// No description provided for @addVideo.
  ///
  /// In zh, this message translates to:
  /// **'添加视频'**
  String get addVideo;

  /// No description provided for @externalSubtitles.
  ///
  /// In zh, this message translates to:
  /// **'外挂字幕'**
  String get externalSubtitles;

  /// No description provided for @style.
  ///
  /// In zh, this message translates to:
  /// **'样式'**
  String get style;

  /// No description provided for @scanningLan.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描局域网...'**
  String get scanningLan;

  /// No description provided for @noRoomsFound.
  ///
  /// In zh, this message translates to:
  /// **'未发现房间'**
  String get noRoomsFound;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profileTitle;

  /// No description provided for @profileEditNickname.
  ///
  /// In zh, this message translates to:
  /// **'编辑昵称'**
  String get profileEditNickname;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In zh, this message translates to:
  /// **'点击头像更换'**
  String get profileChangeAvatar;

  /// No description provided for @profileWatchTime.
  ///
  /// In zh, this message translates to:
  /// **'观看时长'**
  String get profileWatchTime;

  /// No description provided for @profileWatchTimeUnit.
  ///
  /// In zh, this message translates to:
  /// **'分钟'**
  String get profileWatchTimeUnit;

  /// No description provided for @profileJoinCount.
  ///
  /// In zh, this message translates to:
  /// **'加入房间'**
  String get profileJoinCount;

  /// No description provided for @profileWatchCount.
  ///
  /// In zh, this message translates to:
  /// **'观看视频'**
  String get profileWatchCount;

  /// No description provided for @profileWatchUnit.
  ///
  /// In zh, this message translates to:
  /// **'个'**
  String get profileWatchUnit;

  /// No description provided for @profileRecentActivity.
  ///
  /// In zh, this message translates to:
  /// **'最近活动'**
  String get profileRecentActivity;

  /// No description provided for @profileClearActivity.
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get profileClearActivity;

  /// No description provided for @profileCreatedRoom.
  ///
  /// In zh, this message translates to:
  /// **'创建了房间 \"{name}\"'**
  String profileCreatedRoom(String name);

  /// No description provided for @profileJoinedRoom.
  ///
  /// In zh, this message translates to:
  /// **'加入了房间 \"{name}\"'**
  String profileJoinedRoom(String name);

  /// No description provided for @aboutAppName.
  ///
  /// In zh, this message translates to:
  /// **'应用名称'**
  String get aboutAppName;

  /// No description provided for @aboutPackageName.
  ///
  /// In zh, this message translates to:
  /// **'包名'**
  String get aboutPackageName;

  /// No description provided for @aboutVersionNumber.
  ///
  /// In zh, this message translates to:
  /// **'版本号'**
  String get aboutVersionNumber;

  /// No description provided for @aboutBuildNumber.
  ///
  /// In zh, this message translates to:
  /// **'构建号'**
  String get aboutBuildNumber;

  /// No description provided for @aboutCopyright.
  ///
  /// In zh, this message translates to:
  /// **'© 2024 Syncro Team'**
  String get aboutCopyright;

  /// No description provided for @aboutMadeWith.
  ///
  /// In zh, this message translates to:
  /// **'Made with ❤️ using Flutter'**
  String get aboutMadeWith;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @memberJoined.
  ///
  /// In zh, this message translates to:
  /// **'{name} 加入了房间'**
  String memberJoined(String name);

  /// No description provided for @memberLeft.
  ///
  /// In zh, this message translates to:
  /// **'{name} 离开了房间'**
  String memberLeft(String name);

  /// No description provided for @scanningStopped.
  ///
  /// In zh, this message translates to:
  /// **'扫描已停止'**
  String get scanningStopped;

  /// No description provided for @roomsFound.
  ///
  /// In zh, this message translates to:
  /// **'发现的房间'**
  String get roomsFound;

  /// No description provided for @scanError.
  ///
  /// In zh, this message translates to:
  /// **'扫描出错'**
  String get scanError;

  /// No description provided for @scanAgain.
  ///
  /// In zh, this message translates to:
  /// **'重新扫描'**
  String get scanAgain;

  /// No description provided for @joinRoom.
  ///
  /// In zh, this message translates to:
  /// **'加入房间'**
  String get joinRoom;

  /// No description provided for @createRoomTitle.
  ///
  /// In zh, this message translates to:
  /// **'创建房间'**
  String get createRoomTitle;

  /// No description provided for @roomNameHint.
  ///
  /// In zh, this message translates to:
  /// **'房间名称'**
  String get roomNameHint;

  /// No description provided for @roomNamePlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'输入房间名称'**
  String get roomNamePlaceholder;

  /// No description provided for @portNumber.
  ///
  /// In zh, this message translates to:
  /// **'端口号'**
  String get portNumber;

  /// No description provided for @portNumberPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'默认 37670'**
  String get portNumberPlaceholder;

  /// No description provided for @selectVideoFiles.
  ///
  /// In zh, this message translates to:
  /// **'选择视频文件'**
  String get selectVideoFiles;

  /// No description provided for @selectedVideosCount.
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个视频'**
  String selectedVideosCount(int count);

  /// No description provided for @optionalMultiSelect.
  ///
  /// In zh, this message translates to:
  /// **'可选，支持多选'**
  String get optionalMultiSelect;

  /// No description provided for @manualConnect.
  ///
  /// In zh, this message translates to:
  /// **'手动连接'**
  String get manualConnect;

  /// No description provided for @ipAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP地址'**
  String get ipAddress;

  /// No description provided for @ipAddressPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'例如: 192.168.1.100'**
  String get ipAddressPlaceholder;

  /// No description provided for @connecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接...'**
  String get connecting;

  /// No description provided for @connectionTimeout.
  ///
  /// In zh, this message translates to:
  /// **'连接超时，请检查IP地址和网络连接'**
  String get connectionTimeout;

  /// No description provided for @connectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get connectionFailed;

  /// No description provided for @connectionException.
  ///
  /// In zh, this message translates to:
  /// **'连接异常: {error}'**
  String connectionException(String error);

  /// No description provided for @connect.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get connect;

  /// No description provided for @enterNickname.
  ///
  /// In zh, this message translates to:
  /// **'输入昵称'**
  String get enterNickname;

  /// No description provided for @nicknameUpdated.
  ///
  /// In zh, this message translates to:
  /// **'昵称已保存'**
  String get nicknameUpdated;

  /// No description provided for @avatarUpdated.
  ///
  /// In zh, this message translates to:
  /// **'头像已更新'**
  String get avatarUpdated;

  /// No description provided for @selectAvatarFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择头像失败: {error}'**
  String selectAvatarFailed(String error);

  /// No description provided for @noActivityRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无活动记录'**
  String get noActivityRecords;

  /// No description provided for @clearStatistics.
  ///
  /// In zh, this message translates to:
  /// **'清除统计数据'**
  String get clearStatistics;

  /// No description provided for @confirmClearStatistics.
  ///
  /// In zh, this message translates to:
  /// **'确定要清除所有统计数据吗？此操作不可撤销。'**
  String get confirmClearStatistics;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @join.
  ///
  /// In zh, this message translates to:
  /// **'加入'**
  String get join;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
