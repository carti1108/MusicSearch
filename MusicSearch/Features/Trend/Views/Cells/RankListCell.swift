//
//  RankListCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Kingfisher

final class RankListCell: UICollectionViewCell {
	static let identifier = "RankListCell"

	private let cardView = UIView()
	private let rankLabel = UILabel()
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
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
		self.imageView.kf.cancelDownloadTask()
		self.imageView.contentMode = .scaleAspectFit
		self.imageView.image = nil
		self.imageView.backgroundColor = .systemGray5
		self.imageView.tintColor = UIColor.white.withAlphaComponent(0.78)
	}

	private func setupUI() {
		self.contentView.backgroundColor = .clear
		self.cardView.backgroundColor = UIColor.white.withAlphaComponent(0.06)
		self.cardView.layer.cornerRadius = 20
		self.cardView.layer.borderWidth = 1
		self.cardView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
		self.cardView.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(self.cardView)

		self.rankLabel.font = .boldSystemFont(ofSize: 16)
		self.rankLabel.textColor = UIColor.white.withAlphaComponent(0.62)
		self.rankLabel.textAlignment = .center

		self.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
		self.titleLabel.textColor = .white
		self.titleLabel.numberOfLines = 1
		self.titleLabel.lineBreakMode = .byTruncatingTail
		self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		self.subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
		self.subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.58)
		self.subtitleLabel.numberOfLines = 1
		self.subtitleLabel.lineBreakMode = .byTruncatingTail
		self.subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		[self.rankLabel, self.imageView, self.titleLabel, self.subtitleLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.cardView.addSubview($0)
		}

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 6),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -6),

			self.rankLabel.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 12),
			self.rankLabel.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.rankLabel.widthAnchor.constraint(equalToConstant: 30),

			self.imageView.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 10),
			self.imageView.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.imageView.widthAnchor.constraint(equalToConstant: 40),
			self.imageView.heightAnchor.constraint(equalToConstant: 40),

			self.titleLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 12),
			self.titleLabel.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 10),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -20),

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

		self.imageView.kf.cancelDownloadTask()
		self.imageView.image = nil
		let placeholder = UIImage(
			systemName: item.type == .artists ? "music.mic" : "music.note",
			withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
		)
		if let url = item.imageURL {
			let targetSize = CGSize(width: 40, height: 40)
			let processor = DownsamplingImageProcessor(size: targetSize)
			self.imageView.contentMode = .scaleAspectFill
			self.imageView.kf.setImage(
				with: url,
				placeholder: placeholder,
				options: [
					.processor(processor),
					.scaleFactor(UIScreen.main.scale),
					.backgroundDecode
				]
			)
		} else {
			self.imageView.contentMode = .scaleAspectFit
			self.imageView.image = placeholder
			self.imageView.tintColor = UIColor.white.withAlphaComponent(0.78)
		}

		self.imageView.layer.cornerRadius = (item.type == .artists) ? 20 : 8
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
