import AVFoundation
import Foundation
import MobileCoreServices

/// Available options for an image export.
///
struct MediaImageExportOptions {
    /// Set a maximumImageSize for resizing images, or nil for exporting the full images.
    ///
    let maximumImageSize: CGFloat?

    /// Compression quality from 0.0 (lowest) to 1.0 (original quality) if the image type supports compression.
    ///
    let imageCompressionQuality: Double

    /// If the original asset contains geo location information, enabling this option will remove it.
    let stripsGeoLocationIfNeeded: Bool

    init(maximumImageSize: CGFloat?,
         imageCompressionQuality: Double,
         stripsGeoLocationIfNeeded: Bool) {
        self.maximumImageSize = maximumImageSize
        self.imageCompressionQuality = imageCompressionQuality
        self.stripsGeoLocationIfNeeded = stripsGeoLocationIfNeeded
    }
}

/// Media export handling of UIImages.
///
final class MediaImageExporter: MediaExporter {

    let mediaDirectoryType: MediaDirectory

    /// Export options.
    ///
    private let options: MediaImageExportOptions

    /// Default filename used when writing media images locally, which may be appended with "-1" or "-thumbnail".
    ///
    private let defaultImageFilename = "image"

    private let data: Data
    private let filename: String?
    private let typeHint: String?

    init(data: Data,
         filename: String?,
         typeHint: String? = nil,
         options: MediaImageExportOptions,
         mediaDirectoryType: MediaDirectory = .uploads) {
        self.filename = filename
        self.data = data
        self.typeHint = typeHint
        self.options = options
        self.mediaDirectoryType = mediaDirectoryType
    }

    func export(onCompletion: @escaping MediaExportCompletion) {
        exportImage(data: data, fileName: filename, typeHint: typeHint, onCompletion: onCompletion)
    }

    /// Exports and writes an image's data, expected as PNG or JPEG format, to a local Media URL.
    ///
    /// - Parameters:
    ///     - data: Image data.
    ///     - fileName: Filename if it's known.
    ///     - typeHint: The UTType of data, if it's known.
    ///     - onCompletion: Called when the image export completes.
    ///
    private func exportImage(data: Data,
                             fileName: String?,
                             typeHint: String?,
                             onCompletion: @escaping MediaExportCompletion) {
        do {
            let hint = typeHint ?? kUTTypeJPEG as String
            let sourceOptions: [String: Any] = [kCGImageSourceTypeIdentifierHint as String: hint as CFString]
            guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
                throw ImageExportError.imageSourceCreationWithDataFailed
            }
            guard let utType = CGImageSourceGetType(source) else {
                throw ImageExportError.imageSourceIsAnUnknownType
            }
            exportImageSource(source,
                              filename: fileName,
                              type: utType as String,
                              onCompletion: onCompletion)
        } catch {
            onCompletion(nil, error)
        }
    }

    /// Exports and writes an image source to a local Media URL.
    ///
    /// - Parameters:
    ///     - fileName: Filename if it's known.
    ///     - onCompletion: Called on successful export, with the local file URL of the exported UIImage.
    ///     - onError: Called if an error was encountered during creation.
    ///
    /// - Returns: a progress object that report the current state of the export process.
    ///
    private func exportImageSource(_ source: CGImageSource,
                                   filename: String?,
                                   type: String,
                                   onCompletion: @escaping MediaExportCompletion) {
        do {
            let filename = filename ?? defaultImageFilename
            // Makes a new URL within the local Media directory
            let url = try mediaFileManager.createLocalMediaURL(filename: filename,
                                                               fileExtension: URL.fileExtensionForUTType(type))

            // Checks export options and configures the image writer as needed.
            let writer = ImageSourceWriter(url: url, sourceUTType: type as CFString)
            _ = try writer.writeImageSource(source, options: options)

            let exported = UploadableMedia(localURL: url,
                                           filename: url.lastPathComponent,
                                           mimeType: url.mimeTypeForPathExtension)
            onCompletion(exported, nil)
        } catch {
            onCompletion(nil, error)
        }
    }
}

extension MediaImageExporter {
    enum ImageExportError: Error {
        case imageSourceCreationWithDataFailed
        case imageSourceIsAnUnknownType

