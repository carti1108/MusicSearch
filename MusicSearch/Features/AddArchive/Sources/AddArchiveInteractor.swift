import MicroRIBs
import ArchiveDomain
import Foundation
import FeatureAddArchiveInterface
import MSDomain
import TrackSearchDomain

public protocol AddArchivePresentable: Presentable {
	var listener: AddArchivePresentableListener? { get set }
	func update(genres: [String])
	func populate(with track: Track)
}

public final class AddArchiveInteractor: PresentableInteractor<AddArchivePresentable>, AddArchiveInteractable, AddArchivePresentableListener {

	public weak var router: AddArchiveRouting?
	public weak var listener: AddArchiveListener?

	private let archiveRepository: ArchiveRepository
	private let searchTracksUseCase: SearchTracksUseCase

	public init(presenter: AddArchivePresentable, archiveRepository: ArchiveRepository, searchTracksUseCase: SearchTracksUseCase) {
		self.archiveRepository = archiveRepository
		self.searchTracksUseCase = searchTracksUseCase
		super.init(presenter: presenter)
		presenter.listener = self
	}

	public override func didBecomeActive() {
		super.didBecomeActive()
		Task {
			await fetchAndCombineGenres()
		}
	}
	
	private func fetchAndCombineGenres() async {
		do {
			let tracks = try await archiveRepository.fetchArchivedTracks()
			let customGenres = Array(Set(tracks.map { $0.genre })).sorted()
			let predefined = PredefinedGenre.allCases.map { $0.rawValue }
			
			var combined = predefined
			for custom in customGenres {
				if !combined.contains(custom) {
					combined.append(custom)
				}
			}
			
			await MainActor.run {
				presenter.update(genres: combined)
			}
		} catch {
			print("Failed to fetch genres: \(error)")
		}
	}

	public override func willResignActive() {
		super.willResignActive()
	}

	public func closeTapped() {
		listener?.didCloseAddArchive()
	}
	public func searchTapped() {
		router?.routeToSearch(searchTracksUseCase: searchTracksUseCase) { [weak self] track in
			self?.presenter.populate(with: track)
		}
	}
	
	public func saveTapped(title: String, artist: String, genre: String, label: String, rating: Double, memo: String, releaseDate: Date?, listenDate: Date, coverImageData: Data?, albumTitle: String, distributor: String, albumType: String, isIntroGood: Bool, isGoodUntilMiddle: Bool, isGoodUntilEnd: Bool, platformIDs: [String: String]) {
		let track = ArchivedTrack(
			platformIDs: platformIDs,
			coverImageData: coverImageData,
			title: title,
			artist: artist,
			genre: genre,
			label: label,
			releaseDate: releaseDate,
			listenDate: listenDate,
			rating: rating,
			memo: memo,
			albumTitle: albumTitle,
			distributor: distributor,
			albumType: albumType,
			isIntroGood: isIntroGood,
			isGoodUntilMiddle: isGoodUntilMiddle,
			isGoodUntilEnd: isGoodUntilEnd
		)
		
		Task {
			do {
				try await archiveRepository.addArchivedTrack(track)
				await MainActor.run {
					listener?.didCloseAddArchive()
				}
			} catch {
				print("Failed to save track: \(error)")
			}
		}
	}
}
