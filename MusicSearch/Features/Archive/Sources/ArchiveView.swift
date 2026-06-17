import SwiftUI
import Combine
import MSDesignSystem
import ArchiveDomain

public struct ArchiveViewState: Equatable {
	public var totalTracksCount: Int
	public var topGenreName: String
	public var recentTracks: [ArchivedTrack]

	public init(totalTracksCount: Int, topGenreName: String, recentTracks: [ArchivedTrack]) {
		self.totalTracksCount = totalTracksCount
		self.topGenreName = topGenreName
		self.recentTracks = recentTracks
	}
}

public enum ArchiveViewAction {
	case onAddTapped
	case onSearchTapped
	case onFolderTapped
	case onViewAllTapped
	case onDeleteTapped(track: ArchivedTrack)
}

@MainActor
public final class ArchiveViewModel: ObservableObject {
	public weak var listener: ArchivePresentableListener? = nil

	@Published public var state: ArchiveViewState

	public init(
		listener: ArchivePresentableListener? = nil,
		state: ArchiveViewState
	) {
		self.listener = listener
		self.state = state
	}

	public func update(state: ArchiveViewState) {
		self.state = state
	}

	
	public func update(totalTracksCount: Int, recentTracks: [ArchivedTrack]) {
		self.state.totalTracksCount = totalTracksCount
		self.state.recentTracks = recentTracks
	}

	public func request(action: ArchiveViewAction) {
		self.listener?.request(action: action)
	}
}

public protocol ArchivePresentableListener: AnyObject {
	func request(action: ArchiveViewAction)
}



// MARK: - Model (데이터 주입용)
public struct ArchiveView: View {
	@ObservedObject public var viewModel: ArchiveViewModel

	public init(viewModel: ArchiveViewModel) {
		self.viewModel = viewModel
	}

	public var body: some View {
		ZStack(alignment: .bottom) {
			CustomColor.background
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
						Button(action: { viewModel.request(action: .onViewAllTapped) }) {
							Text("전체보기")
								.customText(.labelSm)
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

				ForEach(viewModel.state.recentTracks) { track in
					TrackRowItem(track: track)
						.listRowBackground(Color.clear)
						.listRowSeparator(.hidden)
						.listRowInsets(EdgeInsets(top: 0, leading: CustomSpacing.containerMargin, bottom: CustomSpacing.gutter, trailing: CustomSpacing.containerMargin))
						.swipeActions(edge: .trailing, allowsFullSwipe: true) {
							Button(role: .destructive) {
								viewModel.request(action: .onDeleteTapped(track: track))
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
					Button(action: { viewModel.request(action: .onAddTapped) }) {
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
				Button(action: { viewModel.request(action: .onSearchTapped) }) {
					Image(systemName: "magnifyingglass")
						.symbolRenderingMode(.hierarchical)
						.font(.system(size: 20))
						.foregroundColor(CustomColor.onSurfaceVariant)
						.padding(8)
						.background(CustomColor.surfaceContainer)
						.clipShape(Circle())
				}
				
				Button(action: { viewModel.request(action: .onFolderTapped) }) {
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
		.background(CustomColor.background)
		.buttonStyle(BouncyButtonStyle())
	}



	private var dashboardCards: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text("총 \(viewModel.state.totalTracksCount) 곡을 기록했어요.")
					.customText(.bodyMd)
					.foregroundColor(CustomColor.onSurfaceVariant)
				Text("가장 즐겨듣는 장르: \(viewModel.state.topGenreName)")
					.customText(.labelSm)
					.foregroundColor(CustomColor.outline)
			}
			Spacer()
		}
		.padding(.horizontal, CustomSpacing.containerMargin)
		.padding(.vertical, 8)
	}


}

// MARK: - Components

public struct TrackRowItem: View {
	public let track: ArchivedTrack
	@State private var isPressed: Bool = false

	public var body: some View {
		HStack(spacing: CustomSpacing.base) {
			// Cover Image or Placeholder
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

			// Track Info
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

			// Tags and Rating
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
