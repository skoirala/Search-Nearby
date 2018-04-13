import UIKit

class ImageDownloader {

    static let `default` = ImageDownloader()
    
    private init() { }

    var pendingTasks: [String: URLSessionTask] = [:]
    var imageCompletionHandlers: [String: (UIImage) -> Void] = [:]

    let cache: NSCache<NSString, UIImage> = NSCache()

    func image(for imageUrl: String) -> UIImage? {
        return cache.object(forKey: imageUrl as NSString)
    }

    func getImage(for imageUrl: String, completion: @escaping (UIImage) -> Void) {

        if let image = cache.object(forKey: imageUrl as NSString) {
            completion(image)
            return
        }

        if pendingTasks[imageUrl] != nil {
            return
        }
        guard let url = URL(string: imageUrl) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let strongSelf = self else {  return }
            if error != nil {
                assert(true)
                return
            }

            DispatchQueue.main.async {
                guard let data = data,
                    let image = UIImage(data: data)?.withRenderingMode(.alwaysTemplate) else {
                        assert(true)
                        return
                }

                strongSelf.cache.setObject(image, forKey: imageUrl as NSString)
                strongSelf.pendingTasks[imageUrl] = nil
                completion(image)
            }
        }
        pendingTasks[imageUrl] = task
        task.resume()
    }
}
