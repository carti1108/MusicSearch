import Foundation
import Combine
import MSDomain

@MainActor
public final class AddArchiveViewModel: ObservableObject {
    @Published public var availableGenres: [String] = []
    @Published public var selectedTrack: Track? = nil
    
    public init() {}
}
