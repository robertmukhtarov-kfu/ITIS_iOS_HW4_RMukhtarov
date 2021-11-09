//
//  ContentView.swift
//  hw4
//
//  Created by Robert Mukhtarov on 08.11.2021.
//

import UIKit
import SnapKit
import Kingfisher

final class ContentView: UIView {

    // MARK: - Layout Constants

    private enum LayoutConstants {
        static let labelFontSize = 16.0
        static let cornerRadius = 10.0
        static let borderWidth = 1.0
    }

    // MARK: - Views

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: LayoutConstants.labelFontSize, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Internal Methods

    func reset() {
        label.isHidden = true
        imageView.isHidden = true
    }

    func setText(_ text: String) {
        label.isHidden = false
        imageView.isHidden = true
        label.text = text
    }

    func setImage(with imageURL: String, completion: @escaping () -> Void) {
        label.isHidden = true
        imageView.isHidden = false
        imageView.kf.setImage(with: URL(string: imageURL)) { [weak self] result in
            switch result {
            case .success:
                completion()
            case .failure:
                self?.setText("Failed to load an image")
            }
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addSubviews()
        makeConstraints()
        reset()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Setup

    private func setup() {
        layer.masksToBounds = true
        layer.cornerRadius = LayoutConstants.cornerRadius
        layer.borderColor = UIColor.black.cgColor
        layer.borderWidth = LayoutConstants.borderWidth
    }

    private func addSubviews() {
        addSubview(imageView)
        addSubview(label)
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
