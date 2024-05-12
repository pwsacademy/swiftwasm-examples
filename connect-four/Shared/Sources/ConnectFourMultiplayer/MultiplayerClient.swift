import ConnectFour

/// A client for joining a multiplayer game of Connect Four.
/// 
/// This type requires an implementation of `WebSocketClient` to handle network communication.
public class MultiplayerClient<WebSocket: WebSocketClient> {

    /// Additional data that is available after the client has connected and started a game.
    public struct Data: Equatable {

        /// A unique ID for the game.
        public let id: Int

        /// The actual game in play.
        public var game: Game

        /// The name of the opponent.
        public let opponent: String

        /// The color assigned to this client.
        public let assignedColor: Player
    }

    /// The possible states of the client.
    /// 
    /// The state of the actual game is contained within the `Data` value.
    public enum State: Equatable {
        case connecting
        case waitingForOpponent
        case inProgress(Data)
        case gameOver(Data)
    }

    /// The player's name.
    public private(set) var player: String

    /// The `WebSocketClient` implementation to use.
    private let webSocket: WebSocket

    /// Callback for state changes.
    /// 
    /// This can be used to update the UI.
    public var onStateChange: () -> Void = { }

    /// The client's current state.
    public private(set) var state: State {
        didSet { onStateChange() }
    }

    public init(player: String, _ webSocket: WebSocket) {
        self.player = player
        self.webSocket = webSocket
        state = .connecting
        configureWebSocket()
    }

    /// Select a column.
    /// 
    /// This action is performed locally, then sent to the server to update the opponent.
    public func selectColumn(_ column: Int) {
        guard case .inProgress(var data) = state else {
            fatalError("no game in progress")
        }
        data.game.selectColumn(column)
        state = .inProgress(data)
        webSocket.send(.selectColumn(column))
    }

    /// Start a new round.
    /// 
    /// This action is performed locally, then sent to the server to update the opponent.
    public func startNextRound() {
        guard case .inProgress(var data) = state else {
            fatalError("no game in progress")
        }
        data.game.startNextRound()
        state = .inProgress(data)
        webSocket.send(.nextRound)
    }

    private func configureWebSocket() {
        webSocket.onOpen = { [self] in
            webSocket.send(.requestGame(name: player))
        }
        webSocket.onMessage = { [self] message in
            switch message {
            case .waitForOpponent:
                state = .waitingForOpponent
            case .startGame(let id, let opponent, let playerColor, let startingColor):
                let game = Game(columns: 7, rows: 6, startingPlayer: startingColor)
                state = .inProgress(.init(id: id, game: game, opponent: opponent, assignedColor: playerColor))
            case .selectColumn(let column):
                guard case .inProgress(var data) = state else {
                    fatalError("no game in progress")
                }
                data.game.selectColumn(column)
                state = .inProgress(data)
            case .nextRound:
                guard case .inProgress(var data) = state else {
                    fatalError("no game in progress")
                }
                data.game.startNextRound()
                state = .inProgress(data)
            case .opponentLeft:
                guard case .inProgress(let data) = state else {
                    fatalError("no game in progress")
                }
                state = .gameOver(data)
            default:
                print("unexpected message \(message.text)")
            }
        }
    }
}
