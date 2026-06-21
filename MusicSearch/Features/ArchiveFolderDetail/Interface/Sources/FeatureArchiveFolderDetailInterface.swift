import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain

public protocol ArchiveFolderDetailBuildable: Buildable {
    func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting
}

public protocol ArchiveFolderDetailRouting: ViewableRouting {
    func routeToFolderDetail(folderItem: FolderItem)
    func detachFolderDetail()
}

public protocol ArchiveFolderDetailListener: AnyObject {
    func archiveFolderDetailDidTapClose()
}


@MainActor
public protocol ArchiveFolderDetailDependency: Dependency {
    var archiveRepository: ArchiveRepository { get }
    var exportToSpotifyUseCase: ExportToSpotifyUseCase { get }
    var manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase { get }
}
