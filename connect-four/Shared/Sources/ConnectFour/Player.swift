public enum Player: String {

    case red
    case yellow

    public var opponent: Self {
        self == .red ? .yellow : .red
    }

    public static func random() -> Self {
        Bool.random() ? red : yellow
    }
}
