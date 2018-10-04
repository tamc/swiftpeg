A Swift Parsing Micro-Framework
===============================

An experiment in writing a parsing framework in Swift.

Features:

1. Very small: a single file ([peg.swift](./peg.swift)), a few classes
2. Grammar can be written directly in code
3. Can output any Types (not just 'nodes')

Not features:

1. Not very fast
2. Not a standard format

Example
-------

An example (of a calculator) is in [examples/simple-calculator/main.swift](./examples/simple-calculator/main.swift).

To run it:
  
  cd examples/simple-calculator
  make
  ./simple-calculator


Installation
------------

To install it in your own code, just copy the content of the [peg.swift](./peg.swift) file into your code.

Usage
-----

Your parser needs to conform to the PegParser protocol. That means it has to have:

    var parseState: ParseState

You need to set this to the text to parse:

    parseState = ParseState(textToParse: "Hello World")

You then match against this by using a terminal:

    terminal("Hello") // returns a Type that adopts the Symbol protocol
    terminal("Not matching") // returns nil

You can specify the Type of Symbol to return by passing a closure as the second argument:

    struct Thing: Symbol {}
    terminal("Hello", {_ in Thing() }) // returns a Thing
    terminal("Not matching") // returns nil

You can take advantage of being able to pass functions:

    struct Thing: Symbol { let substring: Substring }
    terminal("Hello", Thing.init) // returns a thing

You can combine terminals:

    terminal("Hello") && terminal(" ") && terminal("World") // Returns a Symbol
    terminal("Hello") && terminal("Tom") // Returns nil

    terminal("Goodbye") || terminal("Hello") // Returns a Symbol
    terminal("Tom") || terminal("Jerry") // Returns nil

There are also:

    anyNumberOf(terminal("Tom")) // Returns a Symbol
    oneOrMore(terminal("Tom")) // Returns nil
    oneOrMore(terminal("Hello")) // Returns a Symbol

You can capture groups of terminals by using nonterminals:

    struct Greeting: Symbol {}
    nonterminal({ _ in Greeting()}, match: terminal("Hello") && anyNumberOf(terminal(" ")) && (terminal("World") || terminal("Tom"))) // Returns a Greeting

    struct Sentence: Symbol { let children: [Symbol] }
    struct Verb: Symbol { let text: Substring }
    struct Noun: Symbol { let text: Substring }
    nonterminal(Sentence.init, match: terminal("Hello", Verb.init) && anyNumberOf(terminal(" ")) && (terminal("World", Noun.init) || terminal("Tom", Noun.init))) // Will return a Sentence whose children variable contains [ Verb("Hello"), Noun("World")] - note no spaces, terminals that do not provide a symbol are not returned

There are also look-ahead operators

    followedBy(...)
    notFollowedBy(...)

You can nest and make use of functions, see [./main.swift] for examples.

Warning on regular expressions
------------------------------

You can pass a NSRegularExpression instead of a String to terminal:

    terminal(NSRegularExpression(pattern: "([+-]?[0-9][0-9]*")!)) 

Which can simplify (and speed up?) some hand written grammars.

However, at least on OSX NSRegularExpression matching causes some object to be added to an autoreleasepool that is only released at the end of a run loop. If the run loop doesn't end soon (because, say, you are parsing in a command line app) then you can appear to leak memory. You can fix it by wrapping a section of code in autoreleasepool {}. You can see an example of this commented out in the `termina(_ regexp: NSRegularExpression:...)` method of [Peg.swift](./Peg.swift). 

For performance you might want to move the autorelease higher up in your code. But there is no clear way of judging this.
