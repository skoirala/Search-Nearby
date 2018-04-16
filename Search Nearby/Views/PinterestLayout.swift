import UIKit

class PinterestLayout: UICollectionViewLayout {

    weak var delegate: PinterestLayoutDelegate!

    var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    var numberOfColumns: Int = 2

    var sectionInset = UIEdgeInsets(top: 10,
                                    left: 10,
                                    bottom: 10,
                                    right: 10)
    var interItemSpacing: CGFloat = 10
    var lineSpacing: CGFloat = 10

    var contentHeight: CGFloat = 0

    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }

        let width = collectionView.bounds.width
        let totalHorizontalInset = collectionView.contentInset.left + collectionView.contentInset.right
        return width - totalHorizontalInset
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth,
                      height: contentHeight)
    }

    override func prepare() {

        guard cache.isEmpty == true,
            let collectionView = collectionView else {
            return
        }
        var column = 0

        let itemWidth = (contentWidth - CGFloat(numberOfColumns - 1) * interItemSpacing - sectionInset.left - sectionInset.right) / CGFloat(numberOfColumns)

        let numberOfRows = collectionView.numberOfItems(inSection: 0)

        var yOffset: [CGFloat] = Array(repeating: sectionInset.top, count: Int(numberOfColumns))

        var xOffset: [CGFloat] = (0 ..< numberOfColumns)
                                    .map { column in
                                        let columnOffset = CGFloat(column) * itemWidth + CGFloat(column) * interItemSpacing
                                            return  columnOffset + sectionInset.left
                                    }

        for item in 0 ..< numberOfRows {
            let originY =  lineSpacing + yOffset[column]

            let width = itemWidth

            let indexPath = IndexPath(item: item, section: 0)
            let height = delegate.heightOfItem(at: self,
                                               indexPath: indexPath)

            let frame = CGRect(x: xOffset[column],
                               y: originY,
                               width: width,
                               height: height)
            let layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttributes.frame = frame
            cache[indexPath] = layoutAttributes
            yOffset[column] = frame.maxY

            contentHeight = max(contentHeight, frame.maxY + sectionInset.bottom)

            column = column < (numberOfColumns - 1) ? column + 1 : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []

        for layoutAttribute in cache.values {
            if rect.intersects(layoutAttribute.frame) {
                layoutAttributes += [layoutAttribute]
            }
        }
        return layoutAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath]
    }
}

protocol PinterestLayoutDelegate: class {
    func heightOfItem(at pinterestLayout: PinterestLayout, indexPath: IndexPath) -> CGFloat
}
