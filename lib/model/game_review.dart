class GameReview {
  final String id;
  final String reviewerId;
  final String revieweeId;
  final String gameInfoId;

  final int scoreServe;
  final int scoreReceive;
  final int scoreRally;
  final int scoreStrokes;
  final int scoreStrategy;

  final int scoreManner;
  final int scorePunctuality;
  final int scoreCommunity;
  final int scorePoliteness;
  final int scoreRematch;

  final String comment;

  final DateTime createdAt;
  final DateTime? updatedAt;


  GameReview({
    required this.id,
    required this.reviewerId,
    required this.revieweeId,
    required this.gameInfoId,
    required this.scoreServe,
    required this.scoreReceive,
    required this.scoreRally,
    required this.scoreStrokes,
    required this.scoreStrategy,
    required this.scoreManner,
    required this.scorePunctuality,
    required this.scoreCommunity,
    required this.scorePoliteness,
    required this.scoreRematch,
    required this.comment,
    required this.createdAt,
    required this.updatedAt
  });

  factory GameReview.fromJson(Map<String, dynamic> json) {
    return GameReview(
      id: json['id'],
      reviewerId: json['reviewerId'],
      revieweeId: json['revieweeId'],
      gameInfoId: json['gameInfoId'],
      scoreServe: json['scoreServe'],
      scoreReceive: json['scoreReceive'],
      scoreRally: json['scoreRally'],
      scoreStrokes: json['scoreStrokes'],
      scoreStrategy: json['scoreStrategy'],
      scoreManner: json['scoreManner'],
      scorePunctuality: json['scorePunctuality'],
      scoreCommunity: json['scoreCommunity'],
      scorePoliteness: json['scorePoliteness'],
      scoreRematch: json['scoreRematch'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
        ? DateTime.parse(json['updatedAt'])
        : null,
    );
  }
}