// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsPlayback => 'Lecture';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsNetwork => 'Réseau';

  @override
  String get settingsAutoPlay => 'Lecture auto';

  @override
  String get settingsAutoPlayDesc => 'Passer à la vidéo suivante';

  @override
  String get settingsHwDecode => 'Décodage matériel';

  @override
  String get settingsHwDecodeDesc =>
      'Utiliser le GPU pour accélérer le décodage';

  @override
  String get settingsDefaultVolume => 'Volume par défaut';

  @override
  String get settingsDefaultVolumeDesc => 'Volume au démarrage';

  @override
  String get settingsDynamicColor => 'Couleur dynamique';

  @override
  String get settingsDynamicColorDesc => 'Utiliser la couleur du fond d\'écran';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Système';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutTitle => 'À propos de Syncro';

  @override
  String get settingsAboutDesc => 'Version et code source';

  @override
  String get settingsAboutVersion => 'Version';

  @override
  String get settingsAboutOpenSource => 'Code source';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeSystem => 'Système';

  @override
  String get settingsAutoDiscover => 'Découverte auto';

  @override
  String get settingsAutoDiscoverDesc => 'Rechercher les salles disponibles';

  @override
  String get navRoom => 'Salles';

  @override
  String get navProfile => 'Profil';

  @override
  String get playerStyle => 'Style';

  @override
  String get chatRoom => 'Chat';

  @override
  String get roomCreated => 'Salle créée. En attente...';

  @override
  String playlistUpdated(int count) {
    return 'Liste mise à jour ($count vidéos)';
  }

  @override
  String get chatHint => 'Tapez un message...';

  @override
  String get homeCreateRoom => 'Créer une salle';

  @override
  String get homeJoinRoom => 'Rejoindre';

  @override
  String get homeRoomCode => 'Code de salle';

  @override
  String get homeRoomCodeHint => 'Entrez le code';

  @override
  String get homeNickname => 'Pseudo';

  @override
  String get homeNicknameHint => 'Entrez votre pseudo';

  @override
  String get homeSelectVideo => 'Sélectionner une vidéo';

  @override
  String get homeNoVideo => 'Aucune vidéo';

  @override
  String get homeStart => 'Démarrer';

  @override
  String get homeCancel => 'Annuler';

  @override
  String get homeConfirm => 'Confirmer';

  @override
  String get playerPlay => 'Lecture';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerSubtitle => 'Sous-titres';

  @override
  String get playerAudioTrack => 'Piste audio';

  @override
  String get playerNoSubtitle => 'Sans sous-titres';

  @override
  String get playerExternalSubtitle => 'Sous-titre externe';

  @override
  String get playerDanmaku => 'Commentaires';

  @override
  String get playerDanmakuHint => 'Envoyer un commentaire...';

  @override
  String get playerDanmakuSend => 'Envoyer';

  @override
  String get playlistTitle => 'Liste de lecture';

  @override
  String get playlistAdd => 'Ajouter';

  @override
  String get playlistClear => 'Vider la liste';

  @override
  String get playlistClearConfirm =>
      'Vider toutes les vidéos ? Impossible d\'annuler.';

  @override
  String get playlistEmpty => 'Liste vide';

  @override
  String roomMemberCount(int count) {
    return '$count en ligne';
  }

  @override
  String get roomHost => 'Hôte';

  @override
  String get roomMember => 'Membre';

  @override
  String get roomLeave => 'Quitter';

  @override
  String get roomLeaveConfirm => 'Voulez-vous vraiment quitter ?';

  @override
  String get roomDisbandConfirm =>
      'Vous êtes l\'hôte. Partir dissoudra la salle. Continuer ?';

  @override
  String get errorNetworkFailed => 'Échec de la connexion réseau';

  @override
  String get errorFileNotFound => 'Fichier introuvable';

  @override
  String get errorSubtitleExtractFailed =>
      'Échec de l\'extraction des sous-titres';

  @override
  String get errorRoomNotFound => 'Salle introuvable';

  @override
  String get errorNicknameEmpty => 'Le pseudo ne peut pas être vide';

  @override
  String get successJoinRoom => 'Salle rejointe avec succès';

  @override
  String get successSubtitleLoaded => 'Sous-titre chargé';

  @override
  String get loadingHostVideo =>
      'Chargement de la vidéo partagée par l\'hôte...';

  @override
  String get brightness => 'Luminosité';

  @override
  String get volume => 'Volume';

  @override
  String get sendDanmaku => 'Envoyer un commentaire...';

  @override
  String get hideChat => 'Cacher le chat';

  @override
  String get showChat => 'Afficher le chat';

  @override
  String get openVideo => 'Ouvrir la vidéo';

  @override
  String get fullscreen => 'Plein écran';

  @override
  String get playbackError => 'Erreur de lecture';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get selectOtherVideo => 'Sélectionner une autre vidéo';

  @override
  String get retry => 'Réessayer';

  @override
  String get noVideo => 'Aucune vidéo';

  @override
  String get tapFolderIconSelectVideo =>
      'Tapez l\'icône dossier ci-dessus pour sélectionner des vidéos';

  @override
  String get selectVideo => 'Sélectionner une vidéo';

  @override
  String get createPlaylistFailed => 'Échec de création de la liste';

  @override
  String get addVideoFailed => 'Échec d\'ajout de la vidéo';

  @override
  String get selectVideoFailed => 'Échec de sélection de la vidéo';

  @override
  String get shareRoomIp => 'Partager l\'IP de la salle';

  @override
  String get dissolveRoom => 'Dissoudre la salle';

  @override
  String get leaveRoom => 'Quitter la salle';

  @override
  String get shareRoom => 'Partager la salle';

  @override
  String get otherUsersCanJoinRoom =>
      'Les autres utilisateurs peuvent rejoindre via :';

  @override
  String get close => 'Fermer';

  @override
  String get exitRoom => 'Quitter la salle';

  @override
  String get confirmExitCurrentRoom =>
      'Voulez-vous vraiment quitter la salle ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get exit => 'Quitter';

  @override
  String get confirmLeaveCurrentRoom =>
      'Voulez-vous vraiment quitter la salle ?';

  @override
  String get leave => 'Quitter';

  @override
  String get endRoom => 'Terminer la salle';

  @override
  String get confirmEndRoom => 'Voulez-vous vraiment terminer la salle ?';

  @override
  String get roomHasOtherUsersDisconnect => 'Il y a';

  @override
  String get users =>
      'autres utilisateurs dans la salle qui seront déconnectés.';

  @override
  String get cannotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get openLinkFailed => 'Échec d\'ouverture du lien';

  @override
  String get currentLatestVersion => 'Vous utilisez la dernière version';

  @override
  String get appDescription =>
      'Syncro est une application de lecture vidéo synchronisée multiplateforme qui prend en charge la visionnage vidéo synchronisé en ligne pour plusieurs utilisateurs. Peu importe à quelle distance vous et vos amis êtes, vous pouvez profiter ensemble d\'une expérience de visionnage synchronisée.';

  @override
  String get checkUpdate => 'Vérifier les mises à jour';

  @override
  String get checkForNewVersion => 'Vérifier s\'il y a une nouvelle version';

  @override
  String get githubOpenSourceUrl => 'URL GitHub du code source';

  @override
  String get openSourceLicenseStatement => 'Déclaration de licence open source';

  @override
  String get viewUsedOpenSourceLibraries =>
      'Voir les bibliothèques open source utilisées';

  @override
  String get playerNotInitialized => 'Lecteur non initialisé';

  @override
  String get noAvailableAudioTracks => 'Aucune piste audio disponible';

  @override
  String get audioTrack => 'Piste audio';

  @override
  String get embeddedSubtitles => 'Sous-titres intégrés';

  @override
  String get restoreSubtitle => 'Restaurer les sous-titres';

  @override
  String get disableSubtitle => 'Désactiver les sous-titres';

  @override
  String get noEmbeddedSubtitles => 'Aucun sous-titre intégré';

  @override
  String get externalSubtitlesHostOnly =>
      'Sous-titre externe (hôte uniquement)';

  @override
  String get loadExternalSubtitle => 'Charger un sous-titre externe';

  @override
  String get externalSubtitleSyncedToAllMembers =>
      'Sous-titre externe synchronisé sur tous les membres';

  @override
  String get subtitle => 'Sous-titre';

  @override
  String get fontSize => 'Taille de police';

  @override
  String get showBackground => 'Afficher l\'arrière-plan';

  @override
  String get opacity => 'Opacité';

  @override
  String get restoreDefault => 'Réinitialiser';

  @override
  String get fontColor => 'Couleur de police';

  @override
  String get previewEffect => 'Effet d\'aperçu';

  @override
  String get subtitlePreviewEffect => 'Effet d\'aperçu des sous-titres';

  @override
  String get videoList => 'Liste de vidéos';

  @override
  String get loaded => 'Chargé';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      'Tous les membres de la salle chargeront automatiquement ce sous-titre';

  @override
  String get canSelectSrtOrAssSubtitleFiles =>
      'Vous pouvez sélectionner des fichiers .srt ou .ass';

  @override
  String get hostHasNotLoadedExternalSubtitles =>
      'L\'hôte n\'a pas chargé de sous-titre externe';

  @override
  String get clearSubtitle => 'Effacer les sous-titres';

  @override
  String get addSubtitle => 'Ajouter un sous-titre';

  @override
  String get clearPlaylist => 'Vider la liste de lecture';

  @override
  String get confirmClearAllVideos =>
      'Voulez-vous vraiment vider toutes les vidéos ? Cette action est irréversible.';

  @override
  String get clear => 'Effacer';

  @override
  String get add => 'Ajouter';

  @override
  String get clearList => 'Vider la liste';

  @override
  String get playlist => 'Liste de lecture';

  @override
  String get addVideo => 'Ajouter une vidéo';

  @override
  String get externalSubtitles => 'Sous-titres externes';

  @override
  String get style => 'Style';

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
