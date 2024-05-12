import ConnectFour
import JavaScriptKit

struct Canvas {

    private static let padding = 20.0
    private static let spacing = 20.0
    private static let chipRadius = 25.0
    private static let chipSize = 2 * chipRadius
    private static let width = 2 * padding + 7 * chipSize + 6 * spacing
    private static let height = 2 * padding + 6 * chipSize + 5 * spacing

    private var element: JSValue

    init(_ element: JSValue) {
        self.element = element
        self.element.width = .number(Self.width)
        self.element.height = .number(Self.height)
    }

    /// Returns the index of the column that corresponds with the given x-coordinate.
    /// 
    /// Coordinates outside of a column are rounded to the nearest column.
    func columnForOffset(_ x: Double) -> Int {
        if x < Self.padding {
            return 0
        }
        if x > Self.width - Self.padding {
            return 6
        }
        let column = Int((x - Self.padding) / (Self.chipSize + Self.spacing))
        let offsetInColumn = (x - Self.padding) - Double(column) * (Self.chipSize + Self.spacing)
        if offsetInColumn > Self.chipSize + Self.spacing / 2 {
            return column + 1
        } else {
            return column
        }
    }
    
    func draw(_ game: Game) {
        var context = element.getContext("2d")
        context.fillStyle = "darkblue"
        _ = context.beginPath()
        _ = context.roundRect(0, 0, Self.width, Self.height, 20)
        _ = context.fill()

        for column in 0..<7 {
            for row in 0..<6 {
                let player = game[column, row]
                context.fillStyle = .string(color(for: player))
                _ = context.beginPath()
                _ = context.arc(
                    Self.padding + Double(column) * (Self.chipSize + Self.spacing) + Self.chipRadius,
                    Self.padding + Double(row) * (Self.chipSize + Self.spacing) + Self.chipRadius,
                    Self.chipRadius,
                    0,
                    2 * Double.pi
                )
                _ = context.fill()
            }
        }
    }

    private func color(for player: Player?) -> String {
        switch player {
        case .red:
            return "rgb(255, 0, 0)"
        case .yellow:
            return "rgb(255, 255, 0)"
        case nil:
            return "rgb(255, 255, 255)"
        }
    }
}