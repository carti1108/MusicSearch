import SwiftUI
import ComposableArchitecture
import FeatureArchiveTrackSearch
import TrackSearchDomain
import FeatureTrackSearchTesting

@main
struct ArchiveTrackSearchExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ArchiveTrackSearchView(
                store: Store(initialState: ArchiveTrackSearchFeature.State()) {
                    ArchiveTrackSearchFeature()
                } withDependencies: {
                    $0.searchTracksUseCase = MockSearchTracksUseCase()
                    $0.continuousClock = ImmediateClock()
                }
            )
        }
    }
}


