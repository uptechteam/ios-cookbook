//
//  NetworkOutgoingTweet.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/12/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

struct NetworkOutgoingTweet: Encodable {
  let username: String
  let text: String
  let clientID: String
}
