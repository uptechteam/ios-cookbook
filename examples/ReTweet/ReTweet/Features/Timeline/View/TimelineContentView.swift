//
//  TimelineContentView.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class TimelineContentView: UIView {

  fileprivate typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, TimelineViewController.Props.Item>>

  private let tableView = UITableView()
  fileprivate let refreshControl = UIRefreshControl()
  private let dataSource: DataSource

  fileprivate let resendTap: Observable<Int>
  private let items = PublishSubject<[TimelineViewController.Props.Item]>()
  private let disposeBag = DisposeBag()

  override init(frame: CGRect) {
    (self.dataSource, self.resendTap) = makeDataSource()
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    tableView.addSubview(refreshControl)
    tableView.register(TimelineTweetCell.self)
    tableView.register(TimelinePendingTweetCell.self)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 170

    addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.leftAnchor.constraint(equalTo: leftAnchor),
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.rightAnchor.constraint(equalTo: rightAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
      ])

    items
      .map { [SectionModel(model: Void(), items: $0)] }
      .bind(to: tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)
  }

  func setItems(_ items: [TimelineViewController.Props.Item]) {
    self.items.onNext(items)
  }

  func toggleLoading(on: Bool) {
    if on {
      refreshControl.beginRefreshing()
    } else {
      refreshControl.endRefreshing()
    }
  }
}

private func makeDataSource() -> (dataSource: TimelineContentView.DataSource, resendTap: Observable<Int>) {
  let resendTap = PublishSubject<Int>()
  let dataSource = TimelineContentView.DataSource(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
    switch item {
    case .tweet(let props):
      let cell: TimelineTweetCell = tableView.dequeueReusableCell(for: indexPath)
      cell.render(props: props)
      return cell

    case .pendingTweet(let props):
      let cell: TimelinePendingTweetCell = tableView.dequeueReusableCell(for: indexPath)
      cell.render(props: props)

      cell.rx.resendTap
        .subscribe(onNext: { resendTap.onNext(indexPath.row) })
        .disposed(by: cell.disposeOnReuseBag)

      return cell
    }
  })

  return (dataSource, resendTap.asObservable())
}

extension Reactive where Base: TimelineContentView {
  var resendButtonTap: Observable<Int> {
    return base.resendTap
  }

  var pullToRefresh: Observable<Void> {
    return base.refreshControl.rx.controlEvent(.valueChanged).asObservable()
  }
}
