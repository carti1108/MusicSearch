import Foundation
import Testing
@testable import FeatureArchive
import FeatureArchiveTesting
import MicroRIBs

@MainActor
struct ArchiveRouterTests {

	@Test("routeToAddArchive 호출 시 AddArchiveBuilder를 통해 라우팅하는가")
	func routeToAddArchiveAttachesChild() {
		// Given
		let interactor = ArchiveInteractor(
			presenter: ArchivePresentableSpy(),
			archiveRepository: MockArchiveRepository()
		)
		let viewController = ArchiveViewController()
		let builder = MockAddArchiveBuildable()
		let router = ArchiveRouter(
			interactor: interactor,
			viewController: viewController,
			addArchiveBuilder: builder
		)

		// When
		router.routeToAddArchive()

		// Then
		#expect(builder.buildCallCount == 1)
		#expect(router.children.count == 1)
	}

	@Test("detachAddArchive 호출 시 자식 라우터를 분리하는가")
	func detachAddArchiveDetachesChild() {
		// Given
		let interactor = ArchiveInteractor(
			presenter: ArchivePresentableSpy(),
			archiveRepository: MockArchiveRepository()
		)
		let viewController = ArchiveViewController()
		let builder = MockAddArchiveBuildable()
		let router = ArchiveRouter(
			interactor: interactor,
			viewController: viewController,
			addArchiveBuilder: builder
		)
		router.routeToAddArchive() // Attach first
		#expect(router.children.count == 1)

		// When
		router.detachAddArchive()

		// Then
		#expect(router.children.count == 0)
	}
}

final class MockAddArchiveBuildable: AddArchiveBuildable {
	var buildCallCount = 0
	func build(withListener listener: AddArchiveListener) -> ViewableRouting {
		buildCallCount += 1
		return MockViewableRouting(interactable: MockInteractable(), viewControllable: MockViewControllable())
	}
}

final class MockViewableRouting: ViewableRouting {
	var viewControllable: ViewControllable
	var interactable: Interactable
	var children: [Routing] = []
	var lifecycle: MicroRIBs.Observable<RouterLifecycle> {
		get { fatalError() }
	}

	init(interactable: Interactable, viewControllable: ViewControllable) {
		self.interactable = interactable
		self.viewControllable = viewControllable
	}

	func load() {}
	func attachChild(_ child: Routing) {}
	func detachChild(_ child: Routing) {}
}

final class MockInteractable: Interactable {
	var isActive: Bool = true
	var isActiveStream: MicroRIBs.Observable<Bool> { get { fatalError() } }
	func activate() {}
	func deactivate() {}
}

final class MockViewControllable: ViewControllable {
	var uiviewController: UIKit.UIViewController = UIKit.UIViewController()
}
