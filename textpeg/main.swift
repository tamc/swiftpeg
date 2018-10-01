import Foundation

let text = try String(contentsOfFile: "textpeg.txt", encoding: .utf8)
let parser = TextPeg(text: text)
print(parser.text_peg() ?? "Failed to Parse")
