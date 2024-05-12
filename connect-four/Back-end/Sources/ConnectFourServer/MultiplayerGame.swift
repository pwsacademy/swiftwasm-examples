import ConnectFour
import ConnectFourMultiplayer
import Vapor

struct MultiplayerGame {

    let id: Int
    private(set) var clients: [Client]

    init(id: Int) {
        self.id = id
        clients = []
    }

    var isFull: Bool {
        clients.count == 2
    }

    mutating func registerClient(name: String, _ socket: WebSocket) {
        let color = clients.isEmpty ? Player.random() : clients.first!.assignedColor.opponent
        clients.append(.init(socket: socket, name: name, assignedColor: color))
    }

    func start() {
        guard isFull else { return }
        let startingColor = Player.random()
        clients[0].socket.send(
            .startGame(
                id: id,
                opponent: clients[1].name,
                yourColor: clients[0].assignedColor,
                startingColor: startingColor
            )
        )
        clients[1].socket.send(
            .startGame(
                id: id,
                opponent: clients[0].name,
                yourColor: clients[1].assignedColor,
                startingColor: startingColor
            )
        )
    }

    /// The client connected on the given socket.
    subscript(_ socket: WebSocket) -> Client? {
        clients.first { $0.socket === socket }
    }

    /// The client assigned the given color.
    subscript(_ playerColor: Player) -> Client? {
        clients.first { $0.assignedColor == playerColor }
    }
}
