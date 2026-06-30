import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain

public struct ArchiveFolderDetailView: View {
    @Bindable var store: StoreOf<ArchiveFolderDetailFeature>
    
    @State private var showingExportAlert = false
    @State private var exportResultMessage = ""

    public init(store: StoreOf<ArchiveFolderDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ZStack {
            CustomColor.background.ignoresSafeArea()
            
            if let folders = store.folders {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CustomSpacing.gutter) {
                        ForEach(folders) { folder in
                            FolderTile(title: folder.title, subtitle: folder.subtitle)
                                .onTapGesture {
                                    store.send(.folderTapped(folder))
                                }
                        }
                    }
                    .padding(.horizontal, CustomSpacing.containerMargin)
                    .padding(.top, CustomSpacing.base)
                }
            } else if let tracks = store.tracks {
                List {
                    ForEach(tracks) { track in
                        DetailTrackRowItem(track: track)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(Visibility.hidden)
                            .listRowInsets(EdgeInsets(top: 0, leading: CustomSpacing.containerMargin, bottom: CustomSpacing.gutter, trailing: CustomSpacing.containerMargin))
                            .onTapGesture {
                                store.send(.trackTapped(track))
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            
            if case .exporting(let progress) = store.exportState {
                Color.black.opacity(0.4).ignoresSafeArea()
                VStack(spacing: CustomSpacing.base) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: CustomColor.primary))
                        .scaleEffect(1.5)
                    
                    Text("Spotify로 내보내는 중...")
                        .customText(.bodyLg)
                        .foregroundColor(CustomColor.onSurface)
                    
                    Text("\(progress.currentCount) / \(progress.totalCount) 곡 처리 완료")
                        .customText(.bodyMd)
                        .foregroundColor(CustomColor.onSurfaceVariant)
                }
                .padding(32)
                .background(CustomColor.surfaceContainer)
                .cornerRadius(CustomRadius.lg)
                .shadow(radius: 10)
            }
        }
        .onChange(of: store.exportState) { _, newValue in
            if case .completed(let success, let failed) = newValue {
                exportResultMessage = "성공: \(success)곡, 실패: \(failed)곡"
                showingExportAlert = true
            }
        }
        .alert(isPresented: $showingExportAlert) {
            Alert(
                title: Text("내보내기 완료"),
                message: Text(exportResultMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct FolderTile: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: CustomSpacing.base) {
            Rectangle()
                .fill(CustomColor.surfaceContainerLow)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(CustomRadius.md)
                .overlay(
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundColor(CustomColor.surfaceContainerHigh)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customText(.bodyMd)
                    .foregroundColor(CustomColor.onSurface)
                Text(subtitle)
                    .customText(.labelSm)
                    .foregroundColor(CustomColor.outline)
            }
        }
    }
}

struct DetailTrackRowItem: View {
    let track: ArchivedTrack
    @State private var isPressed: Bool = false

    var body: some View {
        HStack(spacing: CustomSpacing.base) {
            Group {
                if let data = track.coverImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(gradient: Gradient(colors: [CustomColor.primary.opacity(0.6), CustomColor.tertiary.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .overlay(
                            Image(systemName: "music.quarternote.3")
                                .font(.system(size: CustomSpacing.base))
                                .foregroundColor(CustomColor.onPrimary)
                        )
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: CustomRadius.md))
            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .customText(.bodyLg)
                    .foregroundColor(CustomColor.onSurface)
                    .lineLimit(1)
                
                Text(track.artist)
                    .customText(.bodyMd)
                    .foregroundColor(CustomColor.onSurfaceVariant)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(track.genre)
                    .customText(.monoLabel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(CustomColor.surfaceContainerHighest)
                    .foregroundColor(CustomColor.onSurface)
                    .clipShape(Capsule())

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(CustomColor.tertiary)
                    Text(String(format: "%.1f", track.rating))
                        .customText(.labelSm)
                        .foregroundColor(CustomColor.onSurfaceVariant)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.001))
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
