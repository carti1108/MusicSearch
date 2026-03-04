//
//  TrackSearchViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Combine

final class TrackSearchViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDelegate {

	enum Section { case main }

	private let viewModel: TrackSearchViewModel
	private var cancellables = Set<AnyCancellable>()
	private var lastPresentedErrorMessage: String?

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

	private let emptyLabel: UILabel = {
		let label = UILabel()
		label.text = "검색 결과가 없습니다."
		label.textColor = .secondaryLabel
		label.textAlignment = .center
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	init(viewModel: TrackSearchViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.configureDataSource()
		self.bindViewModel()
	}

	private func setupUI() {
		self.navigationItem.title = "검색"
		self.tabBarItem.title = "Search"
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

	private func bindViewModel() {
		self.viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.updateUI(with: state)
			}
			.store(in: &self.cancellables)
	}

	private func updateUI(with state: TrackSearchState) {
		self.setLoading(state.isLoading)
		self.presentErrorIfNeeded(state.errorMessage)

		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.main])
		var seen = Set<Track>()
		let uniqueTracks = state.tracks.filter { seen.insert($0).inserted }
		snapshot.appendItems(uniqueTracks)
		self.dataSource.apply(snapshot, animatingDifferences: true)

		let hasText = !(self.searchController.searchBar.text?.isEmpty ?? true)
		self.emptyLabel.isHidden = !(hasText && !state.isLoading && uniqueTracks.isEmpty)
	}
	
	private func setLoading(_ isLoading: Bool) {
		if isLoading {
			self.loadingIndicator.startAnimating()
		} else {
			self.loadingIndicator.stopAnimating()
		}
	}
	
	private func presentErrorIfNeeded(_ message: String?) {
		guard let message, !message.isEmpty else { return }
		guard self.lastPresentedErrorMessage != message else { return }
		guard self.presentedViewController == nil else { return }
		self.lastPresentedErrorMessage = message
		
		let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "취소", style: .cancel))
		alert.addAction(UIAlertAction(title: "재시도", style: .default, handler: { [weak self] _ in
			self?.viewModel.process(action: .retry)
		}))
		self.present(alert, animated: true)
	}

	func updateSearchResults(for searchController: UISearchController) {
		guard let text = searchController.searchBar.text else { return }
		self.viewModel.process(action: .search(keyword: text))
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		guard let track = self.dataSource.itemIdentifier(for: indexPath) else { return }
		self.viewModel.process(action: .select(track: track))
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let offsetY = scrollView.contentOffset.y
		let contentHeight = scrollView.contentSize.height
		let height = scrollView.frame.size.height
		
		if offsetY > contentHeight - height * 2 {
			self.viewModel.process(action: .loadMore)
		}
	}
}
