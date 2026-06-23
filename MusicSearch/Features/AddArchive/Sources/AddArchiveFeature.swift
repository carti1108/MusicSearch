import Foundation
import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import MSDomain

@Reducer
public struct AddArchiveFeature {
	
	@ObservableState
	public struct State: Equatable {
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
		
		@Presents public var searchTrack: ArchiveTrackSearchFeature.State?
		
		public var editTrackId: UUID?
		public var isEditMode: Bool = false
		
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
	
	public enum Action: BindableAction {
		case binding(BindingAction<State>)
		case onAppear
		case closeButtonTapped
		case searchButtonTapped
		case saveButtonTapped
		case trackSelected(Track)
		case coverImageLoaded(Data?)
		case setCoverImageData(Data?)
		case genresLoaded(TaskResult<[String]>)
		case trackSaved(TaskResult<Void>)
		case searchTrack(PresentationAction<ArchiveTrackSearchFeature.Action>)
		case delegate(DelegateAction)
	}
	
	public enum DelegateAction {
		case didCloseAddArchive
	}
	
	private let archiveRepository: ArchiveRepository
	private let searchTracksUseCase: SearchTracksUseCase
	private let onDelegate: (DelegateAction) -> Void
	
	public init(
		archiveRepository: ArchiveRepository,
		searchTracksUseCase: SearchTracksUseCase,
		onDelegate: @escaping (DelegateAction) -> Void
	) {
		self.archiveRepository = archiveRepository
		self.searchTracksUseCase = searchTracksUseCase
		self.onDelegate = onDelegate
	}
	
	public var body: some ReducerOf<Self> {
		BindingReducer()
		
		Reduce { state, action in
			switch action {
			case .binding:
				return .none
				
			case .onAppear:
				return .run { send in
					await send(.genresLoaded(TaskResult {
						let tracks = try await archiveRepository.fetchArchivedTracks()
						let customGenres = Array(Set(tracks.map { $0.genre })).sorted()
						let predefined = PredefinedGenre.allCases.map { $0.rawValue }
						
						var combined = predefined
						for custom in customGenres {
							if !combined.contains(custom) {
								combined.append(custom)
							}
						}
						return combined
					}))
				}
				
			case let .genresLoaded(.success(genres)):
				state.availableGenres = genres
				return .none
				
			case .genresLoaded(.failure):
				return .none
				
			case .closeButtonTapped:
				return .run { @MainActor _ in
					onDelegate(.didCloseAddArchive)
				}
				
			case .searchButtonTapped:
				state.searchTrack = ArchiveTrackSearchFeature.State()
				return .none
				
			case let .setCoverImageData(data):
				state.coverImageData = data
				return .none
				
			case let .trackSelected(track):
				state.selectedTrack = track
				state.title = track.title
				state.artist = track.artist
				state.albumTitle = track.albumTitle ?? ""
				
				if let type = track.albumType {
					if type.lowercased() == "single" {
						state.albumType = "싱글"
					} else if type.lowercased() == "ep" || type.lowercased() == "ep/single" {
						state.albumType = "EP"
					} else {
						state.albumType = "정규"
					}
				}
				
				if let date = track.releaseDate {
					state.hasReleaseDate = true
					state.releaseDate = date
				}
				
				state.platformIDs["spotify"] = track.id
				
				if let imageURL = track.imageURL {
					return .run { send in
						do {
							let (data, _) = try await URLSession.shared.data(from: imageURL)
							await send(.coverImageLoaded(data))
						} catch {
							await send(.coverImageLoaded(nil))
						}
					}
				}
				return .none
				
			case let .coverImageLoaded(data):
				state.coverImageData = data
				return .none
				
			case .saveButtonTapped:
				let track = ArchivedTrack(
					id: state.editTrackId ?? UUID(),
					platformIDs: state.platformIDs,
					coverImageData: state.coverImageData,
					title: state.title,
					artist: state.artist,
					genre: state.genre,
					label: state.label,
					releaseDate: state.hasReleaseDate ? state.releaseDate : nil,
					listenDate: state.listenDate,
					rating: state.rating,
					memo: state.memo,
					albumTitle: state.albumTitle,
					distributor: state.distributor,
					albumType: state.albumType,
					isIntroGood: state.isIntroGood,
					isGoodUntilMiddle: state.isGoodUntilMiddle,
					isGoodUntilEnd: state.isGoodUntilEnd
				)
				return .run { [isEditMode = state.isEditMode] send in
					await send(.trackSaved(TaskResult {
						if isEditMode {
							try await archiveRepository.updateArchivedTrack(track)
						} else {
							try await archiveRepository.addArchivedTrack(track)
						}
					}))
				}
				
			case .trackSaved(.success):
				return .run { @MainActor _ in
					onDelegate(.didCloseAddArchive)
				}
				
			case .trackSaved(.failure):
				return .none
				
			case let .searchTrack(.presented(.delegate(.trackSelected(track)))):
				state.searchTrack = nil
				return .send(.trackSelected(track))
				
			case .searchTrack:
				return .none
				
			case let .delegate(delegateAction):
				return .run { @MainActor _ in
					onDelegate(delegateAction)
				}
			}
		}
		.ifLet(\.$searchTrack, action: \.searchTrack) {
			ArchiveTrackSearchFeature(searchTracksUseCase: searchTracksUseCase)
		}
	}
}
