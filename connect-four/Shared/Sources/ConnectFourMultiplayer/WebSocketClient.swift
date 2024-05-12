/// Users of `MultiplayerClient` must provide an implementation of this protocol
/// using whatever WebSocket API is available on their platform.
public protocol WebSocketClient: AnyObject {

    /// Called when a connection with the server has been opened.
    var onOpen: () -> Void { get set }

    /// Process a message from the server.
    var onMessage: (Message) -> Void { get set }

    /// Send a message to the server.
    func send(_ message: Message)
}
