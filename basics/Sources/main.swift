import JavaScriptKit

let document = JSObject.global.document
var p = document.createElement("p")
p.innerText = "Hello from SwiftWasm!"
_ = document.body.appendChild(p)
