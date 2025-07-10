class Player {
  final int tradeID;
  final int startPrice;
  final int buyNowPrice;
  final int assetID;
  final int resourceID;
  final String name;
  final int rating;
  final String position;
  final int expires;
  final int transactionID;
  final int contracts;
  final String chemistryStyle;
  final int chemistryStyleID;
  final int owners;
  final double amount;

  Player({
    required this.tradeID,
    required this.startPrice,
    required this.buyNowPrice,
    required this.assetID,
    required this.resourceID,
    required this.name,
    required this.rating,
    required this.position,
    required this.expires,
    required this.transactionID,
    required this.contracts,
    required this.chemistryStyle,
    required this.chemistryStyleID,
    required this.owners,
    required this.amount,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      tradeID: json['tradeID'],
      startPrice: json['startPrice'],
      buyNowPrice: json['buyNowPrice'],
      assetID: json['assetID'],
      resourceID: json['resourceID'],
      name: json['name'],
      rating: json['rating'],
      position: json['position'],
      expires: json['expires'],
      transactionID: json['transactionID'],
      contracts: json['contracts'],
      chemistryStyle: json['chemistryStyle'],
      chemistryStyleID: json['chemistryStyleID'],
      owners: json['owners'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tradeID': tradeID,
      'startPrice': startPrice,
      'buyNowPrice': buyNowPrice,
      'assetID': assetID,
      'resourceID': resourceID,
      'name': name,
      'rating': rating,
      'position': position,
      'expires': expires,
      'transactionID': transactionID,
      'contracts': contracts,
      'chemistryStyle': chemistryStyle,
      'chemistryStyleID': chemistryStyleID,
      'owners': owners,
      'amount': amount,
    };
  }
}

class ApiResponse {
  final String error;
  final String message;
  final Player? player;

  ApiResponse({required this.error, required this.message, this.player});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      error: json['error'] ?? '',
      message: json['message'] ?? '',
      player: json['player'] != null ? Player.fromJson(json['player']) : null,
    );
  }

  bool get isSuccess => error.isEmpty && player != null;
  bool get hasError => error.isNotEmpty;
}

class Prices {
  final double console100k;
  final double pc100k;

  Prices({required this.console100k, required this.pc100k});

  factory Prices.fromJson(Map<String, dynamic> json) {
    return Prices(
      console100k: json['console_100k'].toDouble(),
      pc100k: json['pc_100k'].toDouble(),
    );
  }
}

class TransactionStatus {
  final int status;
  final double amount;
  final String? error;

  TransactionStatus({required this.status, required this.amount, this.error});

  factory TransactionStatus.fromJson(Map<String, dynamic> json) {
    return TransactionStatus(
      status: json['status'] ?? 0,
      amount: json['amount']?.toDouble() ?? 0.0,
      error: json['error'],
    );
  }

  bool get isSuccessful => status == 1;
}

class DetailedPlayerInfo {
  final int id;
  final int fifa;
  final int playerId;
  final int resourceId;
  final int rating;
  final String level;
  final String position;
  final String cardName;
  final String fullName;
  final int attr1;
  final int attr2;
  final int attr3;
  final int attr4;
  final int attr5;
  final int attr6;
  final int clubEaId;
  final int leagueEaId;
  final int nationEaId;
  final int rareType;
  final int specialImg;
  final String guidAssetId;
  final int psMinPrice;
  final int psMaxPrice;
  final int psLowestBin;
  final int ps5MinPrice;
  final int ps5MaxPrice;
  final int ps5LowestBin;
  final int xbMinPrice;
  final int xbMaxPrice;
  final int xbLowestBin;
  final int xbsxMinPrice;
  final int xbsxMaxPrice;
  final int xbsxLowestBin;
  final int pcMinPrice;
  final int pcMaxPrice;
  final int pcLowestBin;
  final int igs;
  final String? imageNation;
  final String? imageClub;
  final String? image;
  final String? rareName;

