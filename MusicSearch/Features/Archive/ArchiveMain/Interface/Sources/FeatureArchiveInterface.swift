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

@MainActor
public protocol ArchiveBuildable: Buildable {
    func build(withListener listener: ArchiveListener) -> ArchiveRouting
}

@MainActor
public protocol ArchiveRouting: ViewableRouting {
}

@MainActor
public protocol ArchiveListener: AnyObject {
}
