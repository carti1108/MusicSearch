//
//  UIImageView+RemoteImage.swift
//  MusicSearch
//
//  Created by Codex on 5/10/26.
//

import UIKit
import Kingfisher

public extension UIImageView {
	func setRemoteImage(
		_ url: URL?,
		targetSize: CGSize,
		transitionDuration: TimeInterval = 0.2
	) {
		self.kf.cancelDownloadTask()
		self.contentMode = .scaleAspectFill
		self.image = nil

		guard let url else { return }

		let fallbackSize = CGSize(width: 300, height: 300)
		let resolvedSize = targetSize == .zero ? fallbackSize : targetSize
		let processor = DownsamplingImageProcessor(size: resolvedSize)

		self.kf.setImage(
			with: url,
			placeholder: nil,
			options: [
				.processor(processor),
				.scaleFactor(UIScreen.main.scale),
				.backgroundDecode,
				.transition(.fade(transitionDuration))
			]
		)
	}
}
