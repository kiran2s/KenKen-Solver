/*****************************/
/*** KENKEN IMPLEMENTATION ***/
/*****************************/

/*
Performance statistics of kenken/3 when tested on the 4 x 4 Kenken puzzle
testcase provided:

user   time:	0.000 sec
system time:	0.000 sec
cpu    time:	0.000 sec
real   time:	0.000 sec

Memory               limit         in use            free

   trail  stack      16383 Kb            3 Kb        16380 Kb
   cstr   stack      16383 Kb            4 Kb        16379 Kb
   global stack      32768 Kb            2 Kb        32766 Kb
   local  stack      16383 Kb            1 Kb        16382 Kb
   atom   table      32768 atoms      1796 atoms     30972 atoms

kenken/3 completes the 6 x 6 Kenken testcase provided very quickly as well.
*/

% First ensures that T is an N x N grid, then applies the domain constraint
% that each cell can only contain an integer from 1 through N. The constraint
% that every cell within the same row or column must contain different integers
% is then applied. The cage constraints are then checked for, and it is ensured
% that all cells contain ground terms before outputing the result to the user.
kenken(N, C, T) :-
	length(T, N), maplist(verify_length(N), T),
	maplist(apply_domain_constraint(1, N), T),
	maplist(fd_all_different, T),
	apply_all_different_to_columns(N, T),
	apply_cage_constraints(C, T),
	maplist(fd_labeling, T).

% Swaps the order of the length/2 arguments for use with maplist.
verify_length(Length, List) :- length(List, Length).

% Changes the order of the fd_domain/3 arguments for use with maplist.
apply_domain_constraint(Lower, Upper, Vars) :- fd_domain(Vars, Lower, Upper).

% Ensures that every cell within the same column contains different integers.
apply_all_different_to_columns(_, T) :- all_columns_empty(T).
apply_all_different_to_columns(N, T) :-
	length(L, N),
	match_column_to_list(T, L, RemainingColumns),
	fd_all_different(L),
	apply_all_different_to_columns(N, RemainingColumns).

% Helper predicate that matches the 1st column of a matrix (1st argument) with
% a list (2nd argument) and returns the matrix with the 1st column removed.
match_column_to_list([], [], []).
match_column_to_list(	[[CellVal|RemRowVals]|Tt],
						[CellVal|Lt],
						[RemRowVals|RemSubRows]		) :-
	match_column_to_list(Tt, Lt, RemSubRows).

% Helper predicate that checks that all lists within the argument are empty.
all_columns_empty([]).
all_columns_empty([[]|RemainingColumns]) :- all_columns_empty(RemainingColumns).

% Checks all cage constraints against the input kenken grid.
apply_cage_constraints([], _).
apply_cage_constraints([Ch|Ct], T) :-
	verify_cage_constraint(Ch, T),
	apply_cage_constraints(Ct, T).

% Matches a given constraint with 1 of the 4 kenken arithmetic operations.
verify_cage_constraint(+(S, L), T) :- sum(0, S, L, T).
verify_cage_constraint(*(P, L), T) :- prod(1, P, L, T).
verify_cage_constraint(-(D, J, K), T) :- diff(D, J, K, T).
verify_cage_constraint(/(Q, J, K), T) :- quot(Q, J, K, T).

% Checks if the sum constraint of a cage is met.
sum(S, S, [], _).
sum(SumOfCells, S, [RowIndex-ColIndex|Lt], T) :-
	nth(RowIndex, T, Row), nth(ColIndex, Row, CellVal),
	NewSum #= SumOfCells + CellVal, sum(NewSum, S, Lt, T).

% Checks if the product constraint of a cage is met.
prod(P, P, [], _).
prod(ProdOfCells, P, [RowIndex-ColIndex|Lt], T) :-
	nth(RowIndex, T, Row), nth(ColIndex, Row, CellVal),
	NewProd #= ProdOfCells * CellVal, prod(NewProd, P, Lt, T).

