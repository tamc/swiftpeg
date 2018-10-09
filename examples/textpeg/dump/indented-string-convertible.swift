import Foundation

protocol IndentedStringConvertible {
    func indentedDescription(indent: String, depth: Int) -> String
}

extension NonTerminalClass: IndentedStringConvertible {
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
