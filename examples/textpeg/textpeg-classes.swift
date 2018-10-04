import Foundation

extension String: Symbol {}

protocol IndentedStringConvertible {
    func indentedDescription(indent: String, depth: Int) -> String
}

class NonTerminalClass: Symbol, CustomStringConvertible, IndentedStringConvertible {
    let children: [Symbol]
    init?(children: [Symbol]) {
        self.children = children
    }
    var description: String {
        return indentedDescription()
    }
    
    func indentedDescription(indent: String = "  ", depth: Int = 0) -> String {
        var description: [String] = ["\(String(repeating:indent, count:depth))\(type(of: self))"]
        for child in children {
            if let c = child as? IndentedStringConvertible {
                description.append(c.indentedDescription(indent: indent, depth: depth + 1))
            } else {
                description.append("\(String(repeating:indent, count: depth+1))\(String(describing:child))")
            }
        }
        return description.joined(separator: "\n")
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