  DetailedPlayerInfo({
    required this.id,
    required this.fifa,
    required this.playerId,
    required this.resourceId,
    required this.rating,
    required this.level,
    required this.position,
    required this.cardName,
    required this.fullName,
    required this.attr1,
    required this.attr2,
    required this.attr3,
    required this.attr4,
    required this.attr5,
    required this.attr6,
    required this.clubEaId,
    required this.leagueEaId,
    required this.nationEaId,
    required this.rareType,
    required this.specialImg,
    required this.guidAssetId,
    required this.psMinPrice,
    required this.psMaxPrice,
    required this.psLowestBin,
    required this.ps5MinPrice,
    required this.ps5MaxPrice,
    required this.ps5LowestBin,
    required this.xbMinPrice,
    required this.xbMaxPrice,
    required this.xbLowestBin,
    required this.xbsxMinPrice,
    required this.xbsxMaxPrice,
    required this.xbsxLowestBin,
    required this.pcMinPrice,
    required this.pcMaxPrice,
    required this.pcLowestBin,
    required this.igs,
    this.imageNation,
    this.imageClub,
    this.image,
    this.rareName,
  });

  factory DetailedPlayerInfo.fromJson(Map<String, dynamic> json) {
    return DetailedPlayerInfo(
      id: json['id'] ?? 0,
      fifa: json['fifa'] ?? 25,
      playerId: json['player_id'] ?? 0,
      resourceId: json['resource_id'] ?? 0,
      rating: json['rating'] ?? 0,
      level: json['level'] ?? '',
      position: json['position'] ?? '',
      cardName: json['card_name'] ?? '',
      fullName: json['full_name'] ?? '',
      attr1: json['attr1'] ?? 0,
      attr2: json['attr2'] ?? 0,
      attr3: json['attr3'] ?? 0,
      attr4: json['attr4'] ?? 0,
      attr5: json['attr5'] ?? 0,
      attr6: json['attr6'] ?? 0,
      clubEaId: json['club_ea_id'] ?? 0,
      leagueEaId: json['league_ea_id'] ?? 0,
      nationEaId: json['nation_ea_id'] ?? 0,
      rareType: json['rare_type'] ?? 0,
      specialImg: json['special_img'] ?? 0,
      guidAssetId: json['guid_asset_id'] ?? '',
      psMinPrice: json['ps_min_price'] ?? 0,
      psMaxPrice: json['ps_max_price'] ?? 0,
      psLowestBin: json['ps_lowest_bin'] ?? 0,
      ps5MinPrice: json['ps5_min_price'] ?? 0,
      ps5MaxPrice: json['ps5_max_price'] ?? 0,
      ps5LowestBin: json['ps5_lowest_bin'] ?? 0,
      xbMinPrice: json['xb_min_price'] ?? 0,
      xbMaxPrice: json['xb_max_price'] ?? 0,
      xbLowestBin: json['xb_lowest_bin'] ?? 0,
      xbsxMinPrice: json['xbsx_min_price'] ?? 0,
      xbsxMaxPrice: json['xbsx_max_price'] ?? 0,
      xbsxLowestBin: json['xbsx_lowest_bin'] ?? 0,
      pcMinPrice: json['pc_min_price'] ?? 0,
      pcMaxPrice: json['pc_max_price'] ?? 0,
      pcLowestBin: json['pc_lowest_bin'] ?? 0,
      igs: json['igs'] ?? 0,
      imageNation: json['image_nation'],
      imageClub: json['image_club'],
      image: json['image'],
      rareName: json['rare_name'],
    );
  }
}

class TradeInfo {
  final int id;
  final int userId;
  final int itemId;
  final bool? success;
  final int api;
  final int priceDrop;
  final String? emailHash;
  final String createdAt;
  final String? updatedAt;

  TradeInfo({
    required this.id,
    required this.userId,
    required this.itemId,
    this.success,
    required this.api,
    required this.priceDrop,
    this.emailHash,
    required this.createdAt,
    this.updatedAt,
  });

