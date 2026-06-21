import MicroRIBs
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import ArchiveDomain
import ArchiveDomain
import Foundation

protocol ArchiveFolderInteractable: Interactable, ArchiveFolderDetailListener {
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            
            let releaseGrouped = Dictionary(grouping: tracks.filter { $0.releaseDate != nil }, by: { track -> String in
                if let date = track.releaseDate {
                    return formatter.string(from: date)
                }
                return ""
            })
            let releaseYearFolders = releaseGrouped.keys.sorted(by: >).map { year in
                FolderItem(title: year + "년 발매", subtitle: "\(releaseGrouped[year]?.count ?? 0) 곡", type: .releaseYear(year: year))
            }
            
            let listenGrouped = Dictionary(grouping: tracks, by: { track -> String in
                return formatter.string(from: track.listenDate)
            })
            let listenYearFolders = listenGrouped.keys.sorted(by: >).map { year in
                FolderItem(title: year + "년 청취", subtitle: "\(listenGrouped[year]?.count ?? 0) 곡", type: .listenYear(year: year))
            }
            
            let groupedByGenre = Dictionary(grouping: tracks, by: { $0.genre })
            let genreFolders = groupedByGenre.keys.sorted().map { genre in
                FolderItem(title: genre, subtitle: "\(groupedByGenre[genre]?.count ?? 0) 곡", type: .genre(name: genre))
            }
            
            let groupedByRating = Dictionary(grouping: tracks, by: { Int($0.rating) })
            let ratingFolders = groupedByRating.keys.sorted(by: >).map { rating in
                let stars = String(repeating: "★", count: rating) + String(repeating: "☆", count: max(0, 5 - rating))
                return FolderItem(title: stars, subtitle: "\(groupedByRating[rating]?.count ?? 0) 곡", type: .rating(value: rating))
            }
            
            await MainActor.run {
                self.viewModel.releaseYearFolders = releaseYearFolders
                self.viewModel.listenYearFolders = listenYearFolders
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
    
    func archiveFolderDetailDidTapClose() {
        router?.detachFolderDetail()
    }
    
    func didTapFolder(_ folder: FolderItem) {
        router?.routeToFolderDetail(folderItem: folder)
    }
}
