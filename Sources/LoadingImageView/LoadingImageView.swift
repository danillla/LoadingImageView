//
//  LoadingImageView.swift
//
//
//  Created by Daniil Alferov on 05.11.2022.
//

import UIKit

open class LoadingImageView: UIView {
    
    private var networkService: NetworkService = NetworkServiceImp()
    
    public var url: URL? {
        didSet {
            self.start()
        }
    }
    
    public var image: UIImage? {
        set {
            self.imageView.image = newValue
        }
        get {
            return self.imageView.image
        }
    }
    
    private var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.backgroundColor = .white
        imageView.tintColor = .lightGray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        return activityIndicator
    }()
    
    // MARK: - Init
    
    convenience init(url: URL) {
        self.init(frame: .zero)
        self.url = url
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setupView() {
        self.backgroundColor = .white
        self.imageView.backgroundColor = .white
    }
    
    private func addLoader() {
        self.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    private func removeLoader() {
        self.activityIndicator.removeFromSuperview()
    }
    
    private func start() {
        guard let url = self.url else {
            return
        }
        self.addLoader()
        let loadFunc = self.pickLoadFunc()
        loadFunc(url)
    }
    
    private func pickLoadFunc() -> (URL) -> () {
        if #available(iOS 13.0, *) {
            return self.loadAsync
        } else {
            return self.loadOldschool
        }
    }
    
    @available(iOS 13.0, *)
    private func loadAsync(url: URL) {
        Task {
            let result = await self.networkService.loadData(url: url)
            switch result {
            case .success(let data):
                self.processSuccessResponse(with: data)
            case .failure(_):
                self.processFailedResponse()
            }
        }
    }
    
    private func loadOldschool(url: URL) {
        let success: (Data) -> Void = { [weak self] data in
            guard let self = self else { return }
            self.processSuccessResponse(with: data)
        }
        let failure: (LoaderError) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.processFailedResponse()
        }
        self.networkService.loadData(url: url,
                                     success: success,
                                     failure: failure)
    }
    
    private func processSuccessResponse(with data: Data) {
        DispatchQueue.main.async {
            guard let image = UIImage(data: data) else {
                self.setFailedImage()
                return
            }
            self.removeLoader()
            self.image = image
            self.imageView.contentMode = .scaleAspectFill
            self.addSubview(self.imageView)
        }
    }
    
    private func processFailedResponse() {
        DispatchQueue.main.async {
            self.setFailedImage()
        }
    }
    
    private func setFailedImage() {
        self.imageView.contentMode = .center
        self.image = UIImage(named: "failedLoadImage", in: Bundle.module, compatibleWith: nil)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicator.frame = self.bounds
        self.imageView.frame = self.bounds
    }
    
}
