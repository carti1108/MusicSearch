import Foundation
import Testing
@testable import FeatureAddArchive
import FeatureAddArchiveTesting
import MicroRIBs

@MainActor
struct AddArchiveRouterTests {

	@Test("Router 초기화 테스트")
	func routerInitialization() {
		// Given
		let interactor = AddArchiveInteractor(
			presenter: AddArchivePresentableSpy(),
			archiveRepository: MockArchiveRepositoryForBuilder()
		)
		let viewController = AddArchiveViewController()
		
		// When
		let router = AddArchiveRouter(
			interactor: interactor,
			viewController: viewController
		)

		// Then
		#expect(router != nil)
		#expect(router.children.isEmpty)
	}
}
