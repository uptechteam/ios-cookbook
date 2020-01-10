//
//  TimelineViewController.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TimelineViewController: UIViewController {

  struct Props {
    enum Item: Equatable {
      case tweet(TimelineTweetCell.Props)
      case pendingTweet(TimelinePendingTweetCell.Props)
    }

    let items: [Item]
    let isLoading: Bool
    let error: String?
  }

  private let newTweetButton = UIBarButtonItem(barButtonSystemItem: .compose, target: nil, action: nil)
  private lazy var contentView = TimelineContentView()
  private let errorPresenter = ErrorPresenter()

  private let timelineProvider: TimelineProvider
  private let store: Store
  private let disposeBag = DisposeBag()
  private var renderedProps: Props?

  init(user: User, timelineProvider: TimelineProvider) {
    self.timelineProvider = timelineProvider
    self.store = Store(
      initialState: TimelineViewController.State(
        user: user,
        timeline: [],
        isLoading: false,
        updateIntent: nil,
        error: nil
      ),
      reducer: TimelineViewController.reduce,
      middlewares: [TimelineViewController.makeProviderMiddleware(timelineProvider: timelineProvider)]
    )

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
    bindToModel()
    bindToStore()
    setupUIActions()

    store.dispatch(action: .loadTweets)
  }

  private func setupUI() {
    title = "Timeline"
    navigationItem.rightBarButtonItem = newTweetButton
  }

  private func bindToModel() {
    timelineProvider.timelineDidChange
      .subscribe(onNext: { [unowned self] in
        self.store.dispatch(action: .updateTimeline(self.timelineProvider.timeline))
      })
      .disposed(by: disposeBag)

    timelineProvider.timelineDidFailToLoad
      .subscribe(onNext: { [unowned self] in
        self.store.dispatch(action: .displayTimelineError($0))
      })
      .disposed(by: disposeBag)
  }

  private func bindToStore() {
    store.state
      .map(TimelineViewController.makeProps(from:))
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in
        self.render(props: $0)
      })
      .disposed(by: disposeBag)
  }

  func setupUIActions() {
    contentView.delegate = self

    newTweetButton.target = self
    newTweetButton.action = #selector(showComposeTweet)

    errorPresenter.onDismiss = { [store] in
      store.dispatch(action: .dismissError)
    }
  }

  private func render(props: Props) {
    if renderedProps?.items != props.items {
      contentView.setItems(props.items)
    }

    if renderedProps?.isLoading != props.isLoading {
      contentView.toggleLoading(on: props.isLoading)
    }

    if let error = props.error, renderedProps?.error != error {
      errorPresenter.present(error: error, on: self)
    }

    renderedProps = props
  }

  @objc
  private func showComposeTweet() {
    let composeViewController = ComposeTweetViewController(timelineProvider: timelineProvider)
    composeViewController.delegate = self
    let composeNavigationController = UINavigationController(rootViewController: composeViewController)
    present(composeNavigationController, animated: true, completion: nil)
  }
}

extension TimelineViewController: TimelineContentViewDelegate {
  func timelineContentViewDidRefresh(_ view: TimelineContentView) {
    store.dispatch(action: .loadTweets)
  }

  func timelineContentView(_ view: TimelineContentView, didTapResendButtonAtIndex index: Int) {
    store.dispatch(action: .resendTweet(index: index))
  }
}

extension TimelineViewController: ComposeTweetViewControllerDelegate {
  func composeTweetViewControllerDidFinish(_ viewController: ComposeTweetViewController) {
    dismiss(animated: true)
  }
}
