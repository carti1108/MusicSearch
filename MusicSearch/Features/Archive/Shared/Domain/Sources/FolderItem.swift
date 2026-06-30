import Foundation

public enum FolderType: Equatable {
    case custom
    case releaseYear(year: String)
    case listenYear(year: String)
    case releaseMonth(year: String, month: String)
    case listenMonth(year: String, month: String)
    case releaseWeek(year: String, month: String, week: String)
    case listenWeek(year: String, month: String, week: String)
    case genre(name: String)
    case rating(value: Int)
}

public struct FolderItem: Identifiable, Equatable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
    public let type: FolderType

    public init(title: String, subtitle: String, type: FolderType) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }

    public static func == (lhs: FolderItem, rhs: FolderItem) -> Bool {
        return lhs.id == rhs.id
    }
}
