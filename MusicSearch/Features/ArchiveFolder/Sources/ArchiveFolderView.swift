import SwiftUI
import MSDesignSystem

public struct FolderItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String
}

public final class ArchiveFolderViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var customFolders: [FolderItem] = []
    @Published var yearFolders: [FolderItem] = []
    @Published var genreFolders: [FolderItem] = []
    @Published var ratingFolders: [FolderItem] = []
    
    public init() {}
    
    func addCustomFolder() {
        // Handle adding custom folder
    }
}

public struct ArchiveFolderView: View {
    @ObservedObject var viewModel: ArchiveFolderViewModel
    
    public init(viewModel: ArchiveFolderViewModel) {
        self.viewModel = viewModel
    }
    
    private var currentFolders: [FolderItem] {
        switch viewModel.selectedTab {
        case 0: return viewModel.customFolders
        case 1: return viewModel.yearFolders
        case 2: return viewModel.genreFolders
        case 3: return viewModel.ratingFolders
        default: return []
        }
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                CustomColor.background.ignoresSafeArea()
                VStack(spacing: 0) {
                    Picker("Folders", selection: $viewModel.selectedTab) {
                        Text("내 폴더").tag(0)
                        Text("연도별").tag(1)
                        Text("장르별").tag(2)
                        Text("별점별").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, CustomSpacing.containerMargin)
                    .padding(.top, CustomSpacing.base)
                    .padding(.bottom, CustomSpacing.containerMargin)
                    
                    ScrollView {
                        if currentFolders.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "folder")
                                    .font(.system(size: 40))
                                    .foregroundColor(CustomColor.outline)
                                Text("폴더가 없습니다.")
                                    .customText(.bodyMd)
                                    .foregroundColor(CustomColor.outline)
                            }
                            .padding(.top, 100)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: CustomSpacing.gutter) {
                                ForEach(currentFolders) { folder in
                                    FolderTile(title: folder.title, subtitle: folder.subtitle)
                                }
                            }
                            .padding(.horizontal, CustomSpacing.containerMargin)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.selectedTab == 0 {
                        Button(action: viewModel.addCustomFolder) {
                            Image(systemName: "plus")
                                .foregroundColor(CustomColor.primary)
                        }
                    }
                }
            }
        }
    }
}

struct FolderTile: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: CustomSpacing.base) {
            Rectangle()
                .fill(CustomColor.surfaceContainerLow)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(CustomRadius.md)
                .overlay(
                    Image(systemName: "folder.fill")
                        .font(.system(size: 32))
                        .foregroundColor(CustomColor.surfaceContainerHigh)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customText(.bodyMd)
                    .foregroundColor(CustomColor.onSurface)
                Text(subtitle)
                    .customText(.labelSm)
                    .foregroundColor(CustomColor.outline)
            }
        }
    }
}
