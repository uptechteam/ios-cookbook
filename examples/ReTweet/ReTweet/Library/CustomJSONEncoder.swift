//
//  CustomJSONEncoder.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/15/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

final class CustomJSONEncoder: JSONEncoder {
  override init() {
    super.init()
    dateEncodingStrategy = .formatted(DateFormatter.realISO)
  }
}
