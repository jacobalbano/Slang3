set var n "should be 5"

func f(n) {
	func ff(n) {
		if true {
			print n
		}
	}
	
	ff div n 2
}

f 10