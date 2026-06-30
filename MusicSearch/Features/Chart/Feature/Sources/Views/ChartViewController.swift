//
//  ChartViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Combine
import MSDesignSystem
import MicroRIBs
import Kingfisher
import MSUtil

@MainActor
final class ChartViewController: UIViewController, ChartPresentable, ChartViewControllable, LoadingPresentable, ErrorPresentable {
	enum Section: Int {
		case podium
		case list
	}

	weak var listener: ChartPresentableListener?
	private var dataSource: UICollectionViewDiffableDataSource<Section, ChartItem>!
	var lastPresentedErrorMessage: String?
	private var currentSegmentIndex: Int = 0
	private var segmentOffsets: [Int: CGPoint] = .init()
	private var isRestoringOffset = false
	private var hasPrimedInitialCrossfade = false
	private var imagePrefetcher: ImagePrefetcher?

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

	private let loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	var loadingIndicatorView: UIActivityIndicatorView { self.loadingIndicator }

	init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private lazy var segmentControl: UISegmentedControl = {
		let flameImage = UIImage(systemName: "flame.fill")
		let micImage = UIImage(systemName: "music.mic")
		let sc = UISegmentedControl(items: ["Top Tracks", "Top Artists"])
		sc.setImage(flameImage, forSegmentAt: 0)
		sc.setImage(micImage, forSegmentAt: 1)
		sc.selectedSegmentIndex = 0
		sc.backgroundColor = UIColor(CustomColor.surface)
		sc.selectedSegmentTintColor = UIColor(CustomColor.primary)
		sc.setTitleTextAttributes([.foregroundColor: UIColor(CustomColor.onPrimary)], for: .selected)
		sc.setTitleTextAttributes([.foregroundColor: UIColor(CustomColor.onSurfaceVariant)], for: .normal)
		sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
		sc.translatesAutoresizingMaskIntoConstraints = false
		return sc
	}()

	private lazy var collectionView: UICollectionView = {
		let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
		cv.backgroundColor = .clear
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.delegate = self
		cv.prefetchDataSource = self
		cv.showsVerticalScrollIndicator = false
		cv.alwaysBounceVertical = true

		cv.register(PodiumCell.self, forCellWithReuseIdentifier: PodiumCell.identifier)
		cv.register(RankListCell.self, forCellWithReuseIdentifier: RankListCell.identifier)
		return cv
	}()

	private let headerStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = CustomSpacing.base
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let eyebrowLabel: UILabel = {
		let label = UILabel()
		label.text = "GLOBAL MOMENTUM"
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = UIColor(CustomColor.onSurfaceVariant)
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "지금 가장 뜨거운\n트랙과 아티스트"
		label.font = .systemFont(ofSize: 30, weight: .heavy)
		label.textColor = UIColor(CustomColor.onBackground)
		label.numberOfLines = 2
		return label
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(CustomColor.background)
		self.setupUI()
		self.configureDataSource()
		self.collectionView.prefetchDataSource = self
		self.currentSegmentIndex = self.segmentControl.selectedSegmentIndex
		self.listener?.viewDidLoad()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}

	func updateSegment(to index: Int) {
		if self.currentSegmentIndex != index {
			self.segmentOffsets[self.currentSegmentIndex] = self.collectionView.contentOffset
			self.currentSegmentIndex = index
		}

		if self.segmentControl.selectedSegmentIndex != index {
			self.segmentControl.selectedSegmentIndex = index
		}
	}

