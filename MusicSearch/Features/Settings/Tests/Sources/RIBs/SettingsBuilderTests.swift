import Foundation
import Testing
@testable import FeatureSettings
import FeatureSettingsTesting
import MSDomain

@MainActor
struct SettingsBuilderTests {

    @Test("build 시 listener와 presenter가 정상 연결되고 의존성이 주입되는가")
    func buildWiresListenerPresenterAndDependencies() {
        // Given
        let dependency = MockSettingsDependency(
            manageSpotifyAuthUseCase: MockManageSpotifyAuthUseCase(),
            fetchSpotifyProfileUseCase: MockFetchSpotifyProfileUseCase()
        )
        let builder = SettingsBuilder(dependency: dependency)
        let listener = SettingsListenerMock()

        // When
        let routing = builder.build(withListener: listener)

        // Then
        #expect(routing is SettingsRouter)
        guard let router = routing as? SettingsRouter else {
            Issue.record("Router 타입이 일치하지 않습니다.")
            return
        }
        guard let interactor = router.interactor as? SettingsInteractor else {
            Issue.record("Interactor가 조립되지 않았습니다.")
            return
        }
        guard let viewController = router.viewControllable as? SettingsViewController else {
            Issue.record("ViewController가 조립되지 않았습니다.")
            return
        }

        #expect(interactor.listener === listener)
        #expect(viewController.listener === interactor)
    }
}
