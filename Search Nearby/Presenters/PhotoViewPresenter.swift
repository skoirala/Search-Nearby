import UIKit

class PhotoViewerPresenter: NSObject, PhotoViewerPresenterType {
    let photo: VenuePhoto

    var session: URLSession!
    var task: URLSessionDataTask?

    var data: Data = Data()

    init(photo: VenuePhoto) {
        self.photo = photo

        super.init()

        let configuration = URLSessionConfiguration.default
        self.session = URLSession(configuration: configuration,
                                  delegate: self,
                                  delegateQueue: nil)
    }

    var view: PhotoViewerViewType!

    var observer: NSKeyValueObservation!

    func loadPhoto() {

        let imageUrl = photo.prefix
            + "\(photo.width)x\(photo.height)"
            + photo.suffix

        let task = session.dataTask(with: URL(string: imageUrl)!)

        observer = task.progress.observe(\.fractionCompleted) { [weak self, weak task] _, _ in
            guard let strongSelf = self, let task = task else { return }
            let progress = CGFloat(task.progress.fractionCompleted)
            strongSelf.view.loadProgress(progress: progress)
        }

        task.resume()
        self.task = task
    }

    func notifyDownloadCompletion() {
        guard let image = UIImage(data: data) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.didLoad(image: image)
        }
    }

    deinit {
        task?.cancel()
    }
}

extension PhotoViewerPresenter: URLSessionDataDelegate {

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        data = Data()
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive responseData: Data) {
        self.data.append(responseData)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            return
        }
        notifyDownloadCompletion()
    }

    func attach(view: PhotoViewerViewType) {
        self.view = view
    }
}
