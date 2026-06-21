import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain

@MainActor
public protocol AddArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
	var musicAppRepository: MusicAppRepository { get }
}

public protocol AddArchiveBuildable: Buildable {
	func build(withListener listener: AddArchiveListener) -> AddArchiveRouting
}

public protocol AddArchiveRouting: ViewableRouting {
	func routeToSearch(searchTracksUseCase: SearchTracksUseCase, onSelect: @escaping (Track) -> Void)
}

public protocol AddArchiveListener: AnyObject {
	func didCloseAddArchive()
}
