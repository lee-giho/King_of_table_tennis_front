enum GameState {
  RECRUITING, // 상대 모집 중
  WAITING, // 게임 시작 기다리는 중
  DOING, // 게임 하는 중
  END // 끝난 게임
}

extension GameStateExtension on GameState {
  static GameState fromString(String state) {
    return GameState.values.firstWhere(
      (e) => e.name.toUpperCase() == state.toUpperCase(),
      orElse: () => GameState.RECRUITING // 기본값
    );
  }

  String get toKorean {
    switch (this) {
      case GameState.RECRUITING:
        return "상대 모집 중";
      case GameState.WAITING:
        return "경기 대기 중";
      case GameState.DOING:
        return "경기 진행 중";
      case GameState.END:
        return "경기 종료";
    }
  }
}