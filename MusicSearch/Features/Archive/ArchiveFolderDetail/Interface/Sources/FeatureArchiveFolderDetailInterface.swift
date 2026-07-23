import ComposableArchitecture
@preconcurrency import ArchiveDomain
import MSDomain

public enum ExportState: Equatable, Sendable {
    case idle
    case exporting(progress: ExportProgress)
    case completed(successCount: Int, failedCount: Int)
}

@ObservableState
public struct ArchiveFolderDetailState: Equatable, Sendable {
    public var folderItem: FolderItem
    public var title: String
    public var folders: [FolderItem]?
    public var tracks: [ArchivedTrack]?
    public var exportState: ExportState = .idle

    public init(folderItem: FolderItem) {
        self.folderItem = folderItem
        self.title = folderItem.title
    }
}

public enum ArchiveFolderDetailAction: Sendable {
    case onAppear
    case loadDataResponse(folders: [FolderItem]?, tracks: [ArchivedTrack]?)
    case folderTapped(FolderItem)
    case trackTapped(ArchivedTrack)
    case closeButtonTapped
    case exportButtonTapped
    case loginPromptTapped
    case exportProgress(ExportProgress)
    case exportCompleted(successCount: Int, failedCount: Int)
    case delegate(DelegateAction)

    public enum DelegateAction: Equatable, Sendable {
        case didTapClose
        case didTapFolder(FolderItem)
        case didTapTrack(ArchivedTrack)
        case showLoginPrompt
    }
}
