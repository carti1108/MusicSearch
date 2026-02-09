//
//  WeatherRecommendationViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit
import Combine

final class WeatherRecommendationViewController: UIViewController, ReuseIdentifiable {

	enum Section {
		case main
	}

	private let weatherContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
		view.layer.cornerRadius = 30
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let weatherInfoStack: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 8
		stack.alignment = .center
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let weatherIconImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFit
		iv.tintColor = .white
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let tempLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 56, weight: .heavy)
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 18, weight: .medium)
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	private let locationLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor.white.withAlphaComponent(0.7)
		label.textAlignment = .center
		return label
	}()

	private let sectionTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "오늘 날씨와 어울리는 선곡 🎧"
		label.font = .systemFont(ofSize: 22, weight: .bold)
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private var lastPresentedErrorMessage: String?
	
	private let activityIndicator: UIActivityIndicatorView = {
		let indicator = UIActivityIndicatorView(style: .large)
		indicator.hidesWhenStopped = true
		indicator.translatesAutoresizingMaskIntoConstraints = false
		return indicator
	}()

	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsVerticalScrollIndicator = false
		return scrollView
	}()

	private let contentView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private lazy var collectionView: UICollectionView = {
		let layout = self.createCarouselLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.showsVerticalScrollIndicator = false
		cv.showsHorizontalScrollIndicator = false
		cv.isScrollEnabled = false
		cv.register(TrackCardCell.self, forCellWithReuseIdentifier: TrackCardCell.reuseIdentifier)
		cv.delegate = self
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()

	private lazy var refreshControl: UIRefreshControl = {
		let control = UIRefreshControl()
		control.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
		return control
	}()

	private let viewModel: WeatherRecommendationViewModel
	private var cancellables: Set<AnyCancellable> = .init()

	private var dataSource: UICollectionViewDiffableDataSource<Section, Track>?

	init(viewModel: WeatherRecommendationViewModel) {
		self.viewModel = viewModel

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
		self.bindViewModel()
		self.viewModel.process(action: .viewWillAppear)
	}

	private func bindViewModel() {
		self.viewModel.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				self?.updateUI(with: state)
			}
			.store(in: &self.cancellables)
	}

	private func updateUI(with state: WeatherRecommendationState) {
		self.setLoading(state.isLoading)
		if !state.isLoading {
			self.refreshControl.endRefreshing()
		}
		self.presentErrorIfNeeded(state.errorMessage)

		self.tempLabel.text = "\(Int(state.weather.temperature))°"
		self.descriptionLabel.text = state.weather.description
		self.locationLabel.text = state.weather.cityName
		self.weatherIconImageView.image = UIImage(systemName: self.iconName(for: state.weather.condition))
		
		self.view.backgroundColor = self.backgroundColor(for: state.weather.condition)
		self.weatherContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.main])
		snapshot.appendItems(state.tracks)
		self.dataSource?.apply(snapshot, animatingDifferences: true)
	}
	
	private func setLoading(_ isLoading: Bool) {
		if isLoading {
			self.activityIndicator.startAnimating()
		} else {
			self.activityIndicator.stopAnimating()
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
	
	private func iconName(for condition: WeatherCondition) -> String {
		switch condition {
		case .thunderstorm:
			return "cloud.bolt.fill"
		case .drizzle:
			return "cloud.drizzle.fill"
		case .rain:
			return "cloud.rain.fill"
		case .snow:
			return "cloud.snow.fill"
		case .atmosphere:
			return "cloud.fog.fill"
		case .clear:
			return "sun.max.fill"
		case .clouds:
			return "cloud.fill"
		case .unknown:
			return "questionmark.circle.fill"
		}
	}
	
	private func backgroundColor(for condition: WeatherCondition) -> UIColor {
		switch condition {
		case .thunderstorm:
			return UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 1.0)
		case .drizzle, .rain:
			return UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0)
		case .snow:
			return UIColor(red: 0.4, green: 0.5, blue: 0.6, alpha: 1.0)
		case .atmosphere:
			return UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
		case .clear:
			return UIColor(red: 0.2, green: 0.5, blue: 0.8, alpha: 1.0)
		case .clouds:
			return UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
		case .unknown:
			return UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 1.0)
		}
	}

	private func setupView() {
		self.view.backgroundColor = .systemBackground

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance

		self.scrollView.refreshControl = self.refreshControl
		self.view.addSubview(self.scrollView)
		self.scrollView.addSubview(self.contentView)
		self.view.addSubview(self.activityIndicator)

		self.contentView.addSubview(self.weatherContainerView)
		self.weatherContainerView.addSubview(self.weatherInfoStack)

		self.weatherInfoStack.addArrangedSubview(self.weatherIconImageView)
		self.weatherInfoStack.addArrangedSubview(self.tempLabel)
		self.weatherInfoStack.addArrangedSubview(self.descriptionLabel)
		self.weatherInfoStack.addArrangedSubview(self.locationLabel)

		self.weatherInfoStack.setCustomSpacing(10, after: self.weatherIconImageView)

		self.contentView.addSubview(self.sectionTitleLabel)
		self.contentView.addSubview(self.collectionView)
	}

	@objc private func handleRefresh() {
		self.viewModel.process(action: .refresh)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			// ScrollView
			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			
			self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
			self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

			// ContentView
			self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

			// Weather Container
			self.weatherContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
			self.weatherContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.weatherContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
			self.weatherContainerView.heightAnchor.constraint(equalToConstant: 240),

			// Weather Info Stack
			self.weatherInfoStack.centerXAnchor.constraint(equalTo: self.weatherContainerView.centerXAnchor),
			self.weatherInfoStack.centerYAnchor.constraint(equalTo: self.weatherContainerView.centerYAnchor),

			// Weather Icon
			self.weatherIconImageView.widthAnchor.constraint(equalToConstant: 70),
			self.weatherIconImageView.heightAnchor.constraint(equalToConstant: 70),

			// Section Title
			self.sectionTitleLabel.topAnchor.constraint(equalTo: self.weatherContainerView.bottomAnchor, constant: 40),
			self.sectionTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),

			// Collection View
			self.collectionView.topAnchor.constraint(equalTo: self.sectionTitleLabel.bottomAnchor, constant: 20),
			self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: 380),
			self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
		])
	}

	private func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Section,Track>(collectionView: self.collectionView) { [weak self] (collectionView, indexPath, track) -> UICollectionViewCell? in
			guard let cell: TrackCardCell = self?.collectionView.dequeueReusableCell(withReuseIdentifier: TrackCardCell.reuseIdentifier, for: indexPath) as? TrackCardCell else {
				return UICollectionViewCell()
			}
			cell.configure(with: track)

			return cell
		}
	}

	private func createCarouselLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { sectionIndex, env in

			let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
												  heightDimension: .fractionalHeight(1.0))
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupWidth = env.container.contentSize.width * 0.75
			let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(groupWidth),
												   heightDimension: .fractionalHeight(1.0))
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .groupPagingCentered
			section.interGroupSpacing = 20

			section.visibleItemsInvalidationHandler = { (items, offset, environment) in
				let containerWidth = environment.container.contentSize.width
				let centerX = offset.x + containerWidth / 2.0

				items.forEach { item in
					let distanceFromCenter = abs(item.frame.midX - centerX)
					let minScale: CGFloat = 0.85
					let scale = max(minScale, 1 - (distanceFromCenter / containerWidth) * 0.4)
					item.transform = CGAffineTransform(scaleX: scale, y: scale)
					item.alpha = max(0.6, 1 - (distanceFromCenter / containerWidth))
				}
			}
			return section
		}
	}
}

extension WeatherRecommendationViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.viewModel.process(action: .trackCardSelected(index: indexPath.item))
	}
}
