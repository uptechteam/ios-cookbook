//
//  TimelineTweetCell.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import Kingfisher

final class TimelineTweetCell: UITableViewCell, NibInitializable, ReusableCell {

  struct Props: Equatable {
    let username: String
    let time: String
    let avatarURL: URL?
    let tweet: String
    let likesAmount: Int
  }

  @IBOutlet private weak var usernameLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var tweetLabel: UILabel!
  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var likesLabel: UILabel!

  override func prepareForReuse() {
    super.prepareForReuse()
    avatarImageView.kf.cancelDownloadTask()
  }

  func render(props: Props) {
    usernameLabel.text = props.username
    timeLabel.text = props.time
    tweetLabel.text = props.tweet
    avatarImageView.kf.setImage(with: props.avatarURL)
    setLikes(props.likesAmount)
  }

  private func setLikes(_ likesAmount: Int) {
    likesLabel.text = "♥ \(likesAmount)"
  }
}
