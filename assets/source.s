func fib(n) {
	ifelse < n 2 {
		return n
	} {
		set var a1 fib sub n 2
		set var a2 fib sub n 1
		
		return add a1 a2
	}
}

print fib 5