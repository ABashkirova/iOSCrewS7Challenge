//
//  InfoCardItem.swift
//  AnimateMe
//
//  Created by Alexandra Bashkirova on 26.11.2021.
//


import AnKit
import UIKit

final class InfoCardItem: CollectionViewItem {
    let imageViewContentMode: UIView.ContentMode
    let badgeItem: BadgeItem?

    var content: Content

    var canResponseToTap: Bool
    var onTap: (() -> Void)?
    var onOpen: (() -> InfoCardCell)?

    var isShimmering: Bool

    override var cellType: CollectionViewCell.Type {
        InfoCardCell.self
    }

    init(
        content: Content,
        imageViewContentMode: UIView.ContentMode,
        badgeItem: BadgeItem? = nil,
        id: ID = ID()
    ) throws {
        self.content = content
        self.imageViewContentMode = imageViewContentMode
        self.badgeItem = badgeItem

        canResponseToTap = true

        isShimmering = false

        try super.init(
            supplementaryItems: [badgeItem].compactMap { $0 },
            id: id
        )
    }
}

extension InfoCardItem: Tappable { }

extension InfoCardItem: Shimmerable { }

extension InfoCardItem {
    struct Content: Hashable {
        let imageContent: UIImage
        let text: String
        let footnoteText: String

        init(
            imageContent: UIImage,
            text: String,
            footnoteText: String = ""
        ) {
            self.imageContent = imageContent
            self.text = text
            self.footnoteText = footnoteText
        }
    }
}


extension InfoCardItem {
    final class BadgeItem: CollectionViewSupplementaryItem {
        let text: String
        let textColor: UIColor
        let textFont: UIFont
        let textAlignment: NSTextAlignment
        let textNumberOfLines: Int
        let textInsets: NSDirectionalEdgeInsets
        let containerAnchor: NSCollectionLayoutAnchor

        let tintColor: UIColor
        let backgroundColor: UIColor

        override var supplementaryViewType: CollectionViewSupplementaryView.Type {
            InfoCardItem.BadgeView.self
        }

        init(
            text: String,
            elementKind: String,
            textColor: UIColor,
            textFont: UIFont,
            textAlignment: NSTextAlignment,
            textNumberOfLines: Int,
            textInsets: NSDirectionalEdgeInsets,
            containerAnchor: NSCollectionLayoutAnchor,
            tintColor: UIColor,
            backgroundColor: UIColor,
            id: ID = ID()
        ) {
            self.text = text
            self.textColor = textColor
            self.textFont = textFont
            self.textAlignment = textAlignment
            self.textNumberOfLines = textNumberOfLines
            self.textInsets = textInsets
            self.containerAnchor = containerAnchor
            self.tintColor = tintColor
            self.backgroundColor = backgroundColor

            super.init(
                elementKind: elementKind,
                id: id
            )
        }
    }
}


extension InfoCardItem {
    final class BadgeView: CollectionViewSupplementaryView {
        private let label: UILabel
        private var labelLeadingConstraint: NSLayoutConstraint?
        private var labelTopConstraint: NSLayoutConstraint?
        private var labelTrailingConstraint: NSLayoutConstraint?
        private var labelBottomConstraint: NSLayoutConstraint?

        override init(frame: CGRect) {
            label = UILabel()

            super.init(frame: frame)

            setupUI()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            layer.addDefaultCircleCorners()
        }

        override func fill(from item: CollectionViewSupplementaryItem, mode: FillMode) {
            super.fill(from: item, mode: mode)
            guard let castedItem = item as? InfoCardItem.BadgeItem else {
                assertionFailure("?")
                return
            }

            label.text = castedItem.text
            label.font = castedItem.textFont
            label.textColor = castedItem.textColor
            label.textAlignment = castedItem.textAlignment
            label.numberOfLines = castedItem.textNumberOfLines

            tintColor = castedItem.tintColor
            backgroundColor = castedItem.backgroundColor

            labelLeadingConstraint?.constant = castedItem.textInsets.leading
            labelTopConstraint?.constant = castedItem.textInsets.top
            labelTrailingConstraint?.constant = -castedItem.textInsets.trailing
            labelBottomConstraint?.constant = -castedItem.textInsets.bottom
        }
    }
}

private extension InfoCardItem.BadgeView {
    func setupUI() {
        [label].addAsSubviewForConstraintsUse(to: self)

        let labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
        self.labelLeadingConstraint = labelLeadingConstraint

        let labelTopConstraint = label.topAnchor.constraint(equalTo: topAnchor)
        self.labelTopConstraint = labelTopConstraint

        let labelTrailingConstraint = label.trailingAnchor.constraint(equalTo: trailingAnchor)
        self.labelTrailingConstraint = labelTrailingConstraint

        let labelBottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
        self.labelBottomConstraint = labelBottomConstraint

        NSLayoutConstraint.activate([
            labelLeadingConstraint,
            labelTopConstraint,
            labelTrailingConstraint,
            labelBottomConstraint
        ])
    }
}
