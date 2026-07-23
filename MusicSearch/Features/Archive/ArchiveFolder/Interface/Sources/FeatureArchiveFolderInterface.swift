import ComposableArchitecture
@preconcurrency import ArchiveDomain

@ObservableState
public struct ArchiveFolderState: Equatable, Sendable {
    public var selectedTab: Int = 0
    public var releaseYearFolders: [FolderItem] = []
    public var listenYearFolders: [FolderItem] = []
    public var genreFolders: [FolderItem] = []
    public var ratingFolders: [FolderItem] = []

    public init() {}
}

public enum ArchiveFolderAction: BindableAction, Sendable {
    case binding(BindingAction<ArchiveFolderState>)
    case onAppear
    case foldersLoaded(
        releaseYear: [FolderItem],
        listenYear: [FolderItem],
        genre: [FolderItem],
        rating: [FolderItem]
    )
    case folderTapped(FolderItem)
    case closeButtonTapped
    case delegate(DelegateAction)

    public enum DelegateAction: Equatable, Sendable {
        case didTapClose
        case didTapFolder(FolderItem)
    }
}
