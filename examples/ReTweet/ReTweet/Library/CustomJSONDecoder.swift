//
//  CustomJSONDecoder.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/15/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

final class CustomJSONDecoder: JSONDecoder {
  override init() {
    super.init()
    dateDecodingStrategy = .formatted(DateFormatter.realISO)
  }
}
