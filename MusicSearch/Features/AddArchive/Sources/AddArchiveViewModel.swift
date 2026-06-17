import Foundation
import Combine

@MainActor
public final class AddArchiveViewModel: ObservableObject {
    @Published public var availableGenres: [String] = []
    
    public init() {}
}
