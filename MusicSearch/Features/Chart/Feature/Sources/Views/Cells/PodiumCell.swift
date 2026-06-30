//
//  PodiumCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/13/25.
//

import UIKit
import MSDesignSystem

final class PodiumCell: UICollectionViewCell {
	static let identifier = "PodiumCell"

	private let containerView = UIView()
	
	private let blurBackgroundView: UIVisualEffectView = {
		let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
		let view = UIVisualEffectView(effect: blurEffect)
		view.layer.cornerRadius = 24
		view.clipsToBounds = true
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

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

	private let trendLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .bold)
		label.textAlignment = .center
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
		self.imageView.setRemoteImage(nil, targetSize: .zero)
		self.imageView.backgroundColor = .systemGray5
		self.imageView.layer.borderWidth = 0
		self.imageView.layer.borderColor = nil
		self.containerView.transform = .identity
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.imageView.layer.cornerRadius = 16
	}

	private func setupUI() {
		self.containerView.backgroundColor = .clear
		self.contentView.addSubview(self.containerView)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.addSubview(self.blurBackgroundView)
		self.containerView.addSubview(self.contentStackView)

		[self.imageView, self.titleLabel, self.trendLabel].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			self.contentStackView.addArrangedSubview($0)
		}
		self.rankLabel.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.addSubview(self.rankLabel)

		self.contentStackView.alignment = .center
		self.contentStackView.setCustomSpacing(4, after: self.titleLabel)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
			self.containerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.containerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.containerView.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -12),

			self.blurBackgroundView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
			self.blurBackgroundView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
			self.blurBackgroundView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
			self.blurBackgroundView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

			self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 10),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -10),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16),

			self.imageView.widthAnchor.constraint(equalTo: self.containerView.widthAnchor, multiplier: 0.75),
			self.imageView.heightAnchor.constraint(equalTo: self.imageView.widthAnchor),
			self.titleLabel.widthAnchor.constraint(equalTo: self.contentStackView.widthAnchor),

			self.rankLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: -15),
			self.rankLabel.leadingAnchor.constraint(equalTo: self.imageView.leadingAnchor, constant: -10)
		])
	}

	func configure(with item: ChartItem) {
		self.titleLabel.text = item.title
		self.imageView.backgroundColor = Self.rankColor(item.rank)
		self.isArtist = (item.type == .artists)

		self.imageView.setRemoteImage(
			item.imageURL,
			targetSize: self.imageView.bounds.size == .zero
				? CGSize(width: 400, height: 400)
				: self.imageView.bounds.size
		)

		let rankString = "\(item.rank)"
		var foregroundColor = UIColor.white
		var fontSize: CGFloat = 36
		var yOffset: CGFloat = 18
		var scale: CGFloat = 0.85

		if item.rank == 1 {
			foregroundColor = UIColor(CustomColor.primary)
			self.imageView.layer.borderWidth = 0
			fontSize = 54
			yOffset = -14
			scale = 1.05
			self.titleLabel.font = .systemFont(ofSize: 15, weight: .heavy)
		} else {
			foregroundColor = UIColor(CustomColor.onSurfaceVariant)
			self.imageView.layer.borderWidth = 1
			self.imageView.layer.borderColor = UIColor(CustomColor.outlineVariant).cgColor
			fontSize = 42
			yOffset = 18
			scale = 0.85
			self.titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
		}

		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: foregroundColor,
			.font: UIFont.systemFont(ofSize: fontSize, weight: .black)
		]
		self.rankLabel.attributedText = NSAttributedString(string: rankString, attributes: attributes)
		self.containerView.transform = CGAffineTransform(translationX: 0, y: yOffset).scaledBy(x: scale, y: scale)

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
