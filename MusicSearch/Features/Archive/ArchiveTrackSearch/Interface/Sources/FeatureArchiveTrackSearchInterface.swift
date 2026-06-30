import Foundation
import MicroRIBs
import MSDomain

@MainActor
public protocol ArchiveTrackSearchBuildable: Buildable {
	func build(withListener listener: ArchiveTrackSearchListener) -> ArchiveTrackSearchRouting
}

public protocol ArchiveTrackSearchRouting: ViewableRouting {
}

@MainActor
public protocol ArchiveTrackSearchListener: AnyObject {
	func archiveTrackSearchDidClose()
	func archiveTrackSearchDidSelectTrack(_ track: Track)
}
