//
//  ChartViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Kingfisher

@MainActor
protocol ChartViewableListener: AnyObject {
	func viewDidLoad()
	func didChangeSegment(index: Int)
	func didTapRefresh()
	func didSelectItem(at indexPath: IndexPath)
}

@MainActor
final class ChartViewController: UIViewController, ChartViewable, LoadingPresentable, ErrorPresentable {
	enum Section: Int {
		case podium
		case list
	}

	weak var listener: ChartViewableListener?
	private var dataSource: UICollectionViewDiffableDataSource<Section, ChartItem>!
	var lastPresentedErrorMessage: String?
	private var currentSegmentIndex: Int = 0
	private var segmentOffsets: [Int: CGPoint] = .init()
	private var isRestoringOffset = false
	private var hasPrimedInitialCrossfade = false
	private var imagePrefetcher: ImagePrefetcher?
	private let backgroundGradientLayer = CAGradientLayer()

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
		let sc = UISegmentedControl(items: ["🔥 Top Tracks", "🎤 Top Artists"])
		sc.selectedSegmentIndex = 0
		sc.backgroundColor = UIColor.white.withAlphaComponent(0.08)
		sc.selectedSegmentTintColor = UIColor(red: 0.34, green: 0.56, blue: 0.98, alpha: 1.0)
		sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
		sc.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.65)], for: .normal)
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
		stack.spacing = 8
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let eyebrowLabel: UILabel = {
		let label = UILabel()
		label.text = "GLOBAL MOMENTUM"
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = UIColor.white.withAlphaComponent(0.62)
		return label
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "지금 가장 뜨거운\n트랙과 아티스트"
		label.font = .systemFont(ofSize: 30, weight: .heavy)
		label.textColor = .white
		label.numberOfLines = 2
		return label
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.configureDataSource()
		self.currentSegmentIndex = self.segmentControl.selectedSegmentIndex
		self.listener?.viewDidLoad()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.backgroundGradientLayer.frame = self.view.bounds
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
		self.backgroundGradientLayer.colors = [
			UIColor(red: 0.02, green: 0.03, blue: 0.09, alpha: 1.0).cgColor,
			UIColor(red: 0.10, green: 0.09, blue: 0.21, alpha: 1.0).cgColor,
			UIColor(red: 0.09, green: 0.17, blue: 0.23, alpha: 1.0).cgColor
		]
		self.backgroundGradientLayer.startPoint = CGPoint(x: 0, y: 0)
		self.backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)
		self.view.layer.insertSublayer(self.backgroundGradientLayer, at: 0)
		self.navigationItem.title = "Chart"
		self.navigationController?.navigationBar.tintColor = .white

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

		self.headerStackView.addArrangedSubview(self.eyebrowLabel)
		self.headerStackView.addArrangedSubview(self.titleLabel)

		self.view.addSubview(self.headerStackView)
		self.view.addSubview(self.segmentControl)
		self.view.addSubview(self.collectionView)
		self.view.addSubview(self.loadingIndicator)

		NSLayoutConstraint.activate([
			self.headerStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 12),
			self.headerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			self.headerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

			self.segmentControl.topAnchor.constraint(equalTo: self.headerStackView.bottomAnchor, constant: 18),
			self.segmentControl.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			self.segmentControl.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			self.segmentControl.heightAnchor.constraint(equalToConstant: 38),

			self.collectionView.topAnchor.constraint(equalTo: self.segmentControl.bottomAnchor, constant: 10),
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
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
				let verticalInset = max((env.container.effectiveContentSize.height - podiumHeight) / 2, 12)
				let itemSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0 / 3.0),
					heightDimension: .fractionalHeight(1.0)
				)
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
				let groupSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(podiumHeight)
				)
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
				let sectionLayout = NSCollectionLayoutSection(group: group)
				sectionLayout.contentInsets = NSDirectionalEdgeInsets(
					top: verticalInset,
					leading: 14,
					bottom: verticalInset,
					trailing: 14
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
		self.dataSource = UICollectionViewDiffableDataSource<Section, ChartItem>(
			collectionView: self.collectionView
		) { collectionView, indexPath, item in
			if indexPath.section == Section.podium.rawValue {
				let cell = collectionView.dequeueReusableCell(
					withReuseIdentifier: PodiumCell.identifier,
					for: indexPath
				) as! PodiumCell
				cell.configure(with: item)
				return cell
			}

			let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: RankListCell.identifier,
				for: indexPath
			) as! RankListCell
			cell.configure(with: item)
			return cell
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
			guard indexPath.section == Section.list.rawValue else { return nil }
			return self.dataSource.itemIdentifier(for: indexPath)?.imageURL
		}

		guard !urls.isEmpty else { return }
		self.imagePrefetcher?.stop()
		let prefetcher = ImagePrefetcher(urls: urls)
		self.imagePrefetcher = prefetcher
		prefetcher.start()
	}

	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		self.imagePrefetcher?.stop()
		self.imagePrefetcher = nil
	}
}
