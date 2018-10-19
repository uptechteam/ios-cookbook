//
//  TimelinePendingTweetCell.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TimelinePendingTweetCell: UITableViewCell, NibInitializable, ReusableCell {

  struct Props: Equatable {
    enum Status: Equatable {
      case sending
      case error
    }

    let username: String
    let time: String
    let tweet: String
    let status: Status
  }

  @IBOutlet private weak var avatarImageView: UIImageView!
  @IBOutlet private weak var usernameLabel: UILabel!
  @IBOutlet private weak var timeLabel: UILabel!
  @IBOutlet private weak var tweetLabel: UILabel!
  @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet fileprivate weak var resendButton: UIButton!

  var disposeOnReuseBag = DisposeBag()

  override func prepareForReuse() {
    super.prepareForReuse()
    disposeOnReuseBag = DisposeBag()
    avatarImageView.kf.cancelDownloadTask()
  }

  func render(props: Props) {
    usernameLabel.text = props.username
    timeLabel.text = props.time
    tweetLabel.text = props.tweet
    setStatus(props.status)
  }

  private func setStatus(_ status: Props.Status) {
    switch status {
    case .error:
      loadingIndicator.stopAnimating()
      resendButton.isHidden = false

    case .sending:
      loadingIndicator.startAnimating()
      resendButton.isHidden = true
    }
  }
}

extension Reactive where Base: TimelinePendingTweetCell {
  var resendTap: Observable<Void> {
    return base.resendButton.rx.tap.asObservable()
  }
}
