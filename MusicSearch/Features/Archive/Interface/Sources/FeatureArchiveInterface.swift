import Foundation
import MicroRIBs
import ArchiveDomain
import FeatureAddArchiveInterface
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface


@MainActor
public protocol ArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
	var addArchiveBuilder: AddArchiveBuildable { get }
	var archiveSearchBuilder: ArchiveSearchBuildable { get }
	var archiveFolderBuilder: ArchiveFolderBuildable { get }
	
}

public protocol ArchiveBuildable: Buildable {
	func build(withListener listener: ArchiveListener) -> ArchiveRouting
}

public protocol ArchiveRouting: ViewableRouting {
	func routeToAddArchive()
	func detachAddArchive()
	
	func routeToSearch()
	func detachSearch()
	
	func routeToFolder()
	func detachFolder()
}

public protocol ArchiveListener: AnyObject {
}
