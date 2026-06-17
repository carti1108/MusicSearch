import MicroRIBs
import ArchiveDomain
import Foundation
import FeatureAddArchiveInterface

public protocol AddArchivePresentable: Presentable {
	var listener: AddArchivePresentableListener? { get set }
	func update(genres: [String])
}

public final class AddArchiveInteractor: PresentableInteractor<AddArchivePresentable>, AddArchiveInteractable, AddArchivePresentableListener {

	public weak var router: AddArchiveRouting?
	public weak var listener: AddArchiveListener?

		private let archiveRepository: ArchiveRepository

	public init(presenter: AddArchivePresentable, archiveRepository: ArchiveRepository) {
		self.archiveRepository = archiveRepository
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
			
			// Combine predefined + custom, removing duplicates, keeping predefined first
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
	public func saveTapped(title: String, artist: String, genre: String, label: String, rating: Double, memo: String, releaseDate: Date?, listenDate: Date, coverImageData: Data?) {
		let track = ArchivedTrack(
			coverImageData: coverImageData,
			title: title,
			artist: artist,
			genre: genre,
			label: label,
			releaseDate: releaseDate,
			listenDate: listenDate,
			rating: rating,
			memo: memo
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