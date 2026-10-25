// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appTitle => 'DigiCard App';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navDecks => 'Barallas';

  @override
  String get viewerZoomHint => 'Belisca ou toca dúas veces para ampliar';

  @override
  String viewerPageOf(int index, int total) {
    return '$index / $total';
  }

  @override
  String get actionClear => 'Limpar';

  @override
  String get actionDone => 'Feito';

  @override
  String multiSelectSearchHint(String facet) {
    return 'Buscar $facet';
  }

  @override
  String multiSelectCount(int count) {
    return '$count seleccionados';
  }

  @override
  String multiSelectNoMatch(String query) {
    return 'Nada coincide con «$query»';
  }

  @override
  String get releasePreviewBadge => 'AVANCE';

  @override
  String get syncSettingUp => 'Preparando a túa biblioteca de cartas';

  @override
  String get syncRederiving => 'Actualizando as túas cartas ás novas regras';

  @override
  String get syncFailedTitle =>
      'Non se puido descargar a base de datos de cartas';

  @override
  String get syncRederivingDetail =>
      'Relendo as cartas que xa tes. Non se está a descargar nada.';

  @override
  String get syncOfflineNote =>
      'A lista completa de cartas gárdase no teu dispositivo, así que a biblioteca e o construtor de barallas funcionan sen conexión.';

  @override
  String get actionTryAgain => 'Tentar de novo';

  @override
  String get syncErrorGeneric => 'Algo foi mal.';

  @override
  String get syncErrorOffline =>
      'Sen conexión a internet. Conéctate e téntao de novo: a base de datos de cartas só se descarga unha vez.';

  @override
  String get syncStageChecking => 'Buscando actualizacións de cartas';

  @override
  String get syncStageReleases => 'Obtendo expansións';

  @override
  String get syncStageDownloading => 'Descargando datos de cartas';

  @override
  String get syncStageParsing => 'Lendo cartas';

  @override
  String get syncStageStoring => 'Gardando cartas';

  @override
  String get syncStageIndexing => 'Creando o índice de busca';

  @override
  String get syncStageComplete => 'Todo ao día';

  @override
  String get syncStageFailed => 'A sincronización fallou';

  @override
  String syncDetailExpansions(int completed, int total) {
    return '$completed de $total expansións';
  }

  @override
  String syncDetailMegabytes(String received, String total) {
    return '$received de $total MB';
  }

  @override
  String syncDetailCards(int count) {
    return '$count cartas';
  }

  @override
  String syncDetailPreview(String pack) {
    return 'Avance: $pack';
  }

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get libraryDatabaseTooltip => 'Base de datos de cartas';

  @override
  String get libraryReleasesError => 'Non se puideron cargar as expansións';

  @override
  String get librarySearchHint => 'Buscar cartas, efectos, trazos';

  @override
  String librarySectionSubtitle(int sets, int cards) {
    return '$sets coleccións · $cards cartas';
  }

  @override
  String get databaseTitle => 'Base de datos de cartas';

  @override
  String get databaseCardsStored => 'Cartas gardadas';

  @override
  String get databasePublished => 'Datos publicados';

  @override
  String get databaseLastDownloaded => 'Última descarga';

  @override
  String get databaseUnknown => 'descoñecido';

  @override
  String get databaseNever => 'nunca';

  @override
  String databaseSources(String source) {
    return 'Os datos das cartas veñen da API de Heroicc, máis $source para as coleccións que Heroicc aínda non publicou. As coleccións que se están a desvelar aparecen soas; ao buscar actualizacións vólvese descargar a lista completa cando Heroicc publica unha nova.';
  }

  @override
  String get databaseCredits => 'Fontes de datos e créditos';

  @override
  String get databaseCheckUpdates => 'Buscar actualizacións';

  @override
  String get cardUpdateTitle => 'Hai datos de cartas novos';

  @override
  String get cardUpdateMessage =>
      'Heroicc publicou unha actualización da base de datos de cartas. Pode incluír coleccións que aquí seguen marcadas como AVANCE.';

  @override
  String get cardUpdateAction => 'Actualizar';

  @override
  String get cardUpdateDismiss => 'Agora non';

  @override
  String appUpdateTitle(String version) {
    return 'DigiCard App $version dispoñible';
  }

  @override
  String get appUpdateInstallHint =>
      'A primeira vez, Android pedirache que permitas instalar apps desde DigiCard App.';

  @override
  String get appUpdateWhereToGet => 'Descárgaa desde GitHub:';

  @override
  String get appUpdateNotes => 'Novidades';

  @override
  String get appUpdateDismiss => 'Agora non';

  @override
  String get appUpdateInstall => 'Instalar';

  @override
  String get appUpdateRetry => 'Tentar de novo';

  @override
  String appUpdateDownloading(int percent) {
    return 'Descargando… $percent %';
  }

  @override
  String get appUpdateFailedDownload =>
      'A descarga non rematou. Comproba a conexión e téntao de novo.';

  @override
  String get appUpdateFailedCorrupt =>
      'A descarga chegou danada e descartouse. Téntao de novo.';

  @override
  String get appUpdateFailedNoApk =>
      'Esta versión non trae un APK para este dispositivo.';

  @override
  String get appUpdateFailedInstaller =>
      'Non se puido abrir o instalador de Android.';

  @override
  String get backupMenu => 'Copia de seguridade';

  @override
  String get backupExport => 'Gardar copia de seguridade';

  @override
  String get backupRestore => 'Restaurar copia de seguridade';

  @override
  String get backupExported => 'Copia de seguridade gardada.';

  @override
  String get backupExportFailed => 'Non se puido gardar a copia.';

  @override
  String get backupNotABackup =>
      'Ese ficheiro non é unha copia de seguridade de DigiCard App.';

  @override
  String get backupTooNew =>
      'Esa copia fíxoa unha versión máis nova da app. Actualiza a app para restaurala.';

  @override
  String get backupReadFailed => 'Non se puido ler o ficheiro.';

  @override
  String get backupRestoreTitle => 'Restaurar esta copia?';

  @override
  String backupRestoreBody(int decks, int lists) {
    String _temp0 = intl.Intl.pluralLogic(
      decks,
      locale: localeName,
      other: '$decks barallas',
      one: '1 baralla',
    );
    String _temp1 = intl.Intl.pluralLogic(
      lists,
      locale: localeName,
      other: '$lists listas de imprescindibles',
      one: '1 lista de imprescindibles',
    );
    return 'Ten $_temp0 e $_temp1. Engádense ao que xa tes: non se borra nada, e sáltanse as barallas que xa teñas exactamente iguais.';
  }

  @override
  String get backupRestoreAction => 'Restaurar';

  @override
  String backupRestored(int added, int skipped, int lists) {
    return 'Barallas engadidas: $added · xa estaban: $skipped · listas de imprescindibles actualizadas: $lists';
  }

  @override
  String get backupRestoreFailed =>
      'Non se puido restaurar a copia. Non se cambiou nada.';

  @override
  String get oddsTitle => 'Probabilidades de roubo';

  @override
  String oddsSubtitle(int cards) {
    return 'Probabilidade de ter polo menos unha copia entre as $cards cartas roubadas á man';
  }

  @override
  String oddsNeedsFullDeck(int size) {
    return 'As probabilidades calcúlanse coa baralla principal completa de $size cartas.';
  }

  @override
  String get oddsGoingFirst => 'Vas primeiro';

  @override
  String get oddsGoingSecond => 'Vas segundo';

  @override
  String get oddsOpeningHand => 'Man inicial';

  @override
  String oddsTurn(int turn) {
    return 'Quenda $turn';
  }

  @override
  String get oddsByGroup => 'POR GRUPO';

  @override
  String get oddsByCard => 'POR CARTA';

  @override
  String get restrictionsTitle => 'A lista de restricións cambiou';

  @override
  String restrictionsAffects(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count das túas barallas',
      one: '1 das túas barallas',
    );
    return 'Afecta a $_temp0.';
  }

  @override
  String restrictionsBanned(String card, int copies) {
    return '$card: agora prohibida (levas $copies)';
  }

  @override
  String restrictionsLimited(String card, int limit, int copies) {
    return '$card: agora limitada a $limit (levas $copies)';
  }

  @override
  String restrictionsFreed(String card) {
    return '$card: xa non está limitada';
  }

  @override
  String restrictionsRaised(String card, int limit) {
    return '$card: agora permítense $limit copias';
  }

  @override
  String restrictionsPairBanned(String card, String partner) {
    return '$card xa non pode ir na mesma baralla ca $partner';
  }

  @override
  String restrictionsPairLifted(String card, String partner) {
    return '$card volve poder ir na mesma baralla ca $partner';
  }

  @override
  String get restrictionsDismiss => 'Entendido';

  @override
  String get restrictionsShowDecks => 'Ver barallas';

  @override
  String get exportTabQr => 'QR';

  @override
  String get exportQrHint =>
      'Escanéao desde DigiCard App en Barallas → Importar → Escanear QR. Gardado na galería, pódese enviar como imaxe e ler con \"QR desde imaxe\".';

  @override
  String get qrScan => 'Escanear QR';

  @override
  String get qrFromImage => 'QR desde imaxe';

  @override
  String get qrScanTitle => 'Escanear o QR dunha baralla';

  @override
  String get qrScanHint => 'Apunta a cámara ao código QR dunha baralla.';

  @override
  String get qrScanNoPermission =>
      'DigiCard App necesita a cámara para escanear o código. Podes permitilo nos axustes do sistema ou ler o código desde unha imaxe.';

  @override
  String get qrScanUnavailable => 'Non se puido abrir a cámara.';

  @override
  String get qrNoCodeInImage => 'Non hai ningún código QR nesa imaxe.';

  @override
  String get qrImageFailed => 'Non se puido ler a imaxe.';

  @override
  String get searchHint => 'Nome, efecto, trazo…';

  @override
  String get searchFailed => 'A busca fallou';

  @override
  String get searchNoCards => 'Non se atoparon cartas';

  @override
  String get searchNoCardsFiltered => 'Proba a quitar algún filtro.';

  @override
  String get searchNoCardsPlain => 'Nada coincide con esa busca.';

  @override
  String get searchClearFilters => 'Quitar filtros';

  @override
  String get searchEndOfResults => 'Fin dos resultados';

  @override
  String get searchSearching => 'Buscando…';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas',
      one: '$count carta',
    );
    return '$_temp0';
  }

  @override
  String get searchSortTooltip => 'Ordenar';

  @override
  String searchRemoveFacet(String facet) {
    return 'Quitar $facet';
  }

  @override
  String get searchClearAll => 'Quitar todo';

  @override
  String get releaseFallbackTitle => 'Expansión';

  @override
  String releaseCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas',
      one: '$count carta',
    );
    return '$_temp0';
  }

  @override
  String get releasePromosOnly => 'Só promos';

  @override
  String releaseAltArts(int count) {
    return 'Ilustr. alt. +$count';
  }

  @override
  String get releaseCardsError => 'Non se puideron cargar as cartas';

  @override
  String get releaseEmptyTitle => 'Non hai cartas nesta expansión';

  @override
  String get releaseEmptyMessage =>
      'Pode que a lista de cartas aínda non se publicase.';

  @override
  String releasePreviewNotice(String source) {
    return 'Colección de avance. Esta expansión aínda non está na base de datos principal, así que as súas cartas veñen de $source e aínda se están a corrixir. Pode que falte algunha, e non hai nin rulings nin ilustracións alternativas. Desliza cara abaixo para buscar cartas recén reveladas.';
  }

  @override
  String releasePromoPreviewNotice(String source) {
    return 'Promos de avance. Estas promos aínda non están na base de datos principal, así que veñen de $source e aínda se están a corrixir. Sairán desta lista cando a base de datos principal as teña. Desliza cara abaixo para buscar promos novas.';
  }

  @override
  String releaseRefreshedNothing(String source) {
    return 'Non hai cartas novas: esta colección está tan completa como a ten $source.';
  }

  @override
  String releasePromosRefreshedNothing(String source) {
    return 'Non hai promos novas: $source non ten ningunha alén destas.';
  }

  @override
  String releaseRefreshedUpdated(String source) {
    return 'Actualizada desde $source.';
  }

  @override
  String get colorRed => 'Vermello';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlack => 'Negro';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorWhite => 'Branco';

  @override
  String get categoryDigimon => 'Digimon';

  @override
  String get categoryTamer => 'Tamer';

  @override
  String get categoryOption => 'Option';

  @override
  String get categoryDigiEgg => 'Digi-Egg';

  @override
  String get releaseGroupBooster => 'Sobres de expansión';

  @override
  String get releaseGroupEx => 'Boosters EX';

  @override
  String get releaseGroupStarter => 'Barallas de inicio';

  @override
  String get releaseGroupAdvanceDeck => 'Boosters avanzados';

  @override
  String get releaseGroupLimited => 'Packs de edición limitada';

  @override
  String get releaseGroupResurgence => 'Boosters Resurgence';

  @override
  String get releaseGroupPromo => 'Cartas promocionais';

  @override
  String get releaseGroupOther => 'Outros produtos';

  @override
  String get sortCardNumber => 'Número de carta';

  @override
  String get sortNameAsc => 'Nome A-Z';

  @override
  String get sortCostAsc => 'Custo, de menor a maior';

  @override
  String get sortCostDesc => 'Custo, de maior a menor';

  @override
  String get sortDpDesc => 'DP, de maior a menor';

  @override
  String get sortLevelAsc => 'Nivel, de menor a maior';

  @override
  String get matchAnyOf => 'Calquera de';

  @override
  String get matchAllOf => 'Todas de';

  @override
  String get matchExactly => 'Exactamente';

  @override
  String get limitationRestricted => 'Restrinxida';

  @override
  String get limitationBanned => 'Prohibida';

  @override
  String get limitationBannedPair => 'Parella prohibida';

  @override
  String get limitationUnrestricted => 'Sen restrición';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get filtersReset => 'Restablecer';

  @override
  String get filterColor => 'Cor';

  @override
  String get filterCardType => 'Tipo de carta';

  @override
  String get filterLevel => 'Nivel';

  @override
  String filterLevelValue(int level) {
    return 'Nv.$level';
  }

  @override
  String get filterPlayCost => 'Custo de xogo / uso';

  @override
  String get filterDigivolveCost => 'Custo de dixievolución';

  @override
  String get filterDp => 'DP';

  @override
  String get filterKeyword => 'Palabra clave';

  @override
  String get filterRarity => 'Rareza';

  @override
  String get filterAttribute => 'Atributo';

  @override
  String get filterForm => 'Forma';

  @override
  String get filterTrait => 'Trazo';

  @override
  String get filterTraits => 'Trazos';

  @override
  String get filterExpansion => 'Expansión';

  @override
  String get filterExpansions => 'Expansións';

  @override
  String get filterNarrowNote =>
      'As cartas ACE, dual e token acoutan os tipos que estean seleccionados.';

  @override
  String get filterAltArts => 'Amosar ilustracións alternativas';

  @override
  String get filterAltArtsSubtitle =>
      'Lista cada impresión en vez dunha carta por número';

  @override
  String get filterRestrictedOnly => 'Só cartas restrinxidas';

  @override
  String get filterRestrictedOnlySubtitle =>
      'Cartas limitadas ou prohibidas pola lista oficial';

  @override
  String get filterAny => 'Calquera';

  @override
  String get filterShowResults => 'Ver resultados';

  @override
  String filterShowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ver $count cartas',
      one: 'Ver 1 carta',
    );
    return '$_temp0';
  }

  @override
  String facetLevels(String levels) {
    return 'Nv. $levels';
  }

  @override
  String get facetCost => 'Custo';

  @override
  String get facetDigivolve => 'Dixievol.';

  @override
  String get facetDp => 'DP';

  @override
  String get facetDualCard => 'Carta dual';

  @override
  String get facetToken => 'Token';

  @override
  String get facetAlternateArts => 'Ilustracións alternativas';

  @override
  String facetRangeExact(String label, int value) {
    return '$label $value';
  }

  @override
  String facetRangeBetween(String label, int min, int max) {
    return '$label $min-$max';
  }

  @override
  String facetRangeFrom(String label, int min) {
    return '$label $min+';
  }

  @override
  String facetRangeUpTo(String label, int max) {
    return '$label ≤$max';
  }

  @override
  String get cardLoadError => 'Non se puido cargar a carta';

  @override
  String get cardNotFound => 'Carta non atopada';

  @override
  String get cardNotFoundMessage =>
      'Pode que se quitase na última actualización de cartas.';

  @override
  String get cardAddToDeck => 'Engadir a unha baralla';

  @override
  String get cardEffect => 'Efecto';

  @override
  String get cardSecurityEffect => 'Efecto de seguridade';

  @override
  String get cardInheritedEffect => 'Efecto herdado';

  @override
  String get cardInheritedEffects => 'Efectos herdados';

  @override
  String get cardOriginalArt => 'Ilustración orixinal';

  @override
  String cardAlternateArt(int number) {
    return 'Ilustración alternativa $number';
  }

  @override
  String cardBlock(int block) {
    return 'Bloque $block';
  }

  @override
  String get cardDualBadge => 'Carta dual';

  @override
  String get cardLevel => 'Nivel';

  @override
  String get cardPlayCost => 'Custo de xogo';

  @override
  String get cardUseCost => 'Custo de uso';

  @override
  String get cardDp => 'DP';

  @override
  String get cardForm => 'Forma';

  @override
  String get cardAttribute => 'Atributo';

  @override
  String cardNotTournamentLegal(String limitation) {
    return '$limitation: non é legal en torneo';
  }

  @override
  String cardLimitedTo(String limitation, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copias',
      one: '$count copia',
    );
    return '$limitation a $_temp0';
  }

  @override
  String get cardPairBanTitle => 'Parella prohibida: xogables, pero non xuntas';

  @override
  String cardPairBanOne(String partner) {
    return 'Unha baralla con esta carta non pode levar ademais $partner.';
  }

  @override
  String cardPairBanMany(String partners) {
    return 'Unha baralla con esta carta non pode levar ademais ningunha destas: $partners.';
  }

  @override
  String cardRaisedCopyLimit(int limit) {
    return 'Unha baralla pode levar ata $limit copias desta carta.';
  }

  @override
  String get cardDigivolveTitle => 'Requisitos de dixievolución';

  @override
  String cardDigivolveFromText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'As últimas $count condicións están impresas na caixa de efecto da carta, non na de custo.',
      one:
          'A última condición está impresa na caixa de efecto da carta, non na de custo.',
    );
    return '$_temp0';
  }

  @override
  String get cardLevelUnpublished => 'Nivel aínda sen publicar';

  @override
  String get cardConditionUnpublished => 'Condición aínda sen publicar';

  @override
  String cardCostValue(int cost) {
    return 'Custo $cost';
  }

  @override
  String cardOtherFace(String category) {
    return 'Outra cara: $category';
  }

  @override
  String get cardErrata => 'Errata';

  @override
  String cardErrataDated(String date) {
    return 'Errata · $date';
  }

  @override
  String get cardErrataPrinted => 'Impreso';

  @override
  String get cardErrataShouldRead => 'Debe lerse';

  @override
  String get cardFoundIn => 'Aparece en';

  @override
  String cardRulings(int count) {
    return 'Rulings ($count)';
  }

  @override
  String get cardPreviewNotice =>
      'Carta de avance dunha colección que aínda non está na base de datos principal. O seu texto vén da comunidade e pode cambiar, e aquí non ten nin rulings nin ilustracións alternativas.';

  @override
  String get cardPromoPreviewNotice =>
      'Promo de avance que aínda non está na base de datos principal. O seu texto vén da comunidade e pode cambiar, e aquí non ten nin rulings nin ilustracións alternativas.';

  @override
  String digivolveLevel(int level) {
    return 'Nv.$level';
  }

  @override
  String digivolveAppmonGrade(String grade) {
    return 'Appmon $grade';
  }

  @override
  String get digivolveAnyColor => 'de calquera cor';

  @override
  String get creditsTitle => 'Datos e créditos';

  @override
  String get creditsArtworkTitle => 'Ilustracións e texto das cartas';

  @override
  String get creditsArtworkBody =>
      'Todas as imaxes de cartas, os seus textos e as ilustracións relacionadas son propiedade intelectual de © Akiyoshi Hongo, Toei Animation e © BANDAI. Aplícanse os seus dereitos de autor, marcas rexistradas e dereitos afíns.\n\nDigiCard App é unha ferramenta feita por afeccionados. Non está afiliada a Bandai Namco Entertainment nin a Toei Animation, nin conta co seu respaldo ou vinculación.';

  @override
  String get creditsHeroiTitle => 'Datos das cartas: Heroicc';

  @override
  String get creditsHeroiBody =>
      'A base de datos de cartas, a lista de expansións e os rulings veñen da API de Heroicc.\n\nDigiCard App non está afiliada a Heroicc, nin conta co seu respaldo ou vinculación. O contido orixinal achegado por Heroicc —é dicir, a parte que non pertence a Akiyoshi Hongo, Toei Animation ou BANDAI— úsase baixo a licenza Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).';

  @override
  String creditsPreviewTitle(String source) {
    return 'Coleccións de avance: $source';
  }

  @override
  String get creditsPreviewBody =>
      'As coleccións que a API de Heroicc aínda non publicou énchense desde a API pública de digimoncard.io, para poder buscar as súas cartas e construír con elas desde o principio. Esas coleccións aparecen marcadas como AVANCE alá onde saian.\n\nDigiCard App non está afiliada a digimoncard.io, nin conta co seu respaldo ou vinculación. Os datos de avance mantenos a comunidade e aínda cambian: conta con que falten cousas e se corrixan, e comproba na carta impresa todo o que importe.';

  @override
  String get creditsImagesTitle => 'Que fai esta app coas imaxes das cartas';

  @override
  String get creditsImagesBody =>
      'As imaxes das cartas amósanse e expórtanse enteiras. A app non recorta nin tapa a liña de copyright nin o nome do artista, e non engade ningunha marca de auga, selo nin logotipo propio á imaxe dunha carta.';

  @override
  String get creditsCachingTitle => 'Caché';

  @override
  String get creditsCachingBody =>
      'A lista completa de cartas descárgase unha vez e gárdase no teu dispositivo, así que navegar e construír barallas non fai ningunha petición máis. As dúas APIs piden que se use caché en vez de volver pedir os datos, e que quen chama se identifique; esta app envía o seu propio User-Agent en cada petición.';

  @override
  String creditsFooter(String source) {
    return 'Imaxes e textos das cartas © Akiyoshi Hongo, Toei Animation, © BANDAI. Datos das cartas de Heroicc e $source. DigiCard App é un proxecto de afeccionados, sen vinculación con ningún deles.';
  }

  @override
  String issueMainDeckShort(int missing, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other:
          'Á baralla principal fáltanlle $missing cartas ($size obrigatorias).',
      one: 'Á baralla principal fáltalle 1 carta ($size obrigatorias).',
    );
    return '$_temp0';
  }

  @override
  String issueMainDeckOver(int excess, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      excess,
      locale: localeName,
      other: 'Á baralla principal sóbranlle $excess cartas ($size permitidas).',
      one: 'Á baralla principal sóbralle 1 carta ($size permitidas).',
    );
    return '$_temp0';
  }

  @override
  String issueEggDeckOver(int excess, int size) {
    return 'Á baralla de ovos sóbranlle $excess ($size permitidos).';
  }

  @override
  String issueTooManyCopies(
    String name,
    String number,
    int quantity,
    int limit,
  ) {
    return '$name ($number): $quantity copias, máximo $limit.';
  }

  @override
  String issueTooManyCopiesLimited(
    String name,
    String number,
    String limitation,
    int limit,
    int quantity,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit copias',
      one: '1 copia',
    );
    return '$name ($number) está $limitation a $_temp0; a baralla leva $quantity.';
  }

  @override
  String issueBannedPair(
    String name,
    String number,
    String partnerName,
    String partnerNumber,
  ) {
    return '$name ($number) e $partnerName ($partnerNumber) son parella prohibida; unha baralla pode levar unha ou outra, non as dúas.';
  }

  @override
  String issueToken(String name, String number) {
    return '$name ($number) é un token. Os tokens créanse durante a partida e non poden formar parte dunha baralla.';
  }

  @override
  String get issueEmptyEggDeck =>
      'A baralla de ovos está baleira. A maioría de barallas levan 4 ou 5 Digi-Eggs.';

  @override
  String get sectionDigiEggs => 'Digi-Eggs';

  @override
  String get sectionDigimon => 'Digimon';

  @override
  String get sectionTamers => 'Tamers';

  @override
  String get sectionOptions => 'Options';

  @override
  String sectionWithLevel(String section, int level) {
    return '$section · Nv.$level';
  }

  @override
  String get decksTitle => 'Barallas';

  @override
  String get decksTabStaples => 'Imprescindibles';

  @override
  String get decksImportDeck => 'Importar lista de baralla';

  @override
  String get decksImportStaples => 'Importar lista de imprescindibles';

  @override
  String get decksNewDeck => 'Nova baralla';

  @override
  String get decksNewList => 'Nova lista';

  @override
  String get decksLoadError => 'Non se puideron cargar as barallas';

  @override
  String get decksEmptyTitle => 'Aínda non hai barallas';

  @override
  String get decksEmptyMessage =>
      'Monta unha baralla de 50 cartas máis ata 5 Digi-Eggs. Cada baralla garda as súas propias revisións, así podes probar cambios sen perder o que xa funcionaba.';

  @override
  String get decksCreateFirst => 'Crea a túa primeira baralla';

  @override
  String get decksSearchHint => 'Buscar barallas';

  @override
  String get decksNoMatchTitle => 'Ningunha baralla coincide';

  @override
  String decksNoMatchMessage(String query) {
    return 'Aquí non hai nada que se chame «$query».';
  }

  @override
  String deckRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisións',
      one: '1 revisión',
    );
    return '$_temp0';
  }

  @override
  String deckRevisionWithCount(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisións',
      one: '1 revisión',
    );
    return '$name · $_temp0';
  }

  @override
  String get deckNoRevisions => 'Sen revisións';

  @override
  String get actionRename => 'Cambiar o nome';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Gardar';

  @override
  String get deckRenameTitle => 'Cambiar o nome da baralla';

  @override
  String get deckNameLabel => 'Nome da baralla';

  @override
  String get dialogNameLabel => 'Nome';

  @override
  String deckDeleteTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String deckDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Elimínanse a baralla e as súas $count revisións. Isto non se pode desfacer.',
      one: 'Elimínanse a baralla e a súa revisión. Isto non se pode desfacer.',
    );
    return '$_temp0';
  }

  @override
  String get deckCountMain => 'Principal';

  @override
  String get deckCountEggs => 'Ovos';

  @override
  String get deckLegal => 'Legal';

  @override
  String get deckDraft => 'Borrador';

  @override
  String get thumbnailTitle => 'Miniatura da baralla';

  @override
  String get thumbnailSubtitle =>
      'A carta que representa esta baralla na lista.';

  @override
  String get thumbnailEmptyTitle => 'Aínda non hai nada que escoller';

  @override
  String get thumbnailEmptyMessage => 'Engade primeiro cartas a esta revisión.';

  @override
  String get thumbnailAutomatic => 'Escoller automaticamente';

  @override
  String thumbnailAutomaticNamed(String name) {
    return 'Escoller automaticamente ($name)';
  }

  @override
  String get stapleSourceTitle =>
      'Construír desde unha lista de imprescindibles';

  @override
  String get stapleSourceEmpty =>
      'Aínda non tes ningunha lista. Crea unha en Barallas · Imprescindibles.';

  @override
  String get stapleSourceHint =>
      'Abre o selector de cartas amosando só esa lista.';

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas',
      one: '1 carta',
    );
    return '$_temp0';
  }

  @override
  String get deckLoadError => 'Non se puido cargar a baralla';

  @override
  String get deckNotFound => 'Baralla non atopada';

  @override
  String get deckNotFoundMessage => 'Pode que se eliminase.';

  @override
  String deckEditing(String revision) {
    return 'Editando $revision';
  }

  @override
  String get deckMenuRename => 'Cambiar o nome da baralla';

  @override
  String get deckMenuThumbnail => 'Miniatura da baralla';

  @override
  String get deckMenuTestHand => 'Man de proba';

  @override
  String get deckMenuExport => 'Exportar';

  @override
  String deckMenuClear(String revision) {
    return 'Baleirar $revision';
  }

  @override
  String get deckMenuDelete => 'Eliminar baralla';

  @override
  String get deckTabCards => 'Cartas';

  @override
  String deckTabRevisions(int count) {
    return 'Revisións ($count)';
  }

  @override
  String get deckTabStats => 'Estatísticas';

  @override
  String get deckAddCards => 'Engadir cartas';

  @override
  String get deckNoRevisionsTitle => 'Esta baralla non ten revisións';

  @override
  String get deckNoRevisionsMessage =>
      'Crea unha para comezar a engadir cartas.';

  @override
  String deckClearTitle(String revision) {
    return 'Baleirar $revision?';
  }

  @override
  String get deckClearMessage =>
      'Quita todas as cartas desta revisión. As demais revisións conservan as súas.';

  @override
  String get actionClearConfirm => 'Baleirar';

  @override
  String get revisionLoadError => 'Non se puido cargar esta revisión';

  @override
  String get revisionEmptyTitle => 'Esta revisión está baleira';

  @override
  String get revisionEmptyMessage =>
      'Engade 50 cartas á baralla principal e ata 5 Digi-Eggs á de ovos. Unha baralla sen nada dentro non se garda, así que saír agora é o mesmo que non tela creado.';

  @override
  String get deckCardTileBadge => 'Carta';

  @override
  String get statsLoadError => 'Non se puido analizar esta revisión';

  @override
  String get statsEmptyTitle => 'Aínda non hai nada que analizar';

  @override
  String get statsEmptyMessage =>
      'Engade cartas para ver a curva e o balance de cores.';

  @override
  String get statsCurveTitle => 'Curva de custo';

  @override
  String get statsCurveSubtitle =>
      'Custo de xogo das cartas da baralla principal';

  @override
  String get statsLevelTitle => 'Reparto por nivel';

  @override
  String get statsLevelSubtitle => 'Niveis da baralla principal';

  @override
  String get statsColorTitle => 'Balance de cores';

  @override
  String get statsColorSubtitle =>
      'Cartas de cada cor, contando as duais dúas veces';

  @override
  String get statsLegal => 'Legal en torneo';

  @override
  String get statsNotLegal => 'Aínda non é legal';

  @override
  String statsDeckCounts(int main, int mainSize, int eggs, int eggSize) {
    return '$main/$mainSize · $eggs/$eggSize';
  }

  @override
  String get statsNoCosts => 'Aínda non hai cartas con custo';

  @override
  String get statsNoColors => 'Aínda non hai cores';

  @override
  String get revisionsExplainer =>
      'A revisión activa é a que editas. Ramifica unha revisión nova para experimentar sen tocar a lista actual.';

  @override
  String get revisionsBranch => 'Ramificar a activa';

  @override
  String get revisionsEmpty => 'Baleira';

  @override
  String revisionBranchTitle(String name) {
    return 'Ramificar desde $name';
  }

  @override
  String revisionBranchHelper(String name) {
    return 'Copia as cartas de $name';
  }

  @override
  String get revisionNameLabel => 'Nome da revisión';

  @override
  String get actionCreate => 'Crear';

  @override
  String get revisionNewEmptyTitle => 'Nova revisión baleira';

  @override
  String revisionSummary(int main, int eggs, String date) {
    return '$main principal · $eggs ovos · $date';
  }

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get revisionRenameTitle => 'Cambiar o nome da revisión';

  @override
  String revisionDuplicateTitle(String name) {
    return 'Duplicar $name';
  }

  @override
  String revisionCopyName(String name) {
    return '$name copia';
  }

  @override
  String revisionDeleteTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String get revisionDeleteBody =>
      'Quítanse as cartas desta revisión. As demais revisións da baralla non se tocan.';

  @override
  String pickerCopyCapped(String name, String limitation, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit copias',
      one: '1 copia',
    );
    return '$name está $limitation a $_temp0.';
  }

  @override
  String pickerBannedPairWarning(String name, String partners) {
    return '$name é parella prohibida con $partners. Unha baralla pode levar unha ou outra, non as dúas.';
  }

  @override
  String get pickerSearchHint => 'Engadir cartas…';

  @override
  String get pickerNoCardsFiltered => 'Proba outra busca ou quita os filtros.';

  @override
  String get pickerNoCardsInList =>
      'Nada desta lista coincide. Proba outra fonte, busca ou filtro.';

  @override
  String get pickerAllCards => 'Todas as cartas';

  @override
  String pickerListChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String get pickerMainDeck => 'Principal';

  @override
  String get pickerEggDeck => 'Ovos';

  @override
  String get pickerTapHint => 'Toca para axustar as copias';

  @override
  String get addToDeckTokenBlocked =>
      'Os tokens créanse durante a partida e non poden ir nunha baralla.';

  @override
  String get addToDeckTitle => 'Engadir a unha baralla';

  @override
  String addToDeckCardLine(String name, String number) {
    return '$name · $number';
  }

  @override
  String get addToDeckEmptyMessage =>
      'Crea unha baralla para comezar a engadirlle cartas.';

  @override
  String get addToDeckNewSubtitle => 'Comeza unha baralla con esta carta';

  @override
  String addToDeckAdded(String name, String deck) {
    return '$name engadida a $deck';
  }

  @override
  String addToDeckAddedWithPair(String name, String deck, String partners) {
    return '$name engadida a $deck: parella prohibida con $partners';
  }

  @override
  String get handTitle => 'Man de proba';

  @override
  String get handNotFullTitle => 'A baralla aínda non está completa';

  @override
  String handNotFullMessage(int count, int size) {
    return 'A man de proba repártese das $size cartas da baralla principal, da que os Digi-Eggs non forman parte. Esta revisión ten $count de $size.';
  }

  @override
  String get handOpeningTitle => 'Man inicial';

  @override
  String get handOpeningSubtitle => 'As 5 cartas que roubas';

  @override
  String get handSecurityTitle => 'Seguridade';

  @override
  String get handSecuritySubtitle => 'Primeiro a de enriba do monte';

  @override
  String get handTestAgain => 'Repetir';

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportTabImage => 'Imaxe';

  @override
  String get exportTabText => 'Texto';

  @override
  String get exportNothingTitle => 'Non hai nada que exportar';

  @override
  String get exportNothingMessage => 'Esta revisión aínda non ten cartas.';

  @override
  String get exportFallbackDeckName => 'Baralla';

  @override
  String get exportRenderFailed => 'Non se puido xerar a imaxe da baralla.';

  @override
  String get exportNeedsPermission =>
      'DigiCard necesita permiso para gardar na túa galería.';

  @override
  String get exportSaved => 'Gardada na túa galería.';

  @override
  String get exportLoadingArt => 'Cargando as ilustracións…';

  @override
  String exportLayoutHint(String description) {
    return '$description. Belisca para ver de preto: a imaxe gardada é a tamaño completo.';
  }

  @override
  String get exportSaving => 'Gardando…';

  @override
  String get exportSaveToGallery => 'Gardar na galería';

  @override
  String exportListCopied(String format) {
    return 'Lista $format copiada.';
  }

  @override
  String get exportCopyToClipboard => 'Copiar ao portapapeis';

  @override
  String get layoutDetailed => 'Detallado';

  @override
  String get layoutDetailedDescription => 'Separado por seccións, 8 por fila';

  @override
  String get layoutCompact => 'Compacto';

  @override
  String get layoutCompactDescription => 'Unha soa grella, 7 por fila';

  @override
  String get listFormatStandard => 'Estándar';

  @override
  String get listFormatUntap => 'Untap';

  @override
  String get importClipboardEmpty => 'O portapapeis non ten texto.';

  @override
  String get importDefaultDeckName => 'Baralla importada';

  @override
  String get importDefaultShortName => 'Importada';

  @override
  String get importTitle => 'Importar lista de baralla';

  @override
  String get importExplainer =>
      'Pega unha lista de baralla en calquera dos dous formatos: «4 Agumon BT1-010» ou «4 Agumon (BT1-010)». Os encabezados e comentarios entre liñas ignóranse.';

  @override
  String get importPaste => 'Pegar';

  @override
  String get importReading => 'Lendo…';

  @override
  String get importReadList => 'Ler lista';

  @override
  String get importNewDeck => 'Baralla nova';

  @override
  String get importNewRevision => 'Revisión nova';

  @override
  String get importNoDecks =>
      'Aínda non tes barallas ás que engadir unha revisión.';

  @override
  String get importDeckField => 'Baralla';

  @override
  String get importNothingRecognised =>
      'Non se recoñeceu ningunha carta nesa lista.';

  @override
  String importSummary(int cards, int copies) {
    return '$cards cartas · $copies copias';
  }

  @override
  String importUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liñas non se puideron recoñecer e quedarán fóra:',
      one: '1 liña non se puido recoñecer e quedará fóra:',
    );
    return '$_temp0';
  }

  @override
  String importAndMore(int count) {
    return '…e $count máis';
  }

  @override
  String get stapleNotFound => 'Lista non atopada';

  @override
  String get stapleMenuRename => 'Cambiar o nome da lista';

  @override
  String get stapleMenuExport => 'Exportar lista';

  @override
  String get stapleMenuDelete => 'Eliminar lista';

  @override
  String get stapleAddCards => 'Engadir cartas';

  @override
  String get stapleEmptyTitle => 'Esta lista está baleira';

  @override
  String get stapleEmptyMessage =>
      'Engade as cartas que queiras ter a man. Aparecen como fonte no construtor de barallas, así podes metelas nunha baralla sen ir buscalas.';

  @override
  String stapleMissingCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hai $count cartas máis nesta lista que aínda non están na túa biblioteca.',
      one: 'Hai 1 carta máis nesta lista que aínda non está na túa biblioteca.',
    );
    return '$_temp0';
  }

  @override
  String stapleRemoved(String name) {
    return '$name quitada';
  }

  @override
  String get actionUndo => 'Desfacer';

  @override
  String get stapleNameLabel => 'Nome da lista';

  @override
  String get staplesLoadError => 'Non se puideron cargar as túas listas';

  @override
  String get staplesEmptyTitle => 'Non hai listas de imprescindibles';

  @override
  String get staplesEmptyMessage =>
      'Unha lista de imprescindibles é un conxunto de cartas ás que volves unha e outra vez: os memory boost, os floodgates, os tamers. Crea unha e aparecerá como fonte mentres engades cartas a unha baralla.';

  @override
  String get staplesCreate => 'Crear unha lista';

  @override
  String get stapleNewTitle => 'Nova lista de imprescindibles';

  @override
  String stapleDeleteTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String stapleDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Elimínanse a lista e as $count cartas que contén. As túas barallas conservan todas as cartas que xa teñen.',
      one:
          'Elimínanse a lista e a carta que contén. As túas barallas conservan todas as cartas que xa teñen.',
    );
    return '$_temp0';
  }

  @override
  String get stapleNothingYet => 'Aínda non hai nada nesta lista.';

  @override
  String stapleExportCopied(String name) {
    return '$name copiada.';
  }

  @override
  String stapleExportTitle(String name) {
    return 'Exportar $name';
  }

  @override
  String get stapleExportExplainer =>
      'Unha liña por carta, coa mesma forma ca unha lista de baralla, así o resultado lese nesta app e nas ferramentas que aceptan listas de baralla.';

  @override
  String get stapleExportEmpty => 'Esta lista aínda non ten cartas.';

  @override
  String stapleExportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hai $count cartas nesta lista que aínda non están na túa biblioteca, así que non se escriben.',
      one:
          'Hai 1 carta nesta lista que aínda non está na túa biblioteca, así que non se escribe.',
    );
    return '$_temp0';
  }

  @override
  String get staplePickerHint => 'Engadir cartas á lista…';

  @override
  String staplePickerSummary(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas',
      one: '1 carta',
    );
    return '$name · $_temp0';
  }

  @override
  String get staplePickerTapHint => 'Toca para engadir ou quitar';

  @override
  String get stapleImportTitle => 'Importar unha lista de imprescindibles';

  @override
  String get stapleImportExplainer =>
      'Pega unha lista de cartas: a exportación desta app ou calquera lista de baralla. As copias ignóranse: unha lista de imprescindibles garda cada carta unha soa vez.';

  @override
  String get stapleImportDestination => 'Onde vai';

  @override
  String get stapleImportNewList => 'Lista nova';

  @override
  String get stapleImportAddToList => 'Engadir a unha lista';

  @override
  String get stapleImportNameHint => 'Tecnoloxía azul';

  @override
  String get stapleImportNoLists => 'Aínda non tes listas ás que engadir.';

  @override
  String get stapleImportListField => 'Lista';

  @override
  String stapleImportListOption(String name, int count) {
    return '$name · $count';
  }

  @override
  String stapleImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count cartas',
      one: 'Importar 1 carta',
    );
    return '$_temp0';
  }

  @override
  String stapleImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartas atopadas',
      one: '1 carta atopada',
    );
    return '$_temp0';
  }

  @override
  String stapleImportUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liñas non coinciden con ningunha carta e quedan fóra:',
      one: '1 liña non coincide con ningunha carta e queda fóra:',
    );
    return '$_temp0';
  }

  @override
  String stapleImportAndMore(int count) {
    return 'e $count máis';
  }

  @override
  String get defaultDeckName => 'Baralla nova';

  @override
  String get importImporting => 'Importando…';

  @override
  String get importAction => 'Importar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle =>
      'Os nomes e os textos das cartas quedan en inglés, que é o idioma no que están impresas.';

  @override
  String get languageSystem => 'O do dispositivo';

  @override
  String languageSystemDetail(String language) {
    return 'Agora: $language';
  }

  @override
  String get cardAddToList => 'Engadir a unha lista de imprescindibles';

  @override
  String get addToListTitle => 'Engadir a unha lista';

  @override
  String get addToListEmptyMessage =>
      'Unha lista de imprescindibles mantén a man, no construtor de barallas, as cartas ás que volves.';

  @override
  String get addToListNewSubtitle => 'Comeza unha lista con esta carta';

  @override
  String addToListAdded(String name, String list) {
    return '$name engadida a $list';
  }

  @override
  String addToListRemoved(String name, String list) {
    return '$name quitada de $list';
  }

  @override
  String get addToListHolds => 'Nesta lista';

  @override
  String get banlistTitle => 'Banlist';

  @override
  String get banlistBanned => 'Prohibidas';

  @override
  String get banlistBannedSubtitle =>
      'Ningunha baralla pode incluír estas cartas';

  @override
  String banlistLimited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copias',
      one: '1 copia',
    );
    return 'Limitadas a $_temp0';
  }

  @override
  String get banlistPairs => 'Parellas prohibidas';

  @override
  String get banlistPairsSubtitle =>
      'Cada carta é legal por si soa, pero unha baralla non pode levar as dúas';

  @override
  String banlistPairLine(String card, String partners) {
    return '$card non pode ir na mesma baralla ca $partners.';
  }

  @override
  String banlistSince(String date) {
    return 'Desde $date';
  }

  @override
  String banlistLatestChange(String date) {
    return 'Último cambio: $date';
  }

  @override
  String get banlistEmptyTitle => 'Sen restricións';

  @override
  String get banlistEmptyMessage =>
      'A base de datos de cartas non ten entradas da lista de restricións. Actualízaa desde a folla da base de datos da biblioteca para traer a lista vixente.';

  @override
  String get banlistError => 'Non se puido cargar a banlist';
}
