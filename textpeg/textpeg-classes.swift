import Foundation

extension String: Symbol {}

protocol NonTerminal: Symbol, CustomStringConvertible {
  var children: [Symbol] { get }
}

extension NonTerminal {
  var description: String {
    return "\(type(of: self))(\(children))"
  }
}

struct Node: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Definition: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Identifier: Symbol {
  init?(substring: Substring) {}
}

struct Sequence: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Alternatives: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Divider: Symbol {
  init?(substring: Substring) {}
}

struct NotFollowedBy: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct FollowedBy: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Ignored: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Optional: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct AnyNumberOf: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct OneOrMore: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct Brackets: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct TerminalString: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct TerminalCharacterRange: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct TerminalRegexp: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}

struct AnyCharacter: NonTerminal {
  let children: [Symbol]
  init?(children: [Symbol]) {
    self.children = children
  }
}
