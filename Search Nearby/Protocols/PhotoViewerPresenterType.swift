import Foundation

protocol PhotoViewerPresenterType: ViewPresenterType {
    func loadPhoto()
    func attach(view: PhotoViewerViewType)
}
