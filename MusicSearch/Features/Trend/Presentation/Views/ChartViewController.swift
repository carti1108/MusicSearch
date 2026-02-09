//
//  ChartViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Combine

final class ChartViewController: UIViewController {

	enum Section: Int {
		case podium
		case list
	}

	private let viewModel: ChartViewModel
	private var cancellables: Set<AnyCancellable> = .init()
	private var dataSource: UICollectionViewDiffableDataSource<Section, ChartItem>!
	private var lastPresentedErrorMessage: String?
	
	private let loadingIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	init(viewModel: ChartViewModel) {
		self.viewModel = viewModel
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
		bindViewModel()
		self.viewModel.process(action: .viewDidLoad)
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
		let type: ChartType = sender.selectedSegmentIndex == 0 ? .tracks : .artists
		self.viewModel.process(action: .changeType(type))
	}

	private func createLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { sectionIndex, env in
			guard let section = Section(rawValue: sectionIndex) else { return nil }

			switch section {
			case .podium:
				let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0/3.0),
													  heightDimension: .fractionalHeight(1.0))
				let item = NSCollectionLayoutItem(layoutSize: itemSize)
				item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

				let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
													   heightDimension: .fractionalHeight(1.0))
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
		dataSource = UICollectionViewDiffableDataSource<Section, ChartItem>(collectionView: collectionView) {
			(collectionView, indexPath, item) -> UICollectionViewCell? in

			if indexPath.section == Section.podium.rawValue {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PodiumCell.identifier, for: indexPath) as! PodiumCell
				cell.configure(with: item)
				return cell
			} else {
				let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RankListCell.identifier, for: indexPath) as! RankListCell
				cell.configure(with: item)
				return cell
			}
		}
	}

	private func bindViewModel() {
		self.viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.render(state: state)
			}
			.store(in: &self.cancellables)
	}

	private func render(state: ChartViewState) {
		self.setLoading(state.isLoading)
		self.presentErrorIfNeeded(state.errorMessage)

		let segmentIndex = (state.type == .tracks) ? 0 : 1
		if self.segmentControl.selectedSegmentIndex != segmentIndex {
			self.segmentControl.selectedSegmentIndex = segmentIndex
		}

		var snapshot = NSDiffableDataSourceSnapshot<Section, ChartItem>()
		snapshot.appendSections([.podium])
		snapshot.appendItems(state.podiumItems, toSection: .podium)

		if !state.listItems.isEmpty {
			snapshot.appendSections([.list])
			snapshot.appendItems(state.listItems, toSection: .list)
		}

		UIView.performWithoutAnimation {
			self.dataSource.apply(snapshot, animatingDifferences: false)
		}
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
			self?.viewModel.process(action: .refresh)
		}))
		self.present(alert, animated: true)
	}
}

extension ChartViewController: UICollectionViewDelegate {

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
		self.viewModel.process(action: .selectItem(at: indexPath))
	}
}
