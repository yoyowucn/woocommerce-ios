import Photos
import UIKit
import Yosemite

enum ProductImageStatus {
    case uploading(asset: PHAsset)
    case remote(image: ProductImage)
}

/// Displays Product images in grid layout.
///
final class ProductImagesCollectionViewController: UICollectionViewController {

    private var productImages: [ProductImageStatus]

    private let imageService: ImageService
    private let onDeletion: ProductImageViewController.Deletion

    init(images: [ProductImageStatus],
         imageService: ImageService = ServiceLocator.imageService,
         onDeletion: @escaping ProductImageViewController.Deletion) {
        self.productImages = images
        self.imageService = imageService
        self.onDeletion = onDeletion
        let columnLayout = ColumnFlowLayout(
            cellsPerRow: 2,
            minimumInteritemSpacing: 16,
            minimumLineSpacing: 16,
            sectionInset: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        super.init(collectionViewLayout: columnLayout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = .basicBackground

        collectionView.register(ProductImageCollectionViewCell.loadNib(), forCellWithReuseIdentifier: ProductImageCollectionViewCell.reuseIdentifier)

        collectionView.reloadData()
    }

    func updateProductImages(_ productImages: [ProductImageStatus]) {
        self.productImages = productImages

        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
//
extension ProductImagesCollectionViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productImages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductImageCollectionViewCell.reuseIdentifier,
                                                            for: indexPath) as? ProductImageCollectionViewCell else {
                                                                fatalError()
        }

        let productImage = productImages[indexPath.row]

        switch productImage {
        case .remote(let image):
            imageService.downloadAndCacheImageForImageView(cell.imageView,
                                                           with: image.src,
                                                           placeholder: .productPlaceholderImage,
                                                           progressBlock: nil) { (image, error) in
                                                            let success = image != nil && error == nil
                                                            if success {
                                                                cell.imageView.contentMode = .scaleAspectFit
                                                            }
                                                            else {
                                                                cell.imageView.contentMode = .center
                                                            }
            }
        case .uploading(let asset):
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            manager.requestImage(for: asset, targetSize: cell.bounds.size, contentMode: .aspectFit, options: option, resultHandler: { (result, info) in
                if let result = result {
                    cell.imageView.image = result
                    cell.imageView.contentMode = .scaleAspectFit
                }
                else {
                    cell.imageView.contentMode = .center
                }
            })
        }

        return cell
    }
}

// MARK: UICollectionViewDelegate
//
extension ProductImagesCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let status = productImages[indexPath.row]
        switch status {
        case .remote(let productImage):
            let productImageViewController = ProductImageViewController(productImage: productImage, onDeletion: onDeletion)
            navigationController?.pushViewController(productImageViewController, animated: true)
        default:
            return
        }
    }
}
