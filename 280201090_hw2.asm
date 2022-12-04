##############################################################
#Dynamic array
##############################################################
#   4 Bytes - Capacity
#	4 Bytes - Size
#   4 Bytes - Address of the Elements
##############################################################

##############################################################
#Song
##############################################################
#   4 Bytes - Address of the Name (name itself is 64 bytes)
#   4 Bytes - Duration
##############################################################


.data
space: .asciiz " "
newLine: .asciiz "\n"
tab: .asciiz "\t"
menu: .asciiz "\n● To add a song to the list-> \t\t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
menuWarn: .asciiz "Please enter a valid input!\n"
name: .asciiz "Enter the name of the song: "
duration: .asciiz "Enter the duration: "
name2: .asciiz "Song name: "
duration2: .asciiz "Song duration: "
emptyList: .asciiz "List is empty!\n"
noSong: .asciiz "\nSong not found!\n"
songAdded: .asciiz "\nSong added.\n"
songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
songListAddress: .word 0 #the address of the song list stored here!

.text 
main:

	jal initDynamicArray
	sw $v0, songListAddress
	
	la $t0, sReg
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	lw $s4, 16($t0)
	lw $s5, 20($t0)
	lw $s6, 24($t0)
	lw $s7, 28($t0)

menuStart:
	la $a0, menu    
    li $v0, 4
    syscall

	li $v0,  5
    syscall
	li $t0, 1
	beq $v0, $t0, addSong
	li $t0, 2
	beq $v0, $t0, deleteSong
	li $t0, 3
	beq $v0, $t0, listSongs
	li $t0, 4
	beq $v0, $t0, terminate
	
	la $a0, menuWarn    
    li $v0, 4
    syscall
	b menuStart
	
addSong:
	jal createSong
	lw $a0, songListAddress
	move $a1, $v0
	jal putElement
	b menuStart
	
deleteSong:
	lw $a0, songListAddress
	jal findSong
	lw $a0, songListAddress
	move $a1, $v0
	jal removeElement
	b menuStart
	
listSongs:
	lw $a0, songListAddress
	jal listElements
	b menuStart
	
terminate:
	la $a0, newLine		
	li $v0, 4
	syscall
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	move $a0, $s1
	syscall
	move $a0, $s2
	syscall
	move $a0, $s3
	syscall
	move $a0, $s4
	syscall
	move $a0, $s5
	syscall
	move $a0, $s6
	syscall
	move $a0, $s7
	syscall
	
	li $v0, 10
	syscall


initDynamicArray:

	#Write your instructions here!
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $gp  				# start point of our allocated memory
	addi $gp, $gp, 12 			# it shows us the start point of the unallocated memory
	addi $t0, $zero, 0 			# size, also defult address
 	addi $t1, $zero, 2 			# capacity
	sw $t1, 0($s0)
	sw $t0, 4($s0)
	
	li $v0, 9
	li $a0, 16
	syscall
	move $t0, $v0
	sw $t0, 8($s0)

	move $v0, $s0
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

