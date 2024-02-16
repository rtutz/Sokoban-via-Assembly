.data
character:  .byte 0,0
resetNumber: .byte 0

lightOnCharacter: .word 0x00B66D
lightOnBox: .word 0xFF0000
lightOnTarget: .word 0xFF0091
lightOff: .word 0x000000
lightOnWall: .word 0x873e23
mem_location: .word 0x20000000 # The memory location for the heap.
resetString: .string "Do you want to restart the game? If so, press 0. Otherwise, press any other number: \n"

hitTargetStmt: .string "YOU WON! \n"
resetGameWon: .string "Press 0 to reset. Otherwise, press any other number to exit. \n"

stringInputBox: .string "Game difficulty (1-6): \n"


# These data are for random generation algorithm: Linear congruential generator
# Note that the parameters are from the RtlUniform from Native API
# CITE: https://en.wikipedia.org/wiki/Linear_congruential_generator
# CITE: https://www.youtube.com/watch?v=kRCmR4qr-hQ&t=578s
a: .word 0x7FFFFFED
C: .word 0x7FFFFFC3
m: .word 0x7FFFFFFF
seed: .word 0x7FFFFFFF
currRandom: .word 0x7FFFFFFF

.globl main
.text

main:
    # Welcome!
    # So the enhancements made were:
    #    a. Increase difficulty by increasing targets and boxes.
    #        This is located at 167 to 312, labeled with "== ENHANCEMENT A =="
    #      Here is the pseudocode for generating random position:
            # produce position_character
            # for every box[i]; i=0, i ++, i < n,
            #     produce position_box[i]
            #     if position_char = position_box[i],
            #         loop again, i remains the same.
            #     otherwise,
            #         for every other box[h]; h = i - 1, h --, h >= 0,
            #             if pos_box[h] = pos_box[i],
            #                 loop again, i remains the same.
            #         save box[i]
            #         i = i + 1

            # for every target[j], j=0, j ++, j < n, 
            #     produce position_target[j]
            #     if position_char = position_target[j],
            #         loop again, j remains the same.
            #     else,
            #         for every box[k]; k=0, k ++, k < n,
            #             if box[k] = target[j],
            #                 loop again, j remains the same.
            #             for every other target[o]; o = j - 1, o --, o >= 0,
            #                 if pos_target[j] = pos_target[o],
            #                     loop again, j remains the same.
            #             save box[j]
            #             j = j + 1
            
    #    Here is the pseudocode logic for running the program:
            # if character is moved,
            #     check if person movement is valid.
            #         if ANY of the box is hit,
            #             if box movement valid (it does not hit walls AND any box)
            #                 move character (move the light, update memory)
            #                 if ANY target_pos = old_character_pos, 
            #                     turn on target light at target_pos 
            #                 move box (move the light, update memory)
            #                 if newBoxPos == ANY taret,
            #                     if ALL target has same position as ANY box,
            #                         print ("YOU WON!")
            #                     if not, 
            #                         awaitLoop 
            #                 if not,
            #                     awaitLoop

            #             if not,
            #                 don't move box
            #                 don't move character
            #                 awaitLoop

            #         if not, 
            #             move character (move the light, update memory)
            #             if ANY target_pos = old_character_pos,
            #                 turn on target light at target_pos
            #             awaitLoop

            #     if not,
            #         don't move character
            #         awaitLoop
            # if not,
            #     awaitLoop
        
    #    b. Improve the random number generator a formal pseudo-random generation function.
    #         I used Linear congruential generator.
    #        See line 832, labelled rand
