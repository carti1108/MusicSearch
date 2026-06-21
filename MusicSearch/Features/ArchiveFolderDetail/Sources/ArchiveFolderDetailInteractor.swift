import MicroRIBs
import ArchiveDomain
import MSDomain
import FeatureArchiveFolderDetailInterface
import Foundation

public protocol ArchiveFolderDetailPresentable: Presentable {
    var listener: ArchiveFolderDetailPresentableListener? { get set }
    func update(state: ArchiveFolderDetailViewState)
    func showLoginPrompt()
}

public final class ArchiveFolderDetailInteractor: PresentableInteractor<ArchiveFolderDetailPresentable>, ArchiveFolderDetailInteractable, ArchiveFolderDetailPresentableListener {

    public weak var router: ArchiveFolderDetailRouting?
    public weak var listener: ArchiveFolderDetailListener?

    private let folderItem: FolderItem
    private let archiveRepository: ArchiveRepository
    private let exportToSpotifyUseCase: ExportToSpotifyUseCase
    private let manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase
    private var tracks: [ArchivedTrack] = []

    public init(presenter: ArchiveFolderDetailPresentable, folderItem: FolderItem, archiveRepository: ArchiveRepository, exportToSpotifyUseCase: ExportToSpotifyUseCase, manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase) {
        self.folderItem = folderItem
        self.archiveRepository = archiveRepository
        self.exportToSpotifyUseCase = exportToSpotifyUseCase
        self.manageSpotifyAuthUseCase = manageSpotifyAuthUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    public override func didBecomeActive() {
        super.didBecomeActive()
        Task {
            await loadData()
        }
    }

    private func loadData() async {
        do {
            let allTracks = try await archiveRepository.fetchArchivedTracks()
            let formatter = DateFormatter()
            
            var filteredTracks: [ArchivedTrack] = []
            var isMonthGroup = false
            var foldersToDisplay: [FolderItem]? = nil

            switch folderItem.type {
            case .releaseYear(let year):
                isMonthGroup = true
                formatter.dateFormat = "yyyy"
                filteredTracks = allTracks.filter { track in
                    if let date = track.releaseDate {
                        return formatter.string(from: date) == year
                    }
                    return false
                }
                
                formatter.dateFormat = "MM"
                let grouped = Dictionary(grouping: filteredTracks, by: { track -> String in
                    if let date = track.releaseDate { return formatter.string(from: date) }
                    return ""
                })
                foldersToDisplay = grouped.keys.filter { !$0.isEmpty }.sorted(by: <).map { month in
                    FolderItem(title: month + "월", subtitle: "\(grouped[month]?.count ?? 0) 곡", type: .releaseMonth(year: year, month: month))
                }
                
            case .listenYear(let year):
                isMonthGroup = true
                formatter.dateFormat = "yyyy"
                filteredTracks = allTracks.filter { track in
                    return formatter.string(from: track.listenDate) == year
                }
                
                formatter.dateFormat = "MM"
                let grouped = Dictionary(grouping: filteredTracks, by: { track -> String in
                    return formatter.string(from: track.listenDate)
                })
                foldersToDisplay = grouped.keys.sorted(by: <).map { month in
                    FolderItem(title: month + "월", subtitle: "\(grouped[month]?.count ?? 0) 곡", type: .listenMonth(year: year, month: month))
                }
                
            case .releaseMonth(let year, let month):
                isMonthGroup = true
                formatter.dateFormat = "yyyy-MM"
                filteredTracks = allTracks.filter { track in
                    if let date = track.releaseDate {
                        return formatter.string(from: date) == "\(year)-\(month)"
                    }
                    return false
                }
                
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: filteredTracks, by: { track -> Int in
                    if let date = track.releaseDate { return calendar.component(.weekOfMonth, from: date) }
                    return 0
                })
                foldersToDisplay = grouped.keys.filter { $0 > 0 }.sorted(by: <).map { week in
                    FolderItem(title: "\(week)주차", subtitle: "\(grouped[week]?.count ?? 0) 곡", type: .releaseWeek(year: year, month: month, week: "\(week)"))
                }
                
            case .listenMonth(let year, let month):
                isMonthGroup = true
                formatter.dateFormat = "yyyy-MM"
                filteredTracks = allTracks.filter { track in
                    return formatter.string(from: track.listenDate) == "\(year)-\(month)"
                }
                
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: filteredTracks, by: { track -> Int in
                    return calendar.component(.weekOfMonth, from: track.listenDate)
                })
                foldersToDisplay = grouped.keys.sorted(by: <).map { week in
                    FolderItem(title: "\(week)주차", subtitle: "\(grouped[week]?.count ?? 0) 곡", type: .listenWeek(year: year, month: month, week: "\(week)"))
                }
                
            case .releaseWeek(let year, let month, let week):
                formatter.dateFormat = "yyyy-MM"
                let calendar = Calendar.current
                filteredTracks = allTracks.filter { track in
                    if let date = track.releaseDate {
                        return formatter.string(from: date) == "\(year)-\(month)" && "\(calendar.component(.weekOfMonth, from: date))" == week
                    }
                    return false
                }
                
            case .listenWeek(let year, let month, let week):
                formatter.dateFormat = "yyyy-MM"
                let calendar = Calendar.current
                filteredTracks = allTracks.filter { track in
                    return formatter.string(from: track.listenDate) == "\(year)-\(month)" && "\(calendar.component(.weekOfMonth, from: track.listenDate))" == week
                }
            case .genre(let name):
                filteredTracks = allTracks.filter { $0.genre == name }
            case .rating(let value):
                filteredTracks = allTracks.filter { Int($0.rating) == value }
            case .custom:
                break
            }
            
            self.tracks = filteredTracks
            
            await MainActor.run {
                if isMonthGroup {
                    presenter.update(state: ArchiveFolderDetailViewState(title: folderItem.title, folders: foldersToDisplay))
                } else {
                    presenter.update(state: ArchiveFolderDetailViewState(title: folderItem.title, tracks: filteredTracks))
                }
            }
            
        } catch {
            print("Error loading details: \(error)")
        }
    }

    public override func willResignActive() {
        super.willResignActive()
    }
    
    public func archiveFolderDetailDidTapClose() {
        router?.detachFolderDetail()
    }

    public func didTapClose() {
        listener?.archiveFolderDetailDidTapClose()
    }
    
    public func didTapFolder(_ folder: FolderItem) {
        router?.routeToFolderDetail(folderItem: folder)
    }
    
    public func didTapTrack(_ track: ArchivedTrack) {
    }
    
    public func didTapExport() {
        guard !tracks.isEmpty else { return }
        
        if manageSpotifyAuthUseCase.getAccessToken() == nil {
            presenter.showLoginPrompt()
        } else {
            performExport()
        }
    }
    
    public func didTapLogin() {
        Task {
            do {
                try await manageSpotifyAuthUseCase.authorize()
                performExport()
            } catch {
                print("Failed to authorize Spotify: \(error)")
            }
        }
    }
    
    private func performExport() {
        guard !tracks.isEmpty else { return }
        
        Task {
            await MainActor.run {
                presenter.update(state: ArchiveFolderDetailViewState(title: folderItem.title, tracks: tracks, exportState: .exporting(progress: ExportProgress(totalCount: tracks.count, currentCount: 0, failedTracks: [], isComplete: false))))
            }
            
            let playlistName = "MusicSearch Archive - \(folderItem.title)"
            for await progress in exportToSpotifyUseCase.execute(tracks: tracks, playlistName: playlistName) {
                await MainActor.run {
                    presenter.update(state: ArchiveFolderDetailViewState(title: folderItem.title, tracks: tracks, exportState: .exporting(progress: progress)))
                    
                    if progress.isComplete {
                        presenter.update(state: ArchiveFolderDetailViewState(title: folderItem.title, tracks: tracks, exportState: .completed(successCount: progress.currentCount - progress.failedTracks.count, failedCount: progress.failedTracks.count)))
                    }
                }
            }
        }
    }
}
