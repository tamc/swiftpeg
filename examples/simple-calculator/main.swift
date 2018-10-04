import Foundation

enum CalculationError: Error {
    case notAnOperator(Symbol)
    case doesNotHaveAValue(Symbol)
}

protocol HasValue {
    var value: Double { get }
}

extension Double: Symbol, HasValue {
    var value: Double { return self }
}

protocol Operator: Symbol {
    init(substring: Substring)
    func apply(_ left: Double, _ right: Double) -> Double
}

extension Sequence {
    /**
    reduceInPairs is like reduce, but will pass the next two elements to the reducing function rather than one. If there are an odd number of elements, the last element will be ignored.
    */
    func reduceInPairs<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element, Element) throws -> Result  ) rethrows -> Result {
        var result = initialResult
        var iterator = makeIterator()
        while let a = iterator.next(), let b = iterator.next() {
            result = try nextPartialResult(result, a, b)
        }
        return result
    }
}

class Calculation: Symbol, HasValue {
    
    let value: Double
    
    init?(_ symbols: [Symbol]) {
        let leftToRightReduction: (Double, Symbol, Symbol) throws -> Double = { (cummulative, op, right) in
            guard let o = op as? Operator else { throw CalculationError.notAnOperator(op) }
            guard let r = right as? HasValue else { throw CalculationError.doesNotHaveAValue(right) }
            return o.apply(cummulative, r.value)
        }
        do {
            if let start = symbols.first as? HasValue {
                value = try symbols.dropFirst().reduceInPairs(start.value, leftToRightReduction)
            } else {
                value = try symbols.reduceInPairs(0.0, leftToRightReduction)
            }
        } catch {
            print(error)
            return nil
        }
    }
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

class Calculator: PegParser {
    
    static let integerRegexp = try! NSRegularExpression(pattern: "[+-]?[0-9]+(\\.[0-9]+)?([eE][+-]?[0-9]+)?", options: [])
    
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
        return space() && (terminal("+", Add.init) || terminal("-", Subtract.init))
    }
    
    func productOperators() -> Symbol? {
        return space() && (terminal("*", Multiply.init) || terminal("/", Divide.init))
    }
    
    func value() -> Symbol? {
        return space() && (brackets() || number())
    }
    
    func brackets() -> Symbol? {
        return terminal("(") && space() && expression() && space() && terminal(")")
    }
    
    func number() -> Symbol? {
        return terminal(Calculator.integerRegexp, Double.init)
    }
    
    func space() -> Symbol? {
        return zeroOrMore(terminal(" "))
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
