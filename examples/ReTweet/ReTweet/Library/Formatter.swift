//
//  Formatter.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/15/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

extension DateFormatter {
  static let realISO: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return formatter
  }()

  static let shortTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .none
    return formatter
  }()
}
