.data	# What follows will be data
prompt: .asciiz "Please enter your equation with no more than TWO operations! or bye \n>>"
welcome_input_for_t_display: .asciiz "Welcome! would you like to enter a ONE DIGIT value for t? Y or N. To end, please enter Bye \n>>"
t_equals: .asciiz "T = "
display: .asciiz "Ans: = "
endmessage: .asciiz "Turning off calculator"
error_not_valid_response: .asciiz "This is not a valid response! \n"
error_parentheses: .asciiz "Error: unbalanced parentheses! \n"
error_undefined: .asciiz "Your equation contains an invalid symbol \n"
error_operators: .asciiz "Error: missing operators \n"
error_notnumber: .asciiz "Not a number! \n"
error_divide0: .asciiz "Error: Divide by 0! \n"
done: .asciiz "\nDone! \n"
parenthenese_array: .space 12
input: .space 12	# set aside 12 bytes for use of whatever purpose
inputY_N: .space 4
array_for_t: .space 1


.text 
beginning:
la $a0, welcome_input_for_t_display
li $v0, 4 #print string 
syscall

li $v0, 8 #read string and stores in $a0
la $a0, inputY_N 
la $a1, inputY_N
syscall 

la $a0, inputY_N 
j check_for_YN

take_inputT:
la $a0, t_equals #prints t = 
li $v0, 4 #print string 
syscall

li $v0, 8 #read string and stores in $a0
la $a0, array_for_t
la $a1, array_for_t
syscall 

la $a0, array_for_t  
jal check_t #check if t contains a valid number

start_section: #start section

la $a0, prompt 
li $v0, 4 #print string 
syscall

li $v0, 8 #read string and stores in $a0
la $a0, input 
la $a1, input
syscall 

la $t0, input
jal replace_t #goes and replace t from within function

la $t0, input #reload the address on input into $t0
jal check_forillegal # jumps to check illegal function

la $t0, input #reload the address on input into $t0
jal check_forpartheses # jumps to check parenthese function

la $t0, input
jal check_unbalancedoperation # checks for unbalanced operations


la $t0, input #reload the address on input into $t0
la $t1, parenthenese_array #load the address of the parenthesis operation
jal rearrangesection #stores in new array

la $t0, parenthenese_array #contains values in memory
jal do_math_test_2

print_final_value:
la $a0, display 
li $v0, 4 #print string 
syscall


# $s5 will contain the final integer
move $a0, $s5  #Tells user it is done
li $v0, 1 #print string 
syscall

la $a0, done
li $v0, 4 #print string 
syscall

j beginning

endprogram:

la $a0, endmessage
li $v0, 4 #print string 
syscall

li $v0, 10 #end program 
syscall

#______________________________________________________________________
end: #jumps back to line after jump and link
jr $ra  


#______________________________________________________________________
#Not valid response section
not_valid_response:
la $a0, error_not_valid_response
li $v0, 4 #print string 
syscall
j beginning 


#______________________________________________________________________
#Check the response
check_for_YN: #check to see if there is a Y or N in the array or none of the options
lb $s0, ($a0)

beq $s0, 0x0000004e, start_section #N
beq $s0, 0x0000006e, start_section #n  

beq $s0, 0x00000059, take_inputT #Y
beq $s0, 0x00000079, take_inputT #y  

move $t0, $a0
beq $s0, 0x00000042, checkbye #B
beq $s0, 0x00000062, checkbye  #b
  
j not_valid_response


#______________________________________________________________________
#Check T value
check_t: #checks to see if the input is between 0 and 9
lbu $s0, 0($a0)
blt $s0, 0x00000030, not_valid_response
bgt $s0, 0x00000039, not_valid_response
j end

#______________________________________________________________________
#Replace t function section
replace_t:

lbu $t1, 0($t0)
beq $t1, 0x00000054, replace_tnow #T
beq $t1, 0x00000074, replace_tnow #t
end_of_replace_tnow:
beq $t1, 0x0000000a, end
addi $t0, $t0, 1
j replace_t 



