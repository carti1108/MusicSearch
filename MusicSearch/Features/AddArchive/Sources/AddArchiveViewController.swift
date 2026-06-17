import UIKit
import SwiftUI
import MicroRIBs
import ArchiveDomain
import PhotosUI
import MSDesignSystem

public protocol AddArchivePresentableListener: AnyObject {
	func closeTapped()
	func saveTapped(title: String, artist: String, genre: String, label: String, rating: Double, memo: String, releaseDate: Date?, listenDate: Date, coverImageData: Data?)
}

public final class AddArchiveViewController: UIViewController, AddArchivePresentable, AddArchiveViewControllable {

	public weak var listener: AddArchivePresentableListener?
	private let viewModel = AddArchiveViewModel()

	private lazy var hostingController: UIHostingController<AddArchiveView> = {
		let view = AddArchiveView(
			viewModel: viewModel,
			onClose: { [weak self] in
				self?.listener?.closeTapped()
			},
			onSave: { [weak self] title, artist, genre, label, rating, memo, releaseDate, listenDate, coverImageData in
				self?.listener?.saveTapped(title: title, artist: artist, genre: genre, label: label, rating: rating, memo: memo, releaseDate: releaseDate, listenDate: listenDate, coverImageData: coverImageData)
			}
		)
		let controller = UIHostingController(rootView: view)
		controller.view.backgroundColor = .clear
		return controller
	}()

	public init() {
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func update(genres: [String]) {
		viewModel.availableGenres = genres
	}

	
	public override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		if isBeingDismissed {
			listener?.closeTapped()
		}
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = UIColor(CustomColor.background)
		setupSwiftUIView()
	}

	private func setupSwiftUIView() {
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

public struct AddArchiveView: View {
	@ObservedObject var viewModel: AddArchiveViewModel
	var onClose: () -> Void
	var onSave: (String, String, String, String, Double, String, Date?, Date, Data?) -> Void

	@State private var title: String = ""
	@State private var artist: String = ""
	@State private var genre: String = ""
	@State private var label: String = ""
	@State private var rating: Double = 3.0
	@State private var memo: String = ""
	
	@State private var releaseDate: Date = Date()
	@State private var hasReleaseDate: Bool = false
	@State private var listenDate: Date = Date()
	
	@State private var coverItem: PhotosPickerItem?
	@State private var coverImageData: Data?
	
	@State private var isGenreExpanded: Bool = false

	public var body: some View {
		NavigationView {
			Form {
				// Cover Image Section
				Section {
					HStack {
						Spacer()
						PhotosPicker(selection: $coverItem, matching: .images) {
							if let data = coverImageData, let uiImage = UIImage(data: data) {
								Image(uiImage: uiImage)
									.resizable()
									.scaledToFill()
									.frame(width: 160, height: 160)
									.clipShape(RoundedRectangle(cornerRadius: CustomRadius.md))
									.shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
							} else {
								VStack(spacing: 8) {
									Image(systemName: "photo.badge.plus")
										.font(.system(size: 40))
									Text("커버 이미지 추가")
										.customText(.labelSm)
								}
								.foregroundColor(CustomColor.outline)
								.frame(width: 160, height: 160)
								.background(CustomColor.surfaceContainerLow)
								.clipShape(RoundedRectangle(cornerRadius: CustomRadius.md))
							}
						}
						.onChange(of: coverItem) {
							Task {
								if let data = try? await coverItem?.loadTransferable(type: Data.self) {
									await MainActor.run { coverImageData = data }
								}
							}
						}
						Spacer()
					}
					.padding(.vertical, 16)
					.listRowBackground(Color.clear)
				}
				
				// Track Info Section
				Section(header: Text("기본 정보")) {
					TextField("노래 제목", text: $title)
					TextField("아티스트", text: $artist)
					
					DisclosureGroup("장르 (선택: \(genre.isEmpty ? "없음" : genre))", isExpanded: $isGenreExpanded) {
						TextField("장르 직접 입력", text: $genre)
						ForEach(viewModel.availableGenres, id: \.self) { genreName in
							Button(action: {
								self.genre = genreName
								isGenreExpanded = false
							}) {
								HStack {
									Text(genreName)
									Spacer()
									if self.genre == genreName {
										Image(systemName: "checkmark")
											.foregroundColor(CustomColor.primary)
									}
								}
							}
							.foregroundColor(CustomColor.onSurface)
						}
					}
					
					TextField("발매사/레이블", text: $label)
				}
				
				// Dates Section
				Section(header: Text("날짜")) {
					Toggle("발매일 입력", isOn: $hasReleaseDate)
					if hasReleaseDate {
						DatePicker("발매일", selection: $releaseDate, displayedComponents: .date)
					}
					DatePicker("청취일", selection: $listenDate, displayedComponents: .date)
				}
				
				// Rating Section
				Section(header: Text("나의 평점: \(String(format: "%.1f", rating))")) {
					Slider(value: $rating, in: 0...5, step: 0.5)
						.tint(CustomColor.tertiary)
				}
				
				// Memo Section
				Section(header: Text("메모")) {
					TextEditor(text: $memo)
						.frame(height: 100)
				}
			}
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("취소", action: onClose)
						.foregroundColor(CustomColor.onSurface)
				}
				ToolbarItem(placement: .principal) {
					Text("새 기록 추가")
						.font(.headline)
						.foregroundColor(CustomColor.onBackground)
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("저장") {
						onSave(title, artist, genre, label, rating, memo, hasReleaseDate ? releaseDate : nil, listenDate, coverImageData)
					}
					.fontWeight(.bold)
					.foregroundColor(title.isEmpty || artist.isEmpty ? CustomColor.outline : CustomColor.primary)
					.disabled(title.isEmpty || artist.isEmpty)
				}
			}
		}
		.preferredColorScheme(.dark)
	}
}