putElement:
	
	#Write your instructions here!
	
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	lw $t0, 4($a0) 				# current size
	
	li $t3, 4
	mul $t4, $t0, $t3 			# t4 = size*4
	lw $t1, 8($a0) 				# start point of the element array
	add $t4, $t4, $t1 			# t4 = size * 4 + start point of array

	sw $a1, 0($t4) 				# elements[size * 4 + start point of array] <- a1: address of the new song
	
	# increase the size
	addi $t0, $t0, 1
	sw $t0, 4($a0)
	lw $t1, 0($a0)				# t1 = old capacity
	bne $t0, $t1, endPut 		# if size != capacity
	
	li $t3, 2
	li $t4, 0 					# t4 = i
	mul $t3, $t3, $t1 			# t3 = capacity * 2
	
	sll $t2, $t3, 2				# t2 = 4 * new capacity, size of the new allocated memory
	
	addi $sp, $sp, -4
	sw $a0, 0($sp)
	
	li $v0, 9
	move $a0, $t2
	syscall
	
	lw $a0, 0($sp)
	addi $sp, $sp, 4
	
	move $s0, $v0				# s0 = address of the start of the new array
	
	sw $t3, 0($a0)				# save new capacity
	lw $t5, 8($a0)				# t5 = beginning of the old_array
	sw $s0, 8($a0)				# put this new address into the dynamic_array
	
	loop:
	beq $t1, $t4, continue		# old_size = i -> continue
	li $t6, 4					# t6 = 4
	mul $t6, $t6, $t4			# t6 = i * 4
	add $s2, $t6, $t5			# t6 = t6 + t5, t6 is the current element right now
	
	add $s1, $s0, $t6			# s1 = i * 4 + base of new_array
	lw $t7, 0($s2)				# t7 = oldarray[i * 4 + base of old_array]
	sw $t7, 0($s1)				# new_array[i * 4 + base of new_array] = t7
	addi $t4, $t4, 1			# i += 1
	j loop
	
	continue:
	beq $t3, $t4, endPut		# new_capacity == i -> endPut 
	li $t6, 4
	mul $t6, $t6, $t4
	add $s1, $s0, $t6			# new location in new array
	sw $zero, 0($s1) 			# new_array[i * 4 + base of new_array] = 0
	addi $t4, $t4, 1			# i += 1
	j continue
	
	endPut:
	la $a0, songAdded
	li $v0, 4
	syscall
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra

removeElement:
	
	#Write your instructions here!
	
	lw $t0, 4($a0)
	beq $t0, $zero, Exception
	
	li $t0, -1
	beq $a1, $t0, NameNotFound
	
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	lw $s0, 4($a0)				# s0: size
	
	
	addi $s0, $s0, -1
	sw $s0, 4($a0)
	lw $s1, 8($a0)				# s1: address of the element array
	sll $t0, $a1, 2				# t0: i*4
	add $t0, $t0, $s1			# address of the element 
	sw $zero, 0($t0)
	move $s6, $a0

	loop5:
	lw $t1, 4($t0)
	beq $t1, $zero, EndRealloc
	sw $t1, 0($t0)
	addi $t0, $t0, 4
	j loop5
	
	EndRealloc:
	li $t4, 2
	beq $t4, $s0, RemoveEnd		# size == 2 -> RemoveEnd
	lw $t3, 0($a0)				# t3: capacity
	div $t3, $t4				# t3 / 2
	mflo $t4 					# t4 = t3 / 2
	sll $t6, $t4, 2				# t6: byte size of the new element array
	bne $t4, $s0, RemoveEnd
		
	li $v0, 9
	move $a0, $t6
	syscall
	move $s2, $v0				# s2: start address of the new element array
	
	li $s3, 0					# s3: i == 0
	loop6:
	beq $s3, $t4, RemoveEndPlusUpdate
	sll $t6, $s3, 2 
	add $s4, $t6, $s2			# new address
	add $s5, $t6, $s1			# old address
	lw $t7, 0($s5)
	sw $t7, 0($s4)
	addi $s3, $s3, 1			#s3: i += 1
	j loop6
	
	NameNotFound:
	li $v0, 4
	la $a0, noSong
	syscall
	j Remainder
	
	RemoveEndPlusUpdate:
	sw $t4, 0($s6)				# save the new capacity
	
	RemoveEnd:
	li $v0, 4
	la $a0, songDeleted
	syscall
	
	Remainder:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
	
	Exception:
	jr $ra
	

listElements:
	
	#Write your instructions here!
	
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	
	lw $s0, 4($a0)					# t0 = size
	lw $s1, 8($a0)					# element address
	
	beq $s0, $zero, ListEmptyList
	
	li $s2, 0						# t2 = i
	loop2:
	beq $s2, $s0, endLoop2			# if i == size -> endLoop2
	sll $t3, $s2, 2					# t3 = i*4
	add $t3, $t3, $s1 				# t3 = i*4 + base
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	move $a0, $t3					# a0 = address of the element
	
	jal printElement
	move $a0, $v0
	
	addi $s2, $s2, 1
	j loop2
	
	ListEmptyList:
	la $a0, emptyList
	li $v0, 4
	syscall
	
	endLoop2:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	addi $sp, $sp, 16
	jr $ra

