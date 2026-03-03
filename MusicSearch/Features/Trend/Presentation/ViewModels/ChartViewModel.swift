//
//  ChartViewModel.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import Foundation

@MainActor
protocol ChartViewable: AnyObject {
	var listener: ChartViewableListener? { get set }

	func updateSegment(to index: Int)
	func update(podiumItems: [ChartItem], listItems: [ChartItem])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
protocol ChartViewCoordinatorAction: AnyObject {
	func didSelect(item: ChartItem)
}

final class ChartViewModel: ChartViewableListener {

	var view: ChartViewable?
	weak var coordinator: ChartViewCoordinatorAction?

	private let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	private let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase

	private var loadTask: Task<Void, Never>?
	private var currentType: ChartType = .tracks
	private var currentPodiumItems: [ChartItem] = []
	private var currentListItems: [ChartItem] = []

	init(
		view: ChartViewable,
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	) {
		self.view = view
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.view?.listener = self
	}

	deinit {
		self.loadTask?.cancel()
	}

	func viewDidLoad() {
		self.loadData(for: self.currentType)
	}

	func didChangeSegment(index: Int) {
		let type: ChartType = (index == 0) ? .tracks : .artists
		guard self.currentType != type else { return }

		self.currentType = type
		self.currentPodiumItems = []
		self.currentListItems = []

		self.view?.update(podiumItems: [], listItems: [])
		self.loadData(for: type)
	}

	func didTapRefresh() {
		self.loadData(for: self.currentType)
	}

	func didSelectItem(at indexPath: IndexPath) {
		let section = indexPath.section
		let index = indexPath.item
		let item: ChartItem?

		if section == 0 { // Podium
			guard index < self.currentPodiumItems.count else { return }
			item = self.currentPodiumItems[index]
		} else { // List
			guard index < self.currentListItems.count else { return }
			item = self.currentListItems[index]
		}

		if let item {
			self.coordinator?.didSelect(item: item)
		}
	}

	private func loadData(for type: ChartType) {
		self.loadTask?.cancel()

		self.view?.showLoading(true)
		self.view?.showError(nil)

		self.loadTask = Task { [weak self] in
			guard let self else { return }

			do {
				switch type {
				case .tracks:
					let tracks = try await self.fetchChartTopTracksUseCase.execute()
					guard !Task.isCancelled else { return }
					let items = self.makeItems(from: tracks)
					self.apply(allItems: items)
					self.view?.showLoading(false)

				case .artists:
					let artists = try await self.fetchChartTopArtistsUseCase.execute()
					guard !Task.isCancelled else { return }
					let items = self.makeItems(from: artists)
					self.apply(allItems: items)
					self.view?.showLoading(false)
				}
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				print("ChartViewModel Error: \(error)")
				self.view?.showError("차트 정보를 불러오지 못했습니다.")

				self.currentPodiumItems = []
				self.currentListItems = []
				self.view?.update(podiumItems: [], listItems: [])
				self.view?.showLoading(false)
			}
		}
	}

	private func apply(allItems: [ChartItem]) {
		guard allItems.count >= 3 else {
			self.currentPodiumItems = []
			self.currentListItems = []
			self.view?.update(podiumItems: [], listItems: [])
			return
		}

		let first = allItems[0]
		let second = allItems[1]
		let third = allItems[2]

		self.currentPodiumItems = [second, first, third]
		self.currentListItems = Array(allItems.dropFirst(3))
		self.view?.update(podiumItems: self.currentPodiumItems, listItems: self.currentListItems)
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
