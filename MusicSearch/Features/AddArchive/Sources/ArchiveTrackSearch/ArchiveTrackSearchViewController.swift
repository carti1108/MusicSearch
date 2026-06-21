import UIKit
import SwiftUI
import Combine
import MSDomain
import MSDesignSystem
import TrackSearchDomain

public final class ArchiveTrackSearchViewController: UIViewController {
    private let searchTracksUseCase: SearchTracksUseCase
    private let onSelect: (Track) -> Void
    private let viewModel: ArchiveTrackSearchViewModel
    
    private lazy var hostingController: UIHostingController<ArchiveTrackSearchView> = {
        let view = ArchiveTrackSearchView(
            viewModel: viewModel,
            onClose: { [weak self] in
                self?.dismiss(animated: true)
            },
            onSelect: { [weak self] track in
                self?.onSelect(track)
                self?.dismiss(animated: true)
            }
        )
        let controller = UIHostingController(rootView: view)
        controller.view.backgroundColor = .clear
        return controller
    }()
    
    public init(searchTracksUseCase: SearchTracksUseCase, onSelect: @escaping (Track) -> Void) {
        self.searchTracksUseCase = searchTracksUseCase
        self.onSelect = onSelect
        self.viewModel = ArchiveTrackSearchViewModel(searchTracksUseCase: searchTracksUseCase)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(CustomColor.background)
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

@MainActor
final class ArchiveTrackSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Track] = []
    @Published var isLoading: Bool = false
    
    private let searchTracksUseCase: SearchTracksUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(searchTracksUseCase: SearchTracksUseCase) {
        self.searchTracksUseCase = searchTracksUseCase
        
        $query
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newQuery in
                self?.search(query: newQuery)
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }
        
        isLoading = true
        Task {
            do {
                let response = try await searchTracksUseCase.execute(query: query, limit: 20, page: 1)
                await MainActor.run {
                    self.results = response.tracks
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Search failed: \(error)")
                }
            }
        }
    }
}

struct ArchiveTrackSearchView: View {
    @ObservedObject var viewModel: ArchiveTrackSearchViewModel
    var onClose: () -> Void
    var onSelect: (Track) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(CustomColor.outline)
                    TextField("곡 제목, 아티스트 검색", text: $viewModel.query)
                        .foregroundColor(CustomColor.onBackground)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !viewModel.query.isEmpty {
                        Button(action: {
                            viewModel.query = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(CustomColor.outline)
                        }
                    }
                }
                .padding(10)
                .background(CustomColor.surfaceContainer)
                .cornerRadius(10)
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                    Spacer()
                } else if viewModel.results.isEmpty && !viewModel.query.isEmpty {
                    Text("검색 결과가 없습니다.")
                        .foregroundColor(CustomColor.outline)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.results, id: \.id) { track in
                            Button(action: {
                                onSelect(track)
                            }) {
                                HStack(spacing: 12) {
                                    if let url = track.imageURL {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                Rectangle().fill(CustomColor.surfaceContainerHigh)
                                            case .success(let image):
                                                image.resizable().aspectRatio(contentMode: .fill)
                                            case .failure:
                                                Rectangle().fill(CustomColor.surfaceContainerHigh)
                                            @unknown default:
                                                Rectangle().fill(CustomColor.surfaceContainerHigh)
                                            }
                                        }
                                        .frame(width: 48, height: 48)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    } else {
                                        Rectangle()
                                            .fill(CustomColor.surfaceContainerHigh)
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(track.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(CustomColor.onBackground)
                                            .lineLimit(1)
                                        Text(track.artist)
                                            .font(.system(size: 14))
                                            .foregroundColor(CustomColor.outline)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(CustomColor.background.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("곡 검색", displayMode: .inline)
            .navigationBarItems(leading: Button("취소", action: onClose))
        }
        .preferredColorScheme(.dark)
    }
}
