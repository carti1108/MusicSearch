import Foundation
import UIKit
import MicroRIBs
import ArchiveDomain
import MSDomain
import TrackSearchDomain

@MainActor
public protocol ArchiveDependency: MicroRIBs.Dependency {
    var archiveRepository: any ArchiveRepository { get }
    var searchTracksUseCase: any SearchTracksUseCase { get }
    var exportPlaylistUseCase: any ExportPlaylistUseCase { get }
    var getMusicAccessTokenUseCase: any GetMusicAccessTokenUseCase { get }
    var authorizeMusicUseCase: any AuthorizeMusicUseCase { get }
}

public protocol ArchiveBuildable: Buildable {
    func build(withListener listener: ArchiveListener) -> ArchiveRouting
}

public protocol ArchiveRouting: ViewableRouting {
}

public protocol ArchiveListener: AnyObject {
}
