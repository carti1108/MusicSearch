//
//  WeatherRecommendationViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit
import RIBs

@MainActor
final class WeatherRecommendationViewController: UIViewController, ReuseIdentifiable, HomePresentable, HomeViewControllable, ErrorPresentable {
	enum Section {
		case main
	}

	weak var listener: HomePresentableListener?

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
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	var lastPresentedErrorMessage: String?

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

	private var dataSource: UICollectionViewDiffableDataSource<Section, Track>?

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
		self.listener?.viewDidLoad()
	}

	func update(weather: Weather, tracks: [Track]) {
		self.sectionTitleLabel.isHidden = false
		self.tempLabel.text = "\(Int(weather.temperature))°"
		self.descriptionLabel.text = weather.description
		self.locationLabel.text = weather.cityName
		self.weatherIconImageView.image = UIImage(systemName: self.iconName(for: weather.condition))

		self.view.backgroundColor = self.backgroundColor(for: weather.condition)
		self.weatherContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)

		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.main])
		snapshot.appendItems(tracks)
		self.dataSource?.apply(snapshot, animatingDifferences: true)
	}

	func showLoading(_ isShow: Bool) {
		if isShow {
			if !self.refreshControl.isRefreshing {
				self.refreshControl.beginRefreshing()
				if self.scrollView.contentOffset.y >= -self.scrollView.adjustedContentInset.top {
					let yOffset = -self.scrollView.adjustedContentInset.top - self.refreshControl.frame.height
					self.scrollView.setContentOffset(CGPoint(x: 0, y: yOffset), animated: true)
				}
			}
		} else {
			self.refreshControl.endRefreshing()
		}
	}

	func showError(_ message: String?) {
		self.presentErrorIfNeeded(message, onRetry: { [weak self] in
			self?.listener?.didTapRefresh()
		})
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
		self.listener?.didTapRefresh()
	}

	private func setupConstraints() {
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

			self.weatherContainerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
			self.weatherContainerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20),
			self.weatherContainerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
			self.weatherContainerView.heightAnchor.constraint(equalToConstant: 240),

			self.weatherInfoStack.centerXAnchor.constraint(equalTo: self.weatherContainerView.centerXAnchor),
			self.weatherInfoStack.centerYAnchor.constraint(equalTo: self.weatherContainerView.centerYAnchor),

			self.weatherIconImageView.widthAnchor.constraint(equalToConstant: 70),
			self.weatherIconImageView.heightAnchor.constraint(equalToConstant: 70),

			self.sectionTitleLabel.topAnchor.constraint(equalTo: self.weatherContainerView.bottomAnchor, constant: 40),
			self.sectionTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),

			self.collectionView.topAnchor.constraint(equalTo: self.sectionTitleLabel.bottomAnchor, constant: 20),
			self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: 380),
			self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
		])
	}

	private func configureDataSource() {
		self.dataSource = UICollectionViewDiffableDataSource<Section, Track>(
			collectionView: self.collectionView
		) { [weak self] _, indexPath, track in
			guard let self,
					let cell = self.collectionView.dequeueReusableCell(
					withReuseIdentifier: TrackCardCell.reuseIdentifier,
				for: indexPath
			) as? TrackCardCell else {
				return UICollectionViewCell()
			}
			cell.configure(with: track)
			return cell
		}
	}

	private func createCarouselLayout() -> UICollectionViewLayout {
		return UICollectionViewCompositionalLayout { _, env in
			let itemSize = NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0)
			)
			let item = NSCollectionLayoutItem(layoutSize: itemSize)

			let groupWidth = env.container.contentSize.width * 0.75
			let groupSize = NSCollectionLayoutSize(
				widthDimension: .absolute(groupWidth),
				heightDimension: .fractionalHeight(1.0)
			)
			let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

			let section = NSCollectionLayoutSection(group: group)
			section.orthogonalScrollingBehavior = .groupPagingCentered
			section.interGroupSpacing = 20

			section.visibleItemsInvalidationHandler = { items, offset, environment in
				let containerWidth = environment.container.contentSize.width
				let centerX = offset.x + (containerWidth / 2.0)

				items.forEach { item in
					let distanceFromCenter = abs(item.frame.midX - centerX)
					let progress = min(distanceFromCenter / containerWidth, 1.0)
					let yOffset = progress * 18
					item.transform = CGAffineTransform(translationX: 0, y: yOffset)
					item.alpha = max(0.75, 1 - (progress * 0.35))
				}
			}
			return section
		}
	}
}

extension WeatherRecommendationViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		self.listener?.didSelectTrack(at: indexPath.item)
	}
}
