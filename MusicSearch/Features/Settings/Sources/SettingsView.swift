import SwiftUI
import MSDesignSystem

public enum SettingsViewAction {
    case onSpotifyLoginTapped
    case onSpotifyDisconnectTapped
}

public protocol SettingsPresentableListener: AnyObject {
    func request(action: SettingsViewAction)
}

public enum SpotifyConnectionState {
    case disconnected
    case connected(name: String, imageURL: URL?)
}

public struct SettingsViewState {
    public var spotifyState: SpotifyConnectionState
    
    public init(spotifyState: SpotifyConnectionState = .disconnected) {
        self.spotifyState = spotifyState
    }
}

public final class SettingsViewModel: ObservableObject {
    public weak var listener: SettingsPresentableListener?
    @Published public var state: SettingsViewState = SettingsViewState()
    
    public init() {}
    
    public func update(state: SettingsViewState) {
        self.state = state
    }
    
    func loginWithSpotify() {
        listener?.request(action: .onSpotifyLoginTapped)
    }
    
    func disconnectSpotify() {
        listener?.request(action: .onSpotifyDisconnectTapped)
    }
    
    func resetData() {
        // Handle data reset
    }
}

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("계정 연동")) {
                    switch viewModel.state.spotifyState {
                    case .disconnected:
                        Button(action: viewModel.loginWithSpotify) {
                            HStack {
                                Image(systemName: "music.note")
                                    .foregroundColor(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                                Text("Spotify 계정 연동")
                                    .foregroundColor(CustomColor.onSurface)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(CustomColor.outline)
                            }
                        }
                    case .connected(let name, let imageURL):
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 16) {
                                if let imageURL = imageURL {
                                    AsyncImage(url: imageURL) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray
                                    }
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(Color.gray)
                                        .frame(width: 50, height: 50)
                                        .overlay(Text(String(name.prefix(1))).foregroundColor(.white))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(name)
                                        .customText(.headlineMd)
                                        .foregroundColor(CustomColor.onSurface)
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                                            .font(.system(size: 12))
                                        Text("Connected")
                                            .customText(.labelSm)
                                    .foregroundColor(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                                    }
                                }
                                Spacer()
                            }
                            
                            Button(action: viewModel.disconnectSpotify) {
                                Text("연동 해제")
                                    .customText(.bodyMd)
                                    .foregroundColor(CustomColor.error)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(CustomColor.surfaceContainerHighest)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전 정보")
                            .customText(.bodyLg)
                            .foregroundColor(CustomColor.onSurface)
                        Spacer()
                        Text("1.0.0")
                            .customText(.bodyMd)
                            .foregroundColor(CustomColor.outline)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("데이터 백업")
                                .customText(.bodyLg)
                                .foregroundColor(CustomColor.onSurface)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(CustomColor.outline)
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("문의하기")
                                .customText(.bodyLg)
                                .foregroundColor(CustomColor.onSurface)
                            Spacer()
                            Image(systemName: "envelope")
                                .foregroundColor(CustomColor.outline)
                        }
                    }
                }
                
                Section(footer: Text("이 작업은 취소할 수 없습니다.")) {
                    Button(action: viewModel.resetData) {
                        Text("모든 데이터 초기화")
                            .customText(.bodyLg)
                            .foregroundColor(CustomColor.error)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("설정")
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(CustomColor.background.ignoresSafeArea())
        }
        .preferredColorScheme(.dark)
    }
}
