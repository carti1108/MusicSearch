import MicroRIBs
import FeatureArchiveFolderInterface
import ArchiveDomain
import Foundation

protocol ArchiveFolderInteractable: Interactable {
    var router: ArchiveFolderRouting? { get set }
    var listener: ArchiveFolderListener? { get set }
}

final class ArchiveFolderInteractor: PresentableInteractor<ArchiveFolderPresentable>, ArchiveFolderInteractable, ArchiveFolderPresentableListener {

    weak var router: ArchiveFolderRouting?
    weak var listener: ArchiveFolderListener?

    private let archiveRepository: ArchiveRepository
    private let viewModel: ArchiveFolderViewModel

    init(presenter: ArchiveFolderPresentable, archiveRepository: ArchiveRepository, viewModel: ArchiveFolderViewModel) {
        self.archiveRepository = archiveRepository
        self.viewModel = viewModel
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        Task {
            await fetchAndGroupTracks()
        }
    }
    
    private func fetchAndGroupTracks() async {
        do {
            let tracks = try await archiveRepository.fetchArchivedTracks()
            
            // Group by Year
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            let groupedByYear = Dictionary(grouping: tracks, by: { track -> String in
                if let date = track.releaseDate {
                    return formatter.string(from: date)
                }
                return "Unknown"
            })
            let yearFolders = groupedByYear.keys.sorted(by: >).map { year in
                FolderItem(title: year + "년", subtitle: "\(groupedByYear[year]?.count ?? 0) 곡")
            }
            
            // Group by Genre
            let groupedByGenre = Dictionary(grouping: tracks, by: { $0.genre })
            let genreFolders = groupedByGenre.keys.sorted().map { genre in
                FolderItem(title: genre, subtitle: "\(groupedByGenre[genre]?.count ?? 0) 곡")
            }
            
            // Group by Rating
            let groupedByRating = Dictionary(grouping: tracks, by: { Int($0.rating) })
            let ratingFolders = groupedByRating.keys.sorted(by: >).map { rating in
                FolderItem(title: "별점 \(rating)점대", subtitle: "\(groupedByRating[rating]?.count ?? 0) 곡")
            }
            
            await MainActor.run {
                self.viewModel.yearFolders = yearFolders
                self.viewModel.genreFolders = genreFolders
                self.viewModel.ratingFolders = ratingFolders
            }
        } catch {
            print("Failed to fetch tracks in folder: \(error)")
        }
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    func didTapClose() {
        listener?.archiveFolderDidTapClose()
    }
}
