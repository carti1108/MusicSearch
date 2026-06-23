import Foundation
import MicroRIBs
import ArchiveDomain
import FeatureAddArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface


@MainActor
public protocol ArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
	var addArchiveBuilder: AddArchiveBuildable { get }
	var archiveSearchBuilder: ArchiveSearchBuildable { get }
	var archiveFolderBuilder: ArchiveFolderBuildable { get }
	var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable { get }
}

public protocol ArchiveBuildable: Buildable {
	func build(withListener listener: ArchiveListener) -> ArchiveRouting
}

public protocol ArchiveRouting: ViewableRouting {
	func routeToAddArchive()
	func routeToEditArchive(track: ArchivedTrack)
	func detachAddArchive()
	
	func routeToSearch()
	func detachSearch()
	
	func routeToFolder()
	func detachFolder()
}

public protocol ArchiveListener: AnyObject {
}
