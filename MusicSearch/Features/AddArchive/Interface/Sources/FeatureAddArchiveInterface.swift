import Foundation
import MicroRIBs
import ArchiveDomain

@MainActor
public protocol AddArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
}

public protocol AddArchiveBuildable: Buildable {
	func build(withListener listener: AddArchiveListener) -> AddArchiveRouting
}

public protocol AddArchiveRouting: ViewableRouting {
}

public protocol AddArchiveListener: AnyObject {
	func didCloseAddArchive()
}
