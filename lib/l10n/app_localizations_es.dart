// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Syncro';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsPlayback => 'Reproducción';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsNetwork => 'Red';

  @override
  String get settingsAutoPlay => 'Reproducción automática';

  @override
  String get settingsAutoPlayDesc =>
      'Reproducir el siguiente vídeo automáticamente';

  @override
  String get settingsHwDecode => 'Decodificación por hardware';

  @override
  String get settingsHwDecodeDesc => 'Usar GPU para acelerar la decodificación';

  @override
  String get settingsDefaultVolume => 'Volumen predeterminado';

  @override
  String get settingsDefaultVolumeDesc => 'Volumen al iniciar';

  @override
  String get settingsDynamicColor => 'Color dinámico';

  @override
  String get settingsDynamicColorDesc => 'Usar color del fondo de pantalla';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Sistema';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutTitle => 'Acerca de Syncro';

  @override
  String get settingsAboutDesc => 'Versión y enlace de código';

  @override
  String get settingsAboutVersion => 'Versión';

  @override
  String get settingsAboutOpenSource => 'Código abierto';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsAutoDiscover => 'Descubrir salas automáticamente';

  @override
  String get settingsAutoDiscoverDesc => 'Buscar salas disponibles en la red';

  @override
  String get navRoom => 'Salas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get playerStyle => 'Estilo';

  @override
  String get chatRoom => 'Chat';

  @override
  String get roomCreated => 'Sala creada. Esperando...';

  @override
  String playlistUpdated(int count) {
    return 'Lista actualizada ($count vídeos)';
  }

  @override
  String get chatHint => 'Escribe un mensaje...';

  @override
  String get homeCreateRoom => 'Crear sala';

  @override
  String get homeJoinRoom => 'Unirse';

  @override
  String get homeRoomCode => 'Código de sala';

  @override
  String get homeRoomCodeHint => 'Introduce el código';

  @override
  String get homeNickname => 'Apodo';

  @override
  String get homeNicknameHint => 'Introduce tu apodo';

  @override
  String get homeSelectVideo => 'Seleccionar vídeo';

  @override
  String get homeNoVideo => 'Sin vídeo';

  @override
  String get homeStart => 'Iniciar';

  @override
  String get homeCancel => 'Cancelar';

  @override
  String get homeConfirm => 'Confirmar';

  @override
  String get playerPlay => 'Reproducir';

  @override
  String get playerPause => 'Pausa';

  @override
  String get playerSubtitle => 'Subtítulos';

  @override
  String get playerAudioTrack => 'Pista de audio';

  @override
  String get playerNoSubtitle => 'Sin subtítulos';

  @override
  String get playerExternalSubtitle => 'Subtítulo externo';

  @override
  String get playerDanmaku => 'Comentarios';

  @override
  String get playerDanmakuHint => 'Enviar comentario...';

  @override
  String get playerDanmakuSend => 'Enviar';

  @override
  String get playlistTitle => 'Lista de reproducción';

  @override
  String get playlistAdd => 'Añadir vídeo';

  @override
  String get playlistClear => 'Limpiar lista';

  @override
  String get playlistClearConfirm =>
      '¿Borrar todos los vídeos? No se puede deshacer.';

  @override
  String get playlistEmpty => 'Lista vacía';

  @override
  String roomMemberCount(int count) {
    return '$count en línea';
  }

  @override
  String get roomHost => 'Anfitrión';

  @override
  String get roomMember => 'Miembro';

  @override
  String get roomLeave => 'Salir de la sala';

  @override
  String get roomLeaveConfirm => '¿Seguro que quieres salir?';

  @override
  String get roomDisbandConfirm =>
      'Eres el anfitrión. Salir disolverá la sala. ¿Continuar?';

  @override
  String get errorNetworkFailed => 'Error de red';

  @override
  String get errorFileNotFound => 'Archivo no encontrado';

  @override
  String get errorSubtitleExtractFailed => 'Error al extraer subtítulos';

  @override
  String get errorRoomNotFound => 'Sala no encontrada';

  @override
  String get errorNicknameEmpty => 'El apodo no puede estar vacío';

  @override
  String get successJoinRoom => 'Sala unida con éxito';

  @override
  String get successSubtitleLoaded => 'Subtítulo cargado';

  @override
  String get loadingHostVideo => 'Cargando vídeo compartido del anfitrión...';

  @override
  String get brightness => 'Brillo';

  @override
  String get volume => 'Volumen';

  @override
  String get sendDanmaku => 'Enviar comentario...';

  @override
  String get hideChat => 'Ocultar chat';

  @override
  String get showChat => 'Mostrar chat';

  @override
  String get openVideo => 'Abrir vídeo';

  @override
  String get fullscreen => 'Pantalla completa';

  @override
  String get playbackError => 'Error de reproducción';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get selectOtherVideo => 'Seleccionar otro vídeo';

  @override
  String get retry => 'Reintentar';

  @override
  String get noVideo => 'Sin vídeo';

  @override
  String get tapFolderIconSelectVideo =>
      'Toca el icono de carpeta arriba para seleccionar archivos de vídeo';

  @override
  String get selectVideo => 'Seleccionar vídeo';

  @override
  String get createPlaylistFailed => 'Error al crear la lista de reproducción';

  @override
  String get addVideoFailed => 'Error al añadir el vídeo';

  @override
  String get selectVideoFailed => 'Error al seleccionar el vídeo';

  @override
  String get shareRoomIp => 'Compartir IP de la sala';

  @override
  String get dissolveRoom => 'Disolver sala';

  @override
  String get leaveRoom => 'Salir de la sala';

  @override
  String get shareRoom => 'Compartir sala';

  @override
  String get otherUsersCanJoinRoom =>
      'Otros usuarios pueden unirse a la sala con la siguiente información:';

  @override
  String get close => 'Cerrar';

  @override
  String get exitRoom => 'Salir de la sala';

  @override
  String get confirmExitCurrentRoom =>
      '¿Seguro que quieres salir de la sala actual?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exit => 'Salir';

  @override
  String get confirmLeaveCurrentRoom =>
      '¿Seguro que quieres salir de la sala actual?';

  @override
  String get leave => 'Salir';

  @override
  String get endRoom => 'Terminar sala';

  @override
  String get confirmEndRoom => '¿Seguro que quieres terminar la sala?';

  @override
  String get roomHasOtherUsersDisconnect => 'Hay';

  @override
  String get users => 'otros usuarios en la sala que serán desconectados.';

  @override
  String get cannotOpenLink => 'No se puede abrir el enlace';

  @override
  String get openLinkFailed => 'Error al abrir el enlace';

  @override
  String get currentLatestVersion => 'Estás usando la versión más reciente';

  @override
  String get appDescription =>
      'Syncro es una aplicación de reproducción de vídeo sincronizada multiplataforma que admite la visualización de vídeo sincronizada en línea para múltiples usuarios. No importa cuán lejos estés de tus amigos, puedes disfrutar juntos de una experiencia de visualización sincronizada.';

  @override
  String get checkUpdate => 'Comprobar actualizaciones';

  @override
  String get checkForNewVersion => 'Comprobar si hay una nueva versión';

  @override
  String get githubOpenSourceUrl => 'URL de GitHub del código abierto';

  @override
  String get openSourceLicenseStatement =>
      'Declaración de licencia de código abierto';

  @override
  String get viewUsedOpenSourceLibraries =>
      'Ver bibliotecas de código abierto utilizadas';

  @override
  String get playerNotInitialized => 'Reproductor no inicializado';

  @override
  String get noAvailableAudioTracks => 'No hay pistas de audio disponibles';

  @override
  String get audioTrack => 'Pista de audio';

  @override
  String get embeddedSubtitles => 'Subtítulos incrustados';

  @override
  String get restoreSubtitle => 'Restaurar subtítulos';

  @override
  String get disableSubtitle => 'Desactivar subtítulos';

  @override
  String get noEmbeddedSubtitles => 'No hay subtítulos incrustados';

  @override
  String get externalSubtitlesHostOnly => 'Subtítulo externo (solo anfitrión)';

  @override
  String get loadExternalSubtitle => 'Cargar subtítulo externo';

  @override
  String get externalSubtitleSyncedToAllMembers =>
      'Subtítulo externo sincronizado a todos los miembros';

  @override
  String get subtitle => 'Subtítulo';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String get showBackground => 'Mostrar fondo';

  @override
  String get opacity => 'Opacidad';

  @override
  String get restoreDefault => 'Restaurar valores por defecto';

  @override
  String get fontColor => 'Color de fuente';

  @override
  String get previewEffect => 'Efecto de vista previa';

  @override
  String get subtitlePreviewEffect => 'Efecto de vista previa de subtítulos';

  @override
  String get videoList => 'Lista de vídeos';

  @override
  String get loaded => 'Cargado';

  @override
  String get allRoomMembersWillAutomaticallyLoadThisSubtitle =>
      'Todos los miembros de la sala cargarán automáticamente este subtítulo';

  @override
  String get canSelectSrtOrAssSubtitleFiles =>
      'Puedes seleccionar archivos de subtítulos .srt o .ass';

  @override
  String get hostHasNotLoadedExternalSubtitles =>
      'El anfitrión no ha cargado subtítulos externos';

  @override
  String get clearSubtitle => 'Limpiar subtítulos';

  @override
  String get addSubtitle => 'Añadir subtítulo';

  @override
  String get clearPlaylist => 'Limpiar lista de reproducción';

  @override
  String get confirmClearAllVideos =>
      '¿Seguro que quieres limpiar todos los vídeos? Esta acción no se puede deshacer.';

  @override
  String get clear => 'Limpiar';

  @override
  String get add => 'Añadir';

  @override
  String get clearList => 'Limpiar lista';

  @override
  String get playlist => 'Lista de reproducción';

  @override
  String get addVideo => 'Añadir vídeo';

  @override
  String get externalSubtitles => 'Subtítulos externos';

  @override
  String get style => 'Estilo';

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
