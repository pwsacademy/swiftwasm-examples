struct Grid: Equatable {

    let numberOfColumns: Int
    let numberOfRows: Int

    private var items: [Player?]

    init(columns: Int, rows: Int) {
        numberOfColumns = columns
        numberOfRows = rows
        items = .init(repeating: nil, count: columns * rows)
    }

    subscript(column: Int, row: Int) -> Player? {
        get {
            items[row * numberOfColumns + column]
        }
        set {
            items[row * numberOfColumns + column] = newValue
        }
    }

    mutating func select(column: Int, player: Player) -> Int {
        // Rows are numbered top-to-bottom (like screen coordinates)
        // but must be filled bottom-to-top.
        for row in (0..<numberOfRows).reversed() {
            if self[column, row] == nil {
                self[column, row] = player
                return row
            }
        }
        fatalError("a column was selected that is already full")
    }
}
