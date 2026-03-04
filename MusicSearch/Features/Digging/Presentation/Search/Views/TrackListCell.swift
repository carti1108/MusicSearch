//
//  TrackListCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/12/25.
//

import UIKit
import Kingfisher

final class TrackListCell: UICollectionViewCell, ReuseIdentifiable {
	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.layer.cornerRadius = 8
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
		label.font = .systemFont(ofSize: 16, weight: .semibold)
		label.textColor = .label
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .regular)
		label.textColor = .secondaryLabel
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	private func setupUI() {
		self.contentView.addSubview(self.albumImageView)
		self.contentView.addSubview(self.textStackView)
		self.textStackView.addArrangedSubview(self.titleLabel)
		self.textStackView.addArrangedSubview(self.artistLabel)

		NSLayoutConstraint.activate([
			self.albumImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
			self.albumImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			self.albumImageView.widthAnchor.constraint(equalToConstant: 60),
			self.albumImageView.heightAnchor.constraint(equalToConstant: 60),

			self.textStackView.leadingAnchor.constraint(equalTo: self.albumImageView.trailingAnchor, constant: 16),
			self.textStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20),
			self.textStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),

			self.contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
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
