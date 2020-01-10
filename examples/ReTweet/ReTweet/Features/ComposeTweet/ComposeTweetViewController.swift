//
//  ComposeTweetViewController.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit

protocol ComposeTweetViewControllerDelegate: AnyObject {
  func composeTweetViewControllerDidFinish(_ viewController: ComposeTweetViewController)
}

final class ComposeTweetViewController: UIViewController {

  weak var delegate: ComposeTweetViewControllerDelegate?

  private let timelineProvider: TimelineProvider

  private let discardButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
  private let sendButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
  private lazy var contentView = ComposeTweetContentView.initFromNib()

  init(timelineProvider: TimelineProvider) {
    self.timelineProvider = timelineProvider
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    view = contentView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupUIActions()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    contentView.tweetTextView.becomeFirstResponder()
  }

  private func setupUI() {
    title = "Compose Tweet"
    navigationItem.leftBarButtonItem = discardButton
    navigationItem.rightBarButtonItem = sendButton
  }

  private func setupUIActions() {
    discardButton.target = self
    discardButton.action = #selector(handleDisccardButtonTap)

    sendButton.target = self
    sendButton.action = #selector(handleSendButtonTap)
  }

  @objc
  private func handleDisccardButtonTap() {
    delegate?.composeTweetViewControllerDidFinish(self)
  }

  @objc
  private func handleSendButtonTap() {
    timelineProvider.sendTweet(message: contentView.tweetTextView.text)
    delegate?.composeTweetViewControllerDidFinish(self)
  }
}