% Checks if the difference constraint of a cage is met.
diff(D, Jr-Jc, Kr-Kc, T) :-
	nth(Jr, T, JRow), nth(Jc, JRow, JCellVal),
	nth(Kr, T, KRow), nth(Kc, KRow, KCellVal),
	(D #= JCellVal - KCellVal; D #= KCellVal - JCellVal).

% Checks if the quotient constraint of a cage is met.
quot(Q, Jr-Jc, Kr-Kc, T) :-
	nth(Jr, T, JRow), nth(Jc, JRow, JCellVal),
	nth(Kr, T, KRow), nth(Kc, KRow, KCellVal),
	(Q #= JCellVal / KCellVal; Q #= KCellVal / JCellVal).


/***********************************/
/*** PLAIN_KENKEN IMPLEMENTATION ***/
/***********************************/

/*
Performance statistics of plain_kenken/3 when tested on the 4 x 4 Kenken puzzle
testcase provided:

user   time:	0.020 to 0.084 sec
system time:	0.000 sec
cpu    time:	0.016 to 0.084 sec
real   time:	0.015 to 0.086 sec

Memory               limit         in use            free

   trail  stack      16383 Kb            0 Kb        16383 Kb
   cstr   stack      16384 Kb            0 Kb        16384 Kb
   global stack      32768 Kb            2 Kb        32766 Kb
   local  stack      16383 Kb            3 Kb        16380 Kb
   atom   table      32768 atoms      1796 atoms     30972 atoms

Overall, kenken/3 clearly takes less time across the board than plain_kenken/3
and uses less of the local stack. However, kenken/3 uses more of the trail and
cstr stacks than plain_kenken/3. It is worth noting that plain_kenken/3 takes
a very long time with the 6 x 6 kenken testcase provided, so much time in fact
that I was never able to complete the test. My implementation of plain_kenken/3
also takes a very long time handling 5 x 5 kenken puzzles. plain_kenken/3 took
65356 ms to determine just one solution to the testcase plain_kenken(5,[],T).
*/

% Similar to kenken/3 but does not use the GNU Prolog finite domain solver.
% First ensures that T is an N x N grid. Then ensures that each row and column
% is a permutation of an N-length list containing all integers from 1 to N.
% The cage constraints are then checked for.
plain_kenken(N, C, T) :-
	length(T, N), maplist(verify_length(N), T),
	list_from_N_to_1(N, LNto1), reverse(LNto1, L1toN),
	maplist(permutation(L1toN), T),
	plain_apply_all_different_to_columns(L1toN, N, T),
	plain_apply_cage_constraints(C, T).

% Helper predicate that checks if the 2nd argument is an N-length list
% containing all integers from N to 1 in descending order.
list_from_N_to_1(0, []).
list_from_N_to_1(N, [Lh|Lt]) :-
	length([Lh|Lt], N),
	Lh is N,
	NMinus1 is N - 1,
	list_from_N_to_1(NMinus1, Lt).

% Ensures that every cell within the same column contains different integers.
plain_apply_all_different_to_columns(_, _, T) :- all_columns_empty(T).
plain_apply_all_different_to_columns(L1toN, N, T) :-
	length(L, N),
	match_column_to_list(T, L, RemainingColumns), permutation(L, L1toN),
	plain_apply_all_different_to_columns(L1toN, N, RemainingColumns).

% Checks all cage constraints against the input kenken grid.
plain_apply_cage_constraints([], _).
plain_apply_cage_constraints([Ch|Ct], T) :-
	plain_verify_cage_constraint(Ch, T),
	plain_apply_cage_constraints(Ct, T).

% Matches a given constraint with 1 of the 4 kenken arithmetic operations.
plain_verify_cage_constraint(+(S, L), T) :- plain_sum(0, S, L, T).
plain_verify_cage_constraint(*(P, L), T) :- plain_prod(1, P, L, T).
plain_verify_cage_constraint(-(D, J, K), T) :- plain_diff(D, J, K, T).
plain_verify_cage_constraint(/(Q, J, K), T) :- plain_quot(Q, J, K, T).

% Checks if the sum constraint of a cage is met without using the
% the GNU Prolog finite domain solver.
plain_sum(S, S, [], _).
plain_sum(SumOfCells, S, [RowIndex-ColIndex|Lt], T) :-
	nth(RowIndex, T, Row), nth(ColIndex, Row, CellVal),
	integer(SumOfCells), integer(CellVal),
	NewSum is SumOfCells + CellVal, plain_sum(NewSum, S, Lt, T).

% Checks if the product constraint of a cage is met without using the
% the GNU Prolog finite domain solver.
plain_prod(P, P, [], _).
plain_prod(ProdOfCells, P, [RowIndex-ColIndex|Lt], T) :-
	nth(RowIndex, T, Row), nth(ColIndex, Row, CellVal),
	integer(ProdOfCells), integer(CellVal),
	NewProd is ProdOfCells * CellVal, plain_prod(NewProd, P, Lt, T).

% Checks if the difference constraint of a cage is met without using the
% the GNU Prolog finite domain solver.
plain_diff(D, Jr-Jc, Kr-Kc, T) :-
	nth(Jr, T, JRow), nth(Jc, JRow, JCellVal),
	nth(Kr, T, KRow), nth(Kc, KRow, KCellVal),
	integer(JCellVal), integer(KCellVal),
	((D is JCellVal - KCellVal); (D is KCellVal - JCellVal)).

% Checks if the quotient constraint of a cage is met without using the
% the GNU Prolog finite domain solver.
plain_quot(Q, Jr-Jc, Kr-Kc, T) :-
	nth(Jr, T, JRow), nth(Jc, JRow, JCellVal),
	nth(Kr, T, KRow), nth(Kc, KRow, KCellVal),
	integer(JCellVal), integer(KCellVal),
	((Q is JCellVal / KCellVal); (Q is KCellVal / JCellVal)).

