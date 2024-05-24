.globl e
e:
    // Grab the Fibonacci sequence target from our instruction data
    ldxb r8, [r1+8+8+80+10240+8+8] // 8 accounts length + 8 flags + 80 account data + 10240 realloc padding + 8 padding + 8 ix length
    mov64 r6, 0
    mov64 r7, 1 // Skip first sequence and return 0 if n<1
    jgt r8, 93, overflow // handle overflow
    jlt r8, 2, exceptions // handle 1 and 0
    ja step
step:
    sub64 r8, 1  // -1 from r8 - subtract first as we already pre-calculated f(1)
    jlt r8, 1, finalize // If there are <1 rounds left, finish it
    mov64 r1, r7 // set to f(n-1)
    add64 r1, r6 // add f(n-2)
    mov64 r6, r7 // set f(n-2) to f(n-1)
    mov64 r7, r1 // set f(n-1) to f(n)
    ja step
exceptions:
    mov64 r1, r8 // 0 = 0 and 1 = 1
    ja finalize
overflow:
    lddw r0, 1 // error
    lddw r1, e1
    lddw r2, 32
    call sol_log_
    exit
finalize:
    call sol_log_64_
    exit
.extern sol_log_ sol_log_64_
.rodata
    e1: .ascii "Sorry, u64 maxes out at F(93) :("