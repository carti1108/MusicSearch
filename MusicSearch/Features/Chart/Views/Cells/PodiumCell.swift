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
	private var isArtist: Bool = false
	private let contentStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 10
		stack.alignment = .fill
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

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
		label.font = .systemFont(ofSize: 14, weight: .bold)
		label.textAlignment = .center
		label.numberOfLines = 2
		label.textColor = .white
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
		self.imageView.contentMode = .scaleAspectFit
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
		self.containerView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
		self.containerView.layer.cornerRadius = 24
		self.containerView.layer.borderWidth = 1
		self.containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
		self.contentView.addSubview(self.containerView)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.addSubview(self.contentStackView)

		[self.imageView, self.titleLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.contentStackView.addArrangedSubview($0)
		}
		self.rankLabel.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.addSubview(self.rankLabel)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.containerView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -12),

			self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 14),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -14),

			self.imageView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.78),
			self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),

			self.rankLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -15),
			self.rankLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: -5)
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
			self.imageView.contentMode = .scaleAspectFill
			self.imageView.kf.setImage(
				with: url,
				placeholder: nil,
				options: [
					.processor(processor),
					.scaleFactor(UIScreen.main.scale),
					.backgroundDecode
				]
			)
		} else {
			self.imageView.contentMode = .scaleAspectFill
			self.imageView.image = nil
		}

		if item.rank == 1 {
			self.imageView.layer.borderWidth = 4
			self.imageView.layer.borderColor = UIColor.systemYellow.cgColor
			self.rankLabel.font = .systemFont(ofSize: 36, weight: .black)
			self.rankLabel.textColor = .systemYellow
			self.containerView.transform = CGAffineTransform(translationX: 0, y: -14)
		} else {
			self.imageView.layer.borderWidth = 0
			self.rankLabel.font = .systemFont(ofSize: 24, weight: .bold)
			self.rankLabel.textColor = .white
			self.containerView.transform = CGAffineTransform(translationX: 0, y: 18)
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
