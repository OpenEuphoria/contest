include cpu.e
include add.cpi
include mul.cpi
include fib.cpi

? add(12,14)
? mul(2,88)
? fib(12)

r0 = 10
r1 = 11
r2 = 12

? { r0, r1, r2 }

cpu:push_state()
cpu:reset()

? { r0, r1, r2 }

cpu:pop_state()

? { r0, r1, r2 }
