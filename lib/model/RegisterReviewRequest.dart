class RegisterReviewRequest {
  final String revieweeId;

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

  RegisterReviewRequest({
    required this.revieweeId,
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
    required this.comment
  });

  factory RegisterReviewRequest.fromJson(Map<String, dynamic> json) {
    return RegisterReviewRequest(
      revieweeId: json['revieweeId'],
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
      comment: json['comment']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "revieweeId": revieweeId,
      "scoreServe": scoreServe,
      "scoreReceive": scoreReceive,
      "scoreRally": scoreRally,
      "scoreStrokes": scoreStrokes,
      "scoreStrategy": scoreStrategy,
      "scoreManner": scoreManner,
      "scorePunctuality": scorePunctuality,
      "scoreCommunity": scoreCommunity,
      "scorePoliteness": scorePoliteness,
      "scoreRematch": scoreRematch,
      "comment": comment
    };
  }
}