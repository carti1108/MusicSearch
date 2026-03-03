//
//  MusicDiggingViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit

@MainActor
protocol MusicDiggingViewableListener: AnyObject {
	func viewDidAppear()
	func didTapRetry()
	func didSelectRecommendation(at indexPath: IndexPath)
}

@MainActor
final class MusicDiggingViewController: UIViewController, MusicDiggingViewable, LoadingPresentable, ErrorPresentable {

	enum Section { case recommendations }

	weak var listener: MusicDiggingViewableListener?
	var lastPresentedErrorMessage: String?

	private var dataSource: UICollectionViewDiffableDataSource<Section, Track>!

	private let scrollView: UIScrollView = {
		let sv = UIScrollView()
		sv.showsVerticalScrollIndicator = true
		sv.alwaysBounceVertical = true
		sv.translatesAutoresizingMaskIntoConstraints = false
		return sv
	}()

	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let seedTrackView = SeedTrackView()

	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "이 곡과 비슷한 무드 🎵"
		label.font = .systemFont(ofSize: 18, weight: .bold)
		label.textColor = .white
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .medium)
		indicator.color = .white
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	var loadingIndicatorView: UIActivityIndicatorView { self.loadingIndicator }

	private lazy var collectionView: UICollectionView = {
		let layout = self.createCarouselLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.showsHorizontalScrollIndicator = false
		cv.showsVerticalScrollIndicator = false
		cv.isScrollEnabled = false
		cv.register(TrackCarouselCell.self, forCellWithReuseIdentifier: TrackCarouselCell.reuseIdentifier)
		cv.delegate = self
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupView()
		self.setupConstraints()
		self.configureDataSource()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.listener?.viewDidAppear()
	}

	func updateSeedTrack(_ track: Track) {
		UIView.transition(with: self.seedTrackView, duration: 0.3, options: .transitionCrossDissolve) {
			self.seedTrackView.configure(with: track)
		}
	}

	func updateRecommendations(_ tracks: [Track]) {
		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.recommendations])
		snapshot.appendItems(tracks)
		self.dataSource.apply(snapshot, animatingDifferences: true)

		if !tracks.isEmpty {
			self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
		}
	}

	func showLoading(_ isShow: Bool) {
		self.setLoading(isShow)
	}

	func showError(_ message: String?) {
		self.presentErrorIfNeeded(message, onRetry: { [weak self] in
			self?.listener?.didTapRetry()
		})
	}

	private func setupView() {
		self.view.backgroundColor = .black

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

		self.view.addSubview(self.scrollView)
		self.scrollView.addSubview(self.contentView)

		self.contentView.addSubview(self.seedTrackView)
		self.contentView.addSubview(self.sectionTitleLabel)
		self.contentView.addSubview(self.collectionView)
		self.contentView.addSubview(self.loadingIndicator)

		self.seedTrackView.translatesAutoresizingMaskIntoConstraints = false
	}

	private func setupConstraints() {
		let screenWidth = UIScreen.main.bounds.width

		NSLayoutConstraint.activate([
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

			self.seedTrackView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.seedTrackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.seedTrackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

			self.sectionTitleLabel.topAnchor.constraint(equalTo: self.seedTrackView.bottomAnchor, constant: 16),
			self.sectionTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.sectionTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),

			self.collectionView.topAnchor.constraint(equalTo: self.sectionTitleLabel.bottomAnchor, constant: 16),
			self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: screenWidth * 0.4 + 60),
			self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20),

			self.loadingIndicator.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
			self.loadingIndicator.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor)
		])
	}

	private func createCarouselLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { _, env in
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupWidth = env.container.contentSize.width * 0.4
			let groupHeight = groupWidth + 40
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .absolute(groupWidth),
				heightDimension: .absolute(groupHeight)
			)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
			section.interGroupSpacing = 16
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
			return section
		}
	}

	private func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Section, Track>(collectionView: self.collectionView) {
			collectionView, indexPath, track in
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: TrackCarouselCell.reuseIdentifier,
				for: indexPath
			) as? TrackCarouselCell else {
				return UICollectionViewCell()
			}
			cell.configure(with: track)
			return cell
		}
	}
}

extension MusicDiggingViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.listener?.didSelectRecommendation(at: indexPath)
	}
}
