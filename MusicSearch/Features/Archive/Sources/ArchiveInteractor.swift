import MicroRIBs
import FeatureArchiveInterface
import ArchiveDomain
import Foundation
import FeatureAddArchiveInterface

public protocol ArchivePresentable: Presentable {
	var listener: ArchivePresentableListener? { get set }
}





public final class ArchiveInteractor: PresentableInteractor<ArchivePresentable>, ArchiveInteractable, ArchivePresentableListener, AddArchiveListener {

	public weak var router: ArchiveRouting?
	public weak var listener: ArchiveListener?
	
	private let viewModel: ArchiveViewModel
	private let archiveRepository: ArchiveRepository

	public init(presenter: ArchivePresentable, viewModel: ArchiveViewModel, archiveRepository: ArchiveRepository) {
		self.archiveRepository = archiveRepository
		self.viewModel = viewModel
		super.init(presenter: presenter)
		presenter.listener = self
		viewModel.listener = self
	}

		public override func didBecomeActive() {
		super.didBecomeActive()
		Task {
			await fetchArchivedTracks()
		}
	}

	private func fetchArchivedTracks() async {
		do {
			let tracks = try await archiveRepository.fetchArchivedTracks()
			
			var topGenre = "없음"
			if !tracks.isEmpty {
				let genreCounts = tracks.reduce(into: [String: Int]()) { counts, track in
					counts[track.genre, default: 0] += 1
				}
				if let maxGenre = genreCounts.max(by: { $0.value < $1.value })?.key {
					topGenre = maxGenre
				}
			}
			
			await MainActor.run {
				self.viewModel.update(state: ArchiveViewState(
					totalTracksCount: tracks.count,
					topGenreName: topGenre,
					recentTracks: tracks
				))
			}
		} catch {
			print("Failed to fetch archived tracks: \(error)")
		}
	}


	public override func willResignActive() {
		super.willResignActive()
	}
	
	// MARK: - ArchivePresentableListener
	
	
	// MARK: - AddArchiveListener
	
	public func didCloseAddArchive() {
		router?.detachAddArchive()
		Task {
			await fetchArchivedTracks()
		}
	}

	public func request(action: ArchiveViewAction) {
		switch action {
		case .onAddTapped:
			router?.routeToAddArchive()
		case .onSearchTapped:
			router?.routeToSearch()
		case .onFolderTapped:
			router?.routeToFolder()

		case .onDeleteTapped(let track):
			Task {
				do {
					try await archiveRepository.deleteArchivedTrack(id: track.id)
					await fetchArchivedTracks()
				} catch {
					print("Failed to delete track: \(error)")
				}
			}
		}
	}
    
    public func archiveSearchDidTapClose() {
        router?.detachSearch()
    }
    
    public func archiveFolderDidTapClose() {
        router?.detachFolder()
    }
    
}
