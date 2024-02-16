.data
a: .word 1103515245
C: .word 12345
m: .word 2147483648	
seed: .word 0x15A4E35
currRandom: .word 0x15A4E35
.globl main
.text
main:
        addi a0, a0, 7
        # Otherwise, use the previous number
        lw, t0, seed
        lw t1, a
        mul t0, t0, t1 # t0 = a*Xn
        lw t1, C
        add t0, t0, t1 # t0 = a*Xn + C
        lw t1, m
        remu t0, t0, t1 # t0 = Unsigned (a*Xn+C)mod(m)
        #mul t0, t0, a0 # t0 = (a*Xn+C)mod(m)*a0
        #divu a0, a0, t1 # a0 = [(a*Xn+C)mod(m)*a0] / m
        la t1, seed
        sw t0, 0(t1)
        remu a0, t0, a0 # [(a*Xn+C)mod(m)]mod(a0)
        la t0, currRandom
        sw a0, 0(t0)

        addi a7, zero, 1
        ecall
        jal ra, readInt
        j main

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

