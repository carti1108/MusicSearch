//
//  TrackCardCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit
import MSDomain
import MSUtil

final class TrackCardCell: UICollectionViewCell, ReuseIdentifiable {
	private let glowLayer = CAGradientLayer()

	private let cardBackgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
		view.layer.cornerRadius = 28
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.22
		view.layer.shadowOffset = CGSize(width: 0, height: 20)
		view.layer.shadowRadius = 26
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let mainStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 16
		stack.alignment = .fill
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 16
		iv.layer.masksToBounds = true
		iv.backgroundColor = .systemGray5
		iv.clipsToBounds = true
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let textStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 4
		stack.alignment = .center
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 21, weight: .heavy)
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 2
		label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = UIColor.white.withAlphaComponent(0.68)
		label.textAlignment = .center
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.setContentHuggingPriority(.required, for: .vertical)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	private func setupUI() {
		self.glowLayer.colors = [
			UIColor(red: 0.47, green: 0.82, blue: 0.96, alpha: 0.32).cgColor,
			UIColor(red: 0.45, green: 0.36, blue: 0.95, alpha: 0.10).cgColor,
			UIColor.clear.cgColor
		]
		self.glowLayer.startPoint = CGPoint(x: 0, y: 0)
		self.glowLayer.endPoint = CGPoint(x: 1, y: 1)
		self.cardBackgroundView.layer.insertSublayer(self.glowLayer, at: 0)

		self.contentView.addSubview(self.cardBackgroundView)
		self.cardBackgroundView.addSubview(self.mainStackView)

		self.mainStackView.addArrangedSubview(self.albumImageView)
		self.mainStackView.addArrangedSubview(self.textStackView)

		self.textStackView.addArrangedSubview(self.titleLabel)
		self.textStackView.addArrangedSubview(self.artistLabel)

		let spacer = UIView()
		self.mainStackView.addArrangedSubview(spacer)

		NSLayoutConstraint.activate([
			self.cardBackgroundView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
			self.cardBackgroundView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 10),
			self.cardBackgroundView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -10),
			self.cardBackgroundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.mainStackView.topAnchor.constraint(equalTo: self.cardBackgroundView.topAnchor, constant: 20),
			self.mainStackView.leadingAnchor.constraint(equalTo: self.cardBackgroundView.leadingAnchor, constant: 16),
			self.mainStackView.trailingAnchor.constraint(equalTo: self.cardBackgroundView.trailingAnchor, constant: -16),
			self.mainStackView.bottomAnchor.constraint(equalTo: self.cardBackgroundView.bottomAnchor, constant: -18),

			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor)
		])
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.glowLayer.frame = self.cardBackgroundView.bounds
		self.glowLayer.cornerRadius = self.cardBackgroundView.layer.cornerRadius
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.albumImageView.setRemoteImage(nil, targetSize: .zero)
		self.titleLabel.text = nil
		self.artistLabel.text = nil
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		self.albumImageView.setRemoteImage(track.imageURL, targetSize: self.albumImageView.bounds.size)
	}
}
