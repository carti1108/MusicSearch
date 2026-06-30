//
//  SeedTrackView.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit
import MSDesignSystem
import MSDomain

final class SeedTrackView: UIView {
	var onTap: (() -> Void)?

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
		label.font = .systemFont(ofSize: 18, weight: .heavy)
		label.textColor = .white
		label.textAlignment = .left
		label.numberOfLines = 2
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 14, weight: .medium)
		label.textColor = .white.withAlphaComponent(0.8)
		label.textAlignment = .left
		label.numberOfLines = 1
		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupUI()
		self.setupActions()
	}

	required init?(coder: NSCoder) { fatalError() }

	override func layoutSubviews() {
		super.layoutSubviews()
		self.gradientLayer.frame = self.albumImageView.bounds
	}

	private func setupUI() {
		self.addSubview(self.albumImageView)
		self.albumImageView.layer.addSublayer(self.gradientLayer)

		self.addSubview(self.textStackView)
		self.textStackView.addArrangedSubview(self.titleLabel)
		self.textStackView.addArrangedSubview(self.artistLabel)

		NSLayoutConstraint.activate([
			self.albumImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
			self.albumImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 60),
			self.albumImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -60),
			self.albumImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor),

			self.textStackView.leadingAnchor.constraint(equalTo: self.albumImageView.leadingAnchor, constant: 16),
			self.textStackView.trailingAnchor.constraint(equalTo: self.albumImageView.trailingAnchor, constant: -16),
			self.textStackView.bottomAnchor.constraint(equalTo: self.albumImageView.bottomAnchor, constant: -16)
		])

		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: 6)
		self.layer.shadowRadius = 10
		self.layer.shadowOpacity = 0.4
	}

	private func setupActions() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.addGestureRecognizer(tapGesture)
		self.isUserInteractionEnabled = true
	}

	@objc
	private func handleTap() {
		self.onTap?()
	}

	func configure(with track: Track) {
		self.titleLabel.text = track.title
		self.artistLabel.text = track.artist

		self.albumImageView.setRemoteImage(track.imageURL, targetSize: self.albumImageView.bounds.size)
	}
}
