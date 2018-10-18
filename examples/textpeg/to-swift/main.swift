import Foundation
import Darwin

guard CommandLine.arguments.count == 2 else {
    print("Please give the name of a textpeg file as the first argument")
    exit(1)
}

let filename = CommandLine.arguments[1]

let text = try String(contentsOfFile: filename, encoding: .utf8)
let compiler = TextPegParser(text: text)
let result = compiler.text_peg() as? TextPeg

guard let result = result else {
    print("Failed to parse \(filename)")
    exit(1)
}

print(result.toSwift())
exit(0)