	func update(podiumItems: [ChartItem], listItems: [ChartItem]) {
		if podiumItems.count > 1 {
			// podiumItems는 [2위, 1위, 3위] 순서로 정렬되어 있으므로 1위는 인덱스 1입니다.
			let firstPlace = podiumItems[1]
			UIView.transition(with: self.backgroundImageView, duration: 0.5, options: .transitionCrossDissolve) {
				self.backgroundImageView.setRemoteImage(firstPlace.imageURL, targetSize: UIScreen.main.bounds.size)
			}
		}

		var snapshot = NSDiffableDataSourceSnapshot<Section, ChartItem>()
		snapshot.appendSections([.podium])
		snapshot.appendItems(podiumItems, toSection: .podium)

		if !listItems.isEmpty {
			snapshot.appendSections([.list])
			snapshot.appendItems(listItems, toSection: .list)
		}

		UIView.performWithoutAnimation {
			self.dataSource.apply(
				snapshot,
				animatingDifferences: false
			) { [weak self] in
				self?.restoreScrollOffsetIfNeeded()
				self?.primeInitialCrossfadeIfNeeded(force: true)
			}
		}
	}

	func showLoading(_ isShow: Bool) {
		self.setLoading(isShow)
	}

	func showError(_ message: String?) {
		self.presentErrorIfNeeded(message, onRetry: { [weak self] in
			self?.listener?.didTapRefresh()
		})
	}

	private func setupUI() {
		navigationItem.title = "Chart"
		self.navigationController?.navigationBar.tintColor = .white

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.titleTextAttributes = [.foregroundColor: UIColor(CustomColor.onBackground)]
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

		self.headerStackView.addArrangedSubview(self.eyebrowLabel)
		self.headerStackView.addArrangedSubview(self.titleLabel)

		self.view.insertSubview(self.backgroundImageView, at: 0)
		self.view.insertSubview(self.blurEffectView, aboveSubview: self.backgroundImageView)
		self.view.insertSubview(self.darkOverlayView, aboveSubview: self.blurEffectView)

		view.addSubview(headerStackView)
		view.addSubview(segmentControl)
		view.addSubview(collectionView)
		view.addSubview(loadingIndicator)

		NSLayoutConstraint.activate([
			backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
			backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
			blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			darkOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
			darkOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			darkOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			darkOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			self.headerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: CustomSpacing.stackMd),
			self.headerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: CustomSpacing.containerMargin),
			self.headerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -CustomSpacing.containerMargin),

			segmentControl.topAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: CustomSpacing.stackMd),
			segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CustomSpacing.containerMargin),
			segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CustomSpacing.containerMargin),
			segmentControl.heightAnchor.constraint(equalToConstant: 38),

			collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: CustomSpacing.stackSm),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

			loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	@objc private func segmentChanged(_ sender: UISegmentedControl) {
		self.segmentOffsets[self.currentSegmentIndex] = self.collectionView.contentOffset
		self.currentSegmentIndex = sender.selectedSegmentIndex
		self.listener?.didChangeSegment(index: sender.selectedSegmentIndex)
	}

	private func restoreScrollOffsetIfNeeded() {
		let target = self.segmentOffsets[self.currentSegmentIndex] ?? .zero
		let adjustedInset = self.collectionView.adjustedContentInset
		let minY = -adjustedInset.top
		let maxY = max(
			minY,
			self.collectionView.contentSize.height
				- self.collectionView.bounds.height
				+ adjustedInset.bottom
		)
		let clampedY = min(max(target.y, minY), maxY)
		let clampedOffset = CGPoint(x: 0, y: clampedY)

		self.isRestoringOffset = true
		self.collectionView.setContentOffset(clampedOffset, animated: false)
		self.isRestoringOffset = false
	}

	private func primeInitialCrossfadeIfNeeded(force: Bool = false) {
		guard force || !self.hasPrimedInitialCrossfade else { return }
		guard self.collectionView.bounds.width > 0, self.collectionView.bounds.height > 0 else { return }

		self.collectionView.layoutIfNeeded()
		self.applyCrossfadeEffects()
		self.hasPrimedInitialCrossfade = true
	}

	private func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { sectionIndex, env in
			guard let section = Section(rawValue: sectionIndex) else { return nil }

			switch section {
			case .podium:
				let podiumHeight = min(max(env.container.effectiveContentSize.height * 0.42, 280), 320)
				let verticalInset = max((env.container.effectiveContentSize.height - podiumHeight) / 2, CustomSpacing.base)
				let itemSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0 / 3.0),
					heightDimension: .fractionalHeight(1.0)
				)
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
				let groupSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(podiumHeight)
				)
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
				let sectionLayout = NSCollectionLayoutSection(group: group)
				sectionLayout.contentInsets = NSDirectionalEdgeInsets(
					top: verticalInset,
					leading: CustomSpacing.stackSm,
					bottom: verticalInset,
					trailing: CustomSpacing.stackSm
				)
				return sectionLayout

			case .list:
				var config = UICollectionLayoutListConfiguration(appearance: .plain)
				config.showsSeparators = false
				config.backgroundColor = .clear
				return NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
			}
		}
	}

	private func configureDataSource() {
		dataSource = UICollectionViewDiffableDataSource<Section, ChartItem>(
			collectionView: collectionView
		) {
			(collectionView, indexPath, item) -> UICollectionViewCell? in

			if indexPath.section == Section.podium.rawValue {
				let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: PodiumCell.identifier,
					for: indexPath
				) as! PodiumCell
				cell.configure(with: item)
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: RankListCell.identifier,
					for: indexPath
				) as! RankListCell
				cell.configure(with: item)
				return cell
			}
		}
	}
}

