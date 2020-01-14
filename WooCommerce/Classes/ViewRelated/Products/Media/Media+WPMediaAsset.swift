import Foundation
import WPMediaPicker
import Yosemite

extension Media {
    var mediaType: MediaType {
        if mimeType.isEmpty == false {
            return MediaType(mimeType: mimeType)
        } else if fileExtension.isEmpty == false {
            return MediaType(fileExtension: fileExtension)
        } else {
            return .other
        }
    }
}

extension MediaType {
    var toWPMediaType: WPMediaType {
        switch self {
        case .image:
            return .image
        case .video:
            return .video
        case .audio:
            return .audio
        default:
            return .other
        }
    }
}

extension Media: WPMediaAsset {
    public func image(with size: CGSize, completionHandler: @escaping WPMediaImageBlock) -> WPMediaRequestID {
        guard let url = URL(string: src) else {
            return 0
        }
        DispatchQueue.global().async {
            ServiceLocator.imageService.retrieveImageFromCache(with: url) { (image) in
                completionHandler(image, nil)
            }

            ServiceLocator.imageService.downloadImage(with: url, size: size, shouldCacheImage: true) { (image, error) in
                completionHandler(image, error)
            }
        }
        return Int32(mediaID)
    }

    public func cancelImageRequest(_ requestID: WPMediaRequestID) {}

    public func videoAsset(completionHandler: @escaping WPMediaAssetBlock) -> WPMediaRequestID {
        return 0
    }

    public func assetType() -> WPMediaType {
        return mediaType.toWPMediaType
    }

    public func duration() -> TimeInterval {
        return 0
    }

    public func baseAsset() -> Any {
        return self
    }

    public func identifier() -> String {
        return "\(mediaID)"
    }

    public func date() -> Date {
        return date
    }

    public func pixelSize() -> CGSize {
        guard let height = height, let width = width else {
            return .zero
        }
        return CGSize(width: width, height: height)
    }
}
