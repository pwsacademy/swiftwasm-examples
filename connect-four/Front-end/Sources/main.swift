import ConnectFourMultiplayer
import JavaScriptKit

var storage = JSObject.global.localStorage
let name = storage.getItem("cf.name").string ?? "Anonymous"

let webSocket = WebSocketClient(url: "ws://127.0.0.1:9090/ws/play")
let client = MultiplayerClient(player: name, webSocket)
let ui = WebUI(client)
