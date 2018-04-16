import UIKit

class PhotoViewerViewController<T: PhotoViewerPresenter>: UIViewController, UIScrollViewDelegate {

    let presenter: T
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    var progressView: DownloadProgressView!

    init(presenter: T) {
        self.presenter = presenter
        super.init(nibName: nil,
                   bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        createViews()
        setupConstraints()

        presenter.attach(view: self)
        presenter.loadPhoto()
    }

    func createViews() {
        view.backgroundColor = .black
        scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(imageView)

        progressView = DownloadProgressView(frame: .zero)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor),

            imageView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        NSLayoutConstraint.activate(
            [progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
             progressView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
             progressView.widthAnchor.constraint(equalTo: progressView.heightAnchor)])
    }

    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: scrollView)
        if scrollView.zoomScale == 1 {

            let zoomRect = scrollView.zoomRectForScale(scale: scrollView.maximumZoomScale,
                                                       center: point)
            scrollView.zoom(to: zoomRect,
                            animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }

    // MARK: UIScrollViewDelegate

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension PhotoViewerViewController: PhotoViewerViewType {

    func loadProgress(progress: CGFloat) {
        progressView.progresss = progress
    }

    func didLoad(image: UIImage) {
        self.imageView.alpha = 0
        self.imageView.image = image

        UIView.animateKeyframes(withDuration: 0.55,
                                delay: 0.5,
                                options: [.calculationModeCubicPaced],
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: {
                                        self.progressView.alpha = 0
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                                        self.imageView.alpha = 1
                                    })
        }, completion: nil)
    }
}
