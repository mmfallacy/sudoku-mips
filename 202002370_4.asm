# CS 21 3 -- S2 AY 2021-2022
# Michael Angelo Monasterial -- 04/06/2022
# 202002370_4.asm -- Sudoku 4x4 main asm file.

.eqv BOARD_SIZE 4
.eqv BOARD_SIZE_SQRT 2

.globl	main
# ====================================================================================
# Stash register to current stack frame for isolated use
.macro	stash(%reg)
			subu	$sp, $sp, 4
			sw	%reg, 0($sp)
.end_macro
# Pop topmost stashed register value in current stack frame
.macro	pop(%reg)
			lw	%reg, 0($sp)
			add	$sp, $sp, 4
.end_macro

# Equivalence for return-like keyword for ending functions
.eqv	return		jr 	$ra

# Call macro for invoking procedures
.macro	call(%fn, %a0, %a1, %a2, %a3)
			add 	$a0, $0, %a0	
			add 	$a1, $0, %a1	
			add 	$a2, $0, %a2	
			add 	$a3, $0, %a3
			jal	%fn
.end_macro
# ====================================================================================
.text
			b	main					# Start at global main:
#========# Procedure: Asks for board input and puts it in specified label's address
#========# (buffer address, target address)
	input_board:	stash($ra)
			stash($s0)
			stash($s1)
			
			li	$v0, 8
			la	$a0, boardstring			# Set buffer for boardstring input
			li	$a1, BOARD_SIZE				# Compute how many characters to read
			addi	$a1, $a1, 1				# Account for additional character (space or \n)
			mul	$a1, $a1, BOARD_SIZE
			syscall
			
			li	$s0, 0
			li	$s1, -1					# Skip first check
			li	$t2, 0
			li	$t3, 0
	#  == While input != 0
	ib_l:		beqz	$s1, ib_d
	
			lbu	$s1, boardstring($s0)			# Load character
			
			blt	$s1, 48, ib_nan				# If non numeric
			
			sub	$s1, $s1, 48
			call(store_integer, $t2, $t3, $s1, 0)
			add	$s1, $s1, 48
	ib_skip:	
			add	$t3, $t3, 1				# Increment 
			add	$s0, $s0, 1				# Increment
			b	ib_l
			
	ib_nan:	add	$t2, $t2, 1				# Increment row
			li	$t3, -1
			b 	ib_skip
	# == ENDWHILE
	ib_d:		
			pop($s1)
			pop($s0)
			pop($ra)
			return
#========# Procedure: Asks for row string input and puts it in specified label's address
#========# (offset)
input_row_string:	stash($ra)

			li 	$v0, 8					# Syscall 8
			la	$a0, board				# Load address of board storage
			add	$a0, $a0, $a1				# Move address for string buffer by offset (subsequent rows)
			li	$a1, BOARD_SIZE
			add	$a1, $a1, 1				# Set no. of chars to read as BOARD_SIZE + 1
			syscall 

			pop($ra)
			return
#========# Procedure: Loads integer at cell (row, col)
#========# (r,c)
	load_integer: 	stash($ra)
			stash($s0)
			
			mul	$s0, $a0, 32
			add	$s0, $s0, $a1				# Compute address offset from board label
			
			lbu	$v0, board($s0)				# Get ASCII digit at computed address
			
			subu	$v0, $v0, 48				# Convert ASCII digit to integer
	
			pop($s0)
			pop($ra)
			return
#========# Procedure: Stores integer at cell (row, col)
#========# (r,c)
	store_integer: 	stash($ra)
			stash($s0)
			
			mul	$s0, $a0, 32
			add	$s0, $s0, $a1				# Compute address offset from board label
			
			addu	$a2, $a2, 48				# Convert ASCII digit to integer
			
			sb	$a2, board($s0)				# Get ASCII digit at computed address
	
			pop($s0)
			pop($ra)
			return
#========# Procedure: Prints board
	print_board:	stash($ra)
			stash($s0)
			li	$t0, BOARD_SIZE
			sub	$t0, $t0, 1
			mul	$t0, $t0, 32				# Compute bounds
			
			la	$t1, board				# Get board address
			
			li	$s0, 0					# Row Iterator
	pb_l:		bgt	$s0, $t0, pb_d
			
			li	$v0, 4
			add	$a0, $s0, $t1
			
			syscall
			
			li	$v0, 11
			li	$a0, '\n'
			
			syscall
			
			addi	$s0, $s0, 32
			b	pb_l
	pb_d:		
			pop($s0)
			pop($ra)
			return