compareString:
	
	#Write your instructions here!
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	li $v0, 0						# result
	la $t0, 0($a0)
	la $t1, 0($a1)
	
	li $s0, 0						# i = 0
	
	loop3:
	beq $a2, $s0, CompareSuccess
	lb $t3, 0($t1)          		# next char in the second string
    lb $t2, 0($t0)          		# next char in the first string
    addi $t0, $t0, 1				# adjust it to the next char 
	addi $t1, $t1, 1				# adjust it to the next char 

    beq $t2, $zero, doneCompletely      # is it the end 
	beq $t3, $zero, doneCompletely

    bne $t2, $t3, doneCompletely     # Are they the not the same 
    addi $s0, $s0, 1           		# i += 1
    b loop3             		

	CompareSuccess:
	lb $t3, 0($t1)          		# next char in the second string
    lb $t2, 0($t0)          		# next char in the first string
	bne $t3, $t2, doneCompletely	# which means since one of them is already ended
									# both must be 0\ 
	li $v0, 1						# 1 indicates match
	
	doneCompletely:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
	
printElement:
	
	#Write your instructions here!
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
	jal printSong
	
	li $v0, 4
	la $a0, newLine
	syscall
	
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	
	move $v0, $a0
	
	jr $ra

createSong:
	
	#Write your instructions here!
	
	li $v0, 9
	li $a0, 8 				# memory space to store song 
	syscall
	move $t0, $v0			# t0: address of the song
	
	# now we add the address of the name
	
	li $v0, 9
	li $a0, 64
	syscall
	move $t1, $v0			# t1: address of the 64 bits name
	
	la $a0, name			# print statement
	li $v0, 4
	syscall
	
	la $a0, 0($t1)
	la $a1, 64
	li $v0, 8
	syscall
	
	sw $a0, 0($t0) 			
	
	la $a0, duration
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	
	sw $v0, 4($t0)
	
	move $v0, $t0
	
	jr $ra

findSong:
	
	#Write your instructions here!
	
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	
	li $s0, 0				# s0: i = 0
	li $s1, -1				# s1: result = -1 as default
	
	lw $s2, 4($a0)			# s2: size of the dynamic array
	lw $s3, 8($a0)			# s3: address of the elements array
	
	beq $s2, $zero, EmptyListEx
	
	la $a0, name
	li $v0, 4
	syscall
	
	li $v0, 8
	la $a0, copmStr
	li $a1, 64
	syscall
	move $t4, $a0			# address of the name which user entered
	
	# Getting the length of the string
	li $t0, 0 # initialize loop-counter
	la $a0, copmStr # load the address of the 1st byte

    loopLength:
        lb $t1, ($a0) # load the content of the address stored in $a0
        beq $t1, $zero, exitLoopLength    # branch if equal
                    # exit the program if $t0 == null 

        addi $t0, $t0, 1 # increment the loop counter
        addi $a0, $a0, 1 # go to next byte      

        j loopLength 

    exitLoopLength:
		addi $t0, $t0, -1
        move $a0, $t0 # prepare to print the integer
        
	# t0: length of the string
	# End of getting the length of the string
	
	move $a2, $t0
	loop4:
	beq $s2, $s0, exitLoop4	
	sll $t1, $s0, 2			# t1: i * 4
	add $t1, $t1, $s3		# t1: i * 4 + address of the element
	lw $t2, 0($t1)			# t2: address of the song
	lw $t3, 0($t2)			# t3: address of the song name
	
	move $a0, $t4
	move $a1, $t3
	jal compareString
	move $t5, $v0			# t5: 1 means it is found, 0 means it is not in the array.
	
	beq $t5, $zero, notIn
	move $s1, $s0
	j exitLoop4
	
	notIn:
	addi $s0, $s0, 1
	j loop4
	
	EmptyListEx:
	li $v0, 4
	la $a0, emptyList
	syscall
	
	exitLoop4:
	move $v0, $s1
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra

printSong:
	
	#Write your instructions here!
	
	lw $t0, 0($a0)			# t0 is the address of the name
	lw $t1, 4($t0)			# t1 is the duration of the song
	
	lw $t2, 0($t0)			# t2 is the name
	
	li $v0, 4
	la $a0, name2
	syscall
	
	li $v0, 4
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, duration2
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall
	
	jr $ra

additionalSubroutines:



