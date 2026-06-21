import Foundation
import MSDomain
import NetworkLayer
import MSUtil

public final class SpotifyAuthRepositoryImpl: SpotifyAuthRepository {
    private let networkManager: NetworkRequesting
    
    public init(networkManager: NetworkRequesting) {
        self.networkManager = networkManager
    }
    
    public func getAccessToken() -> String? {
        return KeychainManager.shared.loadString(forKey: "SpotifyAccessToken")
    }
    
    public func authorize() async throws {
        let config = DefaultSpotifyAPIConfiguration()
        let code = try await SpotifyAuthManager.shared.authorize(config: config)
        
        let response = try await SpotifyAuthManager.shared.exchangeToken(code: code, config: config, networkManager: networkManager)
        
        _ = KeychainManager.shared.saveString(response.access_token, forKey: "SpotifyAccessToken")
        if let refreshToken = response.refresh_token {
            _ = KeychainManager.shared.saveString(refreshToken, forKey: "SpotifyRefreshToken")
        }
        
        UserDefaults.standard.set(Date().addingTimeInterval(TimeInterval(response.expires_in)), forKey: "SpotifyTokenExpiry")
    }
    
    public func disconnect() {
        _ = KeychainManager.shared.delete(forKey: "SpotifyAccessToken")
        _ = KeychainManager.shared.delete(forKey: "SpotifyRefreshToken")
        UserDefaults.standard.removeObject(forKey: "SpotifyTokenExpiry")
    }
    
    public func fetchUserProfile() async throws -> (name: String, imageURL: URL?) {
        guard let token = getAccessToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let api = SpotifyAPI.me(token: token, config: DefaultSpotifyAPIConfiguration())
        let response = try await networkManager.perform(with: api, as: SpotifyUserProfileResponse.self)
        
        let name = response.display_name ?? "Spotify User"
        let urlString = response.images?.first?.url
        let imageURL = urlString != nil ? URL(string: urlString!) : nil
        
        return (name: name, imageURL: imageURL)
    }
}
