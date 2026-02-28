// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsPlayback => 'Воспроизведение';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsNetwork => 'Сеть';

  @override
  String get settingsAutoPlay => 'Автовоспроизведение';

  @override
  String get settingsAutoPlayDesc =>
      'Автоматически воспроизводить следующее видео';

  @override
  String get settingsHwDecode => 'Аппаратное декодирование';

  @override
  String get settingsHwDecodeDesc =>
      'Использовать GPU для ускорения декодирования';

  @override
  String get settingsDefaultVolume => 'Громкость по умолчанию';

  @override
  String get settingsDefaultVolumeDesc => 'Громкость при запуске';

  @override
  String get settingsDynamicColor => 'Динамический цвет';

  @override
  String get settingsDynamicColorDesc => 'Цвет обоев как тема';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Системный';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String get settingsAboutTitle => 'О Syncro';

  @override
  String get settingsAboutDesc => 'Версия и ссылка на код';

  @override
  String get settingsAboutVersion => 'Версия';

  @override
  String get settingsAboutOpenSource => 'Исходный код';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get settingsAutoDiscover => 'Автопоиск комнат';

  @override
  String get settingsAutoDiscoverDesc => 'Автоматически искать комнаты в сети';

  @override
  String get navRoom => 'Комнаты';

  @override
  String get navProfile => 'Профиль';

  @override
  String get playerStyle => 'Стиль';

  @override
  String get chatRoom => 'Чат';

  @override
  String get roomCreated => 'Комната создана. Ожидание...';

  @override
  String playlistUpdated(int count) {
    return 'Список обновлён ($count видео)';
  }

  @override
  String get chatHint => 'Введите сообщение...';

  @override
  String get homeCreateRoom => 'Создать комнату';

  @override
  String get homeJoinRoom => 'Войти в комнату';

  @override
  String get homeRoomCode => 'Код комнаты';

  @override
  String get homeRoomCodeHint => 'Введите код';

  @override
  String get homeNickname => 'Никнейм';

  @override
  String get homeNicknameHint => 'Введите никнейм';

  @override
  String get homeSelectVideo => 'Выбрать видео';

  @override
  String get homeNoVideo => 'Нет видео';

  @override
  String get homeStart => 'Начать';

  @override
  String get homeCancel => 'Отмена';

  @override
  String get homeConfirm => 'Подтвердить';

  @override
  String get playerPlay => 'Играть';

  @override
  String get playerPause => 'Пауза';

  @override
  String get playerSubtitle => 'Субтитры';

  @override
  String get playerAudioTrack => 'Аудиодорожка';

  @override
  String get playerNoSubtitle => 'Без субтитров';

  @override
  String get playerExternalSubtitle => 'Внешние субтитры';

  @override
  String get playerDanmaku => 'Комментарии';

  @override
  String get playerDanmakuHint => 'Отправить комментарий...';

  @override
  String get playerDanmakuSend => 'Отправить';

  @override
  String get playlistTitle => 'Список воспроизведения';

  @override
  String get playlistAdd => 'Добавить видео';

  @override
  String get playlistClear => 'Очистить список';

  @override
  String get playlistClearConfirm => 'Удалить все видео? Это нельзя отменить.';

  @override
  String get playlistEmpty => 'Список пуст';

  @override
  String roomMemberCount(int count) {
    return '$count онлайн';
  }

  @override
  String get roomHost => 'Хост';

  @override
  String get roomMember => 'Участник';

  @override
  String get roomLeave => 'Покинуть комнату';

  @override
  String get roomLeaveConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get roomDisbandConfirm =>
      'Вы хост. Выход распустит комнату. Продолжить?';

  @override
  String get errorNetworkFailed => 'Ошибка сети';

  @override
  String get errorFileNotFound => 'Файл не найден';

  @override
  String get errorSubtitleExtractFailed => 'Ошибка извлечения субтитров';

  @override
  String get errorRoomNotFound => 'Комната не найдена';

  @override
  String get errorNicknameEmpty => 'Никнейм не может быть пустым';

  @override
  String get successJoinRoom => 'Вы успешно вошли в комнату';

  @override
  String get successSubtitleLoaded => 'Субтитры загружены';

  @override
  String get loadingHostVideo => 'Загрузка видео, разделяемого хостом...';

  @override
  String get brightness => 'Яркость';

  @override
  String get volume => 'Громкость';

  @override
  String get sendDanmaku => 'Отправить комментарий...';

  @override
  String get hideChat => 'Скрыть чат';

  @override
  String get showChat => 'Показать чат';

  @override
  String get openVideo => 'Открыть видео';

  @override
  String get fullscreen => 'Полноэкранный режим';

  @override
  String get playbackError => 'Ошибка воспроизведения';

  @override
  String get unknownError => 'Неизвестная ошибка';

  @override
  String get selectOtherVideo => 'Выбрать другое видео';

  @override
  String get retry => 'Повторить';

  @override
  String get noVideo => 'Нет видео';

  @override
  String get tapFolderIconSelectVideo =>
      'Нажмите на иконку папки выше, чтобы выбрать видеофайлы';

  @override
  String get selectVideo => 'Выбрать видео';

  @override
  String get createPlaylistFailed =>
      'Не удалось создать список воспроизведения';

  @override
  String get addVideoFailed => 'Не удалось добавить видео';

  @override
  String get selectVideoFailed => 'Не удалось выбрать видео';

  @override
  String get shareRoomIp => 'Поделиться IP комнаты';

  @override
  String get dissolveRoom => 'Распустить комнату';

  @override
  String get leaveRoom => 'Покинуть комнату';

  @override
  String get shareRoom => 'Поделиться комнатой';

  @override
  String get otherUsersCanJoinRoom =>
      'Другие пользователи могут присоединиться к комнате, используя следующую информацию:';

  @override
  String get close => 'Закрыть';

  @override
  String get exitRoom => 'Выйти из комнаты';

  @override
  String get confirmExitCurrentRoom =>
      'Вы уверены, что хотите выйти из текущей комнаты?';

  @override
  String get cancel => 'Отмена';

  @override
  String get exit => 'Выйти';

  @override
  String get confirmLeaveCurrentRoom =>
      'Вы уверены, что хотите выйти из текущей комнаты?';

  @override
  String get leave => 'Покинуть';

  @override
  String get endRoom => 'Завершить комнату';

  @override
  String get confirmEndRoom => 'Вы уверены, что хотите завершить комнату?';

  @override
  String get roomHasOtherUsersDisconnect => 'В комнате есть';

  @override
  String get users => 'других пользователей, которые будут отключены.';

  @override
  String get cannotOpenLink => 'Невозможно открыть ссылку';

  @override
  String get openLinkFailed => 'Не удалось открыть ссылку';

  @override
  String get currentLatestVersion => 'Вы используете последнюю версию';

  @override
  String get appDescription =>
      'Syncro — это кроссплатформенное приложение для синхронизированного воспроизведения видео, поддерживающее многопользовательское онлайн-синхронизированное просмотр видео. Независимо от того, насколько далеко вы от друзей, вы можете вместе наслаждаться синхронизированным просмотром.';

  @override
  String get checkUpdate => 'Проверить обновления';

  @override
  String get checkForNewVersion => 'Проверить, есть ли новая версия';

  @override
  String get githubOpenSourceUrl => 'GitHub URL исходного кода';

  @override
  String get openSourceLicenseStatement => 'Описание лицензии открытого кода';

  @override
  String get viewUsedOpenSourceLibraries =>
      'Просмотреть используемые библиотеки открытого кода';

  @override
  String get playerNotInitialized => 'Плеер не инициализирован';

  @override
  String get noAvailableAudioTracks => 'Нет доступных аудиодорожек';

  @override
  String get audioTrack => 'Аудиодорожка';

  @override
  String get embeddedSubtitles => 'Встроенные субтитры';

  @override
  String get restoreSubtitle => 'Восстановить субтитры';

  @override
  String get disableSubtitle => 'Отключить субтитры';

  @override
  String get noEmbeddedSubtitles => 'Нет встроенных субтитров';

  @override
  String get externalSubtitlesHostOnly => 'Внешние субтитры (только для хоста)';

  @override
  String get loadExternalSubtitle => 'Загрузить внешние субтитры';

  @override
  String get externalSubtitleSyncedToAllMembers =>
      'Внешние субтитры синхронизированы со всеми участниками';

  @override
  String get subtitle => 'Субтитры';

  @override
  String get fontSize => 'Размер шрифта';

  @override
  String get showBackground => 'Показать фон';

  @override
  String get opacity => 'Прозрачность';

  @override
  String get restoreDefault => 'Восстановить по умолчанию';

  @override
  String get fontColor => 'Цвет шрифта';

  @override
  String get previewEffect => 'Эффект предварительного просмотра';

  @override
  String get subtitlePreviewEffect =>
      'Эффект предварительного просмотра субтитров';

  @override
  String get videoList => 'Список видео';

  @override
  String get loaded => 'Загружено';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      'Все участники комнаты автоматически загрузят эти субтитры';

  @override
  String get canSelectSrtOrAssSubtitleFiles =>
      'Вы можете выбрать файлы субтитров .srt или .ass';

  @override
  String get hostHasNotLoadedExternalSubtitles =>
      'Хост не загрузил внешние субтитры';

  @override
  String get clearSubtitle => 'Очистить субтитры';

  @override
  String get addSubtitle => 'Добавить субтитры';

  @override
  String get clearPlaylist => 'Очистить список воспроизведения';

  @override
  String get confirmClearAllVideos =>
      'Вы уверены, что хотите очистить все видео? Это действие нельзя отменить.';

  @override
  String get clear => 'Очистить';

  @override
  String get add => 'Добавить';

  @override
  String get clearList => 'Очистить список';

  @override
  String get playlist => 'Список воспроизведения';

  @override
  String get addVideo => 'Добавить видео';

  @override
  String get externalSubtitles => 'Внешние субтитры';

  @override
  String get style => 'Стиль';

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
