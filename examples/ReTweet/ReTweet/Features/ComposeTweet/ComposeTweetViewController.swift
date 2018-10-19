//
//  ComposeTweetViewController.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ComposeTweetViewController: UIViewController {

  fileprivate let discardButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
  fileprivate let sendButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  fileprivate lazy var contentView = ComposeTweetContentView.initFromNib()

  let disposeBag = DisposeBag()

  init() {
    super.init(nibName: nil, bundle: nil)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    contentView.tweetTextView.becomeFirstResponder()
  }

  private func setup() {
    setupUI()
  }

  private func setupUI() {
    title = "Compose Tweet"
    navigationItem.leftBarButtonItem = discardButton
    navigationItem.rightBarButtonItem = sendButton
  }
}

extension Reactive where Base: ComposeTweetViewController {
  var didDiscard: Observable<Void> {
    return base.discardButton.rx.tap.asObservable()
  }

  var didSubmit: Observable<ComposedTweet> {
    let tweetText = base.contentView.tweetTextView.rx.text
      .asObservable()
      .map { $0 ?? "" }

    return base.sendButton.rx.tap
      .withLatestFrom(tweetText)
      .map(ComposedTweet.init)
  }
}