replace_tnow: #function that replaces t
la $t2, array_for_t
lb $t3, 0($t2)
sb $t3, 0($t0)
j end_of_replace_tnow




#______________________________________________________________________
#Display Error Section:
undefined_error:
la $a0, error_undefined
li $v0, 4 #print string 
syscall
j beginning 

#______________________________________________________________________
#Checking Section:

check_forillegal: #start of check for illegal function
lbu $t2, 0($t0)


beq $t2, 0x00000042, checkbye
beq $t2, 0x00000062, checkbye 

beq $t2, 0x0000000a, end 
blt $t2, 0x00000028, undefined_error #if t2 is less than 28
bgt $t2, 0x00000039, undefined_error #if t2 is more than 44
beq $t2, 0x0000002c, undefined_error
beq $t2, 0x0000002e, undefined_error

addi $t0, $t0, 1
j check_forillegal

#______________________________________________________________________
checkbye:
addi $t0, $t0, 1
lbu $t2, 0($t0)
beq $t2, $zero, error_not_valid_response 
beq $t2, 0x00000079, endprogram #y

j undefined_error



#______________________________________________________________________
#Display Unbalanced Parenthese Section:
unbalancedparenthese:
la $a0, error_parentheses
li $v0, 4 #print string 
syscall
j beginning 


#______________________________________________________________________________________________________________
#check for parenthesis 

check_forpartheses:#start of check for parenthese function
lbu $t2, 0($t0)
beq $t2, 0x00000028, checkforrightparent
beq $t2, 0x00000029, unbalancedparenthese
beq $t2, 0x0000000a, end 
addi $t0, $t0, 1
j check_forpartheses


checkforrightparent: #check for the ride side of the the parenthese
li $t3, 0x0000000a
addi $t0, $t0, 1
lbu $t2, 0($t0)

beq $t2, $t3, unbalancedparenthese
beq $t2, 0x00000028, unbalancedparenthese  
beq $t2, 0x00000029, end

j checkforrightparent  

#______________________________________________________________________________________________________________
#unbalanced operation section print
unbalanced_operation_error:
la $a0, error_operators
li $v0, 4 #print string 
syscall
j beginning 

#______________________________________________________________________________________________________________
#divide by zero error seciton print
divide_by_zero__error:
la $a0, error_divide0
li $v0, 4 #print string 
syscall
j beginning 


#______________________________________________________________________________________________________________
#check for unbalanced operations
check_unbalancedoperation:
lbu $t1, 0($t0)
beq $t1, 0x0000002a, operation_check #multiply
beq $t1, 0x0000002f, division_operation_check #division
beq $t1, 0x0000002b, operation_check #addition
beq $t1, 0x0000002d, operation_check #subtraction
beq $t1, 0x0000000a, end
end_of_operation_check:
addi $t0, $t0, 1
j check_unbalancedoperation

  
operation_check:
addi $t0, $t0, -1
lbu $t1, 0($t0)
beq $t1, $zero, unbalanced_operation_error #zero null
beq $t1, 0x00000028, unbalanced_operation_error #(
beq $t1, 0x0000002a, unbalanced_operation_error #*
beq $t1, 0x0000002f, unbalanced_operation_error #/
beq $t1, 0x0000002b, unbalanced_operation_error #+
beq $t1, 0x0000002d, unbalanced_operation_error #-  

addi $t0, $t0, 2
lbu $t1, 0($t0)
beq $t1, 0x00000029, unbalanced_operation_error #)
beq $t1, 0x0000002a, unbalanced_operation_error #*
beq $t1, 0x0000002f, unbalanced_operation_error #/
beq $t1, 0x0000002b, unbalanced_operation_error #+
beq $t1, 0x0000002d, unbalanced_operation_error #-  
beq $t1, 0x0000000a, unbalanced_operation_error #new line

