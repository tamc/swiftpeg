import Foundation

extension String: Symbol {}

class NonTerminalClass: Symbol, CustomStringConvertible {
    let children: [Symbol]
    init?(children: [Symbol]) {
        self.children = children
    }
    var description: String {
      return "\(type(of: self)) \"\(children)\""
    }
}

class SymbolClass: Symbol, CustomStringConvertible {
    let substring: Substring
    init?(substring: Substring) {
        self.substring = substring
    }
    var description: String {
        return "\(type(of: self)) \"\(substring)\""
    }
}

class Identifier: SymbolClass {
}

class TextPeg: NonTerminalClass {
}

class Node: NonTerminalClass {
    override var description: String  {
        return "\(super.description)\n"
    }
}

class Definition: NonTerminalClass {
    override var description: String  {
        return "\(super.description)\n"
    }
}


class Sequence: NonTerminalClass {
}

class Alternatives: NonTerminalClass {
}

class NotFollowedBy: NonTerminalClass {
}

class FollowedBy: NonTerminalClass {
}

class Ignored: NonTerminalClass {
}

class Optional: NonTerminalClass {
}

class AnyNumberOf: NonTerminalClass {
}

class OneOrMore: NonTerminalClass {
}

class Brackets: NonTerminalClass {
}

class TerminalString: NonTerminalClass {
}

class TerminalCharacterRange: NonTerminalClass {
}

class TerminalRegexp: NonTerminalClass {
}

class AnyCharacter: NonTerminalClass {
}
