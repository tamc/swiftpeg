import Foundation

var identifierPadding = 20

protocol Formatted {
  func formatted() -> String
}

extension String: Formatted {

  func formatted() -> String {
    return self
  }

  func paddedTo(_ length: Int) -> String {
    let paddingLength = length - count
    let padding = paddingLength > 0 ? String(repeating:" ", count: paddingLength) : ""
    return "\(self)\(padding)"
  }
}

extension SymbolClass: Formatted {
  func formatted() -> String {
    return String(substring)
  }
}

extension NonTerminalClass {
  var formattedChildren: [String] { return children.compactMap({$0 as? Formatted}).map({$0.formatted()}) }

}

extension TextPeg: Formatted {
  func formatted() -> String {
    identifierPadding = calculateIdentifierPadding()
    return formattedChildren.joined(separator:"\n")
  }

  private func calculateIdentifierPadding() -> Int {
    let nodesAndDefinitions = children.filter({$0 is Node || $0 is Definition})
    let identifiers = nodesAndDefinitions.compactMap({$0 as? NonTerminalClass}).compactMap({$0.formattedChildren.first})
    let lengths = identifiers.map({$0.count})
    return lengths.max() ?? 0
  }
}

extension Node: Formatted {
  func formatted() -> String {
    let c = formattedChildren
    return "\(c[0].paddedTo(identifierPadding)) := \(c[1...].joined(separator:""))"
  }
}

extension Definition: Formatted {
  func formatted() -> String {
    let c = formattedChildren
    return "\(c[0].paddedTo(identifierPadding))  = \(c[1...].joined(separator:""))"
  }
}

extension Sequence: Formatted {
  func formatted() -> String {
    return formattedChildren.joined(separator:" ")
  }
}

extension Alternatives: Formatted {
  func formatted() -> String {
    return formattedChildren.joined(separator:" | ")
  }
}

extension NotFollowedBy: Formatted {
  func formatted() -> String {
    return "!\(formattedChildren.joined(separator:""))"
  }
}

extension FollowedBy: Formatted {
  func formatted() -> String {
    return "&\(formattedChildren.joined(separator:""))"
  }
}

extension Ignored: Formatted {
  func formatted() -> String {
    return "`\(formattedChildren.joined(separator:""))"
  }
}

extension Optional: Formatted {
  func formatted() -> String {
    return "\(formattedChildren.joined(separator:""))?"
  }
}

extension AnyNumberOf: Formatted {
  func formatted() -> String {
    return "\(formattedChildren.joined(separator:""))*"
  }
}

extension OneOrMore: Formatted {
  func formatted() -> String {
    return "\(formattedChildren.joined(separator:""))+"
  }
}

extension BracketedExpression: Formatted {
  func formatted() -> String {
    return "(\(formattedChildren.joined(separator:"")))"
  }
}

extension TerminalString: Formatted {
  func formatted() -> String {
    let content = String(describing:formattedChildren.joined(separator:""))
    let quote = content.contains("\"") ? "'" : "\""
    return "\(quote)\(content)\(quote)"
  }
}

extension TerminalCharacterRange: Formatted {
  func formatted() -> String {
    let content = String(describing:formattedChildren.joined(separator:""))
    return "[\(content)]"
  }
}

extension TerminalRegexp: Formatted {
  func formatted() -> String {
    let content = String(describing:formattedChildren.joined(separator:""))
    let quote = "/"
    return "\(quote)\(content)\(quote)"
  }
}

extension AnyCharacter: Formatted {
  func formatted() -> String {
    return "."
  }
}
