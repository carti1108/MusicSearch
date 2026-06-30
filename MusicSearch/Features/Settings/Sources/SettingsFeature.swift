import Foundation
import ComposableArchitecture
import MSDomain

@Reducer
public struct SettingsFeature {
	
	@ObservableState
	public struct State: Equatable {
		public enum SpotifyConnectionState: Equatable {
			case disconnected
			case connected(name: String, imageURL: URL?)
		}
		
		public var spotifyState: SpotifyConnectionState = .disconnected
		
		public init() {}
	}
	
	public enum Action {
		case onAppear
		case loginTapped
		case disconnectTapped
		
		case fetchProfileResponse(TaskResult<SpotifyUserProfile?>)
		case authResponse(TaskResult<Void>)
	}
	
	public struct SpotifyUserProfile: Equatable, Sendable {
		public let name: String
		public let imageURL: URL?
		public init(name: String, imageURL: URL?) {
			self.name = name
			self.imageURL = imageURL
		}
	}
	
	private let manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase
	private let fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase
	
	public init(
		manageSpotifyAuthUseCase: ManageSpotifyAuthUseCase,
		fetchSpotifyProfileUseCase: FetchSpotifyProfileUseCase
	) {
		self.manageSpotifyAuthUseCase = manageSpotifyAuthUseCase
		self.fetchSpotifyProfileUseCase = fetchSpotifyProfileUseCase
	}
	
	public var body: some ReducerOf<Self> {
		Reduce { state, action in
			switch action {
			case .onAppear:
				return .run { send in
					guard manageSpotifyAuthUseCase.getAccessToken() != nil else {
						await send(.fetchProfileResponse(.success(nil)))
						return
					}
					
					await send(.fetchProfileResponse(TaskResult {
						let result = try await fetchSpotifyProfileUseCase.execute()
						return SpotifyUserProfile(name: result.name, imageURL: result.imageURL)
					}))
				}
				
			case .loginTapped:
				return .run { send in
					await send(.authResponse(TaskResult {
						try await manageSpotifyAuthUseCase.authorize()
					}))
				}
				
			case .disconnectTapped:
				manageSpotifyAuthUseCase.disconnect()
				state.spotifyState = .disconnected
				return .none
				
				
			case let .fetchProfileResponse(.success(profile)):
				if let profile = profile {
					state.spotifyState = .connected(name: profile.name, imageURL: profile.imageURL)
				} else {
					state.spotifyState = .disconnected
				}
				return .none
				
			case .fetchProfileResponse(.failure):
				state.spotifyState = .disconnected
				return .none
				
			case .authResponse(.success):
				return .send(.onAppear)
				
			case .authResponse(.failure):
				return .none
			}
		}
	}
}
