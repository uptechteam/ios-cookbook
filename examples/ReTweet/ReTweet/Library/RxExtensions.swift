//
//  RxExtensions.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift

extension ObservableType {
  func filterNil<T>() -> Observable<T> where E == T? {
    return self.filter { $0 != nil }.map { $0! }
  }

  func voidValues() -> Observable<Void> {
    return self.map { _ in Void() }
  }
}
