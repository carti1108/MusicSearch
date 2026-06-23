import SwiftUI
import ComposableArchitecture
import MSDesignSystem
import MSDomain

public struct ArchiveTrackSearchView: View {
	@Bindable var store: StoreOf<ArchiveTrackSearchFeature>
	@Environment(\.dismiss) var dismiss
	
	public init(store: StoreOf<ArchiveTrackSearchFeature>) {
		self.store = store
	}
	
	public var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				HStack {
					Image(systemName: "magnifyingglass")
						.foregroundColor(CustomColor.outline)
					TextField("곡 제목, 아티스트 검색", text: $store.query)
						.foregroundColor(CustomColor.onBackground)
						.autocapitalization(.none)
						.disableAutocorrection(true)
					
					if !store.query.isEmpty {
						Button(action: {
							store.send(.clearQueryTapped)
						}) {
							Image(systemName: "xmark.circle.fill")
								.foregroundColor(CustomColor.outline)
						}
					}
				}
				.padding(10)
				.background(CustomColor.surfaceContainer)
				.cornerRadius(10)
				.padding()
				
				if store.isLoading {
					ProgressView()
						.padding()
					Spacer()
				} else if store.results.isEmpty && !store.query.isEmpty {
					Text("검색 결과가 없습니다.")
						.foregroundColor(CustomColor.outline)
						.padding()
					Spacer()
				} else {
					List {
						ForEach(store.results, id: \.id) { track in
							Button(action: {
								store.send(.trackSelected(track))
							}) {
								HStack(spacing: 12) {
									if let url = track.imageURL {
										AsyncImage(url: url) { phase in
											switch phase {
											case .empty:
												Rectangle().fill(CustomColor.surfaceContainerHigh)
											case .success(let image):
												image.resizable().aspectRatio(contentMode: .fill)
											case .failure:
												Rectangle().fill(CustomColor.surfaceContainerHigh)
											@unknown default:
												Rectangle().fill(CustomColor.surfaceContainerHigh)
											}
										}
										.frame(width: 48, height: 48)
										.clipShape(RoundedRectangle(cornerRadius: 6))
									} else {
										Rectangle()
											.fill(CustomColor.surfaceContainerHigh)
											.frame(width: 48, height: 48)
											.clipShape(RoundedRectangle(cornerRadius: 6))
									}
									
									VStack(alignment: .leading, spacing: 4) {
										Text(track.title)
											.font(.system(size: 16, weight: .medium))
											.foregroundColor(CustomColor.onBackground)
											.lineLimit(1)
										Text(track.artist)
											.font(.system(size: 14))
											.foregroundColor(CustomColor.outline)
											.lineLimit(1)
									}
									Spacer()
								}
								.padding(.vertical, 4)
							}
						}
					}
					.listStyle(PlainListStyle())
				}
			}
			.background(CustomColor.background.edgesIgnoringSafeArea(.all))
			.navigationBarTitle("곡 검색", displayMode: .inline)
			.navigationBarItems(leading: Button("취소", action: {
				store.send(.closeButtonTapped)
				dismiss()
			}))
			.onAppear {
				store.send(.onAppear)
			}
		}
		.preferredColorScheme(.dark)
	}
}
