//
//  TrackCarouselCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit
import MSDesignSystem
import MSDomain
import MSUtil

final class TrackCarouselCell: UICollectionViewCell, ReuseIdentifiable {
	private let cardView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor(CustomColor.outlineVariant).cgColor
		view.layer.cornerRadius = 16
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let mainStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 10
		stack.alignment = .fill
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.backgroundColor = .systemGray5
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 12
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 11, weight: .bold)
		label.textColor = UIColor(CustomColor.onSurface)
		label.textAlignment = .left
		label.numberOfLines = 0
		
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 9, weight: .medium)
		label.textColor = UIColor(CustomColor.onSurfaceVariant)
		label.textAlignment = .left
		label.numberOfLines = 0
		
		return label
	}()

	private let spacerView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor(CustomColor.outlineVariant).cgColor
		view.layer.cornerRadius = 16
		view.setContentHuggingPriority(.defaultLow, for: .vertical)
		view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		return view
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	override func prepareForReuse() {
		super.prepareForReuse()
		self.albumImageView.setRemoteImage(nil, targetSize: .zero)
		self.titleLabel.text = nil
		self.artistLabel.text = nil
	}

	private func setupUI() {
		self.contentView.addSubview(self.cardView)
		self.cardView.addSubview(self.mainStackView)

		self.mainStackView.addArrangedSubview(self.albumImageView)
		self.mainStackView.addArrangedSubview(self.titleLabel)
		self.mainStackView.addArrangedSubview(self.artistLabel)
		self.mainStackView.addArrangedSubview(self.spacerView)

		self.albumImageView.setContentCompressionResistancePriority(.required, for: .vertical)
		self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		self.artistLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		self.albumImageView.setContentHuggingPriority(.required, for: .vertical)
		self.titleLabel.setContentHuggingPriority(.required, for: .vertical)
		self.artistLabel.setContentHuggingPriority(.required, for: .vertical)

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.mainStackView.topAnchor.constraint(equalTo: self.cardView.topAnchor, constant: 8),
			self.mainStackView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 8),
			self.mainStackView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -8),
			self.mainStackView.bottomAnchor.constraint(equalTo: self.cardView.bottomAnchor, constant: -8),

			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor)
		])
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		self.albumImageView.setRemoteImage(track.imageURL, targetSize: self.albumImageView.bounds.size)
	}
}
