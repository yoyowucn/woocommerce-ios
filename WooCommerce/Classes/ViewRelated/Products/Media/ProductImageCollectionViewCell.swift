import UIKit
import Yosemite

class ProductImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureImageView()
    }

}

extension ProductImageCollectionViewCell {
    func update(imageURL: String) {
        guard let url = URL(string: imageURL) else {
            return
        }
        productImageView.downloadImage(from: url,
                                       placeholderImage: UIImage.imageImage,
                                       success: nil,
                                       failure: nil)
    }
}

private extension ProductImageCollectionViewCell {
    func configureImageView() {
        productImageView.contentMode = .scaleAspectFit
        productImageView.layer.cornerRadius = CGFloat(2.0)
        productImageView.layer.borderWidth = 1
        productImageView.layer.borderColor = StyleManager.wooGreyBorder.cgColor
        productImageView.clipsToBounds = true
    }
}
