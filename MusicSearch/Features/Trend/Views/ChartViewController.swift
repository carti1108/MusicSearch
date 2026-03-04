//
//  ChartViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import RIBs

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

protocol ChartViewControllable: ViewControllable {}

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
		sc.backgroundColor = .secondarySystemBackground
		sc.selectedSegmentTintColor = .systemIndigo
		sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
		sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
		sc.translatesAutoresizingMaskIntoConstraints = false
		return sc
	}()

	private lazy var collectionView: UICollectionView = {
		let cv = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
		cv.backgroundColor = .systemBackground
		cv.translatesAutoresizingMaskIntoConstraints = false
		cv.delegate = self
		cv.showsVerticalScrollIndicator = false
		cv.alwaysBounceVertical = true

		cv.register(PodiumCell.self, forCellWithReuseIdentifier: PodiumCell.identifier)
		cv.register(RankListCell.self, forCellWithReuseIdentifier: RankListCell.identifier)
		return cv
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		configureDataSource()
		self.currentSegmentIndex = self.segmentControl.selectedSegmentIndex
		self.listener?.viewDidLoad()
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
		view.backgroundColor = .systemBackground
		navigationItem.title = "Global Trend"

		view.addSubview(segmentControl)
		view.addSubview(collectionView)
		view.addSubview(loadingIndicator)

		NSLayoutConstraint.activate([
			segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			segmentControl.heightAnchor.constraint(equalToConstant: 36),

			collectionView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 10),
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

	private func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { sectionIndex, env in
			guard let section = Section(rawValue: sectionIndex) else { return nil }

			switch section {
			case .podium:
				let itemSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0 / 3.0),
					heightDimension: .fractionalHeight(1.0)
				)
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
				let groupSize = NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .fractionalHeight(1.0)
				)
				let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
				let sectionLayout = NSCollectionLayoutSection(group: group)
				sectionLayout.contentInsets = .zero
				return sectionLayout

			case .list:
				var config = UICollectionLayoutListConfiguration(appearance: .plain)
				config.showsSeparators = false
				config.backgroundColor = .systemBackground
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
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if !self.isRestoringOffset {
			self.segmentOffsets[self.currentSegmentIndex] = scrollView.contentOffset
		}

		let offsetY = scrollView.contentOffset.y
		let fadeDistance = collectionView.bounds.height * 0.7
		let alpha = max(0, 1 - (offsetY / fadeDistance))
		let transform: CGAffineTransform = (offsetY > 0)
		? CGAffineTransform(translationX: 0, y: offsetY * 0.5)
		: .identity

		for item in 0..<3 {
			let indexPath = IndexPath(item: item, section: Section.podium.rawValue)
			guard let cell = self.collectionView.cellForItem(at: indexPath) as? PodiumCell else { continue }
			cell.alpha = alpha
			cell.transform = transform
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.listener?.didSelectItem(at: indexPath)
	}
}
