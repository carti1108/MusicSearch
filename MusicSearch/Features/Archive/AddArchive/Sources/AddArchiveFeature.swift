import Foundation
import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import MSDomain
import OSLog
import Kingfisher

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

		public var editTrackId: UUID?
		public var isEditMode: Bool = false

		@Presents public var alert: AlertState<Alert>?

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
		case alert(PresentationAction<Alert>)
		case delegate(DelegateAction)
	}

	public enum Alert: Equatable {}

	public enum DelegateAction: Equatable {
		case didCloseAddArchive
		case didTapSearchTrack
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
				return .run { @MainActor _ in
					onDelegate(.didTapSearchTrack)
				}

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
							let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
								KingfisherManager.shared.retrieveImage(with: imageURL) { result in
									switch result {
									case .success(let value):
										if let imgData = value.image.pngData() {
											continuation.resume(returning: imgData)
										} else {
											continuation.resume(throwing: URLError(.cannotDecodeRawData))
										}
									case .failure(let error):
										continuation.resume(throwing: error)
									}
								}
							}
							await send(.coverImageLoaded(data))
						} catch {
							Logger(subsystem: "MusicSearch", category: "AddArchiveFeature").error("Fetch cover image failed: \(error.localizedDescription)")
							await send(.coverImageLoaded(nil))
						}
					}
				}
				return .none

			case let .coverImageLoaded(data):
				state.coverImageData = data
				return .none

			case .saveButtonTapped:
				if state.genre.trimmingCharacters(in: .whitespaces).isEmpty {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("장르를 입력해주세요.") }
					return .none
				}
				if state.memo.count > 500 {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("메모는 500자를 초과할 수 없습니다.") }
					return .none
				}
				if let imageData = state.coverImageData, imageData.count > 5 * 1024 * 1024 {
					state.alert = AlertState { TextState("이미지 오류") } message: { TextState("이미지 크기는 5MB를 초과할 수 없습니다.") }
					return .none
				}

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

			case let .trackSaved(.failure(error)):
				state.alert = AlertState { TextState("저장 실패") } message: { TextState("저장 중 문제가 발생했습니다: \(error.localizedDescription)") }
				return .none

			case .alert:
				return .none

			case let .delegate(delegateAction):
				return .run { @MainActor _ in
					onDelegate(delegateAction)
				}
			}
		}
		.ifLet(\.$alert, action: \.alert)
	}
}