addi $t0, $t0, -1
j end_of_operation_check

division_operation_check: # will check if divide by zero
addi $t0, $t0, -1
lbu $t1, 0($t0)
beq $t1, $zero, unbalanced_operation_error #zero null
beq $t1, 0x00000028, unbalanced_operation_error #(
beq $t1, 0x0000002a, unbalanced_operation_error #*
beq $t1, 0x0000002f, unbalanced_operation_error #/
beq $t1, 0x0000002b, unbalanced_operation_error #+
beq $t1, 0x0000002d, unbalanced_operation_error #-  

addi $t0, $t0, 2
lbu $t1, 0($t0)
beq $t1, 0x00000029, unbalanced_operation_error #)
beq $t1, 0x0000002a, unbalanced_operation_error #*
beq $t1, 0x0000002f, unbalanced_operation_error #/
beq $t1, 0x0000002b, unbalanced_operation_error #+
beq $t1, 0x0000002d, unbalanced_operation_error #-  
beq $t1, 0x00000030, divide_by_zero__error # divide by zero compare  
beq $t1, 0x0000000a, unbalanced_operation_error #new line

addi $t0, $t0, -1
j end_of_operation_check

#______________________________________________________________________
rearrangesection:

copystring: # $t0 holds the primary array address, $t1 holds the secondary
lbu $t3, 0($t0)
beq $t3, 0x00000028, start_parenthese_operaion
endofstart_parenthese_operation:
sb $t3, 0($t1)
beq $t3, 0x0000000a, end
addi $t0, $t0, 1
addi $t1, $t1, 1
j copystring

#______________________________________________________________________
#do math parenthenese section

start_parenthese_operaion:
addi $t0, $t0, 1
lbu $t2, 0($t0)
beq $t2, 0x00000029, parenthese_arithmetic
addi $sp, $sp, -4 #start of fact loop
sw $t2, ($sp)
j start_parenthese_operaion

parenthese_arithmetic: #t6 second value, t7 = operator, t8 = first value, $t9 = final value
lw $t6, ($sp)
addi $t6, $t6, -48
addi $sp, $sp, 4
lw $t7, ($sp)
addi $sp, $sp, 4
lw $t8, ($sp)
addi $t8, $t8 -48
addi $sp, $sp, 4 

beq $t7, 0x0000002a, multiplication_parenthese #*
beq $t7, 0x0000002f, division_parenthese #/
beq $t7, 0x0000002b, addition_parenthese #+
beq $t7, 0x0000002d, subtraction_parenthese #-  
#__________________________________________________________________________

multiplication_parenthese:
mul $t9, $t6, $t8
addi $t9, $t9, 48
move $t3, $t9
j endofstart_parenthese_operation

division_parenthese:
div $t8, $t6
mflo $t9
addi $t9, $t9, 48
move $t3, $t9
j endofstart_parenthese_operation
 
addition_parenthese:
add $t9, $t6, $t8
addi $t9, $t9, 48
move $t3, $t9
j endofstart_parenthese_operation

subtraction_parenthese:
sub $t9, $t8, $t6
addi $t9, $t9, 48
move $t3, $t9
j endofstart_parenthese_operation

#__________________________________________________________________________
#Calculate the whole function section
# t1 contains value at memory location, #t0 contains memory location
#__________________________________________________________________________
#Do the math for two or one operations
# x1 + x2 + x3 
do_math_test_2:
lb $t1, 0($t0) # x1
addi $t1, $t1, -48  

addi $t0, $t0, 1
lb $t2, 0($t0) #+

addi $t0, $t0, 1
lb $t3, 0($t0) #x2
addi $t3, $t3, -48

addi $t0, $t0, 1 # +
lb $t4, 0($t0)
beq $t4, 0x0000000a, math_one_operation

addi $t0, $t0, 1 #x3
lb $t5, 0($t0)
addi $t5, $t5, -48 

