import Foundation
import MicroRIBs
import FeatureAddArchiveInterface
import ArchiveDomain
import TrackSearchDomain

final class AddArchiveComponent: Component<AddArchiveDependency> {
    fileprivate var archiveRepository: ArchiveRepository {
        return dependency.archiveRepository
    }
    fileprivate var searchTracksUseCase: SearchTracksUseCase {
        return SpotifySearchTracksUseCaseImpl(spotifyRepository: dependency.musicAppRepository)
    }
}

public final class AddArchiveBuilder: Builder<AddArchiveDependency>, AddArchiveBuildable {
	public override init(dependency: AddArchiveDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: AddArchiveListener) -> AddArchiveRouting {
		let component = AddArchiveComponent(dependency: dependency)
		let viewController = AddArchiveViewController()
		let interactor = AddArchiveInteractor(presenter: viewController, archiveRepository: component.archiveRepository, searchTracksUseCase: component.searchTracksUseCase)
		interactor.listener = listener

		return AddArchiveRouter(interactor: interactor, viewController: viewController)
	}
}
