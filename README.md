phiΦ
===

Phi is a simple programming language. Please copy it and play around with it — create your own language!

Design
------
Phi is all about simplicity.

	int = 10
	float = 10.0
	boolean = true
	string = "word"

	# comment

	if int is 10 {
		say("it's ten!")
	}

	if (int is 9) or (float isnt 7.0) {
		say("aww")
	} else {
		say("booya")
	}

	while int isnt 0 {
		int = int - 1
	}

	add_two = (n) {
		add_one = (n) {
			n + 1
		}
		add_one(add_one(n))
	}

	say(add_two(2))

Everything is an expression. The last expression is the return. Functions have their own scope. stdlib is "say", which prints to standard out.

Reserved words: if, else, while, #, true, false, is, isnt, not, <, >, =, <=, >=, and, or

Setup & requirements
--------------------

Just run bundle. The gem parsley is the only dependency.

Usage
-----

	./phi example/fib.phi

Contributing
------------
If you find any bugs, please create an issue. If you want to add a feature to the language, clone the repo and create your own language. Phi is only meant to demonstrate some of the basics.