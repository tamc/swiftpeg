import Foundation

protocol ToSwift {
  func toSwift() -> String
}

protocol ToIgnorableSwift: ToSwift {
  func toSwift(ignored: Bool) -> String
}

extension String: ToSwift {

  func toSwift() -> String {
    return self
  }

  func underscoreToCamelCase() -> String {
    return components(separatedBy:"_").map({$0.capitalized}).joined(separator:"")
  }

  /// If the string is enclosed in brackets (like so) then strip them. Otherwise return the string.
  func withoutAnyOuterBrackets() -> String {
    guard self.first == "(", self.last == ")" else { return self }
    return String(self.dropFirst().dropLast())
  }

  // Attempts to turn this string into its literal form
  func escapingForRegexpStringLiteral() -> String {
    return String(describing: self)
              .replacingOccurrences(of: "\\", with: "\\\\")
              .replacingOccurrences(of:"\"", with: "\\\"")
              .replacingOccurrences(of:"\\\\u{", with: "\\u{")
  }

}


extension NonTerminalClass {
  var toSwiftChildren: [String] { return children.compactMap({$0 as? ToSwift}).map({$0.toSwift()}) }
  var childrenAsSwiftString: String { return toSwiftChildren.joined(separator: "")}
}

extension TextPeg: ToSwift {
  func toSwift() -> String {
    return """
    import Foundation

    class TextPegParser: PegParser {
      var parseState: ParseState

      init(text: String) {
        parseState = ParseState(textToParse: text)
      }

    \(toSwiftChildren.joined(separator:"\n"))
      private func r(_ pattern: String) -> NSRegularExpression {
          // FIXME: Cache
          return try! NSRegularExpression(pattern: "^\\(pattern)", options: [])
      }
    }
    """
  }
}

extension Node: ToSwift {
  func toSwift() -> String {
    let c = toSwiftChildren
    guard let identifier = children.first as? Identifier else { fatalError("Expecting \(String(describing: children)) to have an Identifier as the first child") }
    let name = identifier.toFunctionName()
    let className = identifier.toClassName()
    let match = c[1...].joined(separator:"")
    return """
      func \(name) -> Symbol? {
        return nonterminal(\(className).init, match: \(match))
      }

    """
  }
}

extension Definition: ToSwift {
  func toSwift() -> String {
    let c = toSwiftChildren
    let name = c[0]
    let match = c[1...].joined(separator:"")
    return """
      func \(name) -> Symbol? {
        return \(match)
      }

    """
  }
}

extension Identifier: ToSwift {

  func toSwift() -> String {
    return "\(childrenAsSwiftString)()"
  }

  func toFunctionName() -> String {
    return toSwift()
  }

  func toClassName() -> String {
    return childrenAsSwiftString.underscoreToCamelCase()
  }
}

extension Sequence: ToSwift {
  func toSwift() -> String {
    return toSwiftChildren.joined(separator:" && ")
  }
}

extension Alternatives: ToSwift {
  func toSwift() -> String {
    return toSwiftChildren.joined(separator:" || ")
  }
}

extension NotFollowedBy: ToSwift {
  func toSwift() -> String {
    return "notFollowedBy(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension FollowedBy: ToSwift {
  func toSwift() -> String {
    return "followedBy(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension Ignored: ToSwift {
  func toSwift() -> String {
    if children.count == 1, let child = children.first as? ToIgnorableSwift {
      return child.toSwift(ignored: true)
    }
    return "ignore(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension Optional: ToSwift {
  func toSwift() -> String {
    return "optional(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension AnyNumberOf: ToSwift {
  func toSwift() -> String {
    return "zeroOrMore(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension OneOrMore: ToSwift {
  func toSwift() -> String {
    return "oneOrMore(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension BracketedExpression: ToSwift {
  func toSwift() -> String {
    return "(\(childrenAsSwiftString.withoutAnyOuterBrackets()))"
  }
}

extension TerminalString: ToIgnorableSwift {
  func toSwift() -> String {
    return toSwift(ignored:false)
  }

  func toSwift(ignored: Bool) -> String {
    let content = childrenAsSwiftString.debugDescription
    let klass = ignored ? "" : ", String.init"
    return "terminal(\(content)\(klass))"
  }
}

extension TerminalCharacterRange: ToIgnorableSwift {
  func toSwift() -> String {
    return toSwift(ignored:false)
  }

  func toSwift(ignored: Bool) -> String {
    let content = childrenAsSwiftString.escapingForRegexpStringLiteral()
    let klass = ignored ? "" : ", String.init"
    return "terminal(r(\"[\(content)]\")\(klass))"
  }
}

extension TerminalRegexp: ToIgnorableSwift {
  func toSwift() -> String {
    return toSwift(ignored:false)
  }

  func toSwift(ignored: Bool) -> String {
   let content = childrenAsSwiftString.escapingForRegexpStringLiteral()
    let klass = ignored ? "" : ", String.init"
    return "terminal(r(\"\(content)\")\(klass))"
  }
}

extension AnyCharacter: ToIgnorableSwift {
  func toSwift() -> String {
    return toSwift(ignored:false)
  }

  func toSwift(ignored: Bool) -> String {
    let klass = ignored ? "" : ", String.init"
    return "terminal(r(\".\")\(klass))"
  }
}
