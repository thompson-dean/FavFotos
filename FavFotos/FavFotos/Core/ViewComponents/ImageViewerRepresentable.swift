//
//  ImageViewerRepresentable.swift
//  FavFotos
//
//  Created by Dean Thompson on 2023/08/14.
//

import SwiftUI
import UIKit
import Combine

struct ImageViewerRepresentable: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIImageViewerView {
        return UIImageViewerView(image: image)
    }
    
    func updateUIView(_ uiView: UIImageViewerView, context: Context) { }
}

public class UIImageViewerView: UIView {
    private let image: UIImage
    private let scrollView: UIScrollView = UIScrollView()
    private let imageView: UIImageView = UIImageView()

    required init(image: UIImage) {
        self.image = image
        super.init(frame: .zero)

        setupScrollView()
        setupImageView()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScrollView() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 10.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addSubview(scrollView)
    }

    private func setupImageView() {
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
    }
    private func setupGestureRecognizers() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onDoubleTap(recognizer:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTapGestureRecognizer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        adjustImageViewSize()
        updateContentSize()
        updateContentInset()
    }

    private func adjustImageViewSize() {
        guard let size = imageView.image?.size else { return }
        let rate = min(scrollView.bounds.width / size.width,
                       scrollView.bounds.height / size.height)
        imageView.frame.size = CGSize(width: size.width * rate,
                                      height: size.height * rate)
    }

    private func updateContentSize() {
        scrollView.contentSize = imageView.frame.size
    }

    private func updateContentInset() {
        let edgeInsets = UIEdgeInsets(
            top: max((self.frame.height - imageView.frame.height) / 2, 0),
            left: max((self.frame.width - imageView.frame.width) / 2, 0),
            bottom: 0,
            right: 0)
        scrollView.contentInset = edgeInsets
    }

    @objc private func onDoubleTap(recognizer: UITapGestureRecognizer) {
        let maximumZoomScale = scrollView.maximumZoomScale

        if maximumZoomScale != scrollView.zoomScale {
            let tapPoint = recognizer.location(in: imageView)
            let size = CGSize(
                width: scrollView.frame.size.width / maximumZoomScale,
                height: scrollView.frame.size.height / maximumZoomScale)
            let origin = CGPoint(
                x: tapPoint.x - size.width / 2,
                y: tapPoint.y - size.height / 2)
            scrollView.zoom(to: CGRect(origin: origin, size: size), animated: true)
        } else {
            scrollView.zoom(to: scrollView.frame, animated: true)
        }
    }
}

extension UIImageViewerView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateContentInset()
    }
}
