//
//  ArchiveTrackSearchView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

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
		NavigationStack {
			VStack(spacing: 0) {
				HStack {
					Image(systemName: "magnifyingglass")
						.foregroundStyle(CustomColor.outline)
					TextField("곡 제목, 아티스트 검색", text: $store.query)
						.foregroundStyle(CustomColor.onBackground)
						.autocapitalization(.none)
						.disableAutocorrection(true)

					if !store.query.isEmpty {
						Button(action: {
							store.send(.clearQueryTapped)
						}) {
							Image(systemName: "xmark.circle.fill")
								.foregroundStyle(CustomColor.outline)
						}
					}
				}
				.padding(10)
				.background(CustomColor.surfaceContainer)
				.clipShape(.rect(cornerRadius: 10))
				.padding()

				if store.isLoading {
					ProgressView()
						.padding()
					Spacer()
				} else if store.results.isEmpty && !store.query.isEmpty {
					Text("검색 결과가 없습니다.")
						.foregroundStyle(CustomColor.outline)
						.padding()
					Spacer()
				} else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
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
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                            Text(track.artist)
                                                .font(.system(size: 14))
                                                .foregroundStyle(Color.white.opacity(0.7))
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                    }
                                    .padding(12)
                                    .liquidGlass(cornerRadius: 16)
                                }
                                .buttonStyle(BouncyButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .scrollDismissesKeyboard(.immediately)
				}
			}
            .background(
                ZStack {
                    CustomColor.background.edgesIgnoringSafeArea(.all)
                    Circle()
                        .fill(CustomColor.surfaceContainerHigh.opacity(0.6))
                        .frame(width: 300, height: 300)
                        .blur(radius: 100)
                        .offset(x: -100, y: -200)
                    Circle()
                        .fill(CustomColor.surfaceContainer.opacity(0.5))
                        .frame(width: 400, height: 400)
                        .blur(radius: 120)
                        .offset(x: 150, y: 300)
                }
                .edgesIgnoringSafeArea(.all)
            )
			.navigationTitle("곡 검색")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("취소") {
						store.send(.closeButtonTapped)
						dismiss()
					}
				}
			}
			.onAppear {
				store.send(.onAppear)
			}
		}
		.preferredColorScheme(.dark)
	}
}
