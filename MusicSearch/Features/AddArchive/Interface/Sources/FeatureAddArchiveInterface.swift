import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain

@MainActor
public protocol AddArchiveDependency: Dependency {
	var archiveRepository: ArchiveRepository { get }
	var searchTracksUseCase: SearchTracksUseCase { get }
	var imageDownloadRepository: ImageDownloadRepository { get }
}

public protocol AddArchiveBuildable: Buildable {
	func build(withListener listener: AddArchiveListener, editTrack: ArchivedTrack?) -> AddArchiveRouting
}

public protocol AddArchiveRouting: ViewableRouting {
}

@MainActor
public protocol AddArchiveListener: AnyObject {
	func didCloseAddArchive()
}
