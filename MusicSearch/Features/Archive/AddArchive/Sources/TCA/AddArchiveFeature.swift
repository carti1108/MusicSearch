//
//  AddArchiveFeature.swift
//  MusicSearch
//
//  Created by Kiseok on 6/30/26.
//

import Foundation
import ComposableArchitecture
import ArchiveDomain
import TrackSearchDomain
import MSDomain
import OSLog
import Kingfisher
import FeatureAddArchiveInterface
import FeatureArchiveTrackSearchInterface
import FeatureArchiveTrackSearch

@Reducer
public struct AddArchiveFeature {

	public typealias State = AddArchiveState
	public typealias Action = AddArchiveAction
	public typealias Alert = AddArchiveAlert

	@Dependency(\.archiveRepository) var archiveRepository
	@Dependency(\.searchTracksUseCase) var searchTracksUseCase

	public init() {}

	public var body: some ReducerOf<Self> {
		BindingReducer()

		Reduce { state, action in
			switch action {
			case .binding:
				return .none

			case .onAppear:
				return .run { send in
					await send(.genresLoaded(TaskResult {
						let tracks = try await archiveRepository.fetchArchivedTracks()
						let customGenres = Array(Set(tracks.map { $0.genre })).sorted()
						let predefined = PredefinedGenre.allCases.map { $0.rawValue }

						var combined = predefined
						for custom in customGenres {
							if !combined.contains(custom) {
								combined.append(custom)
							}
						}
						return combined
					}))
				}

			case let .genresLoaded(.success(genres)):
				state.availableGenres = genres
				return .none

			case .genresLoaded(.failure):
				return .none

			case .closeButtonTapped:
				return .send(.delegate(.didCloseAddArchive))

			case .searchButtonTapped:
				state.trackSearch = ArchiveTrackSearchState()
				return .none

			case let .setCoverImageData(data):
				state.coverImageData = data
				return .none

			case let .trackSelected(track):
				state.selectedTrack = track
				state.title = track.title
				state.artist = track.artist
				state.albumTitle = track.albumTitle ?? ""

				if let type = track.albumType {
					if type.lowercased() == "single" {
						state.albumType = "싱글"
					} else if type.lowercased() == "ep" || type.lowercased() == "ep/single" {
						state.albumType = "EP"
					} else {
						state.albumType = "정규"
					}
				}

				if let date = track.releaseDate {
					state.hasReleaseDate = true
					state.releaseDate = date
				}

				state.platformIDs["spotify"] = track.id

				if let imageURL = track.imageURL {
					return .run { send in
						do {
							let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, Error>) in
								KingfisherManager.shared.retrieveImage(with: imageURL) { result in
									switch result {
									case .success(let value):
										if let imgData = value.image.pngData() {
											continuation.resume(returning: imgData)
										} else {
											continuation.resume(throwing: URLError(.cannotDecodeRawData))
										}
									case .failure(let error):
										continuation.resume(throwing: error)
									}
								}
							}
							await send(.coverImageLoaded(data))
						} catch {
							Logger(subsystem: "MusicSearch", category: "AddArchiveFeature").error("Fetch cover image failed: \(error.localizedDescription)")
							await send(.coverImageLoaded(nil))
						}
					}
				}
				return .none

			case let .coverImageLoaded(data):
				state.coverImageData = data
				return .none

			case .saveButtonTapped:
				if state.genre.trimmingCharacters(in: .whitespaces).isEmpty {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("장르를 입력해주세요.") }
					return .none
				}
				if state.memo.count > 500 {
					state.alert = AlertState { TextState("입력 오류") } message: { TextState("메모는 500자를 초과할 수 없습니다.") }
					return .none
				}
				if let imageData = state.coverImageData, imageData.count > 5 * 1024 * 1024 {
					state.alert = AlertState { TextState("이미지 오류") } message: { TextState("이미지 크기는 5MB를 초과할 수 없습니다.") }
					return .none
				}

				let track = ArchivedTrack(
					id: state.editTrackId ?? UUID(),
					platformIDs: state.platformIDs,
					coverImageData: state.coverImageData,
					title: state.title,
					artist: state.artist,
					genre: state.genre,
					label: state.label,
					releaseDate: state.hasReleaseDate ? state.releaseDate : nil,
					listenDate: state.listenDate,
					rating: state.rating,
					memo: state.memo,
					albumTitle: state.albumTitle,
					distributor: state.distributor,
					albumType: state.albumType,
					isIntroGood: state.isIntroGood,
					isGoodUntilMiddle: state.isGoodUntilMiddle,
					isGoodUntilEnd: state.isGoodUntilEnd
				)
				return .run { [isEditMode = state.isEditMode] send in
					await send(.trackSaved(TaskResult {
						if isEditMode {
							try await archiveRepository.updateArchivedTrack(track)
						} else {
							try await archiveRepository.addArchivedTrack(track)
						}
					}))
				}

			case .trackSaved(.success):
				return .send(.delegate(.didCloseAddArchive))

			case let .trackSaved(.failure(error)):
				state.alert = AlertState { TextState("저장 실패") } message: { TextState("저장 중 문제가 발생했습니다: \(error.localizedDescription)") }
				return .none

			case .alert:
				return .none

			case let .trackSearch(.presented(.delegate(.trackSelected(track)))):
				return .send(.trackSelected(track))

			case .trackSearch(.presented(.closeButtonTapped)):
				return .none

			case .trackSearch:
				return .none

			case .delegate:
				return .none
			}
		}
		.ifLet(\.$alert, action: \.alert)
		.ifLet(\.$trackSearch, action: \.trackSearch) {
			ArchiveTrackSearchFeature()
		}
	}
}
