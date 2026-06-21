import MicroRIBs
import FeatureArchiveInterface
import FeatureAddArchiveInterface
import ArchiveDomain
import SwiftUI
import UIKit
import FeatureArchiveSearchInterface
import FeatureArchiveFolderInterface
import FeatureArchiveFolderDetailInterface


public final class ArchiveBuilder: Builder<ArchiveDependency>, ArchiveBuildable {

	public override init(dependency: ArchiveDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: ArchiveListener) -> ArchiveRouting {
		let component = ArchiveComponent(dependency: dependency)
		
		let state = ArchiveViewState(
			totalTracksCount: 0,
			topGenreName: "",
			recentTracks: []
		)
		let viewModel = ArchiveViewModel(state: state)
		let viewController = ArchiveViewController(viewModel: viewModel)
		let interactor = ArchiveInteractor(presenter: viewController, viewModel: viewModel, archiveRepository: component.archiveRepository)
		interactor.listener = listener
		
		return ArchiveRouter(
			interactor: interactor,
			viewController: viewController,
			addArchiveBuilder: component.dependency.addArchiveBuilder,
			archiveSearchBuilder: component.dependency.archiveSearchBuilder,
			archiveFolderBuilder: component.dependency.archiveFolderBuilder
		)
	}
}

final class ArchiveComponent: Component<ArchiveDependency>, ArchiveDependency {
	var archiveRepository: ArchiveRepository {
		dependency.archiveRepository
	}

	var addArchiveBuilder: AddArchiveBuildable {
		dependency.addArchiveBuilder
	}
	
	var archiveSearchBuilder: ArchiveSearchBuildable {
		dependency.archiveSearchBuilder
	}
	
	var archiveFolderBuilder: ArchiveFolderBuildable {
        dependency.archiveFolderBuilder
    }
    
    var archiveFolderDetailBuilder: ArchiveFolderDetailBuildable {
        dependency.archiveFolderDetailBuilder
    }
	


}
