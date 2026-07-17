import SwiftUI
import ComposableArchitecture
import MSDesignSystem

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsFeature>

    public init(store: StoreOf<SettingsFeature>) {
        self.store = store
    }

    public var body: some View {
        List {
            Section(header: Text("계정 연동")) {
                switch store.spotifyState {
                case .disconnected:
                    Button(action: {
                        store.send(.loginTapped)
                    }) {
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundStyle(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                            Text("Spotify 계정 연동")
                                .foregroundStyle(CustomColor.onSurface)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(CustomColor.outline)
                        }
                    }
                    .listRowBackground(CustomColor.surfaceContainer)
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
                                    .overlay { Text(String(name.prefix(1))).foregroundStyle(.white) }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(name)
                                    .customText(.headlineMd)
                                    .foregroundStyle(CustomColor.onSurface)
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                                    .font(.system(size: 12))
                                    Text("Connected")
                                        .customText(.labelSm)
                                .foregroundStyle(Color(red: 29/255.0, green: 185/255.0, blue: 84/255.0))
                                }
                            }
                            Spacer()
                        }

                        Button(action: {
                            store.send(.disconnectTapped)
                        }) {
                            Text("연동 해제")
                                .customText(.bodyMd)
                                .foregroundStyle(CustomColor.onError)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(CustomColor.error)
                                .clipShape(.rect(cornerRadius: 8))
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(CustomColor.surfaceContainer)
                }
            }

        }
        .navigationTitle("설정")
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(CustomColor.background.ignoresSafeArea())
        .onAppear {
            store.send(.onAppear)
        }
        .preferredColorScheme(.dark)
    }
}
