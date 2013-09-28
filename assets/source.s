func down(n) {
	print n
	ifelse == n 0 {
		return n
	} {
		return down sub n 1
	}
}

down 5