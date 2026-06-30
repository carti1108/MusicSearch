//
//  MusicDiggingViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit
import Kingfisher
import MSDesignSystem
import MicroRIBs
import MSDomain
import MSUtil

@MainActor
final class MusicDiggingViewController: UIViewController, MusicDiggingPresentable, MusicDiggingViewControllable, LoadingPresentable, ErrorPresentable {
	enum Section { case recommendations }

	weak var listener: MusicDiggingPresentableListener?
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

	private let backgroundImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let blurEffectView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .dark)
		let view = UIVisualEffectView(effect: blurEffect)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let darkOverlayView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let eyebrowLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Digging"
		label.font = .systemFont(ofSize: 36, weight: .heavy)
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.text = ""
		label.isHidden = true
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
		self.collectionView.prefetchDataSource = self
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.listener?.viewDidAppear()
	}

	func updateSeedTrack(_ track: Track) {
		UIView.transition(with: self.seedTrackView, duration: 0.3, options: .transitionCrossDissolve) {
			self.seedTrackView.configure(with: track)
		}

		UIView.transition(with: self.backgroundImageView, duration: 0.5, options: .transitionCrossDissolve) {
			self.backgroundImageView.setRemoteImage(track.imageURL, targetSize: UIScreen.main.bounds.size)
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
		self.collectionView.isHidden = isShow
		self.collectionView.isUserInteractionEnabled = !isShow
	}

	func showError(_ message: String?) {
		self.presentErrorIfNeeded(message, onRetry: { [weak self] in
			self?.listener?.didTapRetry()
		})
	}

	private func setupView() {
		self.view.backgroundColor = UIColor(CustomColor.background)

		self.view.insertSubview(self.backgroundImageView, at: 0)
		self.view.insertSubview(self.blurEffectView, aboveSubview: self.backgroundImageView)
		self.view.insertSubview(self.darkOverlayView, aboveSubview: self.blurEffectView)

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
		self.navigationController?.navigationBar.tintColor = .white

		self.view.addSubview(self.scrollView)
		self.scrollView.addSubview(self.contentView)

		self.contentView.addSubview(self.eyebrowLabel)
		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.seedTrackView)
		self.contentView.addSubview(self.sectionTitleLabel)
		self.contentView.addSubview(self.collectionView)
		self.contentView.addSubview(self.loadingIndicator)

		self.seedTrackView.translatesAutoresizingMaskIntoConstraints = false
		self.seedTrackView.onTap = { [weak self] in
			self?.listener?.didTapSeedTrack()
		}
	}

	private func setupConstraints() {
		let screenWidth = UIScreen.main.bounds.width

		NSLayoutConstraint.activate([
			self.backgroundImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.backgroundImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.backgroundImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.backgroundImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.blurEffectView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.blurEffectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.blurEffectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.blurEffectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.darkOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.darkOverlayView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.darkOverlayView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.darkOverlayView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

			self.eyebrowLabel.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor, constant: 18),
			self.eyebrowLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.eyebrowLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),

			self.titleLabel.topAnchor.constraint(equalTo: self.eyebrowLabel.bottomAnchor, constant: 10),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),

			self.seedTrackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 18),
			self.seedTrackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.seedTrackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

			self.sectionTitleLabel.topAnchor.constraint(equalTo: self.seedTrackView.bottomAnchor, constant: 16),
			self.sectionTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.sectionTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),

			self.collectionView.topAnchor.constraint(equalTo: self.sectionTitleLabel.bottomAnchor, constant: 16),
			self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: screenWidth * 0.6 * 1.2),
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

			let groupWidth = env.container.contentSize.width * 0.6
			let groupHeight = groupWidth * 1.2
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .absolute(groupWidth),
				heightDimension: .absolute(groupHeight)
			)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .groupPagingCentered
			section.interGroupSpacing = -10
			section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

			section.visibleItemsInvalidationHandler = { items, offset, environment in
				let containerWidth = environment.container.contentSize.width
				let centerX = offset.x + (containerWidth / 2.0)

				items.forEach { item in
					let distanceFromCenter = abs(item.frame.midX - centerX)
					let progress = min(distanceFromCenter / (containerWidth / 2.0), 1.0)

					let scale = 1.0 - (progress * 0.25)

					let isLeft = item.frame.midX < centerX
					let angle = progress * (CGFloat.pi / 4.5) * (isLeft ? 1 : -1)

					var transform = CATransform3DIdentity
					transform.m34 = -1.0 / 500.0
					transform = CATransform3DRotate(transform, angle, 0, 1, 0)
					transform = CATransform3DScale(transform, scale, scale, 1)

					item.transform3D = transform
					item.alpha = 1.0 - (progress * 0.5)

					item.zIndex = Int((1.0 - progress) * 100)
				}
			}
			return section
		}
	}

	private func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Section, Track>(
			collectionView: self.collectionView
		) {
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

extension MusicDiggingViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let urls = indexPaths.compactMap { indexPath -> URL? in
			guard let track = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
			return track.imageURL
		}
		ImagePrefetcher(urls: urls).start()
	}

	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		let urls = indexPaths.compactMap { indexPath -> URL? in
			guard let track = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
			return track.imageURL
		}
		ImagePrefetcher(urls: urls).stop()
	}
}