#========# Procedure: Checks if the current integer in cell (r,c) fits the rules of sudoku
#========# (r,c)
	valid_cell:	stash($ra)
			stash($s0)
			stash($s1)
			stash($s2)
			stash($s3)
			stash($s4)
			stash($s5)
			
			move	$s0, $a0				# Localize (r,c)
			move	$s1, $a1			
			call(load_integer, $s0, $s1, 0, 0)		# Get integer at cell (r,c)
			move	$s2, $v0				# Localize integer at (r,c)
			
			li	$v0, -1					# Guard for integer at (r,c) == 0
			beqz	$s2, vc_return
			
	# Determine if integer in current cell (r,c) matches any cell in its row and column except possibly at (r,c)
			li	$s3, 0					# Iterator
	# == [$s3] for $s1 in range [0,BOARD_SIZE-1]			
	vc_line_l:	beq	$s3, BOARD_SIZE, vc_line_d	
			
	# Row checker
			sne	$t0, $s3, $s1				# Check if (r,c) != (r,$s3)
			call(load_integer, $s0, $s3, 0, 0)		# Get integer at (r,$s3) 
			seq	$t1, $v0, $s2				# Check if integer read matches current cell

	# Column checker						
			sne	$t2, $s3, $s0				# Check if (r,c) != ($s3,c)
			call(load_integer, $s3, $s1, 0, 0)		# Get integer at ($s3,c)
			seq	$t3, $v0, $s2				# Check if integer read matches current cell
	
	# Matcher		
			and	$t0, $t0, $t1				# $t0 := (r,c) != (r,$s3) && integer matches
			and	$t2, $t2, $t3				# $t0 := (r,c) != (r,$s3) && integer matches
			or 	$t0, $t0, $t2				# Either row checker or column checker produces a matching result
			
			bnez	$t0, vc_match				# Halt if conditions above are met
			
			addi	$s3, $s3, 1				# $s1++
			b	vc_line_l				# Loop
	
	# == [$s3] ENDFOR			
	vc_line_d:		
	# Traverse the subgrids and populate the
	
			rem	$s4, $s0, BOARD_SIZE_SQRT		# Get remainder of (r,c) divided by sqrt(BOARD_SIZE)
			rem	$s5, $s1, BOARD_SIZE_SQRT		
						
			sub	$s4, $s0, $s4				# Get offset to subgrid
			sub	$s5, $s1, $s5
			
			li 	$t0, 0	
	# == [RI] for ri in range(0,BOARD_SIZE_SQRT)
	vc_subgridr_l:	beq	$t0, BOARD_SIZE_SQRT, vc_subgridr_d	# Iterate columns of subgrid 
			add	$t2, $s4, $t0				# Row of (ri,ci) cell in subgrid
			li	$t1, 0					# ci := t1
    	# == [CI] for ci in range(0,BOARD_SIZE_SQRT)	
	vc_subgridc_l:	beq	$t1, BOARD_SIZE_SQRT, vc_subgridc_d
			add	$t3, $s5, $t1				# Column of (ri,ci) cell in subgrid
	
	bkpt:		call(load_integer, $t2, $t3, 0, 0)		# Load integer at ith cell in subgrid
			
			sne	$t4, $t2, $s0				
			sne	$t5, $t3, $s1				
			or	$t4, $t4, $t5				# (r,c) != ($t2, $t3)
			
			seq 	$t5, $v0, $s2				# Integer read matches current cell
			and	$t4, $t4, $t5				# Subgrid matcher produces a matching result
			
			bnez	$t4, vc_match				# Halt if conditions above are met
	
			addi	$t1, $t1, 1
			b	vc_subgridc_l
   	# == [CI] endfor
	vc_subgridc_d: 
			addi	$t0, $t0, 1
			b	vc_subgridr_l
    	# == [RI] endfor	
	vc_subgridr_d:	li	$v0, 1					# Valid
	vc_return:	pop($s5)
			pop($s4)
			pop($s3)
			pop($s2)
			pop($s1)
			pop($s0)
			pop($ra)
			return
			
	vc_match:	li	$v0, 0					# Invalid
			b	vc_return
#========# Procedure: Solves the sudoku board stored at label `board`
	solve:		stash($ra)
			stash($s0)
			stash($s1)
			stash($s2)
			
			li	$s0, 0					# Row Iterator
	# == [RI, CI] while cell (ri,ci) is not zero
	solve_zeror_l:	beq	$s0, BOARD_SIZE, solve_d		# Get Row of first zero 
			li	$s1, 0					# Column Iterator
	
	# == Traverse current row
	solve_zeroc_l:	beq	$s1, BOARD_SIZE, solve_zeroc_d		# Get Column of first zero
	
			call(load_integer, $s0, $s1, 0, 0)
			
			beqz	$v0, solve_zero_d			# Halt if zero is found
	
			addi	$s1, $s1, 1
			b	solve_zeroc_l
	# == Proceed to next row
	solve_zeroc_d:
			addi	$s0, $s0, 1
			b	solve_zeror_l
	
	# == Found Zero at (ri,ci)
	solve_zero_d:
			li 	$s2, 1
	# == [$s2] for i in range [1,9]
	solve_dec_l: 	bgt	$s2, BOARD_SIZE, solve_dec_d
	
			call(store_integer, $s0, $s1, $s2, 0)		# Attempt decision
			
			call(valid_cell, $s0, $s1, 0, 0)		# Check if decision is valid
			
			beqz	$v0, solve_dec_skip			# Skip if decision is not valid
			
			jal solve
			
	solve_dec_skip:	call(store_integer, $s0, $s1, $0, 0)		# Revert	
	
			addi	$s2, $s2, 1
			b	solve_dec_l
	# == ENDFOR
	solve_dec_d:
	
	solve_return:	
			pop($s2)
			pop($s1)
			pop($s0)
			pop($ra)
			return
	# == Done	
	solve_d:	
			call(print_board, 0, 0, 0, 0)
			b 	exit
#========# Procedure: Exits the current program
	exit:		li	$v0, 10
			syscall
	
#========# MAIN: Main entry point of the program
	main:		li	$t0, BOARD_SIZE
			li	$t1, 0
			
	#		call(input_board, 0, 0, 0, 0)		# Uncomment if mode of input is syscall popup
			
	#		b 	input_done
			
	input_loop:	beqz	$t0, input_done
			
			call(input_row_string, $t2, $t1, 0, 0)
			
			addi	$t1, $t1, 32
			sub	$t0, $t0, 1
			b	input_loop
			
	input_done:	call(solve, 0, 0, 0, 0)
			b	exit
.data
	board:		.space	288					# Allocate 9 * 32 space for the board
	nl:		.asciiz	"-------------------------------"	# Allocate one row (32 spaces) for debugging purposes
	boardstring:	.space	90					# Allocate temporary space for contiguous string representation of board
