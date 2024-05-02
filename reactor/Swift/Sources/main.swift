import JavaScriptKit

let pips = Int.random(in: 1...6)
print("Rolled a \(pips)")

var img = JSObject.global.document.getElementById("die")
img.src = .string("\(pips).png")
img.style = "display: block"
