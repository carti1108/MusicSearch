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
import FeatureArchiveTrackSearch

@MainActor
public struct AddArchiveView: View {
	@Bindable var store: StoreOf<AddArchiveFeature>
	@State private var coverItem: PhotosPickerItem?

	public init(
		store: StoreOf<AddArchiveFeature>
	) {
		self.store = store
	}

	public var body: some View {
		NavigationStack {
			Form {
				self.coverImageSection
				self.basicInfoSection
				self.evaluationSection
				self.dateSection
				self.ratingAndMemoSection
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("취소") { self.store.send(.closeButtonTapped) }
						.foregroundStyle(CustomColor.onSurface)
				}
				ToolbarItem(placement: .principal) {
					Text(self.store.isEditMode ? "기록 수정" : "새 기록 추가")
						.font(.headline)
						.foregroundStyle(CustomColor.onBackground)
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button("저장") {
						self.store.send(.saveButtonTapped)
					}
					.bold()
					.foregroundStyle(self.store.title.isEmpty || self.store.artist.isEmpty ? CustomColor.outline : CustomColor.primary)
					.disabled(self.store.title.isEmpty || self.store.artist.isEmpty)
				}
			}
			.onAppear {
				self.store.send(.onAppear)
			}
			.alert($store.scope(state: \.alert, action: \.alert))
			.sheet(item: $store.scope(state: \.trackSearch, action: \.trackSearch)) { store in
				ArchiveTrackSearchView(store: store)
			}
		}
		.preferredColorScheme(.dark)
	}

	@ViewBuilder
	private var coverImageSection: some View {
		let coverImageData = self.store.coverImageData
		Section {
			HStack {
				Spacer()
				PhotosPicker(selection: $coverItem, matching: .images) {
					CoverPickerLabelView(coverImageData: coverImageData)
				}
				.task(id: self.coverItem) {
					if let data = try? await self.coverItem?.loadTransferable(type: Data.self) {
						self.store.send(.setCoverImageData(data))
					}
				}
				Spacer()
			}
			.padding(.vertical, 16)
			.listRowBackground(Color.clear)
		}
	}

	@ViewBuilder
	private var basicInfoSection: some View {
		Section(header: Text("기본 정보")) {
			if !self.store.isEditMode {
				Button("노래 검색하여 자동 입력하기", systemImage: "magnifyingglass") {
					self.store.send(.searchButtonTapped)
				}
				.foregroundStyle(CustomColor.primary)
				.padding(.vertical, 4)
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

			VStack(alignment: .leading, spacing: 8) {
				Text("장르")
					.customText(.bodyMd)
					.foregroundStyle(CustomColor.onSurface)

				if !self.store.genres.isEmpty {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(self.store.genres, id: \.self) { genre in
								HStack(spacing: 4) {
									Text(genre)
										.customText(.monoLabel)
									Button(action: { self.store.send(.removeGenre(genre)) }) {
										Image(systemName: "xmark.circle.fill")
											.foregroundStyle(CustomColor.onSurfaceVariant)
									}
								}
								.padding(.horizontal, 10)
								.padding(.vertical, 6)
								.background(CustomColor.surfaceContainerHighest)
								.foregroundStyle(CustomColor.onSurface)
								.clipShape(Capsule())
							}
						}
					}
				}

				TextField("장르 입력 (쉼표나 리턴으로 추가)", text: $store.genreInputText.sending(\.genreInputTextChanged))
					.onSubmit {
						self.store.send(.addGenre(self.store.genreInputText))
					}
					.onChange(of: self.store.genreInputText) { _, newValue in
						if newValue.hasSuffix(",") {
							let genre = String(newValue.dropLast())
							self.store.send(.addGenre(genre))
						}
					}

				if !self.store.recommendedGenres.isEmpty {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack {
							ForEach(self.store.recommendedGenres, id: \.self) { genre in
								Button(action: { self.store.send(.addGenre(genre)) }) {
									Text(genre)
										.customText(.monoLabel)
										.padding(.horizontal, 10)
										.padding(.vertical, 6)
										.background(CustomColor.surfaceContainer)
										.foregroundStyle(CustomColor.primary)
										.clipShape(Capsule())
								}
							}
						}
					}
				}
			}
			.padding(.vertical, 4)

			TextField("유통사", text: $store.distributor)
			TextField("레이블", text: $store.label)
		}
	}

	@ViewBuilder
	private var evaluationSection: some View {
		Section(header: Text("곡 전개 평가")) {
			Toggle("인트로가 좋았는가", isOn: $store.isIntroGood)
			Toggle("중반부까지 좋았는가", isOn: $store.isGoodUntilMiddle)
			Toggle("끝까지 좋았는가", isOn: $store.isGoodUntilEnd)
		}
	}

	@ViewBuilder
	private var dateSection: some View {
		Section(header: Text("날짜")) {
			Toggle("발매일 입력", isOn: $store.hasReleaseDate)
			if self.store.hasReleaseDate {
				DatePicker("발매일", selection: $store.releaseDate, displayedComponents: .date)
			}
			DatePicker("청취일", selection: $store.listenDate, displayedComponents: .date)
		}
	}

	@ViewBuilder
	private var ratingAndMemoSection: some View {
		Section(header: Text("나의 평점: \(self.store.rating, format: .number.precision(.fractionLength(1)))")) {
			Slider(value: $store.rating, in: 0...5, step: 0.5)
				.tint(CustomColor.tertiary)
		}

		Section(header: Text("메모")) {
			TextEditor(text: $store.memo)
				.frame(height: 100)
		}
	}
}

@MainActor
private struct CoverPickerLabelView: View {
	let coverImageData: Data?

	var body: some View {
		if let coverImageData, let uiImage = UIImage(data: coverImageData) {
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
}
