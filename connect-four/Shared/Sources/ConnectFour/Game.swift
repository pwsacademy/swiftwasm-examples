public struct Game: Equatable {

    public enum State: Equatable {
        case active(Player)
        case win(Player)
        case tie
    }

    private var grid: Grid

    public private(set) var startingPlayer: Player
    public private(set) var state: State
    public private(set) var scores: [Player: Int]

    public init(columns: Int, rows: Int, startingPlayer: Player? = nil) {
        grid = Grid(columns: columns, rows: rows)
        self.startingPlayer = startingPlayer ?? Player.random()
        state = .active(self.startingPlayer)
        scores = [.red: 0, .yellow: 0]
    }

    public var numberOfColumns: Int {
        grid.numberOfColumns
    }

    public var numberOfRows: Int {
        grid.numberOfRows
    }

    public subscript(column: Int, row: Int) -> Player? {
        grid[column, row]
    }

    public func isSelectable(column: Int) -> Bool {
        grid[column, 0] == nil
    }

    public mutating func selectColumn(_ column: Int) {
        guard case .active(let currentPlayer) = state else {
            fatalError("cannot select a column when the game is not active")
        }
        let row = grid.select(column: column, player: currentPlayer)
        if isWinningMove(column, row, currentPlayer) {
            state = .win(currentPlayer)
            scores[currentPlayer]! += 1
        } else if (0..<numberOfColumns).contains(where: isSelectable) {
            state = .active(currentPlayer.opponent)
        } else {
            state = .tie
        }
    }

    public mutating func startNextRound() {
        grid = Grid(columns: numberOfColumns, rows: numberOfRows)
        startingPlayer = startingPlayer.opponent
        state = .active(startingPlayer)
    }

    private func isWinningMove(_ selectedColumn: Int, _ selectedRow: Int, _ currentPlayer: Player) -> Bool {
        var matches = 0
        // Checks if the given position belongs to the current player
        // and returns true if we have four-in-a-row.
        func process(_ column: Int, _ row: Int) -> Bool {
            if grid[column, row] == currentPlayer {
                matches += 1
                if matches == 4 {
                    return true
                }
            } else {
                matches = 0
            }
            return false
        }
        // Flips a column's index from left-to-right to right-to-left or vice-versa.
        func flip(_ column: Int) -> Int {
            (numberOfColumns - 1) - column
        }
        // Check the row.
        for column in 0..<numberOfColumns {
            if process(column, selectedRow) {
                return true
            }
        }
        // Check the column.
        matches = 0
        for row in 0..<numberOfRows {
            if process(selectedColumn, row) {
                return true
            }
        }
        // Check the first diagonal (parallel to the line from bottom left to top right).
        // For this diagonal, column + row is a constant.
        matches = 0
        var sum = selectedColumn + selectedRow
        for column in 0...sum {
            let row = sum - column
            // Skip positions outside of the grid.
            if column >= numberOfColumns || row >= numberOfRows {
                continue 
            }
            if process(column, row) {
                return true
            }
        }
        // Check the second diagonal (parallel to the line from top left to bottom right).
        // This is similar to the first diagonal, but columns are counted right-to-left.
        matches = 0
        sum = flip(selectedColumn) + selectedRow
        for column in 0...sum {
            let row = sum - column
            // Skip positions outside of the grid.
            if column >= numberOfColumns || row >= numberOfRows {
                continue
            }
            if process(flip(column), row) {
                return true
            }
        }
        return false
    }
}
