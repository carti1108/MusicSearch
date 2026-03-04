//
//  PodiumCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import Kingfisher

final class PodiumCell: UICollectionViewCell {
	static let identifier = "PodiumCell"

	private let containerView = UIView()
	private var containerCenterYConstraint: NSLayoutConstraint?
	private var isArtist: Bool = false

	private let rankLabel: UILabel = {
		let label = UILabel()
		label.textAlignment = .center
		return label
	}()

	private let imageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.clipsToBounds = true
		iv.backgroundColor = .systemGray5
		return iv
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .semibold)
		label.textAlignment = .center
		label.numberOfLines = 2
		return label
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
		self.isArtist = false
		self.imageView.kf.cancelDownloadTask()
		self.imageView.image = nil
		self.imageView.backgroundColor = .systemGray5
		self.imageView.layer.borderWidth = 0
		self.imageView.layer.borderColor = nil
		self.containerView.transform = .identity
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if self.isArtist {
			self.imageView.layer.cornerRadius = self.imageView.bounds.width / 2
		} else {
			self.imageView.layer.cornerRadius = 20
		}
	}

	private func setupUI() {
		self.contentView.addSubview(self.containerView)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false

		[self.imageView, self.rankLabel, self.titleLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.containerView.addSubview($0)
		}

		self.containerCenterYConstraint = self.containerView.centerYAnchor.constraint(
			equalTo: self.contentView.centerYAnchor,
			constant: -20
		)

		NSLayoutConstraint.activate([
			self.containerCenterYConstraint!,
			self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

			self.imageView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
			self.imageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
			self.imageView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.95),
			self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),

			self.rankLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -15),
			self.rankLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: -5),

			self.titleLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 10),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor)
		])
	}

	func configure(with item: ChartItem) {
		self.rankLabel.text = "\(item.rank)"
		self.titleLabel.text = item.title
		self.imageView.backgroundColor = Self.rankColor(item.rank)
		self.isArtist = (item.type == .artists)

		self.imageView.kf.cancelDownloadTask()
		self.imageView.image = nil
		if let url = item.imageURL {
			let processor = DownsamplingImageProcessor(
				size: self.imageView.bounds.size == .zero
					? CGSize(width: 400, height: 400)
					: self.imageView.bounds.size
			)
			self.imageView.kf.setImage(
				with: url,
				options: [
					.processor(processor),
					.scaleFactor(UIScreen.main.scale),
					.backgroundDecode
				]
			)
		}

		if item.rank == 1 {
			self.imageView.layer.borderWidth = 4
			self.imageView.layer.borderColor = UIColor.systemYellow.cgColor
			self.rankLabel.font = .systemFont(ofSize: 36, weight: .black)
			self.rankLabel.textColor = .systemYellow
			self.containerView.transform = .identity
		} else {
			self.imageView.layer.borderWidth = 0
			self.rankLabel.font = .systemFont(ofSize: 24, weight: .bold)
			self.rankLabel.textColor = .label
			self.containerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85).translatedBy(x: 0, y: 80)
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
