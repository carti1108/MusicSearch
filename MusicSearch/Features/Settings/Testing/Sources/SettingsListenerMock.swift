import Foundation
import FeatureSettingsInterface

public final class SettingsListenerMock: SettingsListener {
    public var didCloseSettingsCallCount = 0
    
    public init() {}
    
    public func settingsDidTapClose() {
        didCloseSettingsCallCount += 1
    }
}
