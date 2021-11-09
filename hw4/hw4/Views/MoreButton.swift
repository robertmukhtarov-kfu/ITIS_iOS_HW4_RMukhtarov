//
//  MoreButton.swift
//  hw4
//
//  Created by Robert Mukhtarov on 08.11.2021.
//

import UIKit

final class MoreButton: UIButton {

    // MARK: - Layout Constants

    private enum LayoutConstants {
        static let width = 144.0
        static let height = 40.0
        static let fontSize = 16.0
        static let cornerRadius = 20.0
    }

    // MARK: - Overridden Internal Properties

    override var intrinsicContentSize: CGSize {
        CGSize(width: LayoutConstants.width, height: LayoutConstants.height)
    }

    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - View Setup

    private func setup() {
        backgroundColor = .moreButtonBackgroundColor
        titleLabel?.font = .systemFont(ofSize: LayoutConstants.fontSize)
        setTitle("more", for: .normal)
        setTitleColor(.white, for: .normal)
        layer.cornerRadius = LayoutConstants.cornerRadius
    }
}
