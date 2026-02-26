//
//  TrackSearchViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit

@MainActor
protocol TrackSearchViewableListener: AnyObject {
	func didUpdateSearchText(_ keyword: String)
	func didTapRetry()
	func didSelectTrack(_ track: Track)
	func didReachListBottom()
}

@MainActor
final class TrackSearchViewController: UIViewController, TrackSearchViewable, UISearchResultsUpdating, UICollectionViewDelegate, LoadingPresentable, ErrorPresentable {

	enum Section { case main }

	weak var listener: TrackSearchViewableListener?
	var lastPresentedErrorMessage: String?

	private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!

	private let searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.autocapitalizationType = .none
		return sc
	}()

	private lazy var collectionView: UICollectionView = {
		var config = UICollectionLayoutListConfiguration(appearance: .plain)
		config.backgroundColor = .systemBackground
		config.showsSeparators = true
		let layout = UICollectionViewCompositionalLayout.list(using: config)

		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .systemBackground
		cv.keyboardDismissMode = .onDrag
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.delegate = self
		cv.register(TrackListCell.self, forCellWithReuseIdentifier: TrackListCell.reuseIdentifier)
		return cv
	}()

	private let loadingIndicator: UIActivityIndicatorView = {
		let view = UIActivityIndicatorView(style: .medium)
		view.hidesWhenStopped = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	var loadingIndicatorView: UIActivityIndicatorView { self.loadingIndicator }

	private let emptyLabel: UILabel = {
		let label = UILabel()
		label.text = "검색 결과가 없습니다."
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	init(listener: TrackSearchViewableListener) {
		self.listener = listener
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.configureDataSource()
	}

	func updateTracks(_ tracks: [Track]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.main])
		var seen = Set<Track>()
		let uniqueTracks = tracks.filter { seen.insert($0).inserted }
		snapshot.appendItems(uniqueTracks)
		self.dataSource.apply(snapshot, animatingDifferences: true)

		let hasText = !(self.searchController.searchBar.text?.isEmpty ?? true)
		self.emptyLabel.isHidden = !(hasText && uniqueTracks.isEmpty)
	}

	func showLoading(_ isShow: Bool) {
		self.setLoading(isShow)
		if isShow {
			self.emptyLabel.isHidden = true
		}
	}

	func showError(_ message: String?) {
		self.presentErrorIfNeeded(message, onRetry: { [weak self] in
			self?.listener?.didTapRetry()
		})
	}

	private func setupUI() {
		self.title = "검색"
		self.view.backgroundColor = .systemBackground

		self.searchController.searchBar.placeholder = "아티스트, 곡 제목 검색"
		self.searchController.searchResultsUpdater = self
		self.navigationItem.searchController = self.searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false

		self.view.addSubview(self.collectionView)
		self.view.addSubview(self.loadingIndicator)
		self.view.addSubview(self.emptyLabel)

		NSLayoutConstraint.activate([
			self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

			self.emptyLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.emptyLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50)
		])
	}

	private func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Section, Track>(
			collectionView: self.collectionView
		) { collectionView, indexPath, track in
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: TrackListCell.reuseIdentifier,
				for: indexPath
			) as? TrackListCell else {
				return UICollectionViewCell()
			}
			cell.configure(with: track)
			return cell
		}
	}

	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		self.listener?.didUpdateSearchText(text)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		guard let track = self.dataSource.itemIdentifier(for: indexPath) else { return }
		self.listener?.didSelectTrack(track)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let height = scrollView.frame.size.height

		if offsetY > contentHeight - (height * 2) {
			self.listener?.didReachListBottom()
		}
	}
}
