import MicroRIBs

public protocol ArchiveFolderBuildable: Buildable {
    func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting
}

import ArchiveDomain

public protocol ArchiveFolderRouting: ViewableRouting {
    func routeToFolderDetail(folderItem: FolderItem)
    func detachFolderDetail(popUI: Bool)
}

@MainActor
public protocol ArchiveFolderListener: AnyObject {
    func archiveFolderDidTapClose()
    func archiveFolderDidTapTrack(_ track: ArchivedTrack)
}
