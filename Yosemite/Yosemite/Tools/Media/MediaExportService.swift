import Foundation
import CocoaLumberjack
import CoreServices
import Photos
import Networking

/// Encapsulates exporting assets such as PHAssets, images, videos, or files at URLs to `MediaUploadable`.
///
/// - Note: Methods with escaping closures will call back via its corresponding thread.
///
final class MediaExportService {
    /// Completion handler for a created Media object.
    ///
    typealias MediaExportCompletion = (ExportedMedia?, Error?) -> Void

    private lazy var exportQueue: DispatchQueue = {
        return DispatchQueue(label: "org.wordpress.mediaExportService", autoreleaseFrequency: .workItem)
    }()

    // MARK: - Instance methods

    /// Exports media from a PHAsset to the Media object, asynchronously.
    ///
    /// - Parameters:
    ///     - exportable: the exportable resource where data will be read from.
    ///     - onCompletion: Called if the Media was successfully created and the asset's data exported to the absoluteLocalURL.
    ///
    /// - Returns: a progress object that report the current state of the export process.
    ///
    func export(_ exportable: ExportableAsset, onCompletion: @escaping MediaExportCompletion) -> Progress? {
        let progress: Progress = Progress.discreteProgress(totalUnitCount: 1)
        exportQueue.async {
            guard let exporter = self.makeExporter(for: exportable) else {
                preconditionFailure("An exporter needs to be availale")
            }
            let exportProgress = exporter.export(onCompletion: { (exported, error) in
                guard let media = exported, error == nil else {
                    self.handleExportError(error, onCompletion: onCompletion)
                    return
                }
                onCompletion(media, error)
            })
            progress.addChild(exportProgress, withPendingUnitCount: 1)
        }
        return progress
    }
}

// MARK: MediaExporter
//
private extension MediaExportService {
    func makeExporter(for exportable: ExportableAsset) -> MediaExporter? {
        switch exportable {
        case let asset as PHAsset:
            let exporter = MediaAssetExporter(asset: asset)
            exporter.imageOptions = exporterImageOptions
            exporter.allowableFileExtensions = Defaults.allowableFileExtensions
            return exporter
        default:
            return nil
        }
    }
}

// MARK: Error handling
//
private extension MediaExportService {
    func logExportError(_ error: MediaExportError) {
        // Write an error logging message to help track specific sources of export errors.
        let errorLogMessage: String
        switch error {
        case is MediaAssetExporter.AssetExportError:
            errorLogMessage = " with asset export error"
        case is MediaImageExporter.ImageExportError:
            errorLogMessage = " with image export error"
        case is MediaExportSystemError:
            errorLogMessage = " with system error"
        default:
            errorLogMessage = " with unknown error"
        }
        let nerror = error.toNSError()
        DDLogError("Error occurred exporting to Media: \(errorLogMessage), code: \(nerror.code), error: \(nerror)")
    }

    /// Handles and logs any error encountered.
    ///
    func handleExportError(_ error: Error?, onCompletion: MediaExportCompletion) {
        guard let error = error as? MediaExportError else {
            onCompletion(nil, nil)
            return
        }

        logExportError(error)
        // Return the error via the context's queue, and as an NSError to ensure it carries over the right code/message.
        onCompletion(nil, error)
    }
}

// MARK: Configurations
//
private extension MediaExportService {
    var exporterImageOptions: MediaImageExporter.Options {
        var options = MediaImageExporter.Options()
        options.imageCompressionQuality = Defaults.imageCompressionQuality
        options.maximumImageSize = Defaults.maximumImageSize
        return options
    }
}

private extension MediaExportService {
    enum Defaults {
        ///
        /// - Note: This value may or may not be honored, depending on the export implementation and underlying data.
        ///
        static let imageCompressionQuality = 0.85

        static let maximumImageSize: CGFloat = 3000

        static let allowableFileExtensions = Set<String>(["docx", "ppt", "mp4", "ppsx", "3g2", "mpg", "ogv", "pptx", "xlsx", "jpeg", "xls", "mov", "key", "3gp", "png", "avi", "doc", "pdf", "gif", "odt", "pps", "m4v", "wmv", "jpg"])
    }
}
