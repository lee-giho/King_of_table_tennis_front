class CheckScore {
  String gameScore(int leftUserScore, int rightUserScore, int goalScore) {
    if (leftUserScore >= goalScore || rightUserScore >= goalScore) {
      if ((leftUserScore - rightUserScore).abs() == 1 || leftUserScore == rightUserScore) {
        return "DEUCE";
      } else if (leftUserScore > rightUserScore) {
        return "LEFT WIN";
      } else {
        return "RIGHT WIN";
      }
    } else {
      return "CONTINUE";
    }
  }

  String gameSet(int leftUserSet, int rightUserSet, int goal) {
    if (leftUserSet == (goal/2).ceil()) {
      return "LEFT WIN";
    } else if (rightUserSet == (goal/2).ceil()) {
      return "RIGHT WIN";
    } else {
      return "CONTINUE";
    }
  }
}