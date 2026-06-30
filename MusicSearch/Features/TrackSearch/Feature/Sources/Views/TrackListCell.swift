//
//  TrackListCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/12/25.
//

import UIKit
import MSDesignSystem
import MSDomain
import MSUtil

final class TrackListCell: UICollectionViewCell, ReuseIdentifiable {
	private let cardView: UIView = {
		let view = UIView()
		view.backgroundColor = .clear
		view.layer.cornerRadius = 16
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 12
		iv.layer.masksToBounds = true
		iv.backgroundColor = .systemGray5
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let textStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 4
		stack.alignment = .leading
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 17, weight: .bold)
		label.textColor = UIColor(CustomColor.onSurface)
		label.numberOfLines = 0
		
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = UIColor(CustomColor.onSurfaceVariant)
		label.numberOfLines = 0
		
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	private func setupUI() {
		self.contentView.backgroundColor = .clear
		self.contentView.addSubview(self.cardView)
		self.cardView.addSubview(self.albumImageView)
		self.cardView.addSubview(self.textStackView)
		self.textStackView.addArrangedSubview(self.titleLabel)
		self.textStackView.addArrangedSubview(self.artistLabel)

		NSLayoutConstraint.activate([
			self.cardView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 6),
			self.cardView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.cardView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.cardView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -6),

			self.albumImageView.leadingAnchor.constraint(equalTo: self.cardView.leadingAnchor, constant: 16),
			self.albumImageView.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),
			self.albumImageView.widthAnchor.constraint(equalToConstant: 60),
			self.albumImageView.heightAnchor.constraint(equalToConstant: 60),

			self.textStackView.leadingAnchor.constraint(equalTo: self.albumImageView.trailingAnchor, constant: 16),
			self.textStackView.trailingAnchor.constraint(equalTo: self.cardView.trailingAnchor, constant: -20),
			self.textStackView.centerYAnchor.constraint(equalTo: self.cardView.centerYAnchor),

			self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
		])
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.albumImageView.setRemoteImage(nil, targetSize: .zero)
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		let urlToLoad = track.thumbnailURL ?? track.imageURL
		self.albumImageView.setRemoteImage(urlToLoad, targetSize: CGSize(width: 60, height: 60))
	}
}
