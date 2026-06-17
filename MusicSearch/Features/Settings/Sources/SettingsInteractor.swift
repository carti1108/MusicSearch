import MicroRIBs
import FeatureSettingsInterface
import NetworkLayer
import Foundation
import MSUtil
import MSData

protocol SettingsInteractable: Interactable {
    var router: SettingsRouting? { get set }
    var listener: SettingsListener? { get set }
}

final class SettingsInteractor: PresentableInteractor<SettingsPresentable>, SettingsInteractable, SettingsPresentableListener {

    weak var router: SettingsRouting?
    weak var listener: SettingsListener?
    private let networkManager: NetworkRequesting

    init(presenter: SettingsPresentable, networkManager: NetworkRequesting) {
        self.networkManager = networkManager
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
        guard let token = KeychainManager.shared.loadString(forKey: "SpotifyAccessToken") else {
            await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
            return
        }
        
        do {
            let api = SpotifyAPI.me(token: token, config: DefaultSpotifyAPIConfiguration())
            let response = try await networkManager.perform(with: api, as: SpotifyUserProfileResponse.self)
            
            let name = response.display_name ?? "Spotify User"
            let urlString = response.images?.first?.url
            let imageURL = urlString != nil ? URL(string: urlString!) : nil
            
            await MainActor.run {
                presenter.update(state: SettingsViewState(spotifyState: .connected(name: name, imageURL: imageURL)))
            }
        } catch {
            print("Failed to fetch Spotify User Profile: \(error)")
            // If token is expired/invalid, we could handle refresh here. For now just set disconnected
            await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
        }
    }
    
    func request(action: SettingsViewAction) {
        switch action {
        case .onSpotifyLoginTapped:
            Task {
                do {
                    let config = DefaultSpotifyAPIConfiguration()
                    let code = try await SpotifyAuthManager.shared.authorize(config: config)
                    print("Spotify Auth Code received: \(code)")
                    
                    let response = try await SpotifyAuthManager.shared.exchangeToken(code: code, config: config, networkManager: networkManager)
                    
                    _ = KeychainManager.shared.saveString(response.access_token, forKey: "SpotifyAccessToken")
                    if let refreshToken = response.refresh_token {
                        _ = KeychainManager.shared.saveString(refreshToken, forKey: "SpotifyRefreshToken")
                    }
                    
                    UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(response.expires_in)), forKey: "SpotifyTokenExpiry")
                    print("Successfully logged into Spotify and saved tokens!")
                    
                    await fetchUserProfileIfNeeded()
                } catch {
                    print("Spotify Auth failed: \(error)")
                }
            }
        case .onSpotifyDisconnectTapped:
            _ = KeychainManager.shared.delete(forKey: "SpotifyAccessToken")
            _ = KeychainManager.shared.delete(forKey: "SpotifyRefreshToken")
            UserDefaults.standard.removeObject(forKey: "SpotifyTokenExpiry")
            Task {
                await MainActor.run { presenter.update(state: SettingsViewState(spotifyState: .disconnected)) }
            }
        }
    }
}
