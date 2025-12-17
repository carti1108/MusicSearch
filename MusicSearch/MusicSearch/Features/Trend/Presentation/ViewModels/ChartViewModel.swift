//
//  ChartViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation
import Combine

struct ChartViewState: Equatable {
	var type: ChartType = .tracks
	var isLoading: Bool = false
	var errorMessage: String? = nil
	var podiumItems: [ChartItem] = []
	var listItems: [ChartItem] = []
}

enum ChartViewAction {
	case viewDidLoad
	case changeType(ChartType)
	case refresh
}

@MainActor
final class ChartViewModel {
	@Published private(set) var state: ChartViewState = .init()

	private let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	private let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase

	private var loadTask: Task<Void, Never>?

	private var cachedTrackItems: [ChartItem]?
	private var cachedArtistItems: [ChartItem]?

	init(
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	) {
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
	}

	func process(action: ChartViewAction) {
		switch action {
		case .viewDidLoad:
			self.loadIfNeeded(for: self.state.type, force: false)

		case .changeType(let type):
			guard self.state.type != type else { return }
			self.state.type = type
			self.state.listItems = []
			self.loadIfNeeded(for: type, force: false)

		case .refresh:
			self.loadIfNeeded(for: self.state.type, force: true)
		}
	}

	private func loadIfNeeded(for type: ChartType, force: Bool) {
		if !force {
			if type == .tracks, let cached = self.cachedTrackItems {
				self.apply(allItems: cached, type: type)
				return
			}
			if type == .artists, let cached = self.cachedArtistItems {
				self.apply(allItems: cached, type: type)
				return
			}
		}

		self.loadTask?.cancel()
		self.loadTask = Task { [weak self] in
			guard let self else { return }

			self.state.isLoading = true
			self.state.errorMessage = nil

			do {
				switch type {
				case .tracks:
					let tracks = try await self.fetchChartTopTracksUseCase.execute()
					let items = self.makeItems(from: tracks)
					self.cachedTrackItems = items
					self.apply(allItems: items, type: type)

				case .artists:
					let artists = try await self.fetchChartTopArtistsUseCase.execute()
					let items = self.makeItems(from: artists)
					self.cachedArtistItems = items
					self.apply(allItems: items, type: type)
				}
			} catch {
				self.state.errorMessage = "차트 정보를 불러오지 못했습니다."
				self.state.podiumItems = []
				self.state.listItems = []
			}

			self.state.isLoading = false
		}
	}

	private func apply(allItems: [ChartItem], type: ChartType) {
		guard allItems.count >= 3 else {
			self.state.podiumItems = []
			self.state.listItems = []
			return
		}

		let first = allItems[0]
		let second = allItems[1]
		let third = allItems[2]

		self.state.podiumItems = [second, first, third]
		self.state.listItems = Array(allItems.dropFirst(3))
	}

	private func makeItems(from tracks: [Track]) -> [ChartItem] {
		tracks.enumerated().map { index, track in
			let rank = index + 1
			return ChartItem(
				id: "\(ChartType.tracks.rawValue)-\(rank)",
				rank: rank,
				title: track.title,
				subtitle: track.artist,
				imageURL: track.imageURL,
				type: .tracks
			)
		}
	}

	private func makeItems(from artists: [Artist]) -> [ChartItem] {
		artists.enumerated().map { index, artist in
			let rank = index + 1
			let subtitle = artist.listeners.flatMap { $0.isEmpty ? nil : $0 }.map { "Listeners: \($0)" } ?? ""
			return ChartItem(
				id: "\(ChartType.artists.rawValue)-\(rank)",
				rank: rank,
				title: artist.name,
				subtitle: subtitle,
				imageURL: artist.imageURL,
				type: .artists
			)
		}
	}
}


