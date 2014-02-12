:- include('this.pl').

test_strategy(NumToPlay, StrategyOne, StrategyTwo) :-
  test_strategy_recursive(0, StrategyOne, StrategyTwo, 0, 0, 0, 0, 250, 0, NumToPlay).

test_strategy_recursive(N, StratOne, StratTwo, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  NumToPlay \= N,
  play(quiet, StratOne, StratTwo, NumMoves, 'b'),
  NewN is N + 1,
  NewBlue is BlueWin + 1,
  NewTotal is Total + NumMoves,
  ((NumMoves < Shortest) -> NewShortest is NumMoves; NewShortest is Shortest),
  ((NumMoves > Longest) -> NewLongest is NumMoves; NewLongest is Longest),
  test_strategy_recursive(NewN, StratOne, StratTwo, NumDraw, NewBlue, RedWin, NewLongest, NewShortest, NewTotal, NumToPlay).

test_strategy_recursive(N, StratOne, StratTwo, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  NumToPlay \= N,
  play(quiet, StratOne, StratTwo, NumMoves, 'r'),
  NewN is N + 1,
  NewRed is RedWin + 1,
  NewTotal is Total + NumMoves,
  ((NumMoves < Shortest) -> NewShortest is NumMoves; NewShortest is Shortest),
  ((NumMoves > Longest) -> NewLongest is NumMoves; NewLongest is Longest),
  test_strategy_recursive(NewN, StratOne, StratTwo, NumDraw, BlueWin, NewRed, NewLongest, NewShortest, NewTotal, NumToPlay).
  
test_strategy_recursive(N, StratOne, StratTwo, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  NumToPlay \= N,
  (play(quiet, StratOne, StratTwo, NumMoves, 'draw'); 
    play(quiet, StratOne, StratTwo, NumMoves, 'stalemate');
      play(quiet, StratOne, StratTwo, NumMoves, 'exhaust')),
  NewN is N + 1,
  NewDraw is NumDraw + 1,
  NewTotal is Total + NumMoves,
  ((NumMoves < Shortest) -> NewShortest is NumMoves; NewShortest is Shortest),
  ((NumMoves > Longest) -> NewLongest is NumMoves; NewLongest is Longest),
  test_strategy_recursive(NewN, StratOne, StratTwo, NewDraw, BlueWin, RedWin, NewLongest, NewShortest, NewTotal, NumToPlay).

test_strategy_recursive(NumToPlay, StratOne, StratTwo, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  write('BlueWin: '), write(BlueWin),
  write('; RedWin: '), write(RedWin),
  write('; Draws: '), write(NumDraw),
  write('; Longest: '), write(Longest),
  write('; Shortest: '), write(Shortest),
  Average is Total / NumToPlay,
  write('; Average: '), write(Average).
