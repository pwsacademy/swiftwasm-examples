import ConnectFour
import ConnectFourMultiplayer
import JavaScriptKit

class WebUI {

    private var client: MultiplayerClient<WebSocketClient>
    private let document: JSValue
    private let canvas: Canvas

    init(_ client: MultiplayerClient<WebSocketClient>) {
        self.client = client
        document = JSObject.global.document
        let canvasElement = document.querySelector("canvas")
        self.canvas = Canvas(canvasElement)
        _ = canvasElement.addEventListener("click", JSClosure { [self] params in
            guard case .inProgress(let data) = client.state,
                  case .active(data.assignedColor) = data.game.state else {
                return .undefined // not your turn
            }
            let event = params[0].object!
            let column = canvas.columnForOffset(event.offsetX.number!)
            guard data.game.isSelectable(column: column) else {
                return .undefined // column is full
            }
            client.selectColumn(column)
            self.update()
            return .undefined
        })
        let button = document.getElementById("next-round")
        _ = button.addEventListener("click", JSClosure { [self] _ in
            client.startNextRound()
            self.update()
            return .undefined
        })
        client.onStateChange = { [self] in update() }
        update()
    }

    private func update() {
        updateStatus()
        var gameSection = document.getElementById("game")
        switch client.state {
        case .inProgress(_), .gameOver(_):
            gameSection.style = "display: block"
            updateCanvas()
            updateScoreboard()
            updateControls()
        default:
            gameSection.style = "display: none"
        }
    }
    
    private func updateStatus() {
        var status = document.getElementById("status")
        switch client.state {
        case .connecting:
            status.innerText = "Connecting to server ..."
        case .waitingForOpponent:
            status.innerText = "Waiting for an opponent to join ..."
        case .inProgress(let data):
            switch data.game.state {
            case .active(data.assignedColor):
                status.innerText = .string("Your move, \(client.player)")
            case .active(_):
                status.innerText = .string("Waiting for \(data.opponent)'s move...")
            case .win(let winner):
                status.innerText = winner == data.assignedColor ? "You won!" : "You lost"
            case .tie:
                status.innerText = "It's a tie!"
            }
        case .gameOver(_):
            status.innerText = "Your opponent has left the game"
        }
    }

    private func updateCanvas() {
        switch client.state {
        case .inProgress(let data), .gameOver(let data):
            canvas.draw(data.game)
        default:
            fatalError("invalid state")
        }
    }
    
    private func updateScoreboard() {
        switch client.state {
        case .inProgress(let data), .gameOver(let data):
            var playerName = document.getElementById("player-name")
            playerName.innerText = .string(client.player)
            var playerChip = document.getElementById("player-color")
            playerChip.innerText = .string(chip(for: data.assignedColor))
            var playerScore = document.getElementById("player-score")
            playerScore.innerText = .string("\(data.game.scores[data.assignedColor]!)")

            var opponentName = document.getElementById("opponent-name")
            opponentName.innerText = .string(data.opponent)
            var opponentChip = document.getElementById("opponent-color")
            opponentChip.innerText = .string(chip(for: data.assignedColor.opponent))
            var opponentScore = document.getElementById("opponent-score")
            opponentScore.innerText = .string("\(data.game.scores[data.assignedColor.opponent]!)")
        default:
            fatalError("invalid state")
        }
    }

    private func updateControls() {
        var button = document.getElementById("next-round")
        switch client.state {
        case .inProgress(let data):
            if case .active(_) = data.game.state {
                button.style = "display: none"
            } else {
                button.style = "display: inline"
            }
        case .gameOver(_):
            button.style = "display: none"
        default:
            fatalError("invalid state")
        }
    }

    private func chip(for player: Player) -> String {
        switch player {
        case .red:
            return "🔴"
        case .yellow:
            return "🟡"
        }
    }
}
