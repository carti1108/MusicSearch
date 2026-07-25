import Foundation
import ComposableArchitecture
import MSDomain
import TrackSearchDomain

private func unimplemented<T>(_ message: String) -> T {
    fatalError(message)
}

private enum ArchiveRepositoryKey: DependencyKey {
    static let liveValue: any ArchiveRepository & Sendable = unimplemented("ArchiveRepository must be injected")
}

private enum SearchTracksUseCaseKey: DependencyKey {
    static let liveValue: any SearchTracksUseCase & Sendable = unimplemented("SearchTracksUseCase must be injected")
}

private enum ExportPlaylistUseCaseKey: DependencyKey {
    static let liveValue: any ExportPlaylistUseCase & Sendable = unimplemented("ExportPlaylistUseCase must be injected")
}

private enum GetMusicAccessTokenUseCaseKey: DependencyKey {
    static let liveValue: any GetMusicAccessTokenUseCase & Sendable = unimplemented("GetMusicAccessTokenUseCase must be injected")
}

private enum AuthorizeMusicUseCaseKey: DependencyKey {
    static let liveValue: any AuthorizeMusicUseCase & Sendable = unimplemented("AuthorizeMusicUseCase must be injected")
}

public extension DependencyValues {
    var archiveRepository: any ArchiveRepository & Sendable {
        get { self[ArchiveRepositoryKey.self] }
        set { self[ArchiveRepositoryKey.self] = newValue }
    }

    var searchTracksUseCase: any SearchTracksUseCase & Sendable {
        get { self[SearchTracksUseCaseKey.self] }
        set { self[SearchTracksUseCaseKey.self] = newValue }
    }

    var exportPlaylistUseCase: any ExportPlaylistUseCase & Sendable {
        get { self[ExportPlaylistUseCaseKey.self] }
        set { self[ExportPlaylistUseCaseKey.self] = newValue }
    }

    var getMusicAccessTokenUseCase: any GetMusicAccessTokenUseCase & Sendable {
        get { self[GetMusicAccessTokenUseCaseKey.self] }
        set { self[GetMusicAccessTokenUseCaseKey.self] = newValue }
    }

    var authorizeMusicUseCase: any AuthorizeMusicUseCase & Sendable {
        get { self[AuthorizeMusicUseCaseKey.self] }
        set { self[AuthorizeMusicUseCaseKey.self] = newValue }
    }
}
