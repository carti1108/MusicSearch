//
//  LoadingPresentable.swift
//  MusicSearch
//
//  Created by Kiseok on 2/22/26.
//

import UIKit

@MainActor
public protocol LoadingPresentable: AnyObject {
	var loadingIndicatorView: UIActivityIndicatorView { get }
}

@MainActor
extension LoadingPresentable {
	public func setLoading(_ isLoading: Bool) {
		if isLoading {
			self.loadingIndicatorView.startAnimating()
		} else {
			self.loadingIndicatorView.stopAnimating()
		}
	}
}
