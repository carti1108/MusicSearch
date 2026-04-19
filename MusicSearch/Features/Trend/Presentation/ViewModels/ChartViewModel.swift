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

@MainActor
final class ChartViewModel: ChartViewableListener {
	private static let loadingFailureMessage = "차트 정보를 불러오지 못했습니다."
	private typealias ChartSections = (podium: [ChartItem], list: [ChartItem])

	var view: ChartViewable?
	weak var coordinator: ChartViewCoordinatorAction?

	private let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	private let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase

	private var loadTask: Task<Void, Never>?
	private var currentType: ChartType = .tracks
	private var currentPodiumItems: [ChartItem] = []
	private var currentListItems: [ChartItem] = []
	private var cachedSectionsByType: [Int: ChartSections] = .init()

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
		self.loadData(for: self.currentType, forceRefresh: false)
	}

	func didChangeSegment(index: Int) {
		let type: ChartType = index == 0 ? .tracks : .artists
		guard self.currentType != type else { return }

		self.currentType = type
		self.view?.updateSegment(to: index)

		if let cachedSections = self.cachedSections(for: type) {
			self.loadTask?.cancel()
			self.view?.showError(nil)
			self.view?.showLoading(false)
			self.apply(sections: cachedSections, for: type)
			return
		}

		self.clearDisplayedSections()
		self.loadData(for: type, forceRefresh: false)
	}

	func didTapRefresh() {
		self.cachedSectionsByType[self.currentType.rawValue] = nil
		self.loadData(for: self.currentType, forceRefresh: true)
	}

	func didSelectItem(at indexPath: IndexPath) {
		guard let item = self.selectedItem(at: indexPath) else { return }
		self.coordinator?.didSelect(item: item)
	}

	private func loadData(for type: ChartType, forceRefresh: Bool) {
		self.loadTask?.cancel()

		if !forceRefresh, let cachedSections = self.cachedSections(for: type) {
			self.apply(sections: cachedSections, for: type)
			return
		}

		self.beginLoading()

		self.loadTask = Task { [weak self] in
			guard let self else { return }
			defer {
				if !Task.isCancelled {
					self.view?.showLoading(false)
				}
			}

			do {
				let sections = try await self.fetchSections(for: type)
				guard !Task.isCancelled else { return }

				self.cache(sections: sections, for: type)
				self.apply(sections: sections, for: type)
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled else { return }
				self.view?.showError(
					error.userMessage(fallback: Self.loadingFailureMessage)
				)

				if self.currentType == type && self.isDisplayingEmptyState {
					self.view?.update(podiumItems: [], listItems: [])
				}
			}
		}
	}

	private func beginLoading() {
		self.view?.showLoading(true)
		self.view?.showError(nil)
	}

	private func fetchSections(for type: ChartType) async throws -> ChartSections {
		switch type {
		case .tracks:
			return self.makeSections(
				from: self.makeItems(from: try await self.fetchChartTopTracksUseCase.execute())
			)
		case .artists:
			return self.makeSections(
				from: self.makeItems(from: try await self.fetchChartTopArtistsUseCase.execute())
			)
		}
	}

	private func selectedItem(at indexPath: IndexPath) -> ChartItem? {
		switch indexPath.section {
		case 0:
			guard self.currentPodiumItems.indices.contains(indexPath.item) else { return nil }
			return self.currentPodiumItems[indexPath.item]
		default:
			guard self.currentListItems.indices.contains(indexPath.item) else { return nil }
			return self.currentListItems[indexPath.item]
		}
	}

	private func cachedSections(for type: ChartType) -> ChartSections? {
		self.cachedSectionsByType[type.rawValue]
	}

	private func cache(sections: ChartSections, for type: ChartType) {
		self.cachedSectionsByType[type.rawValue] = sections
	}

	private var isDisplayingEmptyState: Bool {
		self.currentPodiumItems.isEmpty && self.currentListItems.isEmpty
	}

	private func clearDisplayedSections() {
		self.currentPodiumItems = []
		self.currentListItems = []
		self.view?.update(podiumItems: [], listItems: [])
	}

	private func makeSections(from allItems: [ChartItem]) -> ChartSections {
		allItems.indices.contains(2)
			? (
				podium: [allItems[1], allItems[0], allItems[2]],
				list: Array(allItems.dropFirst(3))
			)
			: ([], [])
	}

	private func apply(sections: ChartSections, for type: ChartType) {
		guard self.currentType == type else { return }
		self.currentPodiumItems = sections.podium
		self.currentListItems = sections.list
		self.view?.update(podiumItems: sections.podium, listItems: sections.list)
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
			let subtitle = artist.listeners
				.flatMap { $0.isEmpty ? nil : $0 }
				.map { "Listeners: \($0)" } ?? ""

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
