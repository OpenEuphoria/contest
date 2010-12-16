@ echo off

del 2010-12-15-cpu\results.eds
eui judge\judge.ex -n cpu -d 2010-12-15 basics.cpu 5 basics2.cpu 5 cellular.cpu 5 fib.cpu 5 gcd.cpu 5 grid.cpu 5 life.cpu 5 primes.cpu 5 quicksort.cpu 5 speed.cpu
