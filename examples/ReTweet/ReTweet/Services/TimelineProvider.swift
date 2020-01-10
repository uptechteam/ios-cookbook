//
//  TimelineProvider.swift
//  ReTweet
//
//  Created by Arthur Mironenko on 10.01.2020.
//  Copyright © 2020 Arthur Mironenko. All rights reserved.
//

import Foundation
import RxSwift

final class TimelineProvider {

  var timeline = [TimelineTweet]()
  var timelineDidChange: Observable<Void> { timelineDidChangeSubject.asObservable() }
  var timelineDidFailToLoad: Observable<Error> { timelineErrorSubject.asObservable() }

  private let twitterService: TwitterService

  private let timelineDidChangeSubject = PublishSubject<Void>()
  private let timelineErrorSubject = PublishSubject<Error>()

  private var reloadDisposable: Disposable?
  private let disposeBag = DisposeBag()

  init(twitterService: TwitterService) {
    self.twitterService = twitterService
  }

  func reloadTimeline() {
    reloadDisposable = twitterService.getTimeline(offset: 0, limit: 100)
      .subscribe(
        onSuccess: { [unowned self] remoteTweets in
          self.updateRemoteTweetsInTimeline(remoteTweets: remoteTweets)
        },
        onError: { [unowned self] error in
          self.timelineErrorSubject.onNext(error)
        }
      )
  }

  func sendTweet(message: String) {
    let newTweet = ComposedTweet(text: message)
    timeline.insert(.pending(newTweet, error: nil), at: 0)
    timelineDidChangeSubject.onNext(Void())

    sendTweet(composedTweet: newTweet)
  }

  func resendTweet(id: Tweet.Identifier) {
    guard let tweetIndex = timeline.firstIndex(where: { $0.id == id }) else {
      fatalError("Couldn't find a tweet by id in the timeline")
    }

    guard case let .pending(tweet, error) = timeline[tweetIndex], error != nil else {
      fatalError("No corresponding pending tweet with error found")
    }

    timeline[tweetIndex] = .pending(tweet, error: nil)
    timelineDidChangeSubject.onNext(Void())

    sendTweet(composedTweet: tweet)
  }

  private func sendTweet(composedTweet: ComposedTweet) {
    twitterService.postTweet(composedTweet)
      .subscribe { [unowned self] result in
        switch result {
        case .success(let tweet):
          self.handleSendingTweetCompletion(pendingTweet: composedTweet, result: .success(tweet))
        case .error(let error):
          self.handleSendingTweetCompletion(pendingTweet: composedTweet, result: .failure(error))
        }
      }
      .disposed(by: disposeBag)
  }

  private func updateRemoteTweetsInTimeline(remoteTweets: [Tweet]) {
    timeline.removeAll(where: { $0.isRemote })
    timeline.append(contentsOf: remoteTweets.map(TimelineTweet.remote))
    timeline.sort(by: { $0.date > $1.date })
    timelineDidChangeSubject.onNext(Void())
  }

  private func handleSendingTweetCompletion(pendingTweet: ComposedTweet, result: Result<Tweet, Error>) {
    guard let indexOfPendingTweet = timeline.firstIndex(where: { $0.id == pendingTweet.id }) else {
      print("Error! Couldn't find pending tweet in a timeline")
      return
    }

    switch result {
    case .success(let tweet):
      timeline[indexOfPendingTweet] = .remote(tweet)

    case .failure(let error):
      timeline[indexOfPendingTweet] = .pending(pendingTweet, error: error)
    }

    timelineDidChangeSubject.onNext(Void())
  }
}
