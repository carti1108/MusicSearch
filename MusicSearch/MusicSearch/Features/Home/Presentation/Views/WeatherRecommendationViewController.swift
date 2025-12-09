//
//  WeatherRecommendationViewController.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit

struct MockTrack {
	let title: String
	let artist: String
	let color: UIColor
}

struct MockWeather {
	let temp: String
	let description: String
	let location: String
	let iconName: String
	let backgroundColor: UIColor
}

final class WeatherRecommendationViewController: UIViewController, ReuseIdentifiable {

	private let weatherData = MockWeather(
		temp: "22°",
		description: "비가 주륵주륵",
		location: "Seoul, KR",
		iconName: "cloud.rain.fill",
		backgroundColor: UIColor(red: 0.15, green: 0.2, blue: 0.35, alpha: 1.0)
	)

	private let trackList: [MockTrack] = [
		MockTrack(title: "Rainy Day", artist: "Pateko", color: .systemBlue),
		MockTrack(title: "Umbrella", artist: "Epik High", color: .systemTeal),
		MockTrack(title: "비도 오고 그래서", artist: "Heize", color: .systemIndigo),
		MockTrack(title: "November Rain", artist: "Guns N' Roses", color: .darkGray),
		MockTrack(title: "Blue Grey", artist: "BTS", color: .systemGray)
	]

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

	private lazy var collectionView: UICollectionView = {
		let layout = self.createCarouselLayout()
		let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
		cv.backgroundColor = .clear
		cv.showsHorizontalScrollIndicator = false
		cv.register(TrackCardCell.self, forCellWithReuseIdentifier: TrackCardCell.reuseIdentifier)
		cv.dataSource = self
		cv.delegate = self
		cv.translatesAutoresizingMaskIntoConstraints = false
		return cv
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupView()
		self.setupConstraints()
		self.configureData()
	}

	private func setupView() {
		self.view.backgroundColor = self.weatherData.backgroundColor

		self.view.addSubview(self.weatherContainerView)
		self.weatherContainerView.addSubview(self.weatherInfoStack)

		self.weatherInfoStack.addArrangedSubview(self.weatherIconImageView)
		self.weatherInfoStack.addArrangedSubview(self.tempLabel)
		self.weatherInfoStack.addArrangedSubview(self.descriptionLabel)
		self.weatherInfoStack.addArrangedSubview(self.locationLabel)

		self.weatherInfoStack.setCustomSpacing(10, after: self.weatherIconImageView)

		self.view.addSubview(self.sectionTitleLabel)
		self.view.addSubview(self.collectionView)
	}

	private func setupConstraints() {
		NSLayoutConstraint.activate([
			self.weatherContainerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
			self.weatherContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			self.weatherContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			self.weatherContainerView.heightAnchor.constraint(equalToConstant: 240),

			self.weatherInfoStack.centerXAnchor.constraint(equalTo: self.weatherContainerView.centerXAnchor),
			self.weatherInfoStack.centerYAnchor.constraint(equalTo: self.weatherContainerView.centerYAnchor),

			self.weatherIconImageView.widthAnchor.constraint(equalToConstant: 70),
			self.weatherIconImageView.heightAnchor.constraint(equalToConstant: 70),

			self.sectionTitleLabel.topAnchor.constraint(equalTo: self.weatherContainerView.bottomAnchor, constant: 40),
			self.sectionTitleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 24),

			self.collectionView.topAnchor.constraint(equalTo: self.sectionTitleLabel.bottomAnchor, constant: 20),
			self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.collectionView.heightAnchor.constraint(equalToConstant: 380),
			self.collectionView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
		])
	}

	private func configureData() {
		self.tempLabel.text = self.weatherData.temp
		self.descriptionLabel.text = self.weatherData.description
		self.locationLabel.text = self.weatherData.location
		self.weatherIconImageView.image = UIImage(systemName: self.weatherData.iconName)
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

// MARK: - DataSource
extension WeatherRecommendationViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.trackList.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCardCell.reuseIdentifier, for: indexPath) as? TrackCardCell else {
			return UICollectionViewCell()
		}
		cell.configure(with: self.trackList[indexPath.item])
		return cell
	}
}
