//
//  TrackCardCell.swift
//  MusicSearch
//
//  Created by Kiseok on 12/8/25.
//

import UIKit
import Kingfisher

final class TrackCardCell: UICollectionViewCell, ReuseIdentifiable {

	private let cardBackgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = .white
		view.layer.cornerRadius = 24
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.2
		view.layer.shadowOffset = CGSize(width: 0, height: 8)
		view.layer.shadowRadius = 10
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
		stack.spacing = 6
		stack.alignment = .center
		stack.distribution = .fill
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .black
		label.textAlignment = .center
		label.numberOfLines = 1
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .darkGray
		label.textAlignment = .center
		label.numberOfLines = 1
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) { fatalError() }

	private func setupUI() {
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
			self.cardBackgroundView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10),

			self.mainStackView.topAnchor.constraint(equalTo: self.cardBackgroundView.topAnchor, constant: 20),
			self.mainStackView.leadingAnchor.constraint(equalTo: self.cardBackgroundView.leadingAnchor, constant: 16),
			self.mainStackView.trailingAnchor.constraint(equalTo: self.cardBackgroundView.trailingAnchor, constant: -16),
			self.mainStackView.bottomAnchor.constraint(equalTo: self.cardBackgroundView.bottomAnchor, constant: -20),

			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor)
		])
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		self.albumImageView.kf.cancelDownloadTask()
		self.albumImageView.image = nil
		self.titleLabel.text = nil
		self.artistLabel.text = nil
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		self.albumImageView.kf.cancelDownloadTask()
		self.albumImageView.image = nil

		if let url = track.imageURL {
			let placeholder = UIImage(systemName: "music.note")
			self.albumImageView.kf.setImage(
				with: url,
				placeholder: placeholder,
				options: [
					.transition(.fade(0.2)),
					.cacheOriginalImage
				]
			)
		} else {
			self.albumImageView.image = UIImage(systemName: "music.note")
		}
	}
}