#             CITE: https://en.wikipedia.org/wiki/Linear_congruential_generator
#             CITE: https://www.youtube.com/watch?v=kRCmR4qr-hQ&t=578s
    
    
    
    
    # Note that chunks of code for a single purpose is grouped using
    # ============ <Purpose> ============
    # that is located both at the beginning and bottom of that chunk.
    
    # I hope you have an easier time going through the code :DDD
    
    begin:
    # ============ TURN OFF THE LIGHTS AT EVERY SINGLE SPOT.============
    lw a3, lightOff     # Load address of turnOff into a3
    li a1, 0          # Initialize counter for rows

    row_loop:
        addi a2, zero, 0      # Initialize counter for columns

    column_loop:
        mv a0, a3    # Copy address of turnOff into a0
        jal ra, setLED  # Call setLED function, save return address to ra

        addi a2, a2, 1     # Increment column counter
        addi t1, zero, 8
        blt a2, t1, column_loop   # If a2 is less than 8, loop to column_loop
        
        addi a1, a1, 1     # Increment row counter
        blt a1, t1, row_loop   # If a1 is less than 8, loop to row_loop
    
    
    # Ask the user for some n, representing the number of boxes/targets to add to the game.
    la a0, stringInputBox
    li a7, 4
    ecall
    
    # ============ TURN OFF THE LIGHTS AT EVERY SINGLE SPOT.============
    
    call readInt
    mv a6, a0 # move n to t2
    # The memory location is 0x20000000, then we add n to it.
    lw t1, mem_location
    # We also need 0x20000000 + 4n since we have box_x, box_y, target_x, target_y
    slli a0, a0, 2
    add a0, a0, t1
    
    # Set the heap size to a0
    addi a7, zero, 214
    ecall
    
    # Then, box_y starts at 0x20000000
    lw s10, mem_location
    # box_x is at  0x20000000 + 2n
    add s8, s10, a6
    add s8, s8, a6
    # target_y is at 0x20000000 + n
    add s9, s10, a6
    # target_x is at 0x20000000 + 3n
    add s7, s10, a6
    add s7, s7, a6
    add s7, s7, a6
    # box_y
    
    
    
    
    # ============ ENHANCEMENT A ============
    la s11, character # Load the address of all 3 materials
    
    generateCharacter:
    addi a0, zero, 7 # Ensure the limit of rand function is 8 
    call rand
    beq a0, zero, generateCharacter # Character must not be in the top or left
    sb a0, 0(s11) # Store those random (x, y) for character in memory.
    addi a0, zero, 7 # Ensure the limit of rand function is 8
    call rand
    beq a0, zero, generateCharacter # Character must not be in the top or left
    sb a0, 1(s11)

    
    # Set an iteration variable a7 that keeps going until a7 = n
    addi a5, zero, 0
    generateBox:
    addi a0, zero, 6 # Ensure the limit of rand function is 6
    call rand
    mv t5, a0 # Move the random x to t5
    addi a0, zero, 6 # Ensure the limit of rand function is 6
    call rand
    mv t6, a0 # Move the random y to t6

    # Ensure that box isn't at the left or top side (i.e. border)
    beq t5, zero, generateBox
    beq t6, zero, generateBox
    # Ensure box isnt on the edge of border
    addi t3, zero, 1
    beq t5, t3, generateBox
    beq t6, t3, generateBox
    
    lb t3, 0(s11)
    lb t4, 1(s11) # Let (t3,t4) = (x, y) hold position of character
        
    bne t3, t5, checkOtherBoxes # If character_x != box_x, then generateTarget
    beq t4, t6, generateBox # This means that the current box produced
    # is placed where the character currently is.
    
    checkOtherBoxes:
        # Set another iteration variable to check all boxes.
        # Set it first to all values before current index (which is a5).
        addi a4, a5, -1
        # if a4 < 0, then no other points before current point
        blt a4, zero, savePositionBox

    loop: 
        add s1, a4, s10 # s1 = &box_x[i - 1]
        lb s1, 0(s1) # s1 = box_x[i - 1]
        bne t5, s1, next
        add s1, a4, s8 # s1 = &box_y[i - 1]
        lb s1, 0(s1) # s1 = box_y[i - 1]
        beq s1, t6, generateBox # If they're both equal to currentBox, 
        # create anothe box.

        # if the control reaches this point, that means (t5, t6) is not unique

    next: 
        # increment the total point count and jump to start of the loop
        addi a4, a4, -1 
        bge a4, zero, loop 
    
    savePositionBox:
        # Save the box position at the right index.
        add s1, s10, a5 # i.e. box_y[i]
        sb t5, 0(s1) #  box_y[i] = t5
        add s2, s8, a5 # i.e. box_x[i]
        sb t6, 0(s2) # Store those random (x, y) for character in memory.
        # Update s7
        addi a5, a5, 1
        blt a5, a6, generateBox
        
    # Set an iteration variable a5 that keeps going until a5 = n
    addi a5, zero, 0
    
    generateTarget:
    addi a0, zero, 7 # Ensure the limit of rand function is 8
    call rand
    mv t5, a0 # Move the random x to t5
    addi a0, zero, 7 # Ensure the limit of rand function is 8
    call rand
    mv t6, a0 # Move the random y to t6
    
    # Ensure that targegt is not in the border.
    beq t5, zero, generateTarget
    beq t6, zero, generateTarget

    bne t3, t5, maybeSaveTarget # If character_x != target_x, then generateTarget

    bne t4, t6, maybeSaveTarget
    j generateTarget
    
    
    maybeSaveTarget:
    # Iterate over all the boxes previously produced.
    addi a3, zero, 0 # Set an iteration variable a3 that keeps going until a3 = n, 
    # a3 = j
    loopBoxes:
        # reset t1, t2
        addi t1, zero, 0
        addi t2, zero, 0
        add s1, s10, a3 
        lb t1, 0(s1)
        bne t5, t1, nextLoopBoxes
        add s1, a3, s8 # s1 = &box_y[i - 1]
        lb t2, 0(s1) # s1 = box_y[i - 1]
        beq t2, t6, generateTarget
    nextLoopBoxes: 
        # increment the total point count and jump to start of the loop
        addi a3, a3, 1 
        blt a3, a6, loopBoxes 
    
    # if it gets here, that means current target is not equal to any other boxes in the past.
    # Now, we have to check if it is equal to any other previously saved target.
    
    addi a2, a5, -1
    # if a2 < 0, then no other points before current point
    blt a2, zero, savePositionTarget
    loopOtherTarget: 

        add s1, a2, s9 # s1 = &target_x[j - 1]
        lb s1, 0(s1) # s1 = target_x[j - 1]
        bne t5, s1, nextTarget
        add s1, a2, s7 # s1 = &box_y[j - 1]
        lb s1, 0(s1) # s1 = target_y[j - 1]
        beq s1, t6, generateBox

        # if the control reaches this point, that means (t5, t6) is not unique
        # you might want to add code here to handle this situation

    nextTarget: 
        # increment the total point count and jump to start of the loop
        addi a2, a2, -1 
        bge a2, zero, loopOtherTarget 
    
        
    savePositionTarget:
        # Save the target position at the right index.
        add s1, s9, a5 # i.e. target_y[j]
        sb t5, 0(s1) #  target_y[j] = t5
        add s2, s7, a5 # i.e. target_x[j]
        sb t6, 0(s2) # Store those random (x, y) for character in memory.
        # Update s7
        addi a5, a5, 1
        blt a5, a6, generateTarget
    # ============ ENHANCEMENT A ============


    # ============ INITIAL LIGHT UP ============
    # Light up the walls.
    addi a4, zero, 0 # Iteration variable.
    addi a3, zero, 8 # The bound.
    mv a2, zero
    lw a0, lightOnWall
    LightUpTopWall:
        mv a1, a4
        jal ra setLED
        addi a4, a4, 1
        blt a4, a3, LightUpTopWall
    
    addi a1, zero, 0
    addi a4, zero, 0
    LightUpLeftWall:
        mv a2, a4
        jal ra setLED
        addi a4, a4, 1
        blt a4, a3, LightUpLeftWall
    
    addi a2, zero, 7
    addi a4, zero, 0
    LightUpBottomWall:
        mv a1, a4
        jal ra setLED
        addi a4, a4, 1
        blt a4, a3, LightUpBottomWall 
              
    addi a1, zero, 7
    addi a4, zero, 0
    LightUpRightWall:
        mv a2, a4
        jal ra setLED
        addi a4, a4, 1
        blt a4, a3, LightUpRightWall 
    # ============ INITIAL LIGHT UP ============   
        
    
    
    lw a0, lightOnCharacter
    lb a1, 0(s11)      # Load the value at (s11 + 0) into a1
    lb a2, 1(s11)      # Load the value at (s11 + 4) into a2
    call setLED         

    # Initialize a4 to 0 for our loop counter
    addi a4, zero, 0 
    # Start of our loop
    loop_light_up:
    # Calculate the address for the first pair
    add a3, s10, a4 
    lb a1, 0(a3) 
    add a3, s8, a4 
    lb a2, 0(a3) 

    # Call the setLED function for the first pair
    lw a0, lightOnBox 
    call setLED 

    # Calculate the address for the second pair
    add a3, s9, a4 
    lb a1, 0(a3) 
    add a3, s7, a4 
    lb a2, 0(a3) 

    # Call the setLED function for the second pair
    lw a0, lightOnTarget 
    call setLED 

    # Increment a4 by 1
    addi a4, a4, 1 

    # Continue looping while a4 is less than or equal to the value in a6
    blt a4, a6, loop_light_up 
    
    # Reset before pollDpad
    addi a0, zero, 0
    addi t1, zero, 0
    addi t2, zero, 0
    addi t3, zero, 0

    # Await for user to move 
    awaitLoop:
        call pollDpad  # Call the function to check for d-pad input

        # Check the result in a0
        bgez a0, characterMoved
        j awaitLoop  # Otherwise, continue polling in a lo
    
    characterMoved:
         # Load the character's position into (s1, s2)
         lb s1, 0(s11)
         lb s2, 1(s11)
         jal ra, checkMovement # check movement of character. if movement is valid, s0 = 1, else s0=0.
         beq s0, zero, movementInvalidCharacter 
         
         # If we get here, we know that movement is valid (doesn't go to border.)
         # Check that if I move my character, will I hit a box? i.e. newPosChar_x = oldPosBox=x AND newPosChar_y = oldPosBox=y 
         
         # Save old character position  to (t0, tp)
         mv t0, s1 
         mv tp, s2
         auipc ra, 0
         addi  ra, ra, 40 
         addi t1, a0, 0
         beq t1, zero, move_up # Update the position of the character (which is s1,s2)
         addi t1, a0, -1
         beq t1, zero, move_down
         addi t1, a0, -2
         beq t1, zero, move_left
         addi t1, a0, -3
         beq t1, zero, move_right
         
         
         # What we are doing: Loop through every box since
         # we have to check if the character moving => a box moving.
         
         # a5 is iteration variable. Run loop until a5 = a6 = n.
         addi a5, zero, 0
     loadEveryBox:
         add a4, s10, a5 # &box_y[a5]
         lb s3, 0(a4) # s3 = box_y[a5]
         add a4, s8, a5 # &box_x[a5]
         lb s4, 0(a4) # s4 = box_x[a5]
         
         # Check if the character hits the box.
         auipc ra, 0
         addi  ra, ra, 12
         beq   s1, s3, check_s2_s4
         
         # if the character did not hit the box, then go to the next iteration of the box...
         addi a5, a5, 1
         blt a5, a6, loadEveryBox
         
         # This is the case where the character did not hit ANY box at all.
         # i.e. at the end of the loop above.
         sb s1, 0(s11)
         sb s2, 1(s11)
         # Make the light turn off at the old character position 
         lw a0, lightOff
         mv a1, t0
         mv a2, tp
         jal ra, setLED
         
         # Set t5, t5 as old position of character
         mv t5, a1
         mv t6, a2
         # Make the light turn on at the new character position 
         lw a0, lightOnCharacter
         mv a1, s1
         mv a2, s2 
         jal ra, setLED
         
         jal ra, checkSteppedOnTarget # We have to check if the previous position of
         # the character before moving has a target.
         # If so, turn the light on there.
         
         # We also have to reset the resetNumber to 0 since we made a valid move.
         # i.e. the character did not hit a wall this time so the character
         # must not have hit the wall 3 consecutive times.
         la a1, resetNumber
         sb zero, 0(a1)
         j awaitLoop
    
    check_s2_s4:
        beq   s2, s4, charHitBox
        jalr ra
    
    checkSteppedOnTarget:
        addi a4, zero, 0 # a4 is our iteration variable.
    loopCheckSteppedOnTarget:
        # reset t1, t2, t3 to 0
        addi t1, zero, 0
        addi t2, zero, 0
        addi t3, zero, 0
        add t3, s9, a4
        lb t1, 0(t3) # Let t1 = target_y[a4]
        add t3, s7, a4
        lb t2, 0(t3) # Let t2 = target_x[a4]
        # Check if the old position of the character is the same as this target.
        bne t1, t5, nextLoopCheckSteppedOnTarget
        bne t2, t6, nextLoopCheckSteppedOnTarget
        
        # If we get here, that means the current target is the same as the old 
        # character position.
        # Make the light turn on at that position
        lw a0, lightOnTarget
        mv a1, t1
        mv a2, t2
        # save the old ra to t3 temporarily.
        add t3, zero, ra
        jal ra, setLED # update the light.
        
        # put back original ra so we can go back to whomever called us.
        mv ra, t3
        jalr ra
        
    nextLoopCheckSteppedOnTarget:
        addi a4, a4, 1
        blt a4, a6, loopCheckSteppedOnTarget # Update a4 and go to the next iteration
        
        jalr ra # If we get here, that means we went through every target and
        # no target is at the old position of the character.
        
        
        
        
        
    # If we get here, that means the character hit
    # ONE of the box.
    # NOTE: If so, then after EVERYTHING we can just poll dPad since 
    # character cannot hit two boxes with one move.
     charHitBox:
         # Let (s1, s2) be the new position of the box. If we want the new position
         # of the character, we can use (s3, s4) which is the old position of the box.
        mv s1, s3
        mv s2, s4
        # This is so we can check whether the new position of box is valid.
        # This is to check whether the box does not go over the border.
        jal ra, checkMovement
        beq s0, zero, movementInvalid
        
         auipc ra, 0
         addi  ra, ra, 40
         addi t1, a0, 0
         beq t1, zero, move_up # Update the position of the box
         addi t1, a0, -1
         beq t1, zero, move_down
         addi t1, a0, -2
         beq t1, zero, move_left
         addi t1, a0, -3
         beq t1, zero, move_right
        
        # In addition to checking if the box is still within border,
        # we also have to check if the box hit any other box.
        # if so, movement is invalid.
        jal ra, checkBoxHitAnotherBox # s0 = 0 if we hit another box.
        # else, s0 = 1.
        beq s0, zero, movementInvalid
        
        # If we get here, that means box movement is valid. That is,
        # a. box does not go outside the border, and 
        # b. box does not hit another box.
        # Save the value of a0, which is the movement from dpad, to t6.
        mv s0, a0
        # Otherwise, the new position of the box is valid.
        # then, turn off lights at the old position of the character.
        # First turn off the lights there
        mv a1, t0
        mv a2, tp
        mv t5, t0
        mv t6, tp
        lw a0, lightOff
        jal ra, setLED
        # then, update the position of the character in memory.
        sb s3, 0(s11)
        sb s4, 1(s11)
        

        
        # Also, check if we ever stepped on the target.
        jal ra, checkSteppedOnTarget

         # Make the light turn on at the new character position.
         lw a0, lightOnCharacter
         mv a1, s3
         mv a2, s4 
         jal ra, setLED
         # Since we made a valid move, then we have to restart this counter as well.
         la a1, resetNumber
         sb zero, 0(a1)
         # Move the box too and update the memory.
         # Turn off LED at old box position.
         mv a0, s0
         # TODO: Store the new location of the box with indexing.
         add t1, s10, a5
         sb s1, 0(t1)
         add t1, s8, a5
         sb s2, 0(t1)
         lw a0, lightOnBox
         mv a1, s1
         mv a2, s2
         jal ra, setLED
     
         
         # Load EVERY target.
         addi a3, zero, 0 # a3 is the iteration variable for the targets.
         loadTarget:
             # reset t1 and t2
             addi t1, zero, 0
             addi t2, zero, 0
             add t3, s9, a3 # (t1, t2) is position of some target.
             lb t1, 0(t3) # (s1, s2) is position of THE box.
             add t3, s7, a3
             lb t2, 0(t3)
             
             # check if curr_target_x = box_x
             beq t1, s1, check_target_y_box_y
             addi a3, a3, 1
             bge a3, a6, awaitLoop # if we go through every 
             # target, then go back to next move.
             j loadTarget
         
         check_target_y_box_y:
             beq t2, s2, boxHitTarget
             addi a3, a3, 1
             bge a3, a6, awaitLoop
             j loadTarget
     
     # Update s0 = 1 if valid so we didn't hit another box.
     # Otherwise, s0 is 0.
     checkBoxHitAnotherBox:
         # Set another iteration variable a3 to access every box
         addi a3, zero, 0
         addi s0, zero, 1
         compareBoxLoop:
             add t6, s10, a3 # &box_x 
             lb t1, 0(t6) # t1 = box_y[t6]
             add t6, s8, a3 # &box_x[t6]
             lb t2, 0(t6) # t2 = box_x[t6]
             
             # Check if the new box hits the original box.
             beq   s1, t1, check_t2_s2
              
             addi a3, a3, 1 # If we get here, this box was not hit.
             blt a3, a6, compareBoxLoop
             jalr ra  # go back to line 351 since a3 = a6, so we went through every box.
              
             
        check_t2_s2: 
            bne   t2, s2, boxNotHitBox
            addi s0, zero, 0 # If we get here, movement is invalid.
            jalr ra  # go back to line 351
        boxNotHitBox:
            addi a3, a3, 1
            blt a3, a6, compareBoxLoop
            jalr ra  # go back to line 351
             
             
     
         
     
     boxHitTarget:
         # If we get here, that means a box hit a target and the box movement
         # is valid.
         
         # Now, we have to check if ALL the boxes hit
         # ALL the targets.
         # i.e. we already won.
         addi a3, zero, 0
         forEveryTarget:
             # we want to load the target.
             addi t0, zero, 0 # First reset everything,
             addi t1, zero, 0
             addi t2, zero, 0
             add t0, s10, a3 # Load box_x[a3]
             lb t1, 0(t0)
             add t0, s8, a3 # Load box_y[a3]
             lb t2, 0(t0)
             # now, we have to do a double for loop to check every box.
             addi a4, zero, 0
             jal ra, forEveryBox
             
             # if s0 = 0, no box hit this target.
             bne s0, zero, boxHitThisTarget
             # then, just await for the next moevement
             j awaitLoop
             
             boxHitThisTarget:
                 # Then, we have potential to win.
                 addi a3, a3, 1
                 blt a3, a6, forEveryTarget
                 
                 # If we're here, then we won!!!!!!!!!
                 la a0, hitTargetStmt
                 addi a7, zero, 4
                 ecall
                 la a0, resetGameWon
                 ecall
                 call readInt
                 bne, a0, zero, exit 
                 j begin
             
             
             forEveryBox: # This sets s0 to be 1 if ANY box is on the current target.
                 addi t0, zero, 0
                 addi t3, zero, 0
                 addi t4, zero, 0
                 add t0, s9, a4 # Load target_x[a4]
                 lb t3, 0(t0)
                 add t0, s7, a4 # Load target_y[a3]
                 lb t4, 0(t0)
                 
                 # Check if box_x[a3]=target_x[a4]
                 bne t1, t3, boxNotInTarget
                 # Check if box_y[a3]=target_y[a4]
                 bne t2, t4, boxNotInTarget
                 
                 # If we get here, a box hit the target.
                 addi s0, zero, 1 # Then, let the caller function 
                 # know that "Oh, we got a match AAAAAA!"
                 jalr ra # go back to forEveryTarget thingy

                 
                 
                 boxNotInTarget:
                     addi a4, a4, 1
                     blt a4, a6, forEveryBox
                     
                     # If we get here, no box hit this target.
                     addi s0, zero, 0
                     jalr ra
                 
             
             
     # ============ EXTRA HELPER FUNCTIONS. ============ 
     
     move_up:
        # Move Up: s1 = s1 - 1
        addi    s2, s2, -1
        jr ra

    move_down:
        # Move Down: s1 = s1 + 1
        addi    s2, s2, 1
        jr ra

    move_left:
        # Move Left: s2 = s2 - 1
        addi    s1, s1, -1
        jr ra
        
    move_right:
        # Move Right: s2 = s2 + 1
        addi    s1, s1, 1
        jr ra
     
     movementInvalid:
         j awaitLoop
         
     checkMovement:
         addi t1, a0, 0
         beq t1, zero, check_up
         addi t1, a0, -1
         beq t1, zero, check_down
         addi t1, a0, -2
         beq t1, zero, check_left
         addi t1, a0, -3
         beq t1, zero, check_right
     check_up:
        addi t5, zero, 0
        addi t5, s2, -1 # t5 = s4 - 1
        ble t5, zero, movement_invalid # if t5 < 0
        j movement_valid
        jr ra
    check_down:
        addi t6, zero, 7
        addi t5, zero, 0
        addi t5, s2, 1 # t5 = s4 + 1
        bge t5, t6, movement_invalid # if t5 >= 7
        j movement_valid
        jr ra
    check_left:
        addi t5, zero, 0
        addi t5, s1, -1 # t5 = s4 - 1
        ble t5, zero, movement_invalid # if t5 < 0
        j movement_valid
        jr ra
    check_right:
        addi t6, zero, 7
        addi t5, zero, 0
        addi t5, s1, 1 # t5 = s4 + 1
        bge t5, t6, movement_invalid # if t5 >= 7
        j movement_valid
        jr ra

    
    movement_invalid:
        addi s0, zero, 0
        jr ra
        
    movement_valid:
        addi s0, zero, 1
        jr ra
        
    movementInvalidCharacter:
        # If we get an invalid box movement, that means the box
        # was pushing unto the wall.
        # Then, we can update resetNumber += 1.
        # If resetNumber = 3, then prompt reset.
        # NOTE: resetNumber is to essentially make sure that if we hit 
        # the wall 3 consecutive times, it prompts for a reset.
        la s0, resetNumber
        lb t1, 0(s0)
        addi t2, zero, 3
        addi t1, t1, 1
        beq t1, t2, promptReset
        sb t1, 0(s0)
        j awaitLoop
    
    promptReset:
        #  Ask the user if they want to reset.
        addi a7, zero, 4
        la a0, resetString
        ecall
        call readInt
        beq, a0, zero, begin
        j awaitLoop
 
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
     
# Takes in a number in a0, and returns a random 
# number from 0 to this number (exclusive)
rand:
    addi a0, a0, -1 # Ensures value is 0 to a0 exclusive
    lw, t0, seed
    lw t1, a
    mul t0, t0, t1 # t0 = a*Xn
    lw t1, C
    add t0, t0, t1 # t0 = a*Xn + C
    lw t1, m
    remu t0, t0, t1 # t0 = Unsigned (a*Xn+C)mod(m)
    la t1, seed 
    sw t0, 0(t1) 
    remu a0, t0, a0 # [(a*Xn+C)mod(m)]mod(a0)
    # Note that:
    # We use the linear congruential generator formula: Xn = (a * Xn-1 + C) mod m
    # However, for our purposes, currRandom represents Xn mod (a0).
    # This allows currRandom < a0.
    # This choice ensures greater randomness, as Xn has a wider range,
    # compared to using currRandom directly as Xn, which typically
    # falls between 0 to 8 and doesn't offer sufficient randomness.
    la t0, currRandom
    sw a0, 0(t0)
    jalr ra
    
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra

# Use this to read an integer from the console into a0. You're free
# to use this however you see fit.
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra
