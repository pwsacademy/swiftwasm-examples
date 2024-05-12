import ConnectFour

/// The different messages that can be sent between a client and the server.
public enum Message: Equatable {

    /// A player requests to join a game and specifies their name.
    case requestGame(name: String)

    /// The server has received the player's request,
    /// and that player should now wait for an opponent.
    case waitForOpponent

    /// Both players can start the game.
    case startGame(id: Int, opponent: String, yourColor: Player, startingColor: Player)

    /// A player selects a column.
    case selectColumn(_ column: Int)

    /// A player requests to play another round.
    case nextRound

    /// A player has quit.
    case opponentLeft

    /// An unknown message.
    /// 
    /// This should not be used, it indicates an error state.
    case unknown(String)

    public init(_ text: String) {
        if let match = text.wholeMatch(
            of: try! Regex(#"request game I am ([\w\s]+)"#)
        ) {
            guard let capture1 = match.output[1].substring else {
                self = .unknown(text)
                return
            }
            self = .requestGame(name: String(capture1))
        } else if text == "wait for opponent" {
            self = .waitForOpponent
        } else if let match = text.wholeMatch(
            of: try! Regex(#"start game (\d+) opponent is ([\w\s]+) you play (red|yellow) game starts (red|yellow)"#)
        ) {
            guard let capture1 = match.output[1].substring,
                  let id = Int(capture1),
                  let capture2 = match.output[2].substring,
                  let capture3 = match.output[3].substring,
                  let playerColor = Player(rawValue: String(capture3)),
                  let capture4 = match.output[4].substring,
                  let startingColor = Player(rawValue: String(capture4)) else {
                self = .unknown(text)
                return
            }
            self = .startGame(
                id: id,
                opponent: String(capture2),
                yourColor: playerColor,
                startingColor: startingColor
            )
        } else if let match = text.wholeMatch(
            of: try! Regex(#"select column (\d+)"#)
        ) {
            guard let capture1 = match.output[1].substring,
                  let column = Int(capture1) else {
                self = .unknown(text)
                return
            }
            self = .selectColumn(column)
        } else if text == "next round" {
            self = .nextRound
        } else if text == "opponent left" {
            self = .opponentLeft
        } else {
            self = .unknown(text)
        }
    }
    
    public var text: String {
        switch self {
        case .requestGame(let name):
            return "request game I am \(name)"
        case .waitForOpponent:
            return "wait for opponent"
        case .startGame(let id, let opponent, let playerColor, let startingColor):
            return "start game \(id) opponent is \(opponent) you play \(playerColor.rawValue) game starts \(startingColor.rawValue)"
        case .selectColumn(let column):
            return "select column \(column)"
        case .nextRound:
            return "next round"
        case .opponentLeft:
            return "opponent left"
        case .unknown(let text):
            return text
        }
    }
}
