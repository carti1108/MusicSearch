//
//  WeatherRecommendationViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit
import MSDesignSystem
import MicroRIBs
import MSDomain
import MSUtil
import WeatherRecommendationDomain

@MainActor
final class WeatherRecommendationViewController: UIViewController, ReuseIdentifiable, WeatherRecommendationPresentable, WeatherRecommendationViewControllable, ErrorPresentable {
	enum Section {
		case main
	}

	weak var listener: WeatherRecommendationPresentableListener?
	private let backgroundGradientLayer = CAGradientLayer()

	private let topGlowView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let bottomGlowView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let eyebrowLabel: UILabel = {
		let label = UILabel()
		label.text = "SOUNDTRACK FOR RIGHT NOW"
		label.font = .systemFont(ofSize: 12, weight: .semibold)
		label.textColor = UIColor.white.withAlphaComponent(0.72)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let heroTitleLabel: UILabel = {
		let label = UILabel()
		label.text = "오늘의 공기와\n어울리는 플레이리스트"
		label.font = .systemFont(ofSize: 32, weight: .heavy)
		label.textColor = .white
		label.numberOfLines = 2
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let heroSubtitleLabel: UILabel = {
		let label = UILabel()
		label.text = "날씨와 무드를 바탕으로 바로 재생할 수 있는 곡을 골라드려요."
		label.font = .systemFont(ofSize: 15, weight: .medium)
		label.textColor = UIColor.white.withAlphaComponent(0.72)
		label.numberOfLines = 0
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let weatherContainerView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
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
		label.font = .systemFont(ofSize: 62, weight: .black)
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()

	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 17, weight: .semibold)
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
		let attributedString = NSMutableAttributedString(string: "오늘 날씨와 어울리는 선곡 ")
		let attachment = NSTextAttachment()
		attachment.image = UIImage(systemName: "headphones")?.withTintColor(UIColor(CustomColor.onSurface), renderingMode: .alwaysOriginal)
		let bounds = CGRect(x: 0, y: -4, width: 24, height: 24)
		attachment.bounds = bounds
		attributedString.append(NSAttributedString(attachment: attachment))
		label.attributedText = attributedString
		label.font = .systemFont(ofSize: 24, weight: .heavy)
		label.textColor = UIColor(CustomColor.onSurface)
		label.numberOfLines = 0
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.isHidden = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	var lastPresentedErrorMessage: String?
	private(set) var isShowingLoading = false

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
		cv.clipsToBounds = false
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

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.backgroundGradientLayer.frame = self.view.bounds
		self.topGlowView.layer.cornerRadius = self.topGlowView.bounds.height / 2
		self.bottomGlowView.layer.cornerRadius = self.bottomGlowView.bounds.height / 2
	}

	func update(weather: Weather, tracks: [Track]) {
		self.sectionTitleLabel.isHidden = false
		self.tempLabel.text = "\(Int(weather.temperature))°"
		self.descriptionLabel.text = weather.description
		self.locationLabel.text = weather.cityName
		self.weatherIconImageView.image = UIImage(systemName: self.iconName(for: weather.condition))

		let newColors = self.gradientColors(for: weather.condition).map(\.cgColor)
		if self.backgroundGradientLayer.colors as? [CGColor] != newColors {
			let animation = CABasicAnimation(keyPath: "colors")
			animation.fromValue = self.backgroundGradientLayer.colors
			animation.toValue = newColors
			animation.duration = 0.5
			self.backgroundGradientLayer.add(animation, forKey: "colorsChange")
			self.backgroundGradientLayer.colors = newColors
		}

		self.animateWeatherIcon(for: weather.condition)

		self.weatherContainerView.backgroundColor = .clear

		var snapshot = NSDiffableDataSourceSnapshot<Section, Track>()
		snapshot.appendSections([.main])
		snapshot.appendItems(tracks)
		self.dataSource?.apply(snapshot, animatingDifferences: true)
	}

	func showLoading(_ isShow: Bool) {
		self.isShowingLoading = isShow
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

	private func gradientColors(for condition: WeatherCondition) -> [UIColor] {
		switch condition {
		case .clear:
			return [UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0), UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0)]
		case .clouds, .atmosphere:
			return [UIColor(red: 0.4, green: 0.45, blue: 0.5, alpha: 1.0), UIColor(red: 0.2, green: 0.25, blue: 0.3, alpha: 1.0)]
		case .rain, .drizzle:
			return [UIColor(red: 0.2, green: 0.3, blue: 0.4, alpha: 1.0), UIColor(red: 0.1, green: 0.15, blue: 0.2, alpha: 1.0)]
		case .thunderstorm:
			return [UIColor(red: 0.2, green: 0.1, blue: 0.3, alpha: 1.0), UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)]
		case .snow:
			return [UIColor(red: 0.5, green: 0.6, blue: 0.7, alpha: 1.0), UIColor(red: 0.3, green: 0.4, blue: 0.5, alpha: 1.0)]
		case .unknown:
			return [UIColor(CustomColor.background), UIColor(CustomColor.background)]
		}
	}

	private func animateWeatherIcon(for condition: WeatherCondition) {
		if #available(iOS 17.0, *) {
			self.weatherIconImageView.removeAllSymbolEffects()

			switch condition {
			case .thunderstorm:
				self.weatherIconImageView.addSymbolEffect(.pulse.byLayer, options: .repeating)
				self.weatherIconImageView.addSymbolEffect(.bounce.byLayer, options: .repeating)

			case .drizzle:
				self.weatherIconImageView.addSymbolEffect(.variableColor.iterative.reversing, options: .repeating)

			case .rain:
				self.weatherIconImageView.addSymbolEffect(.variableColor.cumulative, options: .repeating)
				self.weatherIconImageView.addSymbolEffect(.bounce.down, options: .repeating)

			case .snow:
				self.weatherIconImageView.addSymbolEffect(.bounce.down, options: .repeating.speed(0.5))

			case .atmosphere:
				self.weatherIconImageView.addSymbolEffect(.variableColor.iterative.reversing, options: .repeating)

			case .clear:
				self.weatherIconImageView.addSymbolEffect(.pulse, options: .repeating)

			case .clouds, .unknown:
				break
			}
		}
	}

	private func setupView() {
		self.backgroundGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
		self.backgroundGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
		self.backgroundGradientLayer.colors = self.gradientColors(for: .unknown).map(\.cgColor)
		self.view.layer.insertSublayer(self.backgroundGradientLayer, at: 0)
		self.view.backgroundColor = UIColor(CustomColor.background)

		let appearance = UINavigationBarAppearance()
		appearance.configureWithTransparentBackground()
		appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
		appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
		self.navigationController?.navigationBar.standardAppearance = appearance
		self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
		self.navigationItem.title = "Home"

		self.scrollView.refreshControl = self.refreshControl
		self.view.addSubview(self.topGlowView)
		self.view.addSubview(self.bottomGlowView)
		self.view.addSubview(self.scrollView)
		self.scrollView.addSubview(self.contentView)

		self.contentView.addSubview(self.eyebrowLabel)
		self.contentView.addSubview(self.heroTitleLabel)
		self.contentView.addSubview(self.heroSubtitleLabel)
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
			self.topGlowView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -120),
			self.topGlowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -80),
			self.topGlowView.widthAnchor.constraint(equalToConstant: 260),
			self.topGlowView.heightAnchor.constraint(equalToConstant: 260),

			self.bottomGlowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 100),
			self.bottomGlowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 120),
			self.bottomGlowView.widthAnchor.constraint(equalToConstant: 300),
			self.bottomGlowView.heightAnchor.constraint(equalToConstant: 300),

			self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

			self.contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
			self.contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
			self.contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
			self.contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
			self.contentView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),

			self.eyebrowLabel.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
			self.eyebrowLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
			self.eyebrowLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -24),

			self.heroTitleLabel.topAnchor.constraint(equalTo: self.eyebrowLabel.bottomAnchor, constant: 10),
			self.heroTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
			self.heroTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -24),

			self.heroSubtitleLabel.topAnchor.constraint(equalTo: self.heroTitleLabel.bottomAnchor, constant: 10),
			self.heroSubtitleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 24),
			self.heroSubtitleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -24),

			self.weatherContainerView.topAnchor.constraint(equalTo: self.heroSubtitleLabel.bottomAnchor, constant: 26),
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
			self.collectionView.heightAnchor.constraint(equalToConstant: 450),
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
