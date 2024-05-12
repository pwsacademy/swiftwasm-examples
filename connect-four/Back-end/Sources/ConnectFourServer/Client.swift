import ConnectFour
import Vapor

/// A connected client.
struct Client {

    let socket: WebSocket
    let name: String
    let assignedColor: Player
}
