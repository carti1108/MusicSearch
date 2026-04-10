//
//  TrackSearchViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import MicroRIBs

@MainActor
final class TrackSearchViewController: UIViewController, TrackSearchPresentable, TrackSearchViewControllable, UISearchResultsUpdating, UICollectionViewDelegate, LoadingPresentable, ErrorPresentable {
	enum Section { case main }

	weak var listener: TrackSearchPresentableListener?
	var lastPresentedErrorMessage: String?
	private let backgroundGradientLayer = CAGradientLayer()

	private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!

	private let searchController: UISearchController = {
		let sc = UISearchController(searchResultsController: nil)
		sc.obscuresBackgroundDuringPresentation = false
		sc.searchBar.autocapitalizationType = .none
		return sc
	}()

	private lazy var collectionView: UICollectionView = {
		var config = UICollectionLayoutListConfiguration(appearance: .plain)
		config.backgroundColor = .clear
		config.showsSeparators = false
		let layout = UICollectionViewCompositionalLayout.list(using: config)

		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
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
		label.text = "검색 결과가 없습니다.\n다른 키워드로 탐색해보세요."
		label.textColor = UIColor.white.withAlphaComponent(0.68)
		label.textAlignment = .center
		label.numberOfLines = 2
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let headerStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let eyebrowLabel: UILabel = {
		let label = UILabel()
		label.text = "DISCOVER"
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = UIColor.white.withAlphaComponent(0.62)
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "원하는 곡을 찾고\n바로 Digging 해보세요"
		label.font = .systemFont(ofSize: 30, weight: .heavy)
		label.textColor = .white
		label.numberOfLines = 2
		return label
	}()

	private let subtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "아티스트나 트랙명을 검색한 뒤 비슷한 곡 흐름으로 이어서 탐색할 수 있어요."
		label.font = .systemFont(ofSize: 15, weight: .medium)
		label.textColor = UIColor.white.withAlphaComponent(0.68)
		label.numberOfLines = 0
		return label
	}()

	init() {
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

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.backgroundGradientLayer.frame = self.view.bounds
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
		self.navigationItem.title = "검색"
		self.tabBarItem.title = "Search"
		self.backgroundGradientLayer.colors = [
			UIColor(red: 0.03, green: 0.05, blue: 0.11, alpha: 1.0).cgColor,
			UIColor(red: 0.08, green: 0.10, blue: 0.22, alpha: 1.0).cgColor,
			UIColor(red: 0.07, green: 0.18, blue: 0.28, alpha: 1.0).cgColor
		]
		self.backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
		self.backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
		self.view.layer.insertSublayer(self.backgroundGradientLayer, at: 0)

		self.searchController.searchBar.placeholder = "아티스트, 곡 제목 검색"
		self.searchController.searchResultsUpdater = self
		self.searchController.searchBar.searchTextField.backgroundColor = UIColor.white.withAlphaComponent(0.08)
		self.searchController.searchBar.searchTextField.textColor = .white
		self.searchController.searchBar.searchTextField.leftView?.tintColor = UIColor.white.withAlphaComponent(0.72)
		self.searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
			string: "아티스트, 곡 제목 검색",
			attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]
		)
		self.navigationItem.searchController = self.searchController
		self.navigationItem.hidesSearchBarWhenScrolling = false
		self.navigationController?.navigationBar.tintColor = .white

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

		self.headerStackView.addArrangedSubview(self.eyebrowLabel)
		self.headerStackView.addArrangedSubview(self.titleLabel)
		self.headerStackView.addArrangedSubview(self.subtitleLabel)

		self.view.addSubview(self.headerStackView)
		self.view.addSubview(self.collectionView)
		self.view.addSubview(self.loadingIndicator)
		self.view.addSubview(self.emptyLabel)

		NSLayoutConstraint.activate([
			self.headerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
			self.headerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),
			self.headerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -24),

			self.collectionView.topAnchor.constraint(equalTo: self.headerStackView.bottomAnchor, constant: 18),
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
