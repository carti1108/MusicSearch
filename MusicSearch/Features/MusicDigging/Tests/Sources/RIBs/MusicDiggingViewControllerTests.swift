import Foundation
import Testing
import UIKit
@testable import FeatureMusicDigging
import FeatureMusicDiggingTesting
import MusicDiggingDomain

@MainActor
private final class MusicDiggingListenerSpy: MusicDiggingPresentableListener {
    var viewDidAppearCallCount = 0
    var didTapSeedTrackCallCount = 0
    var didSelectRecommendationCallCount = 0
    var lastSelectedIndexPath: IndexPath?
    var didTapRetryCallCount = 0
    
    func viewDidAppear() {
        viewDidAppearCallCount += 1
    }
    func didTapSeedTrack() {
        didTapSeedTrackCallCount += 1
    }
    func didSelectRecommendation(at indexPath: IndexPath) {
        didSelectRecommendationCallCount += 1
        lastSelectedIndexPath = indexPath
    }
    func didTapRetry() {
        didTapRetryCallCount += 1
    }
}

@MainActor
struct MusicDiggingViewControllerTests {
    
    @Test("viewDidAppear 호출 시 listener의 viewDidAppear를 호출하는가")
    func viewDidAppearNotifiesListener() {
        // Given
        let viewController = MusicDiggingViewController()
        let listener = MusicDiggingListenerSpy()
        viewController.listener = listener
        
        viewController.loadViewIfNeeded()
        
        // When
        viewController.viewDidAppear(false)
        
        // Then
        #expect(listener.viewDidAppearCallCount == 1)
    }

    @Test("showLoading 시 로딩 인디케이터와 컬렉션 뷰 상태가 변경되는가")
    func showLoadingUpdatesUI() throws {
        // Given
        let viewController = MusicDiggingViewController()
        viewController.loadViewIfNeeded()
        
        // When
        viewController.showLoading(true)
        
        // Then
        #expect(viewController.loadingIndicatorView.isAnimating == true)
        
        // When
        viewController.showLoading(false)
        
        // Then
        #expect(viewController.loadingIndicatorView.isAnimating == false)
    }

    @Test("didSelectItemAt 호출 시 listener에 선택된 IndexPath를 전달하는가")
    func didSelectItemAtNotifiesListener() throws {
        // Given
        let viewController = MusicDiggingViewController()
        let listener = MusicDiggingListenerSpy()
        viewController.listener = listener
        viewController.loadViewIfNeeded()
        
        let track = Track(id: "1", title: "Test", artist: "Artist", imageURL: nil, previewURL: nil, externalURL: nil)
        viewController.updateRecommendations([track])
        
        let collectionView = try #require(viewController.view.findSubview(ofType: UICollectionView.self))
        let indexPath = IndexPath(item: 0, section: 0)
        
        // When
        viewController.collectionView(collectionView, didSelectItemAt: indexPath)
        
        // Then
        #expect(listener.didSelectRecommendationCallCount == 1)
        #expect(listener.lastSelectedIndexPath == indexPath)
    }
}