extension ChartViewController: UICollectionViewDelegate {
	func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		self.primeInitialCrossfadeIfNeeded(force: true)
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !self.isRestoringOffset {
			self.segmentOffsets[self.currentSegmentIndex] = scrollView.contentOffset
		}

		self.applyCrossfadeEffects()
	}

	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		let progress = self.calculateScrollProgress()
		self.applyEffect(to: cell, at: indexPath, progress: progress)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.listener?.didSelectItem(at: indexPath)
	}

	private func calculateScrollProgress() -> CGFloat {
		let fadeDistance = min(max(self.collectionView.bounds.height * 0.22, 120), 180)
		guard fadeDistance > 0 else { return 0 }
		let offsetY = max(0, self.collectionView.contentOffset.y)
		return max(0, min(1, offsetY / fadeDistance))
	}

	private func applyCrossfadeEffects() {
		let progress = self.calculateScrollProgress()

		for cell in self.collectionView.visibleCells {
			guard let indexPath = self.collectionView.indexPath(for: cell) else { continue }
			self.applyEffect(to: cell, at: indexPath, progress: progress)
		}
	}

	private func applyEffect(to cell: UICollectionViewCell, at indexPath: IndexPath, progress: CGFloat) {
		let offsetY = max(0, self.collectionView.contentOffset.y)

		if indexPath.section == Section.podium.rawValue {
			let alpha = 1.0 - progress
			let transformY = offsetY > 0 ? offsetY * 0.45 : 0
			cell.contentView.alpha = alpha
			cell.contentView.transform = CGAffineTransform(translationX: 0, y: transformY)
		} else if indexPath.section == Section.list.rawValue {
			let alpha = progress
			let transformY = 36 * (1.0 - progress)
			cell.contentView.alpha = alpha
			cell.contentView.transform = CGAffineTransform(translationX: 0, y: transformY)
		} else {
			cell.contentView.alpha = 1.0
			cell.contentView.transform = .identity
		}
	}
}

extension ChartViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		let urls = indexPaths.compactMap { indexPath -> URL? in
			// Chart의 dataSource 구조에 따라 안전하게 접근
			guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
			return item.thumbnailURL ?? item.imageURL
		}
		ImagePrefetcher(urls: urls).start()
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		let urls = indexPaths.compactMap { indexPath -> URL? in
			guard let item = self.dataSource?.itemIdentifier(for: indexPath) else { return nil }
			return item.thumbnailURL ?? item.imageURL
		}
		ImagePrefetcher(urls: urls).stop()
	}
}
