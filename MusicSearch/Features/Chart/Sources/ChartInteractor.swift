//
//  ChartInteractor.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import UIKit
import MicroRIBs
import MSDomain
import MSUtil
import FeatureChartInterface

@MainActor
protocol ChartPresentableListener: AnyObject {
	func viewDidLoad()
	func didChangeSegment(index: Int)
	func didTapRefresh()
	func didSelectItem(at indexPath: IndexPath)
}

@MainActor
protocol ChartPresentable: Presentable {
	var listener: ChartPresentableListener? { get set }
	func updateSegment(to index: Int)
	func update(podiumItems: [ChartItem], listItems: [ChartItem])
	func showLoading(_ isShow: Bool)
	func showError(_ message: String?)
}

@MainActor
final class ChartInteractor: PresentableInteractor<ChartPresentable>, ChartInteractable, ChartPresentableListener {
	private typealias ChartSections = (podium: [ChartItem], list: [ChartItem])

	weak var router: ChartRouting?
	weak var listener: ChartListener?

	private let fetchChartTopTracksUseCase: FetchChartTopTracksUseCase
	private let fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase
	private let fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase
	private let urlOpener: URLOpening

	private var loadTask: Task<Void, Never>?
	private var currentType: ChartType = .tracks
	private var currentPodiumItems: [ChartItem] = []
	private var currentListItems: [ChartItem] = []
	private var cachedSectionsByType: [Int: ChartSections] = .init()

	init(
		presenter: ChartPresentable,
		fetchChartTopTracksUseCase: FetchChartTopTracksUseCase,
		fetchChartTopArtistsUseCase: FetchChartTopArtistsUseCase,
		fetchMusicAppDeepLinkUseCase: FetchMusicAppDeepLinkUseCase,
		urlOpener: URLOpening
	) {
		self.fetchChartTopTracksUseCase = fetchChartTopTracksUseCase
		self.fetchChartTopArtistsUseCase = fetchChartTopArtistsUseCase
		self.fetchMusicAppDeepLinkUseCase = fetchMusicAppDeepLinkUseCase
		self.urlOpener = urlOpener
		super.init(presenter: presenter)
		presenter.listener = self
	}

	func viewDidLoad() {
		self.loadData(for: self.currentType, isRefresh: false)
	}

	func didChangeSegment(index: Int) {
		let type: ChartType = (index == 0) ? .tracks : .artists
		guard self.currentType != type else { return }

		self.currentType = type
		self.presenter.updateSegment(to: index)

		if let cachedSections = self.cachedSectionsByType[type.rawValue] {
			self.loadTask?.cancel()
			self.presenter.showError(nil)
			self.presenter.showLoading(false)
			self.apply(sections: cachedSections, for: type)
			return
		}

		self.currentPodiumItems = []
		self.currentListItems = []
		self.presenter.update(podiumItems: [], listItems: [])
		self.loadData(for: type, isRefresh: false)
	}

	func didTapRefresh() {
		self.cachedSectionsByType[self.currentType.rawValue] = nil
		self.loadData(for: self.currentType, isRefresh: true)
	}

	func didSelectItem(at indexPath: IndexPath) {
		let section = indexPath.section
		let index = indexPath.item
		let item: ChartItem?

		if section == 0 {
			guard index < self.currentPodiumItems.count else { return }
			item = self.currentPodiumItems[index]
		} else {
			guard index < self.currentListItems.count else { return }
			item = self.currentListItems[index]
		}

		guard let item else { return }

		if item.type == .tracks {
			let track = Track(title: item.title, artist: item.subtitle, imageURL: item.imageURL)
			self.openMusicApp(for: track)
		} else {
			self.openMusicApp(for: item.title)
		}
	}

	private func loadData(for type: ChartType, isRefresh: Bool) {
		self.loadTask?.cancel()

		if !isRefresh, let cachedSections = self.cachedSectionsByType[type.rawValue] {
			self.apply(sections: cachedSections, for: type)
			return
		}

		self.presenter.showLoading(true)
		self.presenter.showError(nil)

		let fetchChartTopTracksUseCase = self.fetchChartTopTracksUseCase
		let fetchChartTopArtistsUseCase = self.fetchChartTopArtistsUseCase
		self.loadTask = Task { [weak self] in
			do {
				switch type {
				case .tracks:
					let tracks = try await fetchChartTopTracksUseCase.execute()
					guard !Task.isCancelled, let self else { return }
					let sections = self.makeSections(from: self.makeItems(from: tracks))
					self.cachedSectionsByType[type.rawValue] = sections
					self.apply(sections: sections, for: type)
					self.presenter.showLoading(false)

				case .artists:
					let artists = try await fetchChartTopArtistsUseCase.execute()
					guard !Task.isCancelled, let self else { return }
					let sections = self.makeSections(from: self.makeItems(from: artists))
					self.cachedSectionsByType[type.rawValue] = sections
					self.apply(sections: sections, for: type)
					self.presenter.showLoading(false)
				}
			} catch is CancellationError {
				return
			} catch {
				guard !Task.isCancelled, let self else { return }
				self.presenter.showError("차트 정보를 불러오지 못했습니다.")

				if self.currentType == type && self.currentPodiumItems.isEmpty && self.currentListItems.isEmpty {
					self.presenter.update(podiumItems: [], listItems: [])
				}
				self.presenter.showLoading(false)
			}
		}
	}

	private func makeSections(from allItems: [ChartItem]) -> ChartSections {
		guard allItems.count >= 3 else {
			return ([], [])
		}

		let first = allItems[0]
		let second = allItems[1]
		let third = allItems[2]
		let podiumItems = [second, first, third]
		let listItems = Array(allItems.dropFirst(3))
		return (podiumItems, listItems)
	}

	private func apply(sections: ChartSections, for type: ChartType) {
		guard self.currentType == type else { return }
		self.currentPodiumItems = sections.podium
		self.currentListItems = sections.list
		self.presenter.update(podiumItems: self.currentPodiumItems, listItems: self.currentListItems)
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

	private func openMusicApp(for track: Track) {
		let fetchMusicAppDeepLinkUseCase = self.fetchMusicAppDeepLinkUseCase
		let urlOpener = self.urlOpener
		Task {
			guard let url = await fetchMusicAppDeepLinkUseCase.execute(track: track) else { return }
			urlOpener.open(url)
		}
	}

	private func openMusicApp(for artist: String) {
		let fetchMusicAppDeepLinkUseCase = self.fetchMusicAppDeepLinkUseCase
		let urlOpener = self.urlOpener
		Task {
			guard let url = await fetchMusicAppDeepLinkUseCase.execute(artist: artist) else { return }
			urlOpener.open(url)
		}
	}
}
