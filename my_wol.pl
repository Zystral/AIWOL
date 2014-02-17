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

bloodlust('b', [Blue, Red], NewBoardState, Move) :-
  length(Red, NumRed),
  findall([A,B,MA,MB], (member([A,B], Blue), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            PossMoves),
  find_lowest_enemy('b', PossMoves, [Blue, Red], [], NumRed, Move, _), 
  generate_next_state(Move, [Blue,Red], NewBoardState).

bloodlust('r', [Blue, Red], NewBoardState, Move) :-
  length(Blue, NumBlue),
  findall([A,B,MA,MB], (member([A,B], Red),
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            PossMoves),
  find_lowest_enemy('r', PossMoves, [Blue, Red], [], NumBlue, Move, _),
  generate_next_state(Move, [Blue,Red], NewBoardState).
  
find_lowest_enemy(Colour, [Move | PossMoves], CurrentBoardState, BestMove, NumEnemy, UltimateMove, FinalEnemy) :-
  generate_next_state(Move, CurrentBoardState, [NewBlue, NewRed]), 
  write(NewRed), write(','), write(NewBlue),
  ((Colour = 'b') -> List = NewRed; List = NewBlue),
  length(List, NewEnemy),
  ((NewEnemy < NumEnemy) -> (NewBestMove = Move, NewNumEnemy is NewEnemy); (NewBestMove = BestMove, NewNumEnemy is NumEnemy)),
  find_lowest_enemy(Colour, PossMoves, CurrentBoardState, NewBestMove, NewNumEnemy, UltimateMove, FinalEnemy).


find_lowest_enemy(_, [], _, Move, NumEnemy, Move, NumEnemy).

generate_next_state(Move, PrevBoardState, NextBoardState) :-
  write(PrevBoardState), write(' '),
  alter_board(Move, PrevBoardState, NewBoardState),
  write(NewBoardState),
  next_generation(NewBoardState, NextBoardState), write(NextBoardState).