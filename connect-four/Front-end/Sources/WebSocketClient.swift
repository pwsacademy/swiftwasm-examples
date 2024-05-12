import ConnectFourMultiplayer
import WebSockets

class WebSocketClient: ConnectFourMultiplayer.WebSocketClient {

    private let webSocket: WebSocket

    var onOpen: () -> Void = { }
    var onMessage: (Message) -> Void = { _ in }

    init(url: String) {
        webSocket = WebSocket(url: url)
        webSocket.onopen = { [self] _ in
            onOpen()
            return .undefined
        }
        webSocket.onmessage = { [self] event in
            guard let text = event.jsObject.data.string else {
                fatalError("received non-text message")
            }
            onMessage(Message(text))
            return .undefined
        }
    }

    func send(_ message: Message) {
        webSocket.send(data: .string(message.text))
    }
}
