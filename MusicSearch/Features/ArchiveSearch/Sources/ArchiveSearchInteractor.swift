import MicroRIBs
import FeatureArchiveSearchInterface
import ArchiveDomain
import Foundation
import Combine

protocol ArchiveSearchInteractable: Interactable {
    var router: ArchiveSearchRouting? { get set }
    var listener: ArchiveSearchListener? { get set }
}

final class ArchiveSearchInteractor: PresentableInteractor<ArchiveSearchPresentable>, ArchiveSearchInteractable, ArchiveSearchPresentableListener {

    weak var router: ArchiveSearchRouting?
    weak var listener: ArchiveSearchListener?

    private let archiveRepository: ArchiveRepository
    private let viewModel: ArchiveSearchViewModel
    private var cancellables = Set<AnyCancellable>()
    private var allTracks: [ArchivedTrack] = []

    init(presenter: ArchiveSearchPresentable, archiveRepository: ArchiveRepository, viewModel: ArchiveSearchViewModel) {
        self.archiveRepository = archiveRepository
        self.viewModel = viewModel
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        
        Task {
            do {
                self.allTracks = try await archiveRepository.fetchArchivedTracks()
            } catch {
                print("Failed to fetch tracks for search: \(error)")
            }
        }
        
        viewModel.$searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.filterTracks(query: query)
            }
            .store(in: &cancellables)
    }
    
    private func filterTracks(query: String) {
        guard !query.isEmpty else {
            viewModel.recommendedTracks = []
            return
        }
        let lowerQuery = query.lowercased()
        let filtered = allTracks.filter { track in
            track.title.lowercased().contains(lowerQuery) ||
            track.artist.lowercased().contains(lowerQuery) ||
            track.genre.lowercased().contains(lowerQuery)
        }
        viewModel.recommendedTracks = filtered
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func didTapClose() {
        listener?.archiveSearchDidTapClose()
    }
}
