import ConnectFour
import ConnectFourMultiplayer
import Vapor

// The games are stored in-memory for now.
private var games: [MultiplayerGame] = []

func routes(_ app: Application) throws {

    app.get { req in
        req.redirect(to: "index.html")
    }

    app.get("play") { req in
        req.redirect(to: "play.html")
    }

    app.webSocket("ws", "play") { req, socket in
        socket.onText { socket, string in
            switch Message(string) {
            case .requestGame(let name):
                processRequest(from: socket, name: name)
            case .selectColumn(let column):
                processSelection(from: socket, column: column)
            case .nextRound:
                processNextRound(from: socket)
            default:
                break
            }
        }
        socket.onClose.whenComplete { _ in
            processQuit(from: socket)
        }
    }
}

private func processRequest(from socket: WebSocket, name: String) {
    if games.isEmpty || games.last!.isFull {
        let id = games.last?.id ?? 0 + 1
        var game = MultiplayerGame(id: id)
        game.registerClient(name: name, socket)
        games.append(game)
        socket.send(.waitForOpponent)
    } else {
        let index = games.count - 1
        games[index].registerClient(name: name, socket)
        games[index].start()
    }
}

private func processSelection(from socket: WebSocket, column: Int) {
    guard let game = games.first(where: { $0[socket] != nil }),
          let client = game[socket],
          let opponent = game[client.assignedColor.opponent] else {
        return
    }
    opponent.socket.send(.selectColumn(column))
}

private func processNextRound(from socket: WebSocket) {
    guard let game = games.first(where: { $0[socket] != nil }),
          let client = game[socket],
          let opponent = game[client.assignedColor.opponent] else {
        return
    }
    opponent.socket.send(.nextRound)
}

private func processQuit(from socket: WebSocket) {
    guard let game = games.first(where: { $0[socket] != nil }),
          let client = game[socket],
          let opponent = game[client.assignedColor.opponent],
          !opponent.socket.isClosed else {
        return
    }
    opponent.socket.send(.opponentLeft)
}
