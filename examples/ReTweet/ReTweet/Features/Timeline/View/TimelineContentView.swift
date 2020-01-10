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

protocol TimelineContentViewDelegate: AnyObject {
  func timelineContentViewDidRefresh(_ view: TimelineContentView)
  func timelineContentView(_ view: TimelineContentView, didTapResendButtonAtIndex: Int)
}

final class TimelineContentView: UIView {

  fileprivate typealias DataSource = RxTableViewSectionedReloadDataSource<SectionModel<Void, TimelineViewController.Props.Item>>

  weak var delegate: TimelineContentViewDelegate?

  private let refreshControl = UIRefreshControl()
  private let tableView = UITableView()
  private var dataSource: DataSource!

  private let items = PublishSubject<[TimelineViewController.Props.Item]>()
  private let disposeBag = DisposeBag()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  private func setup() {
    dataSource = makeDataSource()

    refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)

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

  private func makeDataSource() -> TimelineContentView.DataSource {
    return TimelineContentView.DataSource(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
      switch item {
      case .tweet(let props):
        let cell: TimelineTweetCell = tableView.dequeueReusableCell(for: indexPath)
        cell.render(props: props)
        return cell

      case .pendingTweet(let props):
        let cell: TimelinePendingTweetCell = tableView.dequeueReusableCell(for: indexPath)
        cell.render(props: props)

        cell.rx.resendTap
          .subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.delegate?.timelineContentView(self, didTapResendButtonAtIndex: indexPath.row)
          })
          .disposed(by: cell.disposeOnReuseBag)

        return cell
      }
    })
  }

  @objc private func handleRefreshControl() {
    if refreshControl.isRefreshing {
      DispatchQueue.main.async {
        self.delegate?.timelineContentViewDidRefresh(self)
      }
    }
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