  factory TradeInfo.fromJson(Map<String, dynamic> json) {
    return TradeInfo(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      itemId: json['item_id'] ?? 0,
      success: json['success'],
      api: json['api'] ?? 0,
      priceDrop: json['price_drop'] ?? 0,
      emailHash: json['email_hash'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}

class Cart {
  final int id;
  final int userId;

  Cart({required this.id, required this.userId});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(id: json['id'] ?? 0, userId: json['user_id'] ?? 0);
  }
}

class DetailedPlayer {
  final int id;
  final int fifa;
  final String console;
  final int cartId;
  final int resourceId;
  final String position;
  final String level;
  final int rareType;
  final int price;
  final int buyPrice;
  final String dsfutShowedAt;
  final String createdAt;
  final String image;
  final String imageNation;
  final String imageClub;
  final DetailedPlayerInfo info;
  final int dsfutUserId;
  final String dsfutTimeStart;
  final String? tradeStatus;
  final int dsfutStartSecondsAgo;
  final int playerBoardBlock;
  final String hash;
  final List<String> ignoreHashes;
  final int dsfutShowedAtAgo;
  final TradeInfo tradeInfo;
  final DetailedPlayerInfo playerInfo;
  final Cart cart;

  DetailedPlayer({
    required this.id,
    required this.fifa,
    required this.console,
    required this.cartId,
    required this.resourceId,
    required this.position,
    required this.level,
    required this.rareType,
    required this.price,
    required this.buyPrice,
    required this.dsfutShowedAt,
    required this.createdAt,
    required this.image,
    required this.imageNation,
    required this.imageClub,
    required this.info,
    required this.dsfutUserId,
    required this.dsfutTimeStart,
    this.tradeStatus,
    required this.dsfutStartSecondsAgo,
    required this.playerBoardBlock,
    required this.hash,
    required this.ignoreHashes,
    required this.dsfutShowedAtAgo,
    required this.tradeInfo,
    required this.playerInfo,
    required this.cart,
  });

  factory DetailedPlayer.fromJson(Map<String, dynamic> json) {
    return DetailedPlayer(
      id: json['id'] ?? 0,
      fifa: json['fifa'] ?? 25,
      console: json['console'] ?? '',
      cartId: json['cart_id'] ?? 0,
      resourceId: json['resource_id'] ?? 0,
      position: json['position'] ?? '',
      level: json['level'] ?? '',
      rareType: json['rare_type'] ?? 0,
      price: json['price'] ?? 0,
      buyPrice: json['buy_price'] ?? 0,
      dsfutShowedAt: json['dsfut_showed_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      image: json['image'] ?? '',
      imageNation: json['image_nation'] ?? '',
      imageClub: json['image_club'] ?? '',
      info: DetailedPlayerInfo.fromJson(json['info'] ?? {}),
      dsfutUserId: json['dsfut_user_id'] ?? 0,
      dsfutTimeStart: json['dsfut_time_start'] ?? '',
      tradeStatus: json['trade_status'],
      dsfutStartSecondsAgo: json['dsfut_start_seconds_ago'] ?? 0,
      playerBoardBlock: json['player_board_block'] ?? 0,
      hash: json['hash'] ?? '',
      ignoreHashes: List<String>.from(json['ignore_hashes'] ?? []),
      dsfutShowedAtAgo: json['dsfut_showed_at_ago'] ?? 0,
      tradeInfo: TradeInfo.fromJson(json['trade_info'] ?? {}),
      playerInfo: DetailedPlayerInfo.fromJson(json['player_info'] ?? {}),
      cart: Cart.fromJson(json['cart'] ?? {}),
    );
  }

  // Helper methods
  String get displayName => info.cardName;
  String get fullDisplayName => info.fullName;
  int get rating => info.rating;
  bool get isSpecial => level == 'special';
}
