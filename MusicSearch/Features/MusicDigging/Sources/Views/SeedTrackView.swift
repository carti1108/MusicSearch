//
//  SeedTrackView.swift
//  MusicSearch
//
//  Created by Kiseok on 12/11/25.
//

import UIKit
import MSDomain

final class SeedTrackView: UIView {
	var onTap: (() -> Void)?

	private let containerView: UIView = {
		let view = UIView()
		view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
		view.layer.cornerRadius = 28
		view.layer.borderWidth = 1
		view.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOpacity = 0.24
		view.layer.shadowOffset = CGSize(width: 0, height: 20)
		view.layer.shadowRadius = 30
		view.layer.masksToBounds = false
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let contentStackView: UIStackView = {
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
		iv.backgroundColor = .systemGray5
		iv.clipsToBounds = true
		iv.layer.cornerRadius = 12
		iv.translatesAutoresizingMaskIntoConstraints = false
		return iv
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 24, weight: .heavy)
		label.textColor = .white
		label.textAlignment = .center
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let artistLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.textColor = .white.withAlphaComponent(0.8)
		label.textAlignment = .center
		label.numberOfLines = 1
		label.lineBreakMode = .byTruncatingTail
		label.translatesAutoresizingMaskIntoConstraints = false
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
		self.containerView.layer.shadowPath = UIBezierPath(
			roundedRect: self.containerView.bounds,
			cornerRadius: self.containerView.layer.cornerRadius
		).cgPath
	}

	private func setupUI() {
		self.addSubview(self.containerView)
		self.containerView.addSubview(self.contentStackView)

		self.contentStackView.addArrangedSubview(self.albumImageView)
		self.contentStackView.addArrangedSubview(self.titleLabel)
		self.contentStackView.addArrangedSubview(self.artistLabel)

		self.titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		self.artistLabel.setContentCompressionResistancePriority(.required, for: .vertical)

		self.albumImageView.setContentCompressionResistancePriority(.required, for: .vertical)
		self.albumImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)

		NSLayoutConstraint.activate([
			self.containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
			self.containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
			self.containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
			self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),

			self.contentStackView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 16),
			self.contentStackView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 16),
			self.contentStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -16),
			self.contentStackView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -16),

			self.albumImageView.heightAnchor.constraint(equalTo: self.albumImageView.widthAnchor)
		])
	}

	private func setupActions() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
		self.containerView.addGestureRecognizer(tapGesture)
		self.containerView.isUserInteractionEnabled = true
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
