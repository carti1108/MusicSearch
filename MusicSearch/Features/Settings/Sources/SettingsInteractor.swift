import MicroRIBs
import FeatureSettingsInterface
import Foundation
import MSDomain

protocol SettingsInteractable: Interactable {
    var router: SettingsRouting? { get set }
    var listener: SettingsListener? { get set }
}

final class SettingsInteractor: PresentableInteractor<SettingsPresentable>, SettingsInteractable, SettingsPresentableListener {

    weak var router: SettingsRouting?
    weak var listener: SettingsListener?
    private let manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase
    private let fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase

    init(
        presenter: SettingsPresentable,
        manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase,
        fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase
    ) {
        self.manageSpotifyAuthUseCase = manageSpotifyAuthUseCase
        self.fetchSpotifyProfileUseCase = fetchSpotifyProfileUseCase
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        Task {
            await fetchUserProfileIfNeeded()
        }
    }

    override func willResignActive() {
        super.willResignActive()
    }
    
    private func fetchUserProfileIfNeeded() async {
        guard manageSpotifyAuthUseCase.getAccessToken() != nil else {
            await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
            return
        }
        
        do {
            let profile = try await fetchSpotifyProfileUseCase.execute()
            await MainActor.run {
                presenter.update(state: SettingsViewState(spotifyState: .connected(name: profile.name, imageURL: profile.imageURL)))
            }
        } catch {
            print("Failed to fetch Spotify User Profile: \(error)")
            await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
        }
    }
    
    func request(action: SettingsViewAction) {
        switch action {
        case .onSpotifyLoginTapped:
            Task {
                do {
                    try await manageSpotifyAuthUseCase.authorize()
                    await fetchUserProfileIfNeeded()
                } catch {
                    print("Spotify Auth failed: \(error)")
                }
            }
        case .onSpotifyDisconnectTapped:
            manageSpotifyAuthUseCase.disconnect()
            Task {
                await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
            }
        }
    }
}
