Swift Parsing Expression Grammar Micro-Framework
================================================

An experiment in writing a parsing framework in Swift.

Features:

1. Very small: a single file [./peg.swift], a few classes
2. Grammar can be written directly in code
3. Can output any Types (not just 'nodes')

Example
-------

An example (of a calculator) is in [./main.swift].

To run it:

    swiftc peg.swift main.swift
    ./main

Installation
------------

To install it in your own code, just copy the content of the peg.swift file.

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
