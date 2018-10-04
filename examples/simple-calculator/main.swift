import Foundation
func valueFor(_ symbol: Symbol) -> Double {
    switch symbol {
    case let c as Calculation:
        return c.value
    case let d as Double:
        return d
    case let s as String:
	guard let n = Double(s) else { fatalError("Not a float") }
	return n
    default:
        fatalError("Unrecognised type")
    }
}

class Calculation: Symbol {

    let value: Double

    init?(_ symbols: [Symbol]) {
        var symbols = symbols
        guard symbols.isEmpty == false else { self.value = 0; return }
        var v = valueFor(symbols.removeFirst())
	while symbols.isEmpty == false {
		guard let o = symbols.removeFirst() as? Operator else { return nil }
		let otherValue = valueFor(symbols.removeFirst())
    v = o.apply(v, otherValue)
	}
        self.value = v
    }
}

protocol Operator: Symbol {
  init(substring: Substring)
  func apply(_ left: Double, _ right: Double) -> Double
}

struct Add: Operator {
  let substring: Substring

  func apply(_ left: Double, _ right: Double) -> Double {
    return left + right
  }
}

struct Subtract: Operator {
  let substring: Substring

  func apply(_ left: Double, _ right: Double) -> Double {
    return left - right
  }
}

struct Multiply: Operator {
  let substring: Substring

  func apply(_ left: Double, _ right: Double) -> Double {
    return left * right
  }
}

struct Divide: Operator {
  let substring: Substring

  func apply(_ left: Double, _ right: Double) -> Double {
    return left / right
  }
}

extension Double: Symbol { }

class Calculator: PegParser {

    static let integerRegexp = try! NSRegularExpression(pattern: "[+-]?[0-9]+(.[0-9]+)?([eE][+-]?[0-9]+)?", options: [])

    var parseState: ParseState

    init(_ string: String) {
        parseState = ParseState(textToParse: string)
    }

    func expression() -> Symbol? {
        return sum() || product() || value()
    }

    func sum() -> Symbol? {
        return nonterminal(Calculation.init, match: (product() || value()) && oneOrMore(sumOperators() && (product() || value())))
    }

    func product() -> Symbol? {
        return nonterminal(Calculation.init, match: value() && oneOrMore(productOperators() && value()))
    }

    func sumOperators() -> Symbol? {
        return terminal("+", Add.init) || terminal("-", Subtract.init)
    }

    func productOperators() -> Symbol? {
        return terminal("*", Multiply.init) || terminal("/", Divide.init)
    }

    func value() -> Symbol? {
        return (terminal("(") && expression() && terminal(")")) || number()
    }

    func number() -> Symbol? {
        return terminal(Calculator.integerRegexp, Double.init)
    }
}

print("Enter a sum, like 1.0+1.0 and press enter, ctrl-c to exit")
while true {
  let s = readLine(strippingNewline: true)!
  if let c = Calculator(s).expression() as? Calculation {
    print(c.value)
    } else {
    print("Could not parse \(s)")
    }
}
