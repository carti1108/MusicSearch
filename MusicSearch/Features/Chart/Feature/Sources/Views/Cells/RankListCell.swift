//
//  RankListCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import MSDesignSystem

final class RankListCell: UICollectionViewCell {
	static let identifier = "RankListCell"

	private let cardView = UIView()
	
	private let blurBackgroundView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
		let view = UIVisualEffectView(effect: blurEffect)
		view.layer.cornerRadius = 16
		view.clipsToBounds = true
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let rankLabel = UILabel()
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let trendLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .bold)
		label.textAlignment = .right
		return label
	}()
	private let imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.backgroundColor = .systemGray5
		iv.layer.cornerRadius = 8
		return iv
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.imageView.setRemoteImage(nil, targetSize: .zero)
		self.imageView.backgroundColor = .systemGray5
		self.imageView.tintColor = UIColor.white.withAlphaComponent(0.78)
	}

	private func setupUI() {
		self.contentView.backgroundColor = .clear
		self.cardView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.cardView)
		self.cardView.addSubview(self.blurBackgroundView)

		self.rankLabel.font = .boldSystemFont(ofSize: 16)
		self.rankLabel.textColor = UIColor(CustomColor.primary)
		self.rankLabel.textAlignment = .center

		self.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
		self.titleLabel.textColor = UIColor(CustomColor.onSurface)
		self.titleLabel.numberOfLines = 1
		self.titleLabel.lineBreakMode = .byTruncatingTail
		self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		self.subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
		self.subtitleLabel.textColor = UIColor(CustomColor.onSurfaceVariant)
		self.subtitleLabel.numberOfLines = 1
		self.subtitleLabel.lineBreakMode = .byTruncatingTail
		self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		[self.rankLabel, self.imageView, self.titleLabel, self.subtitleLabel, self.trendLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.cardView.addSubview($0)
		}

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 6),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -6),

			self.blurBackgroundView.topAnchor.constraint(equalTo: self.cardView.topAnchor),
			self.blurBackgroundView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor),
			self.blurBackgroundView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor),
			self.blurBackgroundView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor),

			self.rankLabel.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 12),
			self.rankLabel.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.rankLabel.widthAnchor.constraint(equalToConstant: 30),

			self.imageView.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 10),
			self.imageView.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.imageView.widthAnchor.constraint(equalToConstant: 40),
			self.imageView.heightAnchor.constraint(equalToConstant: 40),

			self.trendLabel.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -16),
			self.trendLabel.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.trendLabel.widthAnchor.constraint(equalToConstant: 40),

			self.titleLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 12),
			self.titleLabel.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 10),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.trendLabel.leadingAnchor, constant: -10),

			self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
			self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.cardView.bottomAnchor, constant: -10)
		])
	}

	func configure(with item: ChartItem) {
		self.rankLabel.text = "\(item.rank)"
		self.titleLabel.text = item.title
		self.subtitleLabel.text = item.subtitle
		self.imageView.backgroundColor = Self.rankColor(item.rank)

		let urlToLoad = item.thumbnailURL ?? item.imageURL
		self.imageView.setRemoteImage(urlToLoad, targetSize: CGSize(width: 40, height: 40))

		if item.trend > 0 {
			self.trendLabel.text = "▲ \(item.trend)"
			self.trendLabel.textColor = .systemGreen
		} else if item.trend < 0 {
			self.trendLabel.text = "▼ \(abs(item.trend))"
			self.trendLabel.textColor = .systemRed
		} else {
			self.trendLabel.text = "-"
			self.trendLabel.textColor = .systemGray
		}
	}

	private static func rankColor(_ rank: Int) -> UIColor {
		switch rank {
		case 1: return .systemYellow
		case 2: return .systemGray
		case 3: return .systemOrange
		default: return .systemGray5
		}
	}
}
