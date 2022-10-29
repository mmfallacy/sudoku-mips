# CS 21 Machine Problem 1

## Sudoku Solver

##### Michael Angelo L. Monasterial

##### 2020-02370

---

> **Video Documentation Link:** [CS21MP1_Docvid_202002370](https://drive.google.com/file/d/13fg3tVA38BdTsIDpmM3IEOUo1-e69rHH/view?usp=sharing)

### 1. Summary on how the Solver works

This solver works under the premise that all inputs are solvable, hence it is not capable of determining if a board is unsolvable and terminates upon arriving at a solution.

The primary concept used for implementing this solver is backtracking, which is a technique that exhaust every possible state of some problem, tracing back when it reaches an impossibility until a solution is obtained.

The solver first asks for `n` inputs, with `n` as the `BOARD_SIZE`. Every input serves as the string representation of a Sudoku board. After successfully populating the Sudoku board, a backtracking algorithm is used. This algorithm involves obtaining the first zero cell of the board and it attempts to fill it with digits from $1$ to $9$. Upon finding some integer from the said range, it stores it in the aforementioned cell and attempts to fill the remaining empty cells. The solver then returns to the previous decision made once it reaches a cell without any valid solution and reverts it so it can attempt to fill it with the next possible solution until it arrives at a complete board.

This solver is able to solve a 4x4 board and a 9x9 board using the same algorithm. The only difference needed to be made is that the `BOARD_SIZE` needs to be specified, as well as the `BOARD_SIZE_SQRT`.

### 2. High-level Pseudocode

The following code blocks below is written in a pseudocode syntactically similar to Python. Hence, `range(p,q)` produces an iterable from `p` to `q-1`.

- Let `BOARD_SIZE` be equal to the height (and width) of the Sudoku board input. This can be tweaked to solve a 4x4 or 9x9 Sudoku board. 

- Let procedure `STORE_LINE` take three inputs: `rs`:= string to store, `label` := where to store `rs`, and `offset`:= how far from the start of `label` `rs` should be stored. This procedure then stores a string at some specified memory address.

- Also, let `board` be some label that denotes the start of some memory address with $288$ bytes allocated. This is due to the fact that input is represented as lines of strings, separated a few bytes to form a 2d board in the Data segment of MARS MIPS
  
  ![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-20-30-00-image.png) 

- The code block below shows the `MAIN` procedure which serves as the entry point of the application. This procedure handles taking the board input and invokes procedure `SOLVE` upon populating the board representation.

```python
procedure MAIN: None
    for i range(0,BOARD_SIZE):
        rs := take one line as input
        STORE_LINE(rs, board, i*32)

    SOLVE()
```

- Let `LOAD_INTEGER` and `STORE_INTEGER` be procedures that, given some `r` and `c`, loads (or stores) an integer as part of the sudoku board representation at cell `(r,c)`. Procedure `STORE_INTEGER` also takes input `i`:= integer to store at cell `(r,c)`

- The code block below shows the `VALID_CELL` procedure which takes two inputs: `r` := row of a cell and `c`:= column of a cell. This procedures checks if the current inputted cell contains a value that adheres to the rules of Sudoku. That is, no repeated digits (from 1 to 9) in a row, column, and subgrid.

```python
procedure VALID_CELL(r: int, c: int): bool
    cell := LOAD_INTEGER(r,c)

    for i in range(0, BOARD_SIZE):
        rc := LOAD_I   NTEGER(r,i)
        cc := LOAD_INTEGER(i,c)

        # If cell matches some other cell in its row (or column) aside from itself
        if (cell == rc and (r,i) != (r,c) or
            cell == cc and (i,c)!=(r,c)): return 0

    # Take start of subgrid's row and col
    sr :=  r - r % sqrt(BOARD_SIZE)
    sc :=  c - c % sqrt(BOARD_SIZE)

    for ri in range(0, sqrt(BOARD_SIZE)):
        for ci in range(0, sqrt(BOARD_SIZE)):
            sc := LOAD_INTEGER(sr+ri, sc+ci)

            # If cell matches some other cell in its subgrid aside from itself
            if (cell == sc and (sr+r1, sc+ci) != (r,c)): return 0

    return 1 
```

- Let `PRINT_BOARD` be a procedure that prints the sudoku board representation as a series of strings, each on its own line. Observe that for simplicity of implementation, a trailing `\n` newline character is present at the end of the board.

- The code block below shows the `SOLVE` procedure. This procedure applies the backtracking algorithm which tests every integer from 1 to 9 on empty cells (denoted as 0) and backtracks whenever a series of decisions result into a cell without any possible solutions.

```python
procedure SOLVE:
    # Obtain r,c of first empty cell 
    for r in range(0, BOARD_SIZE+1):

        # Base Case: If all cells are non-empty
        if(r==BOARD_SIZE) {
            PRINT_BOARD()
            EXIT()
        }

        for c in range(0, BOARD_SIZE):
            cell := LOAD_INTEGER(r,c)
            if(cell == 0) break


    for i in range(1,10):
        STORE_INTEGER(r,c,i)    # Attempt
        if VALID_CELL(r,c):
            SOLVE()    # Recurse
        STORE_INTEGER(r,c,0)    # Revert


    return
```

Observe that these pseudocodes exhibit the program flow of both the 4x4 and 9x9 Sudoku solver as the only difference in both implementations are the values of `BOARD_SIZE`.

### 3. Procedures and Macros

The following section exhibits every macro and procedure used/defined within the program.

#### 3.1 Macros

##### 3.1.1 Macros defined  by `.eqv` directive

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-21-54-55-image.png)

