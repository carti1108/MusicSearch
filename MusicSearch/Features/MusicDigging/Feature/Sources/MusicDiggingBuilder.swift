//
//  MusicDiggingBuilder.swift
//  MusicSearch
//
//  Created by Kiseok on 3/4/26.
//

import MicroRIBs
import MSDomain
import MSUtil
import FeatureMusicDiggingInterface





@MainActor
public final class MusicDiggingBuilder: Builder<MusicDiggingDependency>, MusicDiggingBuildable {
	public override init(dependency: MusicDiggingDependency) {
		super.init(dependency: dependency)
	}
	
	public func build(
		withListener listener: MusicDiggingListener,
		seedTrack: Track
	) -> MusicDiggingRouting {
		let viewController = MusicDiggingViewController()
		let interactor = MusicDiggingInteractor(
			seedTrack: seedTrack,
			presenter: viewController,
			fetchSimilarTracksUseCase: self.dependency.fetchSimilarTracksUseCase,
			fetchMusicAppDeepLinkUseCase: self.dependency.fetchMusicAppDeepLinkUseCase,
			urlOpener: self.dependency.urlOpener
		)
		interactor.listener = listener
		return MusicDiggingRouter(interactor: interactor, viewController: viewController)
	}
}
