import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import ArchiveDomain

public struct ArchiveView: View {
    @Bindable var store: StoreOf<ArchiveFeature>
    
    @State private var showFilterSheet = false
    @State private var filterIntroGood = false
    @State private var filterMiddleGood = false
    @State private var filterEndGood = false

    public init(store: StoreOf<ArchiveFeature>) {
        self.store = store
    }
    
    private var filteredTracks: [ArchivedTrack] {
        store.recentTracks.filter { track in
            (!filterIntroGood || track.isIntroGood) &&
            (!filterMiddleGood || track.isGoodUntilMiddle) &&
            (!filterEndGood || track.isGoodUntilEnd)
        }
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                CustomColor.background
                Circle()
                    .fill(CustomColor.surfaceContainerHighest.opacity(0.4))
                    .frame(width: 400, height: 400)
                    .blur(radius: 120)
                    .offset(x: -150, y: -200)
                Circle()
                    .fill(CustomColor.surfaceContainer.opacity(0.5))
                    .frame(width: 350, height: 350)
                    .blur(radius: 100)
                    .offset(x: 200, y: 150)
            }
            .ignoresSafeArea()

            List {
                VStack(spacing: CustomSpacing.containerMargin) {
                    headerView
                    
                    dashboardCards

                    HStack(alignment: .bottom) {
                        Text("최근 기록한 음악")
                            .customText(.headlineMd)
                            .foregroundColor(CustomColor.onBackground)
                        Spacer()
                        Button(action: { showFilterSheet = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 20))
                                .foregroundColor(CustomColor.primary)
                        }
                    }
                    .padding(.horizontal, CustomSpacing.containerMargin)
                    .padding(.top, CustomSpacing.containerMargin)
                    .padding(.bottom, 16)
                    .buttonStyle(BouncyButtonStyle())
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())

                ForEach(filteredTracks) { track in
                    Button(action: {
                        store.send(.onTrackTapped(track: track))
                    }) {
                        TrackRowItem(track: track)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: CustomSpacing.containerMargin, bottom: CustomSpacing.gutter, trailing: CustomSpacing.containerMargin))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.onDeleteTapped(track: track))
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.bottom, 80)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { store.send(.onAddTapped) }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(CustomColor.onPrimary)
                            .frame(width: 56, height: 56)
                            .background(CustomColor.primary)
                            .clipShape(Circle())
                            .shadow(color: CustomColor.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .padding(.trailing, CustomSpacing.containerMargin)
                    .padding(.bottom, CustomSpacing.containerMargin)
                }
            }
        }
        .sheet(isPresented: $showFilterSheet) {
            filterSheet
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    private var filterSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("곡 전개 평가 필터")) {
                    Toggle("인트로가 좋음", isOn: $filterIntroGood)
                    Toggle("중반부까지 좋음", isOn: $filterMiddleGood)
                    Toggle("끝까지 좋음", isOn: $filterEndGood)
                }
                
                Button(action: {
                    filterIntroGood = false
                    filterMiddleGood = false
                    filterEndGood = false
                }) {
                    Text("필터 초기화")
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("필터")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        showFilterSheet = false
                    }
                }
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Text("Archive")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(CustomColor.onBackground)

            Spacer()

            HStack(spacing: 16) {
                Button(action: { store.send(.onSearchTapped) }) {
                    Image(systemName: "magnifyingglass")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundColor(CustomColor.onSurfaceVariant)
                        .padding(8)
                        .background(CustomColor.surfaceContainer)
                        .clipShape(Circle())
                }
                
                Button(action: { store.send(.onFolderTapped) }) {
                    Image(systemName: "folder.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.system(size: 20))
                        .foregroundColor(CustomColor.onSurfaceVariant)
                        .padding(8)
                        .background(CustomColor.surfaceContainer)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, CustomSpacing.containerMargin)
        .padding(.top, CustomSpacing.containerMargin)
        .padding(.bottom, 8)
        .buttonStyle(BouncyButtonStyle())
    }

    private var dashboardCards: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("총 \(store.totalTracksCount) 곡을 기록했어요.")
                    .customText(.bodyMd)
                    .foregroundColor(CustomColor.onSurfaceVariant)
                Text("가장 즐겨듣는 장르: \(store.topGenreName)")
                    .customText(.labelSm)
                    .foregroundColor(CustomColor.outline)
            }
            Spacer()
        }
        .padding(.horizontal, CustomSpacing.containerMargin)
        .padding(.vertical, 8)
    }
}

public struct TrackRowItem: View {
    public let track: ArchivedTrack
    @State private var isPressed: Bool = false

    public var body: some View {
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
        .padding(12)
        .liquidGlass(cornerRadius: 16)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}
