import Foundation
import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import MSDomain

public enum AddArchiveAlert: Equatable, Sendable {}

@ObservableState
public struct AddArchiveState: Equatable, Sendable {
    public var availableGenres: [String] = []
    public var selectedTrack: Track? = nil

    public var title: String = ""
    public var artist: String = ""
    public var genre: String = ""
    public var label: String = ""
    public var albumTitle: String = ""
    public var distributor: String = ""
    public var albumType: String = "정규"
    public var isIntroGood: Bool = false
    public var isGoodUntilMiddle: Bool = false
    public var isGoodUntilEnd: Bool = false
    public var rating: Double = 3.0
    public var memo: String = ""

    public var releaseDate: Date = Date()
    public var hasReleaseDate: Bool = false
    public var listenDate: Date = Date()

    public var coverImageData: Data?
    public var isGenreExpanded: Bool = false
    public var platformIDs: [String: String] = [:]

    public var editTrackId: UUID?
    public var isEditMode: Bool = false

    @Presents public var alert: AlertState<AddArchiveAlert>?

    public init(editTrack: ArchivedTrack? = nil) {
        if let track = editTrack {
            self.editTrackId = track.id
            self.isEditMode = true
            self.title = track.title
            self.artist = track.artist
            self.genre = track.genre
            self.label = track.label
            self.albumTitle = track.albumTitle ?? ""
            self.distributor = track.distributor ?? ""
            self.albumType = track.albumType ?? "정규"
            self.isIntroGood = track.isIntroGood
            self.isGoodUntilMiddle = track.isGoodUntilMiddle
            self.isGoodUntilEnd = track.isGoodUntilEnd
            self.rating = track.rating
            self.memo = track.memo ?? ""
            if let date = track.releaseDate {
                self.hasReleaseDate = true
                self.releaseDate = date
            }
            self.listenDate = track.listenDate
            self.coverImageData = track.coverImageData
            self.platformIDs = track.platformIDs
        }
    }
}

@CasePathable
public enum AddArchiveAction: BindableAction, Sendable {
    case binding(BindingAction<AddArchiveState>)
    case onAppear
    case closeButtonTapped
    case searchButtonTapped
    case saveButtonTapped
    case trackSelected(Track)
    case coverImageLoaded(Data?)
    case setCoverImageData(Data?)
    case genresLoaded(TaskResult<[String]>)
    case trackSaved(TaskResult<Void>)
    case alert(PresentationAction<AddArchiveAlert>)
    case delegate(DelegateAction)

    public enum DelegateAction: Equatable, Sendable {
        case didCloseAddArchive
        case didTapSearchTrack
    }
}
