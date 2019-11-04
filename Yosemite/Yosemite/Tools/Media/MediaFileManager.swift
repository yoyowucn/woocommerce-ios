import Foundation
import CocoaLumberjack

/// Type of the local Media directory URL in implementation.
///
enum MediaDirectory {
    /// Default, system Documents directory, for persisting media files for upload.
    case uploads
    /// System Caches directory, for creating discardable media files, such as thumbnails.
    case cache
    /// System temporary directory, used for unit testing or temporary media files.
    case temporary

    /// Returns the directory URL for the directory type.
    ///
    fileprivate var url: URL {
        let fileManager = FileManager.default
        // Get a parent directory, based on the type.
        let parentDirectory: URL
        switch self {
        case .uploads:
            parentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        case .cache:
            parentDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        case .temporary:
            parentDirectory = fileManager.temporaryDirectory
        }
        return parentDirectory.appendingPathComponent(MediaFileManager.mediaDirectoryName, isDirectory: true)
    }
}

/// Encapsulates Media functions relative to the local Media directory.
///
class MediaFileManager: NSObject {

    fileprivate static let mediaDirectoryName = "Media"

    let directory: MediaDirectory

    // MARK: - Class init

    /// The default instance of a MediaFileManager.
    ///
    @objc (defaultManager)
    static let `default`: MediaFileManager = {
        return MediaFileManager()
    }()

    /// Helper method for getting a MediaFileManager for the .cache directory.
    ///
    @objc (cacheManager)
    class var cache: MediaFileManager {
        return MediaFileManager(directory: .cache)
    }

    // MARK: - Init

    /// Init with default directory of .uploads.
    ///
    /// - Note: This is particularly because the original Media directory was in the NSFileManager's documents directory.
    ///   We shouldn't change this default directory lightly as older versions of the app may rely on Media files being in
    ///   the documents directory for upload.
    ///
    init(directory: MediaDirectory = .uploads) {
        self.directory = directory
    }

    // MARK: - Instance methods

    /// Returns filesystem URL for the local Media directory.
    ///
    @objc func directoryURL() throws -> URL {
        let fileManager = FileManager.default
        let mediaDirectory = directory.url
        // Check whether or not the file path exists for the Media directory.
        // If the filepath does not exist, or if the filepath does exist but it is not a directory, try creating the directory.
        // Note: This way, if unexpectedly a file exists but it is not a dir, an error will throw when trying to create the dir.
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: mediaDirectory.path, isDirectory: &isDirectory) == false || isDirectory.boolValue == false {
            try fileManager.createDirectory(at: mediaDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        return mediaDirectory
    }

    /// Returns a unique filesystem URL for a Media filename and extension, within the local Media directory.
    ///
    /// - Note: if a file already exists with the same name, the file name is appended with a number
    ///   and incremented until a unique filename is found.
    ///
    @objc func makeLocalMediaURL(withFilename filename: String, fileExtension: String?, incremented: Bool = true) throws -> URL {
        let baseURL = try directoryURL()
        var url: URL
        if let fileExtension = fileExtension {
            let basename = (filename as NSString).deletingPathExtension.lowercased()
            url = baseURL.appendingPathComponent(basename, isDirectory: false)
            url.appendPathExtension(fileExtension)
        } else {
            url = baseURL.appendingPathComponent(filename, isDirectory: false)
        }
        // Increment the filename as needed to ensure we're not
        // providing a URL for an existing file of the same name.
        return incremented ? url.incrementalFilename() : url
    }

    /// Objc friendly signature without specifying the `incremented` parameter.
    ///
    @objc func makeLocalMediaURL(withFilename filename: String, fileExtension: String?) throws -> URL {
        return try makeLocalMediaURL(withFilename: filename, fileExtension: fileExtension, incremented: true)
    }

    /// Returns a string appended with the thumbnail naming convention for local Media files.
    ///
    @objc func mediaFilenameAppendingThumbnail(_ filename: String) -> String {
        var filename = filename as NSString
        let pathExtension = filename.pathExtension
        filename = filename.deletingPathExtension.appending("-thumbnail") as NSString
        return filename.appendingPathExtension(pathExtension)!
    }

    /// Returns the size of a Media image located at the file URL, or zero if it doesn't exist.
    ///
    /// - Note: once we drop ObjC, this should be an optional that would return nil instead of zero.
    ///
    @objc func imageSizeForMediaAt(fileURL: URL?) -> CGSize {
        guard let fileURL = fileURL else {
            return CGSize.zero
        }
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) == true, isDirectory.boolValue == false else {
            return CGSize.zero
        }
        guard
            let imageSource = CGImageSourceCreateWithURL(fileURL as CFURL, nil),
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? Dictionary<String, AnyObject>
            else {
                return CGSize.zero
        }
        var width = CGFloat(0), height = CGFloat(0)
        if let widthProperty = imageProperties[kCGImagePropertyPixelWidth as String] as? CGFloat {
            width = widthProperty
        }
        if let heightProperty = imageProperties[kCGImagePropertyPixelHeight as String] as? CGFloat {
            height = heightProperty
        }
        return CGSize(width: width, height: height)
    }

    // MARK: - Class methods

    /// Helper method for getting the default upload directory URL.
    ///
    @objc class func uploadsDirectoryURL() throws -> URL {
        return try MediaFileManager.default.directoryURL()
    }
}
