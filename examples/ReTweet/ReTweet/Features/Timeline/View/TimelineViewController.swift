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

  private let postTweetSubject = PublishSubject<ComposedTweet>()

  private let viewModel: Timeline.ViewModel
  private let disposeBag = DisposeBag()
  private var renderedProps: Props?

  init(user: User, twitterService: TwitterService) {
    self.viewModel = Timeline.ViewModel(user: user, twitterService: twitterService)
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
    setup()
  }

  private func setup() {
    setupUI()
    setupBindings()
  }

  private func setupUI() {
    title = "Timeline"
    navigationItem.rightBarButtonItem = newTweetButton
  }

  private func setupBindings() {
    let inputs = Timeline.ViewModel.Inputs(
      viewWillAppear: rx.methodInvoked(#selector(viewWillAppear(_:))).map({ _ in Void() }),
      pullToRefresh: contentView.rx.pullToRefresh,
      newTweetButtonTap: newTweetButton.rx.tap.asObservable(),
      postTweet: postTweetSubject.asObservable(),
      resendTweet: contentView.rx.resendButtonTap,
      dismissError: errorPresenter.dismissed
    )

    let outputs = viewModel.makeOutputs(from: inputs)

    outputs.props
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in self.render(props: $0) })
      .disposed(by: disposeBag)

    outputs.route
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [unowned self] in self.navigate(by: $0) })
      .disposed(by: disposeBag)

    outputs.stateChanges
      .subscribe()
      .disposed(by: disposeBag)
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

  private func navigate(by route: Timeline.Route) {
    switch route {
    case .newTweet:
      showComposeTweet()
    }
  }

  private func showComposeTweet() {
    let composeViewController = ComposeTweetViewController()
    let composeNavigationController = UINavigationController(rootViewController: composeViewController)
    navigationController?.present(composeNavigationController, animated: true, completion: nil)

    composeViewController.rx.didDiscard
      .subscribe(onNext: { [weak self] in self?.navigationController?.dismiss(animated: true) })
      .disposed(by: composeViewController.disposeBag)

    composeViewController.rx.didSubmit
      .subscribe(onNext: { [weak self] submittedTweet in
        self?.postTweetSubject.onNext(submittedTweet)
        self?.navigationController?.dismiss(animated: true)
      })
      .disposed(by: composeViewController.disposeBag)
  }
}

