// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'DigiCard App';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navDecks => 'Mazos';

  @override
  String get viewerZoomHint => 'Pellizca o toca dos veces para ampliar';

  @override
  String viewerPageOf(int index, int total) {
    return '$index / $total';
  }

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionDone => 'Hecho';

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
  String get syncSettingUp => 'Preparando tu biblioteca de cartas';

  @override
  String get syncRederiving => 'Actualizando tus cartas a las nuevas reglas';

  @override
  String get syncFailedTitle =>
      'No se pudo descargar la base de datos de cartas';

  @override
  String get syncRederivingDetail =>
      'Releyendo las cartas que ya tienes. No se está descargando nada.';

  @override
  String get syncOfflineNote =>
      'La lista completa de cartas se guarda en tu dispositivo, así que la biblioteca y el constructor de mazos funcionan sin conexión.';

  @override
  String get actionTryAgain => 'Reintentar';

  @override
  String get syncErrorGeneric => 'Algo ha ido mal.';

  @override
  String get syncErrorOffline =>
      'Sin conexión a internet. Conéctate e inténtalo de nuevo: la base de datos de cartas solo se descarga una vez.';

  @override
  String get syncStageChecking => 'Buscando actualizaciones de cartas';

  @override
  String get syncStageReleases => 'Obteniendo expansiones';

  @override
  String get syncStageDownloading => 'Descargando datos de cartas';

  @override
  String get syncStageParsing => 'Leyendo cartas';

  @override
  String get syncStageStoring => 'Guardando cartas';

  @override
  String get syncStageIndexing => 'Creando el índice de búsqueda';

  @override
  String get syncStageComplete => 'Todo al día';

  @override
  String get syncStageFailed => 'La sincronización ha fallado';

  @override
  String syncDetailExpansions(int completed, int total) {
    return '$completed de $total expansiones';
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
  String get libraryReleasesError => 'No se pudieron cargar las expansiones';

  @override
  String get librarySearchHint => 'Buscar cartas, efectos, rasgos';

  @override
  String librarySectionSubtitle(int sets, int cards) {
    return '$sets colecciones · $cards cartas';
  }

  @override
  String get databaseTitle => 'Base de datos de cartas';

  @override
  String get databaseCardsStored => 'Cartas guardadas';

  @override
  String get databasePublished => 'Datos publicados';

  @override
  String get databaseLastDownloaded => 'Última descarga';

  @override
  String get databaseUnknown => 'desconocido';

  @override
  String get databaseNever => 'nunca';

  @override
  String databaseSources(String source) {
    return 'Los datos de las cartas vienen de la API de Heroicc, más $source para las colecciones que Heroicc aún no ha publicado. Al actualizar se vuelve a descargar la lista completa, que es como aparecen las colecciones nuevas.';
  }

  @override
  String get databaseCredits => 'Fuentes de datos y créditos';

  @override
  String get databaseCheckUpdates => 'Buscar actualizaciones';

  @override
  String get searchHint => 'Nombre, efecto, rasgo…';

  @override
  String get searchFailed => 'La búsqueda ha fallado';

  @override
  String get searchNoCards => 'No se han encontrado cartas';

  @override
  String get searchNoCardsFiltered => 'Prueba a quitar algún filtro.';

  @override
  String get searchNoCardsPlain => 'Nada coincide con esa búsqueda.';

  @override
  String get searchClearFilters => 'Quitar filtros';

  @override
  String get searchEndOfResults => 'Fin de los resultados';

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
  String get releasePromosOnly => 'Solo promos';

  @override
  String releaseAltArts(int count) {
    return 'Ilustr. alt. +$count';
  }

  @override
  String get releaseCardsError => 'No se pudieron cargar las cartas';

  @override
  String get releaseEmptyTitle => 'No hay cartas en esta expansión';

  @override
  String get releaseEmptyMessage =>
      'Puede que la lista de cartas aún no se haya publicado.';

  @override
  String releasePreviewNotice(String source) {
    return 'Colección de avance. Esta expansión aún no está en la base de datos principal, así que sus cartas vienen de $source y todavía se están corrigiendo. Puede que falte alguna, y no hay ni rulings ni ilustraciones alternativas. Desliza hacia abajo para buscar cartas recién reveladas.';
  }

  @override
  String releaseRefreshedNothing(String source) {
    return 'No hay cartas nuevas: esta colección está tan completa como la tiene $source.';
  }

  @override
  String releaseRefreshedUpdated(String source) {
    return 'Actualizada desde $source.';
  }

  @override
  String get colorRed => 'Rojo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorYellow => 'Amarillo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlack => 'Negro';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorWhite => 'Blanco';

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
  String get releaseGroupStarter => 'Mazos de inicio';

  @override
  String get releaseGroupAdvanceDeck => 'Boosters avanzados';

  @override
  String get releaseGroupLimited => 'Packs de edición limitada';

  @override
  String get releaseGroupResurgence => 'Boosters Resurgence';

  @override
  String get releaseGroupPromo => 'Cartas promocionales';

  @override
  String get releaseGroupOther => 'Otros productos';

  @override
  String get sortCardNumber => 'Número de carta';

  @override
  String get sortNameAsc => 'Nombre A-Z';

  @override
  String get sortCostAsc => 'Coste, de menor a mayor';

  @override
  String get sortCostDesc => 'Coste, de mayor a menor';

  @override
  String get sortDpDesc => 'DP, de mayor a menor';

  @override
  String get sortLevelAsc => 'Nivel, de menor a mayor';

  @override
  String get matchAnyOf => 'Cualquiera de';

  @override
  String get matchAllOf => 'Todas de';

  @override
  String get matchExactly => 'Exactamente';

  @override
  String get limitationRestricted => 'Restringida';

  @override
  String get limitationBanned => 'Prohibida';

  @override
  String get limitationBannedPair => 'Pareja prohibida';

  @override
  String get limitationUnrestricted => 'Sin restricción';

  @override
  String get filtersTitle => 'Filtros';

  @override
  String get filtersReset => 'Restablecer';

  @override
  String get filterColor => 'Color';

  @override
  String get filterCardType => 'Tipo de carta';

  @override
  String get filterLevel => 'Nivel';

  @override
  String filterLevelValue(int level) {
    return 'Nv.$level';
  }

  @override
  String get filterPlayCost => 'Coste de juego / uso';

  @override
  String get filterDigivolveCost => 'Coste de digievolución';

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
  String get filterTrait => 'Rasgo';

  @override
  String get filterTraits => 'Rasgos';

  @override
  String get filterExpansion => 'Expansión';

  @override
  String get filterExpansions => 'Expansiones';

  @override
  String get filterNarrowNote =>
      'Las cartas ACE, dual y token acotan los tipos que estén seleccionados.';

  @override
  String get filterAltArts => 'Mostrar ilustraciones alternativas';

  @override
  String get filterAltArtsSubtitle =>
      'Lista cada impresión en vez de una carta por número';

  @override
  String get filterRestrictedOnly => 'Solo cartas restringidas';

  @override
  String get filterRestrictedOnlySubtitle =>
      'Cartas limitadas o prohibidas por la lista oficial';

  @override
  String get filterAny => 'Cualquiera';

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
  String get facetCost => 'Coste';

  @override
  String get facetDigivolve => 'Digievol.';

  @override
  String get facetDp => 'DP';

  @override
  String get facetDualCard => 'Carta dual';

  @override
  String get facetToken => 'Token';

  @override
  String get facetAlternateArts => 'Ilustraciones alternativas';

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
  String get cardLoadError => 'No se pudo cargar la carta';

  @override
  String get cardNotFound => 'Carta no encontrada';

  @override
  String get cardNotFoundMessage =>
      'Puede que se quitara en la última actualización de cartas.';

  @override
  String get cardAddToDeck => 'Añadir a un mazo';

  @override
  String get cardEffect => 'Efecto';

  @override
  String get cardSecurityEffect => 'Efecto de seguridad';

  @override
  String get cardInheritedEffect => 'Efecto heredado';

  @override
  String get cardInheritedEffects => 'Efectos heredados';

  @override
  String get cardOriginalArt => 'Ilustración original';

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
  String get cardPlayCost => 'Coste de juego';

  @override
  String get cardUseCost => 'Coste de uso';

  @override
  String get cardDp => 'DP';

  @override
  String get cardForm => 'Forma';

  @override
  String get cardAttribute => 'Atributo';

  @override
  String cardNotTournamentLegal(String limitation) {
    return '$limitation: no es legal en torneo';
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
  String get cardPairBanTitle => 'Pareja prohibida: jugables, pero no juntas';

  @override
  String cardPairBanOne(String partner) {
    return 'Un mazo con esta carta no puede llevar además $partner.';
  }

  @override
  String cardPairBanMany(String partners) {
    return 'Un mazo con esta carta no puede llevar además ninguna de estas: $partners.';
  }

  @override
  String cardRaisedCopyLimit(int limit) {
    return 'Un mazo puede llevar hasta $limit copias de esta carta.';
  }

  @override
  String get cardDigivolveTitle => 'Requisitos de digievolución';

  @override
  String cardDigivolveFromText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Las últimas $count condiciones están impresas en la caja de efecto de la carta, no en la de coste.',
      one:
          'La última condición está impresa en la caja de efecto de la carta, no en la de coste.',
    );
    return '$_temp0';
  }

  @override
  String get cardLevelUnpublished => 'Nivel aún sin publicar';

  @override
  String get cardConditionUnpublished => 'Condición aún sin publicar';

  @override
  String cardCostValue(int cost) {
    return 'Coste $cost';
  }

  @override
  String cardOtherFace(String category) {
    return 'Otra cara: $category';
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
  String get cardErrataShouldRead => 'Debe leerse';

  @override
  String get cardFoundIn => 'Aparece en';

  @override
  String cardRulings(int count) {
    return 'Rulings ($count)';
  }

  @override
  String get cardPreviewNotice =>
      'Carta de avance de una colección que aún no está en la base de datos principal. Su texto viene de la comunidad y puede cambiar, y aquí no tiene ni rulings ni ilustraciones alternativas.';

  @override
  String digivolveLevel(int level) {
    return 'Nv.$level';
  }

  @override
  String digivolveAppmonGrade(String grade) {
    return 'Appmon $grade';
  }

  @override
  String get digivolveAnyColor => 'de cualquier color';

  @override
  String get creditsTitle => 'Datos y créditos';

  @override
  String get creditsArtworkTitle => 'Ilustraciones y texto de las cartas';

  @override
  String get creditsArtworkBody =>
      'Todas las imágenes de cartas, sus textos y las ilustraciones relacionadas son propiedad intelectual de © Akiyoshi Hongo, Toei Animation y © BANDAI. Se aplican sus derechos de autor, marcas registradas y derechos afines.\n\nDigiCard App es una herramienta hecha por aficionados. No está afiliada a Bandai Namco Entertainment ni a Toei Animation, ni cuenta con su respaldo o vinculación.';

  @override
  String get creditsHeroiTitle => 'Datos de las cartas: Heroicc';

  @override
  String get creditsHeroiBody =>
      'La base de datos de cartas, la lista de expansiones y los rulings vienen de la API de Heroicc.\n\nDigiCard App no está afiliada a Heroicc, ni cuenta con su respaldo o vinculación. El contenido original aportado por Heroicc —es decir, la parte que no pertenece a Akiyoshi Hongo, Toei Animation o BANDAI— se usa bajo la licencia Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0).';

  @override
  String creditsPreviewTitle(String source) {
    return 'Colecciones de avance: $source';
  }

  @override
  String get creditsPreviewBody =>
      'Las colecciones que la API de Heroicc aún no ha publicado se rellenan desde la API pública de digimoncard.io, para poder buscar sus cartas y construir con ellas desde el principio. Esas colecciones aparecen marcadas como AVANCE allá donde salgan.\n\nDigiCard App no está afiliada a digimoncard.io, ni cuenta con su respaldo o vinculación. Los datos de avance los mantiene la comunidad y todavía cambian: cuenta con que falten cosas y se corrijan, y comprueba en la carta impresa todo lo que importe.';

  @override
  String get creditsImagesTitle =>
      'Qué hace esta app con las imágenes de las cartas';

  @override
  String get creditsImagesBody =>
      'Las imágenes de las cartas se muestran y se exportan enteras. La app no recorta ni tapa la línea de copyright ni el nombre del artista, y no añade ninguna marca de agua, sello ni logotipo propio a la imagen de una carta.';

  @override
  String get creditsCachingTitle => 'Caché';

  @override
  String get creditsCachingBody =>
      'La lista completa de cartas se descarga una vez y se guarda en tu dispositivo, así que navegar y construir mazos no hace ninguna petición más. Las dos APIs piden que se use caché en vez de volver a pedir los datos, y que quien llama se identifique; esta app envía su propio User-Agent en cada petición.';

  @override
  String creditsFooter(String source) {
    return 'Imágenes y textos de las cartas © Akiyoshi Hongo, Toei Animation, © BANDAI. Datos de las cartas de Heroicc y $source. DigiCard App es un proyecto de aficionados, sin vinculación con ninguno de ellos.';
  }

  @override
  String issueMainDeckShort(int missing, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other:
          'Al mazo principal le faltan $missing cartas ($size obligatorias).',
      one: 'Al mazo principal le falta 1 carta ($size obligatorias).',
    );
    return '$_temp0';
  }

  @override
  String issueMainDeckOver(int excess, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      excess,
      locale: localeName,
      other: 'Al mazo principal le sobran $excess cartas ($size permitidas).',
      one: 'Al mazo principal le sobra 1 carta ($size permitidas).',
    );
    return '$_temp0';
  }

  @override
  String issueEggDeckOver(int excess, int size) {
    return 'Al mazo de huevos le sobran $excess ($size permitidos).';
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
    return '$name ($number) está $limitation a $_temp0; el mazo lleva $quantity.';
  }

  @override
  String issueBannedPair(
    String name,
    String number,
    String partnerName,
    String partnerNumber,
  ) {
    return '$name ($number) y $partnerName ($partnerNumber) son pareja prohibida; un mazo puede llevar una u otra, no las dos.';
  }

  @override
  String issueToken(String name, String number) {
    return '$name ($number) es un token. Los tokens se crean durante la partida y no pueden formar parte de un mazo.';
  }

  @override
  String get issueEmptyEggDeck =>
      'El mazo de huevos está vacío. La mayoría de mazos llevan 4 o 5 Digi-Eggs.';

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
  String get decksTitle => 'Mazos';

  @override
  String get decksTabStaples => 'Imprescindibles';

  @override
  String get decksImportDeck => 'Importar lista de mazo';

  @override
  String get decksImportStaples => 'Importar lista de imprescindibles';

  @override
  String get decksNewDeck => 'Nuevo mazo';

  @override
  String get decksNewList => 'Nueva lista';

  @override
  String get decksLoadError => 'No se pudieron cargar los mazos';

  @override
  String get decksEmptyTitle => 'Aún no hay mazos';

  @override
  String get decksEmptyMessage =>
      'Monta un mazo de 50 cartas más hasta 5 Digi-Eggs. Cada mazo guarda sus propias revisiones, así puedes probar cambios sin perder lo que ya funcionaba.';

  @override
  String get decksCreateFirst => 'Crea tu primer mazo';

  @override
  String get decksSearchHint => 'Buscar mazos';

  @override
  String get decksNoMatchTitle => 'Ningún mazo coincide';

  @override
  String decksNoMatchMessage(String query) {
    return 'Aquí no hay nada que se llame «$query».';
  }

  @override
  String deckRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisiones',
      one: '1 revisión',
    );
    return '$_temp0';
  }

  @override
  String deckRevisionWithCount(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisiones',
      one: '1 revisión',
    );
    return '$name · $_temp0';
  }

  @override
  String get deckNoRevisions => 'Sin revisiones';

  @override
  String get actionRename => 'Cambiar nombre';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get deckRenameTitle => 'Cambiar el nombre del mazo';

  @override
  String get deckNameLabel => 'Nombre del mazo';

  @override
  String get dialogNameLabel => 'Nombre';

  @override
  String deckDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String deckDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se eliminan el mazo y sus $count revisiones. Esto no se puede deshacer.',
      one: 'Se elimina el mazo y su revisión. Esto no se puede deshacer.',
    );
    return '$_temp0';
  }

  @override
  String get deckCountMain => 'Principal';

  @override
  String get deckCountEggs => 'Huevos';

  @override
  String get deckLegal => 'Legal';

  @override
  String get deckDraft => 'Borrador';

  @override
  String get thumbnailTitle => 'Miniatura del mazo';

  @override
  String get thumbnailSubtitle =>
      'La carta que representa a este mazo en la lista.';

  @override
  String get thumbnailEmptyTitle => 'Aún no hay nada que elegir';

  @override
  String get thumbnailEmptyMessage => 'Añade primero cartas a esta revisión.';

  @override
  String get thumbnailAutomatic => 'Elegir automáticamente';

  @override
  String thumbnailAutomaticNamed(String name) {
    return 'Elegir automáticamente ($name)';
  }

  @override
  String get stapleSourceTitle =>
      'Construir desde una lista de imprescindibles';

  @override
  String get stapleSourceEmpty =>
      'Todavía no tienes ninguna lista. Crea una en Mazos · Imprescindibles.';

  @override
  String get stapleSourceHint =>
      'Abre el selector de cartas mostrando solo esa lista.';

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
  String get deckLoadError => 'No se pudo cargar el mazo';

  @override
  String get deckNotFound => 'Mazo no encontrado';

  @override
  String get deckNotFoundMessage => 'Puede que se haya eliminado.';

  @override
  String deckEditing(String revision) {
    return 'Editando $revision';
  }

  @override
  String get deckMenuRename => 'Cambiar el nombre del mazo';

  @override
  String get deckMenuThumbnail => 'Miniatura del mazo';

  @override
  String get deckMenuTestHand => 'Mano de prueba';

  @override
  String get deckMenuExport => 'Exportar';

  @override
  String deckMenuClear(String revision) {
    return 'Vaciar $revision';
  }

  @override
  String get deckMenuDelete => 'Eliminar mazo';

  @override
  String get deckTabCards => 'Cartas';

  @override
  String deckTabRevisions(int count) {
    return 'Revisiones ($count)';
  }

  @override
  String get deckTabStats => 'Estadísticas';

  @override
  String get deckAddCards => 'Añadir cartas';

  @override
  String get deckNoRevisionsTitle => 'Este mazo no tiene revisiones';

  @override
  String get deckNoRevisionsMessage => 'Crea una para empezar a añadir cartas.';

  @override
  String deckClearTitle(String revision) {
    return '¿Vaciar $revision?';
  }

  @override
  String get deckClearMessage =>
      'Quita todas las cartas de esta revisión. Las demás revisiones conservan las suyas.';

  @override
  String get actionClearConfirm => 'Vaciar';

  @override
  String get revisionLoadError => 'No se pudo cargar esta revisión';

  @override
  String get revisionEmptyTitle => 'Esta revisión está vacía';

  @override
  String get revisionEmptyMessage =>
      'Añade 50 cartas al mazo principal y hasta 5 Digi-Eggs al de huevos. Un mazo sin nada dentro no se guarda, así que salir ahora es lo mismo que no haberlo creado.';

  @override
  String get deckCardTileBadge => 'Carta';

  @override
  String get statsLoadError => 'No se pudo analizar esta revisión';

  @override
  String get statsEmptyTitle => 'Aún no hay nada que analizar';

  @override
  String get statsEmptyMessage =>
      'Añade cartas para ver la curva y el balance de colores.';

  @override
  String get statsCurveTitle => 'Curva de coste';

  @override
  String get statsCurveSubtitle =>
      'Coste de juego de las cartas del mazo principal';

  @override
  String get statsLevelTitle => 'Reparto por nivel';

  @override
  String get statsLevelSubtitle => 'Niveles del mazo principal';

  @override
  String get statsColorTitle => 'Balance de colores';

  @override
  String get statsColorSubtitle =>
      'Cartas de cada color, contando las duales dos veces';

  @override
  String get statsLegal => 'Legal en torneo';

  @override
  String get statsNotLegal => 'Aún no es legal';

  @override
  String statsDeckCounts(int main, int mainSize, int eggs, int eggSize) {
    return '$main/$mainSize · $eggs/$eggSize';
  }

  @override
  String get statsNoCosts => 'Todavía no hay cartas con coste';

  @override
  String get statsNoColors => 'Todavía no hay colores';

  @override
  String get revisionsExplainer =>
      'La revisión activa es la que editas. Ramifica una revisión nueva para experimentar sin tocar la lista actual.';

  @override
  String get revisionsBranch => 'Ramificar la activa';

  @override
  String get revisionsEmpty => 'Vacía';

  @override
  String revisionBranchTitle(String name) {
    return 'Ramificar desde $name';
  }

  @override
  String revisionBranchHelper(String name) {
    return 'Copia las cartas de $name';
  }

  @override
  String get revisionNameLabel => 'Nombre de la revisión';

  @override
  String get actionCreate => 'Crear';

  @override
  String get revisionNewEmptyTitle => 'Nueva revisión vacía';

  @override
  String revisionSummary(int main, int eggs, String date) {
    return '$main principal · $eggs huevos · $date';
  }

  @override
  String get actionDuplicate => 'Duplicar';

  @override
  String get revisionRenameTitle => 'Cambiar el nombre de la revisión';

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
    return '¿Eliminar $name?';
  }

  @override
  String get revisionDeleteBody =>
      'Se quitan las cartas de esta revisión. Las demás revisiones del mazo no se tocan.';

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
    return '$name es pareja prohibida con $partners. Un mazo puede llevar una u otra, no las dos.';
  }

  @override
  String get pickerSearchHint => 'Añadir cartas…';

  @override
  String get pickerNoCardsFiltered =>
      'Prueba otra búsqueda o quita los filtros.';

  @override
  String get pickerNoCardsInList =>
      'Nada de esta lista coincide. Prueba otra fuente, búsqueda o filtro.';

  @override
  String get pickerAllCards => 'Todas las cartas';

  @override
  String pickerListChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String get pickerMainDeck => 'Principal';

  @override
  String get pickerEggDeck => 'Huevos';

  @override
  String get pickerTapHint => 'Toca para ajustar las copias';

  @override
  String get addToDeckTokenBlocked =>
      'Los tokens se crean durante la partida y no pueden ir en un mazo.';

  @override
  String get addToDeckTitle => 'Añadir a un mazo';

  @override
  String addToDeckCardLine(String name, String number) {
    return '$name · $number';
  }

  @override
  String get addToDeckEmptyMessage =>
      'Crea un mazo para empezar a añadirle cartas.';

  @override
  String get addToDeckNewSubtitle => 'Empieza un mazo con esta carta';

  @override
  String addToDeckAdded(String name, String deck) {
    return '$name añadida a $deck';
  }

  @override
  String addToDeckAddedWithPair(String name, String deck, String partners) {
    return '$name añadida a $deck: pareja prohibida con $partners';
  }

  @override
  String get handTitle => 'Mano de prueba';

  @override
  String get handNotFullTitle => 'El mazo aún no está completo';

  @override
  String handNotFullMessage(int count, int size) {
    return 'La mano de prueba se reparte de las $size cartas del mazo principal, del que los Digi-Eggs no forman parte. Esta revisión tiene $count de $size.';
  }

  @override
  String get handOpeningTitle => 'Mano inicial';

  @override
  String get handOpeningSubtitle => 'Las 5 cartas que robas';

  @override
  String get handSecurityTitle => 'Seguridad';

  @override
  String get handSecuritySubtitle => 'Primero la de arriba del montón';

  @override
  String get handTestAgain => 'Repetir';

  @override
  String get exportTitle => 'Exportar';

  @override
  String get exportTabImage => 'Imagen';

  @override
  String get exportTabText => 'Texto';

  @override
  String get exportNothingTitle => 'No hay nada que exportar';

  @override
  String get exportNothingMessage => 'Esta revisión todavía no tiene cartas.';

  @override
  String get exportFallbackDeckName => 'Mazo';

  @override
  String get exportRenderFailed => 'No se pudo generar la imagen del mazo.';

  @override
  String get exportNeedsPermission =>
      'DigiCard necesita permiso para guardar en tu galería.';

  @override
  String get exportSaved => 'Guardada en tu galería.';

  @override
  String get exportLoadingArt => 'Cargando las ilustraciones…';

  @override
  String exportLayoutHint(String description) {
    return '$description. Pellizca para ver de cerca: la imagen guardada es a tamaño completo.';
  }

  @override
  String get exportSaving => 'Guardando…';

  @override
  String get exportSaveToGallery => 'Guardar en la galería';

  @override
  String exportListCopied(String format) {
    return 'Lista $format copiada.';
  }

  @override
  String get exportCopyToClipboard => 'Copiar al portapapeles';

  @override
  String get layoutDetailed => 'Detallado';

  @override
  String get layoutDetailedDescription => 'Separado por secciones, 8 por fila';

  @override
  String get layoutCompact => 'Compacto';

  @override
  String get layoutCompactDescription => 'Una sola rejilla, 7 por fila';

  @override
  String get listFormatStandard => 'Estándar';

  @override
  String get listFormatUntap => 'Untap';

  @override
  String get importClipboardEmpty => 'El portapapeles no tiene texto.';

  @override
  String get importDefaultDeckName => 'Mazo importado';

  @override
  String get importDefaultShortName => 'Importado';

  @override
  String get importTitle => 'Importar lista de mazo';

  @override
  String get importExplainer =>
      'Pega una lista de mazo en cualquiera de los dos formatos: «4 Agumon BT1-010» o «4 Agumon (BT1-010)». Los encabezados y comentarios entre líneas se ignoran.';

  @override
  String get importPaste => 'Pegar';

  @override
  String get importReading => 'Leyendo…';

  @override
  String get importReadList => 'Leer lista';

  @override
  String get importNewDeck => 'Mazo nuevo';

  @override
  String get importNewRevision => 'Revisión nueva';

  @override
  String get importNoDecks =>
      'Todavía no tienes mazos a los que añadir una revisión.';

  @override
  String get importDeckField => 'Mazo';

  @override
  String get importNothingRecognised =>
      'No se ha reconocido ninguna carta en esa lista.';

  @override
  String importSummary(int cards, int copies) {
    return '$cards cartas · $copies copias';
  }

  @override
  String importUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas no se han podido reconocer y se dejarán fuera:',
      one: '1 línea no se ha podido reconocer y se dejará fuera:',
    );
    return '$_temp0';
  }

  @override
  String importAndMore(int count) {
    return '…y $count más';
  }

  @override
  String get stapleNotFound => 'Lista no encontrada';

  @override
  String get stapleMenuRename => 'Cambiar el nombre de la lista';

  @override
  String get stapleMenuExport => 'Exportar lista';

  @override
  String get stapleMenuDelete => 'Eliminar lista';

  @override
  String get stapleAddCards => 'Añadir cartas';

  @override
  String get stapleEmptyTitle => 'Esta lista está vacía';

  @override
  String get stapleEmptyMessage =>
      'Añade las cartas que quieras tener a mano. Aparecen como fuente en el constructor de mazos, así puedes meterlas en un mazo sin ir a buscarlas.';

  @override
  String stapleMissingCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hay $count cartas más en esta lista que todavía no están en tu biblioteca.',
      one:
          'Hay 1 carta más en esta lista que todavía no está en tu biblioteca.',
    );
    return '$_temp0';
  }

  @override
  String stapleRemoved(String name) {
    return '$name quitada';
  }

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get stapleNameLabel => 'Nombre de la lista';

  @override
  String get staplesLoadError => 'No se pudieron cargar tus listas';

  @override
  String get staplesEmptyTitle => 'No hay listas de imprescindibles';

  @override
  String get staplesEmptyMessage =>
      'Una lista de imprescindibles es un conjunto de cartas a las que vuelves una y otra vez: los memory boost, los floodgates, los tamers. Crea una y aparecerá como fuente mientras añades cartas a un mazo.';

  @override
  String get staplesCreate => 'Crear una lista';

  @override
  String get stapleNewTitle => 'Nueva lista de imprescindibles';

  @override
  String stapleDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String stapleDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Se eliminan la lista y las $count cartas que contiene. Tus mazos conservan todas las cartas que ya tienen.',
      one:
          'Se eliminan la lista y la carta que contiene. Tus mazos conservan todas las cartas que ya tienen.',
    );
    return '$_temp0';
  }

  @override
  String get stapleNothingYet => 'Todavía no hay nada en esta lista.';

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
      'Una línea por carta, con la misma forma que una lista de mazo, así el resultado se lee en esta app y en las herramientas que aceptan listas de mazo.';

  @override
  String get stapleExportEmpty => 'Esta lista todavía no tiene cartas.';

  @override
  String stapleExportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hay $count cartas en esta lista que todavía no están en tu biblioteca, así que no se escriben.',
      one:
          'Hay 1 carta en esta lista que todavía no está en tu biblioteca, así que no se escribe.',
    );
    return '$_temp0';
  }

  @override
  String get staplePickerHint => 'Añadir cartas a la lista…';

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
  String get staplePickerTapHint => 'Toca para añadir o quitar';

  @override
  String get stapleImportTitle => 'Importar una lista de imprescindibles';

  @override
  String get stapleImportExplainer =>
      'Pega una lista de cartas: la exportación de esta app o cualquier lista de mazo. Las copias se ignoran: una lista de imprescindibles guarda cada carta una sola vez.';

  @override
  String get stapleImportDestination => 'Dónde va';

  @override
  String get stapleImportNewList => 'Lista nueva';

  @override
  String get stapleImportAddToList => 'Añadir a una lista';

  @override
  String get stapleImportNameHint => 'Tecnología azul';

  @override
  String get stapleImportNoLists =>
      'Todavía no tienes listas a las que añadir.';

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
      other: '$count cartas encontradas',
      one: '1 carta encontrada',
    );
    return '$_temp0';
  }

  @override
  String stapleImportUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas no coinciden con ninguna carta y se dejan fuera:',
      one: '1 línea no coincide con ninguna carta y se deja fuera:',
    );
    return '$_temp0';
  }

  @override
  String stapleImportAndMore(int count) {
    return 'y $count más';
  }

  @override
  String get defaultDeckName => 'Mazo nuevo';

  @override
  String get importImporting => 'Importando…';

  @override
  String get importAction => 'Importar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle =>
      'Los nombres y los textos de las cartas se quedan en inglés, que es el idioma en el que están impresas.';

  @override
  String get languageSystem => 'El del dispositivo';

  @override
  String languageSystemDetail(String language) {
    return 'Ahora: $language';
  }
}
