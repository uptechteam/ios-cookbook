//
//  NetworkTweet.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/12/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

struct NetworkTweet: Decodable {
  let clientID: String
  let username: String
  let text: String
  let avatar: String
  let date: Date
  let likes: Int
}
