//
//  TrackCarouselCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit
import Kingfisher

final class TrackCarouselCell: UICollectionViewCell, ReuseIdentifiable {

	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.backgroundColor = .systemGray5
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 8
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .bold)
		label.textColor = .white
		label.textAlignment = .left
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 12, weight: .medium)
		label.textColor = .white.withAlphaComponent(0.7)
		label.textAlignment = .left
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	private func setupUI() {
		self.contentView.addSubview(self.albumImageView)
		self.contentView.addSubview(self.titleLabel)
		self.contentView.addSubview(self.artistLabel)
		
		self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		self.artistLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		NSLayoutConstraint.activate([
			self.albumImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.albumImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.albumImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor),

			self.titleLabel.topAnchor.constraint(equalTo: self.albumImageView.bottomAnchor, constant: 8),
			self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),

			self.artistLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 4),
			self.artistLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.artistLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.artistLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor)
		])
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		if let url = track.imageURL {
			self.albumImageView.kf.setImage(with: url)
		} else {
			self.albumImageView.image = UIImage(systemName: "music.note")
		}
	}
}
