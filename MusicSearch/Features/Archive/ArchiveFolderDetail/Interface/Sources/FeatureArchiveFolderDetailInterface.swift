//
//  FeatureArchiveFolderDetailInterface.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import MicroRIBs
import ArchiveDomain
import MSDomain

public protocol ArchiveFolderDetailBuildable: Buildable {
    func build(withListener listener: ArchiveFolderDetailListener, folderItem: FolderItem) -> ArchiveFolderDetailRouting
}

@MainActor
public protocol ArchiveFolderDetailRouting: ViewableRouting {
    func routeToFolderDetail(folderItem: FolderItem)
    func detachFolderDetail(popUI: Bool)
}

@MainActor
public protocol ArchiveFolderDetailListener: AnyObject {
    func archiveFolderDetailDidTapClose()
    func archiveFolderDetailDidTapFolder(_ folderItem: FolderItem)
    func archiveFolderDetailDidTapTrack(_ track: ArchivedTrack)
}

@MainActor
public protocol ArchiveFolderDetailDependency: Dependency {
    var archiveRepository: ArchiveRepository { get }
    var exportPlaylistUseCase: ExportPlaylistUseCase { get }
    var getMusicAccessTokenUseCase: GetMusicAccessTokenUseCase { get }
    var authorizeMusicUseCase: AuthorizeMusicUseCase { get }
}
