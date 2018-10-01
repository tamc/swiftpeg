import Foundation

class TextPeg: PegParser {
  var parseState: ParseState

  init(text: String) {
    parseState = ParseState(textToParse: text)
  }

  func text_peg() -> Symbol? {
    return oneOrMore(spacing() && (node() || definition()))
  }

  func node() -> Symbol? {
    return nonterminal(Node.init, match: identifier() && assigns() && expression() && end_of_line())
  }

  func definition() -> Symbol? {
    return nonterminal(Definition.init, match: identifier() && equals() && expression() && end_of_line())
  }

  func identifier() -> Symbol? {
    return terminal(r("[a-zA-Z_][a-zA-Z0-9_]*"), Identifier.init) && spacing()
  }

  func assigns() -> Symbol? {
    return terminal(":=") && spacing()
  }

  func equals() -> Symbol? {
    return terminal("=") && spacing()
  }

  func expression() -> Symbol? {
    return alternatives() || sequence()
  }

  func sequence() -> Symbol? {
    return nonterminal(Sequence.init, match: oneOrMore(elements() && spacing()))
  }

  func alternatives() -> Symbol? {
    return nonterminal(Alternatives.init, match: elements() && oneOrMore(divider() && elements()))
  }

  func divider() -> Symbol? {
    return terminal("||", Divider.init) && spacing()
  }

  func elements() -> Symbol? {
    return prefixed() || suffixed() || element()
  }

  func prefixed() -> Symbol? {
    return ignored() || not_followed_by() || followed_by()
  }

  func suffixed() -> Symbol? {
    return optional() || any_number_of() || one_or_more()
  }

  func not_followed_by() -> Symbol? {
    return nonterminal(NotFollowedBy.init, match: terminal("!") && element())
  }

  func followed_by() -> Symbol? {
    return nonterminal(FollowedBy.init, match: terminal("&") && element())
  }

  func ignored() -> Symbol? {
    return nonterminal(Ignored.init, match: terminal("`") && element())
  }

  func optional() -> Symbol? {
    return nonterminal(Optional.init, match: element() && terminal("?"))
  }

  func any_number_of() -> Symbol? {
    return nonterminal(AnyNumberOf.init, match: element() && terminal("*"))
  }

  func one_or_more() -> Symbol? {
    return nonterminal(OneOrMore.init, match: element() && terminal("+"))
  }

  func element() -> Symbol? {
    return bracketed_expression() || identifier() || terminal_string() || terminal_regexp() || terminal_character_range() || any_character()
  }

  func bracketed_expression() -> Symbol? {
    return nonterminal(Brackets.init, match: terminal("(") && spacing() && expression() && terminal(")") && spacing())
  }

  func terminal_string() -> Symbol? {
    return nonterminal(TerminalString.init, match: single_quoted_string() || double_quoted_string())
  }

  func double_quoted_string() -> Symbol? {
    return terminal("\"") && terminal(r("[^\"]*"), String.init) && terminal("\"") && spacing()
  }

  func single_quoted_string() -> Symbol? {
    return terminal("'") && terminal(r("[^']*"), String.init) && terminal("'") && spacing()
  }

  func terminal_character_range() -> Symbol? {
    return nonterminal(TerminalCharacterRange.init, match: terminal("[") && terminal(r("[a-zA-Z\\-0-9]*"), String.init) && terminal("]") && spacing())
  }

  func terminal_regexp() -> Symbol? {
    return nonterminal(TerminalRegexp.init, match: terminal("/") && terminal(r("(\\/||[^\\x2f])*"), String.init) && terminal("/") && spacing())
  }

  func any_character() -> Symbol? {
    return nonterminal(AnyCharacter.init, match: terminal(".") && spacing())
  }

  func end_of_line() -> Symbol? {
    return terminal(r("[\n\r]+||\\z"))
  }

  func spacing() -> Symbol? {
    return terminal(r("[ \\t]*"))
  }

  private func r(_ pattern: String) -> NSRegularExpression {
    // FIXME: Cache
    return try! NSRegularExpression(pattern: pattern, options: [])
  }
}
