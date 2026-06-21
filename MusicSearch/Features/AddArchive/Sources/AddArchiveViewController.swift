import UIKit
import SwiftUI
import MicroRIBs
import ArchiveDomain
import PhotosUI
import MSDesignSystem
import MSDomain

public protocol AddArchivePresentableListener: AnyObject {
	func closeTapped()
	func searchTapped()
	func saveTapped(title: String, artist: String, genre: String, label: String, rating: Double, memo: String, releaseDate: Date?, listenDate: Date, coverImageData: Data?, albumTitle: String, distributor: String, albumType: String, isIntroGood: Bool, isGoodUntilMiddle: Bool, isGoodUntilEnd: Bool, platformIDs: [String: String])
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
			onSearch: { [weak self] in
				self?.listener?.searchTapped()
			},
			onSave: { [weak self] title, artist, genre, label, rating, memo, releaseDate, listenDate, coverImageData, albumTitle, distributor, albumType, isIntroGood, isGoodUntilMiddle, isGoodUntilEnd, platformIDs in
				self?.listener?.saveTapped(title: title, artist: artist, genre: genre, label: label, rating: rating, memo: memo, releaseDate: releaseDate, listenDate: listenDate, coverImageData: coverImageData, albumTitle: albumTitle, distributor: distributor, albumType: albumType, isIntroGood: isIntroGood, isGoodUntilMiddle: isGoodUntilMiddle, isGoodUntilEnd: isGoodUntilEnd, platformIDs: platformIDs)
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
	
	public func populate(with track: Track) {
		viewModel.selectedTrack = track
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
	var onSearch: () -> Void
	var onSave: (String, String, String, String, Double, String, Date?, Date, Data?, String, String, String, Bool, Bool, Bool, [String: String]) -> Void

	@State private var title: String = ""
	@State private var artist: String = ""
	@State private var genre: String = ""
	@State private var label: String = ""
	@State private var albumTitle: String = ""
	@State private var distributor: String = ""
	@State private var albumType: String = "정규"
	@State private var isIntroGood: Bool = false
	@State private var isGoodUntilMiddle: Bool = false
	@State private var isGoodUntilEnd: Bool = false
	@State private var rating: Double = 3.0
	@State private var memo: String = ""
	
	@State private var releaseDate: Date = Date()
	@State private var hasReleaseDate: Bool = false
	@State private var listenDate: Date = Date()
	
	@State private var coverItem: PhotosPickerItem?
	@State private var coverImageData: Data?
	
	@State private var isGenreExpanded: Bool = false
	@State private var platformIDs: [String: String] = [:]

	public var body: some View {
		NavigationView {
			Form {
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
				
				Section(header: Text("기본 정보")) {
					Button(action: onSearch) {
						HStack {
							Image(systemName: "magnifyingglass")
							Text("노래 검색하여 자동 입력하기")
						}
						.foregroundColor(CustomColor.primary)
						.padding(.vertical, 4)
					}
					
					TextField("노래 제목", text: $title)
					TextField("아티스트", text: $artist)
					TextField("앨범명", text: $albumTitle)
					
					Picker("앨범 유형", selection: $albumType) {
						Text("정규").tag("정규")
						Text("싱글").tag("싱글")
						Text("EP").tag("EP")
						Text("기타").tag("기타")
					}
					
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
					
					TextField("유통사", text: $distributor)
					TextField("레이블", text: $label)
				}
				
				Section(header: Text("곡 전개 평가")) {
					Toggle("인트로가 좋았는가", isOn: $isIntroGood)
					Toggle("중반부까지 좋았는가", isOn: $isGoodUntilMiddle)
					Toggle("끝까지 좋았는가", isOn: $isGoodUntilEnd)
				}
				
				Section(header: Text("날짜")) {
					Toggle("발매일 입력", isOn: $hasReleaseDate)
					if hasReleaseDate {
						DatePicker("발매일", selection: $releaseDate, displayedComponents: .date)
					}
					DatePicker("청취일", selection: $listenDate, displayedComponents: .date)
				}
				
				Section(header: Text("나의 평점: \(String(format: "%.1f", rating))")) {
					Slider(value: $rating, in: 0...5, step: 0.5)
						.tint(CustomColor.tertiary)
				}
				
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
						onSave(title, artist, genre, label, rating, memo, hasReleaseDate ? releaseDate : nil, listenDate, coverImageData, albumTitle, distributor, albumType, isIntroGood, isGoodUntilMiddle, isGoodUntilEnd, platformIDs)
					}
					.fontWeight(.bold)
					.foregroundColor(title.isEmpty || artist.isEmpty ? CustomColor.outline : CustomColor.primary)
					.disabled(title.isEmpty || artist.isEmpty)
				}
			}
			.onReceive(viewModel.$selectedTrack) { track in
				guard let track = track else { return }
				self.title = track.title
				self.artist = track.artist
				self.albumTitle = track.albumTitle ?? ""
				
				if let type = track.albumType {
					if type.lowercased() == "single" {
						self.albumType = "싱글"
					} else if type.lowercased() == "ep" || type.lowercased() == "ep/single" {
						self.albumType = "EP"
					} else {
						self.albumType = "정규"
					}
				}
				
				if let date = track.releaseDate {
					self.hasReleaseDate = true
					self.releaseDate = date
				}
				
				self.platformIDs["spotify"] = track.id
				
				if let imageURL = track.imageURL {
					Task {
						do {
							let (data, _) = try await URLSession.shared.data(from: imageURL)
							await MainActor.run {
								self.coverImageData = data
							}
						} catch {
							print("Image load error: \(error)")
						}
					}
				}
			}
		}
		.preferredColorScheme(.dark)
	}
}
