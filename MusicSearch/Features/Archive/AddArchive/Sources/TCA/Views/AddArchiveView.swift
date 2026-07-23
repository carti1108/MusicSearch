//
//  AddArchiveView.swift
//  MusicSearch
//
//  Created by Kiseok on 7/16/26.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import MSDesignSystem

public struct AddArchiveView: View {
	@Bindable var store: StoreOf<AddArchiveFeature>
	@State private var coverItem: PhotosPickerItem?

	public init(store: StoreOf<AddArchiveFeature>) {
		self.store = store
	}

	public var body: some View {
		NavigationStack {
			Form {
				Section {
					HStack {
						Spacer()
						PhotosPicker(selection: $coverItem, matching: .images) {
							if let data = store.coverImageData, let uiImage = UIImage(data: data) {
								Image(uiImage: uiImage)
									.resizable()
									.scaledToFill()
									.frame(width: 160, height: 160)
									.clipShape(.rect(cornerRadius: CustomRadius.md))
									.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
							} else {
								VStack(spacing: 8) {
									Image(systemName: "photo.badge.plus")
										.font(.system(size: 40))
									Text("커버 이미지 추가")
										.customText(.labelSm)
								}
								.foregroundStyle(CustomColor.outline)
								.frame(width: 160, height: 160)
								.background(CustomColor.surfaceContainerLow)
								.clipShape(.rect(cornerRadius: CustomRadius.md))
							}
						}
						.task(id: coverItem) {
							if let data = try? await coverItem?.loadTransferable(type: Data.self) {
								store.send(.setCoverImageData(data))
							}
						}
						Spacer()
					}
					.padding(.vertical, 16)
					.listRowBackground(Color.clear)
				}

				Section(header: Text("기본 정보")) {
					if !store.isEditMode {
						Button(action: { store.send(.searchButtonTapped) }) {
							Label("노래 검색하여 자동 입력하기", systemImage: "magnifyingglass")
								.foregroundStyle(CustomColor.primary)
							.padding(.vertical, 4)
						}
					}

					TextField("노래 제목", text: $store.title)
					TextField("아티스트", text: $store.artist)
					TextField("앨범명", text: $store.albumTitle)

					Picker("앨범 유형", selection: $store.albumType) {
						Text("정규").tag("정규")
						Text("싱글").tag("싱글")
						Text("EP").tag("EP")
						Text("기타").tag("기타")
					}

					DisclosureGroup("장르 (선택: \(store.genre.isEmpty ? "없음" : store.genre))", isExpanded: $store.isGenreExpanded) {
						TextField("장르 직접 입력", text: $store.genre)
						ForEach(store.availableGenres, id: \.self) { genreName in
							Button(action: {
								store.genre = genreName
								store.isGenreExpanded = false
							}) {
								HStack {
									Text(genreName)
									Spacer()
									if store.genre == genreName {
										Image(systemName: "checkmark")
											.foregroundStyle(CustomColor.primary)
									}
								}
							}
							.foregroundStyle(CustomColor.onSurface)
						}
					}

					TextField("유통사", text: $store.distributor)
					TextField("레이블", text: $store.label)
				}

				Section(header: Text("곡 전개 평가")) {
					Toggle("인트로가 좋았는가", isOn: $store.isIntroGood)
					Toggle("중반부까지 좋았는가", isOn: $store.isGoodUntilMiddle)
					Toggle("끝까지 좋았는가", isOn: $store.isGoodUntilEnd)
				}

				Section(header: Text("날짜")) {
					Toggle("발매일 입력", isOn: $store.hasReleaseDate)
					if store.hasReleaseDate {
						DatePicker("발매일", selection: $store.releaseDate, displayedComponents: .date)
					}
					DatePicker("청취일", selection: $store.listenDate, displayedComponents: .date)
				}

				Section(header: Text("나의 평점: \(store.rating, format: .number.precision(.fractionLength(1)))")) {
					Slider(value: $store.rating, in: 0...5, step: 0.5)
						.tint(CustomColor.tertiary)
				}

				Section(header: Text("메모")) {
					TextEditor(text: $store.memo)
						.frame(height: 100)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("취소") { store.send(.closeButtonTapped) }
						.foregroundStyle(CustomColor.onSurface)
				}
				ToolbarItem(placement: .principal) {
					Text(store.isEditMode ? "기록 수정" : "새 기록 추가")
						.font(.headline)
						.foregroundStyle(CustomColor.onBackground)
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("저장") {
						store.send(.saveButtonTapped)
					}
					.bold()
					.foregroundStyle(store.title.isEmpty || store.artist.isEmpty ? CustomColor.outline : CustomColor.primary)
					.disabled(store.title.isEmpty || store.artist.isEmpty)
				}
			}
			.onAppear {
				store.send(.onAppear)
			}
			.alert($store.scope(state: \.alert, action: \.alert))
		}
		.preferredColorScheme(.dark)
	}
}
