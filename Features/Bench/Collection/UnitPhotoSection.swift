import PhotosUI
import TabletomeHobbyData
import TabletomeDomain
import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

/// Photo gallery and import for a single unit.
@MainActor
struct UnitPhotoSection: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(BannerCenter.self) private var banner

    @Bindable var unit: ArmyUnit
    let pipeline: [PipelineStage]

    @State private var pickerItem: PhotosPickerItem?
    @State private var photoToDelete: ModelPhoto?
    @State private var showPhotoViewer = false

    private var addPhotoLabel: String {
        unit.photos.isEmpty
            ? String(localized: "Add Photo")
            : String(localized: "Add Another Photo")
    }

    private var heroPhoto: ModelPhoto? {
        unit.orderedPhotos.first
    }

    var body: some View {
        let pickerLabel = addPhotoLabel
        Group {
            photoHeader
            Section {
                if !unit.photos.isEmpty {
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(pickerLabel, systemImage: "camera")
                    }
                    .accessibilityIdentifier("unitAddPhoto")
                    .accessibilityLabel(pickerLabel)
                    .accessibilityHint(String(localized: "Adds a photo from your library to this unit."))
                }

                if unit.orderedPhotos.count > 1 {
                    ForEach(Array(unit.orderedPhotos.dropFirst())) { photo in
                        photoRow(photo)
                    }
                }
            } header: {
                if !unit.photos.isEmpty {
                    Text(String(localized: "Photos"))
                }
            } footer: {
                if unit.photos.isEmpty {
                    Text(
                        String(
                            localized: """
                            Snap progress shots as you paint — they're stored on this device and tagged to your \
                            current stage.
                            """
                        )
                    )
                } else {
                    Text(
                        String(
                            localized: """
                            Photos are stored on this device. Tag stages automatically from your current painting state.
                            """
                        )
                    )
                }
            }
            .listRowBackground(TTColor.surface)
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await importPhoto(from: item) }
        }
        .confirmationDialog(
            String(localized: "Remove this photo?"),
            isPresented: .init(
                get: { photoToDelete != nil },
                set: { if !$0 { photoToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Remove"), role: .destructive) {
                if let photo = photoToDelete {
                    PhotoStore.delete(photo, in: context)
                    photoToDelete = nil
                }
            }
        }
        .fullScreenCover(isPresented: $showPhotoViewer) {
            UnitPhotoViewer(photo: heroPhoto) {
                showPhotoViewer = false
            }
        }
    }

#if canImport(UIKit)
    @ViewBuilder
    private var photoHeader: some View {
        Section {
            if unit.photos.isEmpty {
                photoEmptyPlaceholder
            } else if let photo = heroPhoto {
                heroButton(photo)
            }
        }
        .listRowBackground(unit.photos.isEmpty ? TTColor.surface : Color.clear)
    }

    private var photoEmptyPlaceholder: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "camera")
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.brand)
                    .accessibilityHidden(true)
                Text(String(localized: "Add Photo"))
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(16.0 / 10.0, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous)
                    .strokeBorder(TTColor.stroke, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
            }
        }
        .accessibilityIdentifier("unitAddPhoto")
        .accessibilityLabel(String(localized: "Add Photo"))
        .accessibilityHint(String(localized: "Adds a photo from your library to this unit."))
    }

    @ViewBuilder
    private func heroButton(_ photo: ModelPhoto) -> some View {
        if let image = PhotoStore.loadImage(photo) {
            Button {
                showPhotoViewer = true
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity)
                    .aspectRatio(16.0 / 10.0, contentMode: .fit)
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        TTBadge("\(unit.photos.count)", tone: .neutral, style: .solid)
                            .padding(DesignTokens.Spacing.sm)
                            .accessibilityHidden(true)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                String(localized: "Cover photo, \(photo.stageKey), \(unit.photos.count) photos")
            )
            .accessibilityHint(String(localized: "Opens the photo"))
            .accessibilityIdentifier("unitCoverPhoto")
        }
    }

    @ViewBuilder
    private func photoRow(_ photo: ModelPhoto) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            stackedPhotoRow(photo)
        } else {
            compactPhotoRow(photo)
        }
    }

    @ViewBuilder
    private func compactPhotoRow(_ photo: ModelPhoto) -> some View {
        HStack(spacing: 12) {
            photoThumb(photo)
            VStack(alignment: .leading, spacing: 2) {
                StageCapsule(state: photo.stageKey, pipeline: pipeline)
                Text(photo.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkSecondary)
            }
            Spacer(minLength: 0)
            photoActions(photo)
        }
    }

    @ViewBuilder
    private func stackedPhotoRow(_ photo: ModelPhoto) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                photoThumb(photo)
                VStack(alignment: .leading, spacing: 4) {
                    StageCapsule(state: photo.stageKey, pipeline: pipeline)
                    Text(photo.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(TTFont.caption)
                        .foregroundStyle(TTColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            photoActions(photo)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func photoThumb(_ photo: ModelPhoto) -> some View {
        if let image = PhotoStore.loadImage(photo) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xs, style: .continuous))
        }
    }

    @ViewBuilder
    private func photoActions(_ photo: ModelPhoto) -> some View {
        HStack(spacing: 12) {
            if photo.isCover {
                Text(String(localized: "Cover"))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            } else {
                Button(String(localized: "Set cover")) {
                    PhotoStore.setCover(photo, in: context)
                }
                .font(TTFont.caption)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("unitPhoto.setCover")
                .accessibilityLabel(String(localized: "Set cover"))
                .accessibilityHint(String(localized: "Uses this photo as the unit's cover image."))
            }
            Button(role: .destructive) {
                photoToDelete = photo
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .frame(minWidth: DesignTokens.minTouchTarget, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("unitPhoto.delete")
            .accessibilityLabel(String(localized: "Delete photo"))
            .accessibilityHint(String(localized: "Removes this photo from the unit."))
        }
    }
#endif

private struct UnitPhotoViewer: View {
    let photo: ModelPhoto?
    let onClose: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                TTColor.canvas.ignoresSafeArea()
#if canImport(UIKit)
                if let photo, let image = PhotoStore.loadImage(photo) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .accessibilityLabel(String(localized: "Photo, \(photo.stageKey)"))
                }
#endif
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { onClose() }
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("unitPhoto.viewer.done")
                }
            }
        }
        .presentationBackground(TTColor.canvas)
    }
}

    private func importPhoto(from item: PhotosPickerItem) async {
        defer { pickerItem = nil }
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                banner.show(String(localized: "Could not read the selected image"))
                return
            }
            _ = try PhotoStore.addPhoto(from: data, to: unit, stageKey: unit.state, in: context)
        } catch {
            banner.show(error.localizedDescription)
        }
    }
}

#if canImport(UIKit)
private struct PhotoThumb: View {
    let photo: ModelPhoto

    var body: some View {
        if let image = PhotoStore.loadImage(photo) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        }
    }
}
#endif

/// Small list-row thumbnail when a unit has a cover photo.
struct UnitPhotoThumb: View {
    let photo: ModelPhoto

    var body: some View {
#if canImport(UIKit)
        PhotoThumb(photo: photo)
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.xs, style: .continuous))
            .accessibilityHidden(true)
#else
        EmptyView()
#endif
    }
}
