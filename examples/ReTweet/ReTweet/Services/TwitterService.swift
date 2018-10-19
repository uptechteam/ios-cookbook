//
//  TwitterService.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/12/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift
import Moya
import RxMoya

enum TwitterTarget {
  case postTweet(NetworkOutgoingTweet)
  case timeline(offset: Int, limit: Int)
}

extension TwitterTarget: TargetType {
  var baseURL: URL {
    return URL(string: "http://localhost:3000/posts")!
  }

  var path: String {
    return "/"
  }

  var method: Moya.Method {
    switch self {
    case .postTweet: return .post
    case .timeline: return .get
    }
  }

  var sampleData: Data {
    return Data()
  }

  var task: Task {
    switch self {
    case .postTweet(let outgoingTweet):
      return Task.requestCustomJSONEncodable(outgoingTweet, encoder: CustomJSONEncoder())

    case .timeline(let offset, let limit):
      return Task.requestParameters(
        parameters: [
          "offset": offset,
          "limit": limit
        ],
        encoding: URLEncoding.default
      )
    }
  }

  var headers: [String: String]? {
    return nil
  }
}

final class TwitterService {

  private let user: User
  private let provider: MoyaProvider<TwitterTarget>
  private let decoder = CustomJSONDecoder()

  init(user: User, provider: MoyaProvider<TwitterTarget>) {
    self.user = user
    self.provider = provider
  }

  func getTimeline(offset: Int, limit: Int) -> Observable<[Tweet]> {
    let target = TwitterTarget.timeline(offset: offset, limit: limit)
    return provider.rx.request(target)
      .filterSuccessfulStatusCodes()
      .map([NetworkTweet].self, using: decoder, failsOnEmptyData: true)
      .debug()
      .map { $0.compactMap(Tweet.init) }
      .asObservable()
  }

  func postTweet(_ tweet: ComposedTweet) -> Observable<Tweet> {
    let newTweet = NetworkOutgoingTweet(username: user.username, text: tweet.text, clientID: tweet.id)
    let target = TwitterTarget.postTweet(newTweet)
    return provider.rx.request(target)
      .filterSuccessfulStatusCodes()
      .map(NetworkTweet.self, using: decoder, failsOnEmptyData: true)
      .asObservable()
      .flatMap { networkTweet -> Observable<Tweet> in
        guard let tweet = Tweet(response: networkTweet) else {
          return Observable.error(MoyaError.requestMapping("Error"))
        }

        return Observable.just(tweet)
      }
      .debug()
  }
}
