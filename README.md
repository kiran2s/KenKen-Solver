# KenKen-Solver

Two KenKen solvers are provided in KenKenSolver.pl: kenken/3 and plain_kenken/3.
Both take the following 3 arguments:

1. A nonnegative integer N specifying the dimensions of the KenKen grid.
2. A list C of numeric cage constraints as specified below.
3. A list of list of integers T representing the N×N grid.

Each constraint is specified by one of the following forms:

+(S, L):    S = sum of integers in L, where S is an integer and L is a list of grid indices.

*(P, L):    P = product of integers in L, where P is an integer and L is a list of grid indices.

−(D, J, K): D = |j-k|, where D is an integer and j and k are the integers corresponding to grid indices J and K respectively.

/(Q, J, K): Q = j/k or k/j, where Q is an integer and j and k are the integers corresponding to grid indices J and K respectively.
The remainder must equal 0.

A grid index is specified by i-j, where i and j are row and column indices in the range 1 through N, inclusive.
The bottom-left and top-right squares are specified by N-1 and 1-N respectively.

The difference between the solvers kenken/3 and plain_kenken/3 is that kenken/3 makes use of the GNU Prolog finite domain solver
while plain_kenken/3 does not.
