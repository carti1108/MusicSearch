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
		self.imageView.image = nil
		self.imageView.backgroundColor = .systemGray5
	}

	private func setupUI() {
		self.rankLabel.font = .boldSystemFont(ofSize: 16)
		self.rankLabel.textColor = .secondaryLabel
		self.rankLabel.textAlignment = .center

		self.titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
		self.titleLabel.textColor = .label

		self.subtitleLabel.font = .systemFont(ofSize: 13, weight: .regular)
		self.subtitleLabel.textColor = .secondaryLabel
		self.subtitleLabel.numberOfLines = 1

		[self.rankLabel, self.imageView, self.titleLabel, self.subtitleLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.contentView.addSubview($0)
		}

		NSLayoutConstraint.activate([
			self.rankLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
			self.rankLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.rankLabel.widthAnchor.constraint(equalToConstant: 30),

			self.imageView.leadingAnchor.constraint(equalTo: self.rankLabel.trailingAnchor, constant: 10),
			self.imageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
			self.imageView.widthAnchor.constraint(equalToConstant: 40),
			self.imageView.heightAnchor.constraint(equalToConstant: 40),

			self.titleLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: 12),
			self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),

			self.subtitleLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
			self.subtitleLabel.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
			self.subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -10)
		])

		let line = UIView()
		line.backgroundColor = .systemGray5
		line.translatesAutoresizingMaskIntoConstraints = false
		self.contentView.addSubview(line)
		NSLayoutConstraint.activate([
			line.heightAnchor.constraint(equalToConstant: 0.5),
			line.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
			line.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			line.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
		])
	}

	func configure(with item: ChartItem) {
		self.rankLabel.text = "\(item.rank)"
		self.titleLabel.text = item.title
		self.subtitleLabel.text = item.subtitle
		self.imageView.backgroundColor = Self.rankColor(item.rank)

		self.imageView.kf.cancelDownloadTask()
		self.imageView.image = nil
		if let url = item.imageURL {
			let targetSize = CGSize(width: 40, height: 40)
			let processor = DownsamplingImageProcessor(size: targetSize)
			self.imageView.kf.setImage(
				with: url,
				options: [
					.processor(processor),
					.scaleFactor(UIScreen.main.scale),
					.backgroundDecode
				]
			)
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


