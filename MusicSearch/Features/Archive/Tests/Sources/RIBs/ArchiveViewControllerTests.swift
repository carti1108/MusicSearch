import Foundation
import Testing
import UIKit
@testable import FeatureArchive
import ArchiveDomain

@MainActor
private final class ArchiveListenerSpy: ArchivePresentableListener {
    // Add methods if needed
}

@MainActor
struct ArchiveViewControllerTests {
    
    @Test("ViewController 초기화 및 ViewDidLoad 시 UI 구성이 정상 동작하는가")
    func viewDidLoadSetsUpUI() {
        // Given
        let viewModel = ArchiveViewModel()
        let viewController = ArchiveViewController(viewModel: viewModel)
        let listener = ArchiveListenerSpy()
        viewController.listener = listener
        
        // When
        viewController.loadViewIfNeeded()
        
        // Then
        #expect(viewController.navigationItem.title == "나의 보관함")
        #expect(viewController.tabBarItem.title == "Archive")
        #expect(viewController.listener === listener)
    }
}
