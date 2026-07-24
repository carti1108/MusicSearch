//
//  ArchiveDestinationViews.swift
//  MusicSearch
//
//  Created by Kiseok on 7/24/26.
//

import SwiftUI
import ComposableArchitecture
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface
import FeatureAddArchiveInterface

public struct ArchiveDestinationViews {
    public let search: (Store<ArchiveSearchState, ArchiveSearchAction>) -> AnyView
    public let folder: (Store<ArchiveFolderState, ArchiveFolderAction>) -> AnyView
    public let addArchive: (Store<AddArchiveState, AddArchiveAction>) -> AnyView
    public let editArchive: (Store<AddArchiveState, AddArchiveAction>) -> AnyView
    public let folderDetail: (Store<ArchiveFolderDetailState, ArchiveFolderDetailAction>) -> AnyView

    public init(
        search: @escaping (Store<ArchiveSearchState, ArchiveSearchAction>) -> AnyView,
        folder: @escaping (Store<ArchiveFolderState, ArchiveFolderAction>) -> AnyView,
        addArchive: @escaping (Store<AddArchiveState, AddArchiveAction>) -> AnyView,
        editArchive: @escaping (Store<AddArchiveState, AddArchiveAction>) -> AnyView,
        folderDetail: @escaping (Store<ArchiveFolderDetailState, ArchiveFolderDetailAction>) -> AnyView
    ) {
        self.search = search
        self.folder = folder
        self.addArchive = addArchive
        self.editArchive = editArchive
        self.folderDetail = folderDetail
    }
}
