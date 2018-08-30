import Foundation

protocol Symbol { }

protocol TerminalNode: Symbol {
    init(_ substring: Substring)
}

protocol PegParser: AnyObject {
    
    var parseState: ParseState { get set }
    
    func ignore(_ match: @autoclosure () -> Symbol?) -> Symbol?
    func optional(_ match: Symbol?) -> Symbol?
    func oneOrMore(_ match: @autoclosure () -> Symbol?) -> Symbol?
    func zeroOrMore(_ match: @autoclosure () -> Symbol?) -> Symbol?
    func followedBy(_ match: @autoclosure () -> Symbol?) -> Symbol?
    func notFollowedBy(_ match: @autoclosure () -> Symbol?) -> Symbol?
    func nonterminal(_ type: ([Symbol]) -> Symbol?, match:  @autoclosure () -> Symbol?) -> Symbol?
    func terminal(_ string: String, _ type: ((Substring) -> Symbol?)?) -> Symbol?
    func terminal(_ regexp: NSRegularExpression, _ type: ((Substring) -> Symbol?)?) -> Symbol?
    func matchSequence(_ elements: @autoclosure () -> Symbol?) -> [Symbol]?
    func addToCurrentMatchSequence(_ node: Symbol?) -> Symbol?
}

extension String: TerminalNode { }

// ParseState contains the text to be parsed, the position reached in parsing, and some helper functions. It does not do any parsing itself.
struct ParseState {
    
    // text is the entire string we are parsing
    let text: String
    
    // index is the position we have reached in text
    private(set) var index: String.Index {
        didSet {
            remainingText = text[index...]
        }
    }

    // remainingText is the part of text that we have not yet parsed. It is changed when the index is changed.
    private(set) var remainingText: Substring

    
    // Any IgnoredNode will be skipped when populating non-terminal nodes
    struct IgnoredNode: Symbol { }
    static let ignoredNode = IgnoredNode()

    // Nonterminal are created from a sequence of terminal and non-terminal nodes. matchSequences keeps the sequences that are currently being checked
    var matchSequences: [[Symbol]]
    
    // indexOfCurrentMatchSequence points to the last array of nodes in matchSequences
    var indexOfCurrentMatchSequence: Array<[Symbol]>.Index { return matchSequences.index(before: matchSequences.endIndex) }
    
    init(textToParse: String, startIndex: String.Index) {
        self.text = textToParse
        self.index = startIndex
        self.matchSequences = [[]] // Contains an array for the top level of matches
        self.remainingText = textToParse[index...]
    }
    
    // convenience initalizer that starts at the beginning of the string
    init(textToParse: String) {
        self.init(textToParse: textToParse, startIndex: textToParse.startIndex)
    }
    
    mutating func moveIndexForward(by offset: Int) {
        index = text.index(index, offsetBy: offset)
    }
    
    mutating func moveIndex(to newIndex: String.Index) {
        index = newIndex
    }
    
}

extension PegParser {
    func ignore(_ match: @autoclosure () -> Symbol?) -> Symbol? {
        guard let _ = matchSequence(match) else { return nil }
        return ParseState.ignoredNode
    }
    
    func optional(_ match: Symbol?) -> Symbol? {
        return match ?? ParseState.ignoredNode
    }
    
    func oneOrMore(_ match: @autoclosure () -> Symbol?) -> Symbol? {
        guard var m = match() else { return nil }
        while let c = match() {
            m = c
        }
        return m
    }
    
    func zeroOrMore(_ match: @autoclosure () -> Symbol?) -> Symbol? {
        var m: Symbol? = ParseState.ignoredNode
        while let c = match() {
            m = c
        }
        return m
    }
    
    func followedBy(_ match: @autoclosure () -> Symbol?) -> Symbol? {
        let startIndex = parseState.index
        defer { parseState.moveIndex(to: startIndex) }
        if let _ = matchSequence(match) {
            return ParseState.ignoredNode
        } else {
            return nil
        }
    }
    
    func notFollowedBy(_ match: @autoclosure () -> Symbol?) -> Symbol? {
        if let _ = followedBy(match) { return nil }
        return ParseState.ignoredNode
    }
    
    func nonterminal(_ type: ([Symbol]) -> Symbol?, match: @autoclosure () -> Symbol?) -> Symbol? {
        guard let children = matchSequence(match) else { return nil }
        guard let symbol = type(children) else { return nil }
        return addToCurrentMatchSequence(symbol)
    }
    
    func terminal(_ string: String, _ type: ((Substring) -> Symbol?)? = nil) -> Symbol? {
        guard parseState.remainingText.hasPrefix(string) else { return nil}
        let startIndex = parseState.index
        parseState.moveIndexForward(by: string.count)
        guard let type = type else { return ParseState.ignoredNode }
        let substring = parseState.text[startIndex..<parseState.index]
        guard let t = type(substring) else { return ParseState.ignoredNode }
        return addToCurrentMatchSequence(t)
    }
    
    func terminal(_ regexp: NSRegularExpression, _ type: ((Substring) -> Symbol?)? = nil) -> Symbol? {
        // NSRegular expressions etc seem to get added to an auto release pool. We need to manually release them to avoid a leak.
        // return autoreleasepool { () -> Symbol? in
            let remainingRange = parseState.index..<(parseState.text.endIndex)
            let remainingNSRange = NSRange(remainingRange, in: parseState.text)
            guard let match = regexp.firstMatch(in: parseState.text, options: [], range: remainingNSRange) else { return nil }
            let matchRange = Range(match.range, in: parseState.text)! // match.range always <= remainingRange so should never fail
            parseState.moveIndex(to: matchRange.upperBound)
            guard let type = type else { return ParseState.ignoredNode }
            let substring = parseState.text[matchRange]
            guard let t = type(substring) else { return ParseState.ignoredNode }
            return addToCurrentMatchSequence(t)
        //}
    }
    
    func matchSequence(_ elements: @autoclosure () -> Symbol?) -> [Symbol]? {
        let startIndex = parseState.index
        parseState.matchSequences.append([])
        defer { _ = parseState.matchSequences.popLast() }
        if let _ = elements(), let children = parseState.matchSequences.last {
            return children
        } else {
            parseState.moveIndex(to: startIndex)
            return nil
        }
    }
    
    func addToCurrentMatchSequence(_ node: Symbol?) -> Symbol? {
        if let node = node, node is ParseState.IgnoredNode == false {
            parseState.matchSequences[parseState.indexOfCurrentMatchSequence].append(node)
        }
        return node
    }
}

func ||(lhs: Symbol?, rhs: @autoclosure () -> Symbol?) -> Symbol? {
    if let l = lhs { return l }
    return rhs()
}

func &&(lhs: Symbol?, rhs: @autoclosure () -> Symbol?) -> Symbol? {
    guard let _ = lhs else { return nil }
    guard let r = rhs() else { return nil }
    return r
}
