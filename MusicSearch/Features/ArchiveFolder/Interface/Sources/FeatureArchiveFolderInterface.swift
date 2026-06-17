import MicroRIBs

public protocol ArchiveFolderBuildable: Buildable {
    func build(withListener listener: ArchiveFolderListener) -> ArchiveFolderRouting
}

public protocol ArchiveFolderRouting: ViewableRouting {
}

public protocol ArchiveFolderListener: AnyObject {
    func archiveFolderDidTapClose()
}