These macros hold program constants that are used in the sudoku solver algorithm. Observe that you can change `BOARD_SIZE` and `BOARD_SIZE_SQRT` to $4$ and $2$ respectively to switch from a 9x9 solver to 4x4 sudoku solver.

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-22-05-57-image.png)

This macro serves as a shorthand for returning from a procedure. This intends to simulate the `return` keyword in most programming languages.

##### 3.1.2 Stash Macro

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-21-57-27-image.png)

This macro serves as a shorthand for quickly stashing a value in the stack by allocating $4$ bytes (since a register can only hold 4 bytes) in the current stack frame and storing it there.

##### 3.1.3 Pop Macro

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-22-04-20-image.png)

This macro serves as a shorthand for popping the topmost value in the current stack frame and storing it in the specified register.

##### 3.1.4 Call Macro

##### ![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-28-22-35-02-image.png)

This macro serves as a shorthand for invoking functions. The macro also takes in parameters which are used to populate the argument registers of a procedure.

#### 3.2. Procedures

##### 3.2.1 `input_row_string`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-00-52-16-image.png)

Procedure `input_row_string` encapsulates the part of procedure `main` in charge of taking a string input which represents a row in the Sudoku board. This is implemented using `syscall 8` which takes in a buffer address and input length.

##### 3.2.2 `load_integer`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-04-11-image.png)

Procedure `load_integer` takes two integer inputs which corresponds to the row and column of the target cell. This is implemented with the intention of encapsulating the offset computation, loading of character from the board representation and conversion from ASCII to integer type into a black box the developer can interface. 

The offset computation involves multiplying the row input by 32, since the Data segment of MARS MIPS displays the data in a tabular manner, with the rows as addresses split into intervals of $32$ bytes and columns as the offset of stored words from the current row's address.

The conversion of ASCII to integer type is computed through subtracting $48$ from the ASCII's decimal interpretation since the character `0` is represented as $48$.

##### 3.2.3 `store_integer`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-15-36-image.png)

Procedure `store_integer` acts as the inverse of `load_integer`. This aims to store an integer into the given cell's row and column by converting it into an ASCII character and storing its byte representation onto the computed offset.

##### 3.2.4 `print_board`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-24-28-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-24-38-image.png)

Procedure `print_board` prints the board representation by iterating through the rows of the board representation and using their addresses as inputs to `syscall 4`. Note that everytime a row is printed, a linefeed `\n` character is printed after. This causes an extra linefeed character to be printed upon reaching the final row.

##### 3.2.5 `valid_cell`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-27-26-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-27-39-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-27-50-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-28-04-image.png)

