//
//  ComposeTweetView.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit

final class ComposeTweetContentView: UIView, NibInitializable {

  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var tweetTextView: UITextView!

  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }

  private func setup() {
    tweetTextView.textContainerInset = .zero
    tweetTextView.textContainer.lineFragmentPadding = 0
  }
}
