import ConnectFourMultiplayer
import Vapor

extension WebSocket {

    func send(_ message: Message) {
        send(message.text)
    }
}
