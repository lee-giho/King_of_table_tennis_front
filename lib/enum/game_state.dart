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
}