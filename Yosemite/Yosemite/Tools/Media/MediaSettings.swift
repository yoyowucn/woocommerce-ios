import Foundation
import AVFoundation

class MediaSettings: NSObject {
    enum VideoResolution: String {
        case size640x480 = "AVAssetExportPreset640x480"
        case size1280x720 = "AVAssetExportPreset1280x720"
        case size1920x1080 = "AVAssetExportPreset1920x1080"
        case size3840x2160 = "AVAssetExportPreset3840x2160"
        case sizeOriginal = "AVAssetExportPresetPassthrough"

        var videoPreset: String {
            switch self {
            case .size640x480:
                return AVAssetExportPreset640x480
            case .size1280x720:
                return AVAssetExportPreset1280x720
            case .size1920x1080:
                return AVAssetExportPreset1920x1080
            case .size3840x2160:
                return AVAssetExportPreset3840x2160
            case .sizeOriginal:
                return AVAssetExportPresetPassthrough
            }
        }

        var description: String {
            switch self {
            case .size640x480:
                return NSLocalizedString("480p", comment: "Indicates a video will be resized to 640x480 when uploaded.")
            case .size1280x720:
                return NSLocalizedString("720p", comment: "Indicates a video will be resized to HD 1280x720 when uploaded.")
            case .size1920x1080:
                return NSLocalizedString("1080p", comment: "Indicates a video will be resized to Full HD 1920x1080 when uploaded.")
            case .size3840x2160:
                return NSLocalizedString("4K", comment: "Indicates a video will be resized to 4K 3840x2160 when uploaded.")
            case(.sizeOriginal):
                return NSLocalizedString("Original", comment: "Indicates a video will use its original size when uploaded.")
            }
        }

        var intValue: Int {
            switch self {
            case .size640x480:
                return 1
            case .size1280x720:
                return 2
            case .size1920x1080:
                return 3
            case .size3840x2160:
                return 4
            case .sizeOriginal:
                return 5
            }
        }

        static func videoResolution(from value: Int) -> MediaSettings.VideoResolution {
            switch value {
            case 1:
                return .size640x480
            case 2:
                return .size1280x720
            case 3:
                return .size1920x1080
            case 4:
                return .size3840x2160
            case 5:
                return .sizeOriginal
            default:
                return .sizeOriginal
            }
        }
    }
}
