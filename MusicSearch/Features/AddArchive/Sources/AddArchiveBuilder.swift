import Foundation
import MicroRIBs
import FeatureAddArchiveInterface
import ArchiveDomain

public final class AddArchiveBuilder: Builder<AddArchiveDependency>, AddArchiveBuildable {
	public override init(dependency: AddArchiveDependency) {
		super.init(dependency: dependency)
	}

	public func build(withListener listener: AddArchiveListener) -> AddArchiveRouting {
		let component = AddArchiveComponent(dependency: dependency)
		let viewController = AddArchiveViewController()
		let interactor = AddArchiveInteractor(presenter: viewController, archiveRepository: dependency.archiveRepository)
		interactor.listener = listener

		return AddArchiveRouter(interactor: interactor, viewController: viewController)
	}
}

final class AddArchiveComponent: Component<AddArchiveDependency> {
}