Procedure `valid_cell` is the MIPS implementation of procedure `VALID_CELL` mentioned in Section 2. This procedure checks if a cell adheres to the rules of Sudoku given its row and column. This utilizes the `load_integer` procedure and a couple of loops to traverse the row and column of the current cell in question as well as the subgrid it belongs to to check if there exists a match. The `valid_cell` procedure is also used by the backtracking procedure `solve` to check if a certain decision is appropriate or not. 

Observe that the if condition checks are implemented as a combination of relational binary expressions using the instructions `sne`, `or`, `seq`, and, `and`.

##### 3.2.6 `solve`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-50-36-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-50-44-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-51-00-image.png)

Procedure `solve` takes care of the backtracking aspect of the solver. It searches for the top-left most zero, which denotes an empty cell, and attempts to solve it by exhausting every possible integer. Upon reaching the first valid integer for that cell, it recurses and attempts to solve the next empty cell. This repeats until the board is finished or some cell has no possible solution. In the case where a cell has no possible solution, it backtracks, which effectively exhausts every possible state of the board until a solution is met. This is implemented by utilizing the aforementioned procedures `load_integer` (used for finding the top-left most zero), `store_integer` (used for applying and reverting a decision), and `valid_cell` (acts as the condition if a decision is deemed valid or if it should be skipped).

##### 3.2.6 `exit`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-01-51-28-image.png)

Procedure `exit` handles the termination of the program by using `syscall 10`

##### 3.2.7 `main`

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-02-11-58-image.png)

Procedure `main` is the entry point of the application. This procedure handles the board input and upon populating the board stored in memory, it invokes the `solve` procedure. Note that in this implementation of `main`, a separate input method is defined which is procedure `input_board`. This procedure is only used for debugging purposes as opposed to the `input_row_string` procedure.

##### 3.2.8 `input_board` (debugging only)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-02-14-04-image.png)

![](D:\Programs\MARS%20Mips\MIPS\Project\assets\2022-04-29-02-14-23-image.png)

Procedure `input_board` is used for debugging purposes. This procedure was implemented to handle boards inputted using the syscall popup of MARS MIPS. Its implementation consists of taking in the board input (instead of linefeed characters, rows are space separated) and placing it in a `boardstring` allocation of $90$ bytes. Afterwards, it is then processed by iterating over `boardstring` and placing every character onto the board representation.  

### 4. Sample Test Cases

    The following are test cases collated from the internet.

#### 4.1 Test Cases for 4x4 Solver

**Inputs:**

```python
# TC 1
1000
3010
0004
0320

# TC 2
3000
4000
0001
1023

# TC 3
0004
2000
0100
0010

# TC 4
4000
0030
0400
0002
```

**Expected Outputs:**

```python
# TC 1
1243
3412
2134
4321

# TC 2
3214
4132
2341
1423

# TC 3
1324
2431
3142
4213

# TC 4
4321
1234
2413
3142
```

**Source:** [Sudoku-download.net](http://www.sudoku-download.net/sudoku_4x4.php)

#### 4.2 Test Cases for 9x9 Solver

**Inputs:**

```python
# TC 1
001000890
027009050
004082000
060920140
000050000
098061030
000210400
010700360
079000200

# TC 2
400000020
800709000
016300000
509000010
374201586
080000709
000007630
000805004
090000007

# TC 3
200810046
000600100
107000020
000000261
020903050
654000000
010000604
003006000
480079005

# TC 4
590007080
000500007
410800506
001300004
005000900
800004200
902003045
100005000
050400069
```

**Expected Outputs:**

```python
# TC 1
631574892
827139654
954682713
765923148
143857926
298461537
386215479
412798365
579346281

# TC 2
437586921
852719463
916342875
569478312
374291586
281653749
145927638
723865194
698134257

# TC 3
235817946
948652173
167394528
379485261
821963457
654721839
712538694
593146782
486279315

# TC 4
596147382
328596417
417832596
271389654
645271938
839654271
962713845
184965723
753428169
```

**Source:** [GitHub - gaberife/SudokuSolver](https://github.com/gaberife/SudokuSolver)

> **Remark:** Sample test cases from the Machine problem document are not included here since additional test cases are more important to prove the veracity and reliability of the solver.
