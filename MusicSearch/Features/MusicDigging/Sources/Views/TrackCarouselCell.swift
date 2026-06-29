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
	private let albumImageView: UIImageView = {
		let iv = UIImageView()
		iv.contentMode = .scaleAspectFill
		iv.backgroundColor = .systemGray5
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 16
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let gradientLayer: CAGradientLayer = {
		let layer = CAGradientLayer()
		layer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.85).cgColor]
		layer.locations = [0.4, 1.0]
		return layer
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
		label.font = .systemFont(ofSize: 16, weight: .black)
		label.textColor = .white
		label.textAlignment = .left
		label.numberOfLines = 2
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 13, weight: .semibold)
		label.textColor = UIColor.white.withAlphaComponent(0.8)
		label.textAlignment = .left
		label.numberOfLines = 1
		return label
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

	override func layoutSubviews() {
		super.layoutSubviews()
		self.gradientLayer.frame = self.albumImageView.bounds
	}

	private func setupUI() {
		self.contentView.addSubview(self.albumImageView)
		self.albumImageView.layer.addSublayer(self.gradientLayer)

		self.contentView.addSubview(self.textStackView)
		self.textStackView.addArrangedSubview(self.titleLabel)
		self.textStackView.addArrangedSubview(self.artistLabel)

		NSLayoutConstraint.activate([
			self.albumImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
			self.albumImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
			self.albumImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
			self.albumImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

			self.textStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
			self.textStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
			self.textStackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16)
		])
		
		// 넷플릭스 썸네일 느낌의 깊은 그림자 효과
		self.contentView.layer.shadowColor = UIColor.black.cgColor
		self.contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
		self.contentView.layer.shadowRadius = 10
		self.contentView.layer.shadowOpacity = 0.4
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		self.albumImageView.setRemoteImage(track.imageURL, targetSize: self.albumImageView.bounds.size)
	}
}