beq $t2, 0x0000002a, multi_two_operation1 #does multi operation with pos
beq $t4, 0x0000002a, multi_two_operation2

beq $t2, 0x0000002f, division_two_operation1 #does division operation with pos
beq $t4, 0x0000002f, division_two_operation2

beq $t2, 0x0000002b, addition_two_operation1 #does addition operation with pos
beq $t4, 0x0000002b, addition_two_operation2

beq $t2, 0x0000002d, subtraction_two_operation1

j not_valid_response

#__________________________________________________________________________
multi_two_operation1:
mul $s1, $t1, $t3
beq $t4, 0x0000002f, multi_division1 #/
beq $t4, 0x0000002b, multi_addition1 #+
beq $t4, 0x0000002d, multi_subtraction1 #-  
mul $s5, $s1, $t5 #contains final value
j print_final_value

multi_division1:
div $s5, $s1, $t5
j print_final_value

multi_addition1:
add $s5, $s1, $t5
j print_final_value

multi_subtraction1:
sub $s5, $s1, $t5
j print_final_value
 
 
multi_two_operation2: ################################## multi operation 2
beq $t2, 0x0000002f, multi_division2 #/
beq $t2, 0x0000002b, multi_addition2 #+
beq $t2, 0x0000002d, multi_subtraction2 #-  
mul $s1, $t3, $t5
mul $s5, $s1, $t1 #contains final value
j print_final_value

multi_division2:
div $s5, $t1, $t3
mul $s5, $s5, $t5
j print_final_value

multi_addition2:
mul $s1, $t3, $t5
add $s5, $t1, $s1
j print_final_value

multi_subtraction2:
mul $s1, $t3, $t5
sub $s5, $t1, $s1
j print_final_value 
#__________________________________________________________________________
division_two_operation1:
div $s1, $t1, $t3
beq $t4, 0x0000002b, division_addition1 #+
beq $t4, 0x0000002d, division_subtraction1 #-  
div $s5, $s1, $t5 #contains final value
j print_final_value

division_addition1:
add $s5, $s1, $t5
j print_final_value

division_subtraction1:
sub $s5, $s1, $t5
j print_final_value


division_two_operation2:
beq $t2, 0x0000002b, division_addition2 #+
beq $t2, 0x0000002d, division_subtraction2 #-
div $s1, $t1, $t3  
div $s5, $s1, $t5 #contains final value
j print_final_value

division_addition2:
div $s1, $t3, $t5
add $s5, $t1, $s1
j print_final_value

division_subtraction2:
div $s1, $t3, $t5
sub $s5, $t1, $s1
j print_final_value
#__________________________________________________________________________
addition_two_operation1:
add $s1, $t1, $t3
beq $t4, 0x0000002d, addition_subtraction1 #-  
add $s5, $s1, $t5 #contains final value
j print_final_value

addition_subtraction1:
sub $s5, $s1, $t5
j print_final_value


addition_two_operation2:
beq $t2, 0x0000002d, addition_subtraction2 #-
add $s1, $t1, $t3  
add $s5, $s1, $t5 #contains final value
j print_final_value

addition_subtraction2:
sub $s1, $t1, $t3
add $s5, $s1, $t5
j print_final_value


#__________________________________________________________________________
subtraction_two_operation1:
sub $s1, $t1, $t3
sub $s5, $s1, $t5
j print_final_value

#__________________________________________________________________________
math_one_operation:

beq $t2, 0x0000002a, multi_one_operation #*
beq $t2, 0x0000002f, division_one_operation #/
beq $t2, 0x0000002b, addition_one_operation #+
beq $t2, 0x0000002d, subtraction_one_operation #-  

multi_one_operation:
mul $s5, $t1, $t3
j print_final_value

division_one_operation:
div $s5, $t1, $t3
j print_final_value

addition_one_operation:
add $s5, $t1, $t3
j print_final_value

subtraction_one_operation:
sub $s5, $t1, $t3
j print_final_value

#__________________________________________________________________________
#End