        var description: String {
            switch self {
            default:
                return NSLocalizedString("The image could not be added to the Media Library.",
                                         comment: "Message shown when an image failed to load while trying to add it to the Media library.")
            }
        }
    }
}

/// Writes an image to a URL from a CGImageSource, via CGImageDestination, particular to the needs of a `MediaImageExporter`.
///
struct ImageSourceWriter {

    /// File URL where the image should be written.
    ///
    private let url: URL

    /// The UTType of the image source.
    ///
    private let sourceUTType: CFString

    init(url: URL, sourceUTType: CFString) {
        self.url = url
        self.sourceUTType = sourceUTType
    }

    /// Struct for returned result from writing an image, and any properties worth keeping track of.
    ///
    struct WriteResultProperties {
        let width: CGFloat?
        let height: CGFloat?
    }

    /// Write a given image source, succeeds unless an error is thrown, returns the resulting properties if available.
    ///
    func writeImageSource(_ source: CGImageSource, options: MediaImageExportOptions) throws -> WriteResultProperties {
        // Create the destination with the URL, or error
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, sourceUTType, 1, nil) else {
            throw ImageSourceWriterError.imageSourceDestinationWithURLFailed
        }

        // Configure image properties for the image source and image destination methods
        // Preserve any existing properties from the source.
        var imageProperties: [NSString: Any] = (CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? Dictionary) ?? [:]
        // Configure destination properties
        imageProperties[kCGImageDestinationLossyCompressionQuality] = options.imageCompressionQuality

        // Keep track of the image's width and height
        var width: CGFloat?
        var height: CGFloat?

        // Configure orientation properties to default .up or 1
        imageProperties[kCGImagePropertyOrientation] = Int(CGImagePropertyOrientation.up.rawValue) as CFNumber
        if var tiffProperties = imageProperties[kCGImagePropertyTIFFDictionary] as? [NSString: Any] {
            // Remove TIFF orientation value
            tiffProperties.removeValue(forKey: kCGImagePropertyTIFFOrientation)
            imageProperties[kCGImagePropertyTIFFDictionary] = tiffProperties
        }
        if var iptcProperties = imageProperties[kCGImagePropertyIPTCDictionary] as? [NSString: Any] {
            // Remove IPTC orientation value
            iptcProperties.removeValue(forKey: kCGImagePropertyIPTCImageOrientation)
            imageProperties[kCGImagePropertyIPTCDictionary] = iptcProperties
        }

        // Configure options for generating the thumbnail, such as the maximum size.
        var thumbnailOptions: [NSString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCache: false,
            kCGImageSourceTypeIdentifierHint: sourceUTType,
            kCGImageSourceCreateThumbnailWithTransform: true ]

        if let maximumSize = options.maximumImageSize {
            thumbnailOptions[kCGImageSourceThumbnailMaxPixelSize] = maximumSize as CFNumber
        }

        // Create a thumbnail of the image source.
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
            throw ImageSourceWriterError.imageSourceThumbnailGenerationFailed
        }

        if options.stripsGeoLocationIfNeeded == true {
            // When removing GPS data for a thumbnail, we have to remove the dictionary
            // itself for the CGImageDestinationAddImage method.
            imageProperties.removeValue(forKey: kCGImagePropertyGPSDictionary)
        }

        // Add the thumbnail image as the destination's image.
        CGImageDestinationAddImage(destination, image, imageProperties as CFDictionary?)

        // Get the dimensions from the CGImage itself
        width = CGFloat(image.width)
        height = CGFloat(image.height)

        // Write the image to the file URL
        let written = CGImageDestinationFinalize(destination)
        guard written == true else {
            throw ImageSourceWriterError.imageSourceDestinationWriteFailed
        }

        // Return the result with any interesting properties.
        return WriteResultProperties(width: width,
                                     height: height)
    }
}

extension ImageSourceWriter {
    enum ImageSourceWriterError: Error {
        case imageSourceDestinationWithURLFailed
        case imageSourceThumbnailGenerationFailed
        case imageSourceDestinationWriteFailed

        var description: String {
            switch self {
            default:
                return NSLocalizedString("The image could not be added to the Media Library.",
                                         comment: "Message shown when an image failed to load while trying to add it to the Media library.")
            }
        }
    }
}
