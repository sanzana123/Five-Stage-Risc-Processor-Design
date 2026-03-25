.global _start
.text

_start:
    addi x1, x0, 5
    nop
    nop
    nop
    addi x2, x0, 7
    nop
    nop
    nop
    add x3, x1, x2
    nop
    nop
    nop
    ebreak
