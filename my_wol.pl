:- include('this.pl').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Test Strategy  %%%%%%%%%%%

test_strategy(NumToPlay, StrategyOne, StrategyTwo) :-
  test_strategy_recursive(0, StrategyOne, StrategyTwo, 0, 0, 0, 0, 250, 0, NumToPlay).

test_strategy_recursive(N, StratOne, StratTwo, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  NumToPlay \= N,
  play(quiet, StratOne, StratTwo, NumMoves, WinningPlayer),
  player_win(WinningPlayer, NumDraw, BlueWin, RedWin, NewDraw, NewBlue, NewRed),
  NewN is N + 1,
  NewTotal is Total + NumMoves,
  ((NumMoves < Shortest) -> NewShortest is NumMoves; NewShortest is Shortest),
  ((NumMoves > Longest) -> NewLongest is NumMoves; NewLongest is Longest),
  test_strategy_recursive(NewN, StratOne, StratTwo, NewDraw, NewBlue, NewRed, NewLongest, NewShortest, NewTotal, NumToPlay).

test_strategy_recursive(NumToPlay, _, _, NumDraw, BlueWin, RedWin, Longest, Shortest, Total, NumToPlay) :-
  write('BlueWin: '), write(BlueWin),
  write('; RedWin: '), write(RedWin),
  write('; Draws: '), write(NumDraw),
  write('; Longest: '), write(Longest),
  write('; Shortest: '), write(Shortest),
  Average is Total / NumToPlay,
  write('; Average: '), write(Average).

player_win('b', NumDraw, BlueWin, RedWin, NumDraw, NewBlue, RedWin) :-
  NewBlue is BlueWin + 1.

player_win('r', NumDraw, BlueWin, RedWin, NumDraw, BlueWin, NewRed) :-
  NewRed is RedWin + 1.

player_win( _ , NumDraw, BlueWin, RedWin, NewDraw, BlueWin, RedWin) :-
  NewDraw is NumDraw + 1.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Bloodlust  %%%%%%%%%%%

bloodlust('b', [Blue, Red], [NewBlue, Red], Move) :-
  length(Red, NumRed),
  findall([A,B,MA,MB], (member([A,B], Blue), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_lowest_enemy('b', [First | PossMoves], [Blue, Red], First, NumRed, Move, _),
  alter_board(Move, Blue, NewBlue).

bloodlust('r', [Blue, Red], [Blue, NewRed], Move) :-
  length(Blue, NumBlue),
  findall([A,B,MA,MB], (member([A,B], Red),
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_lowest_enemy('r', [First | PossMoves], [Blue, Red], First, NumBlue, Move, _),
  alter_board(Move, Red, NewRed).
  
find_lowest_enemy(Colour, [Move | PossMoves], CurrentBoardState, BestMove, NumEnemy, UltimateMove, FinalEnemy) :-
  generate_next_state(Colour, Move, CurrentBoardState, [NewBlue, NewRed]), 
  ((Colour = 'b') -> List = NewRed; List = NewBlue),
  length(List, NewEnemy),
  ((NewEnemy < NumEnemy) -> (NewBestMove = Move, NewNumEnemy is NewEnemy); (NewBestMove = BestMove, NewNumEnemy is NumEnemy)),
  find_lowest_enemy(Colour, PossMoves, CurrentBoardState, NewBestMove, NewNumEnemy, UltimateMove, FinalEnemy).


find_lowest_enemy(_, [], _, Move, NumEnemy, Move, NumEnemy).

generate_next_state('b', Move, [Blue,Red], NextBoardState) :-
  alter_board(Move, Blue, NewBlue),
  next_generation([NewBlue, Red], NextBoardState).

generate_next_state('r', Move, [Blue,Red], NextBoardState) :-
  alter_board(Move, Red, NewRed),
  next_generation([Blue, NewRed], NextBoardState).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Self Preservation  %%%%%%%%%%%

self_preservation('b', [Blue, Red], [NewBlue, Red], Move) :-
  findall([A,B,MA,MB], (member([A,B], Blue), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_highest_self('b', [First | PossMoves], [Blue, Red], First, 0, Move, _),
  alter_board(Move, Blue, NewBlue).

self_preservation('r', [Blue, Red], [Blue, NewRed], Move) :-
  findall([A,B,MA,MB], (member([A,B], Red),
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_highest_self('r', [First | PossMoves], [Blue, Red], First, 0, Move, _),
  alter_board(Move, Red, NewRed).

find_highest_self(Colour, [Move | PossMoves], CurrentBoardState, BestMove, NumSelf, UltimateMove, FinalSelf) :-
  generate_next_state(Colour, Move, CurrentBoardState, [NewBlue, NewRed]), 
  ((Colour = 'b') -> List = NewBlue; List = NewRed),
  length(List, NewSelf),
  ((NewSelf > NumSelf) -> (NewBestMove = Move, NewNumSelf is NewSelf); (NewBestMove = BestMove, NewNumSelf is NumSelf)),
  find_highest_self(Colour, PossMoves, CurrentBoardState, NewBestMove, NewNumSelf, UltimateMove, FinalSelf).


find_highest_self(_, [], _, Move, NumSelf, Move, NumSelf).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Land Grab  %%%%%%%%%%%%%%%%%%%

land_grab('b', [Blue, Red], [NewBlue, Red], Move) :-
  findall([A,B,MA,MB], (member([A,B], Blue), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_greatest_difference('b', [First | PossMoves], [Blue, Red], First, -64, Move, _), 
  alter_board(Move, Blue, NewBlue).

land_grab('r', [Blue, Red], [Blue, NewRed], Move) :-
  findall([A,B,MA,MB], (member([A,B], Red),
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  find_greatest_difference('r', [First | PossMoves], [Blue, Red], First, -64, Move, _),
  alter_board(Move, Red, NewRed).

find_greatest_difference(Colour, [Move | PossMoves], CurrentBoardState, BestMove, MoveDiff, UltimateMove, FinalDiff) :-
  generate_next_state(Colour, Move, CurrentBoardState, [NewBlue, NewRed]),
  length(NewBlue, TempNumBlue),
  length(NewRed, TempNumRed),
  ((Colour = 'b') -> Diff is TempNumBlue - TempNumRed; Diff is TempNumRed - TempNumBlue),
  ((Diff > MoveDiff) -> (NewMoveDiff is Diff, NewBestMove = Move); (NewMoveDiff is MoveDiff, NewBestMove = BestMove)),
  find_greatest_difference(Colour, PossMoves, CurrentBoardState, NewBestMove, NewMoveDiff, UltimateMove, FinalDiff).

find_greatest_difference(_, [], _, Move, NumDiff, Move, NumDiff).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%  Minimax  %%%%%%%%%%%%%%%%%%%

minimax('b', [Blue, Red], [NewBlue, Red], Move) :-
  findall([A,B,MA,MB], (member([A,B], Blue), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  look_down_two_ply('b', [First | PossMoves], [Blue, Red], First, -64, Move, _), 
  alter_board(Move, Blue, NewBlue).

minimax('r', [Blue, Red], [Blue, NewRed], Move) :-
  findall([A,B,MA,MB], (member([A,B], Red), 
                        neighbour_position(A,B,[MA,MB]),
                        \+member([MA,MB], Blue),
                        \+member([MA,MB], Red)),
            [First | PossMoves]),
  look_down_two_ply('r', [First | PossMoves], [Blue, Red], First, -64, Move, _), 
  alter_board(Move, Red, NewRed).

look_down_two_ply('b', [Move | PossMoves], CurrentBoardState, BestMove, MoveAdv, UltimateMove, FinalAdv) :-
  generate_next_state('b', Move, CurrentBoardState, TempBoardState),
  land_grab('r', TempBoardState, NextBoardState, _),
  next_generation(NextBoardState, CrankedNextBoardState),
  land_grab('b', CrankedNextBoardState, FinalBoardState, _),
  next_generation(FinalBoardState, [FinalBlue, FinalRed]),
  length(FinalBlue, NumBlue),
  length(FinalRed, NumRed),
  Adv is NumBlue - NumRed,
  ((Adv > MoveAdv) -> (NewMoveAdv is Adv, NewBestMove = Move); (NewMoveAdv is MoveAdv, NewBestMove = BestMove)),
  look_down_two_ply('b', PossMoves, CurrentBoardState, NewBestMove, NewMoveAdv, UltimateMove, FinalAdv).

look_down_two_ply('r', [Move | PossMoves], CurrentBoardState, BestMove, MoveAdv, UltimateMove, FinalAdv) :-
  generate_next_state('r', Move, CurrentBoardState, TempBoardState),
  land_grab('b', TempBoardState, NextBoardState, _),
  next_generation(NextBoardState, CrankedNextBoardState),
  land_grab('r', CrankedNextBoardState, FinalBoardState, _),
  next_generation(FinalBoardState, [FinalBlue, FinalRed]),
  length(FinalBlue, NumBlue),
  length(FinalRed, NumRed),
  Adv is NumRed - NumBlue,
  ((Adv > MoveAdv) -> (NewMoveAdv is Adv, NewBestMove = Move); (NewMoveAdv is MoveAdv, NewBestMove = BestMove)),
  look_down_two_ply('r', PossMoves, CurrentBoardState, NewBestMove, NewMoveAdv, UltimateMove, FinalAdv).

look_down_two_ply(_,[],_,Move,Adv,Move,Adv).