//
//  TodoViewController.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit
import ReactorKit
import RxCocoa
import RxDataSources
import RxViewController
import RxRelay
import Then
import SnapKit
import FSCalendar


class TodoViewController: BaseViewController, View {
  
  // MARK: - Constant
  
  struct Icon {
    static let downIcon = UIImage(named: "down")?
      .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    static let upIcon = UIImage(named: "up")?
      .withTintColor(.systemGray3, renderingMode: .alwaysOriginal)
    static let leftIcon = UIImage(systemName: "chevron.left")?
      .withTintColor(.label, renderingMode: .alwaysOriginal)
    static let rightIcon = UIImage(systemName: "chevron.right")?
      .withTintColor(.label, renderingMode: .alwaysOriginal)
  }
  
  // MARK: - Property
  
  let selectedDay = PublishRelay<Date>()
  let selectedID = PublishRelay<String>()

  let dataSource = RxCollectionViewSectionedReloadDataSource<TaskListSection>(configureCell: {
    _, collectionView,
    indexPath, reactor in
    
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TaskCell.identifier,
      for: indexPath
    ) as? TaskCell
    cell?.reactor = reactor
    
    return cell ?? UICollectionViewCell()
  }, configureSupplementaryView: { dataSource, collectionView, _, indexPath in
    let header = collectionView.dequeueReusableSupplementaryView(
      ofKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskHeaderCell.identifier,
      for: indexPath
    ) as? TaskHeaderCell
    let reactor = dataSource[indexPath.section].model
    header?.configureUI()
    header?.reactor = reactor
    
    return header ?? UICollectionReusableView()
  })
  
  let headerDateFormatter = DateFormatter().then {
    $0.dateFormat = "YYYY년 MM월 W주차"
    $0.locale = Locale(identifier: "ko_kr")
    $0.timeZone = TimeZone(identifier: "KST")
  }
  // MARK: - UI
  
  private lazy var calendarView = FSCalendar(frame: .zero)
  
  private lazy var toggleButton = UIButton().then {
    $0.setTitle("주", for: .normal)
    
    $0.setTitleColor(.label, for: .normal)
    $0.setImage(Icon.downIcon, for: .normal)
    $0.backgroundColor = .systemGray6
    $0.semanticContentAttribute = .forceRightToLeft
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12.0,
                                      bottom: 0, right: 0)
    $0.layer.cornerRadius = 4.0
  }
  
  private lazy var leftButton = UIButton().then {
    $0.setImage(Icon.leftIcon, for: .normal)
    $0.addTarget(self, action: #selector(tapLeftButton), for: .touchUpInside)
  }
  
  private lazy var rightButton = UIButton().then {
    $0.setImage(Icon.rightIcon, for: .normal)
    $0.addTarget(self, action: #selector(tapRightButton), for: .touchUpInside)
  }
  
  private lazy var headerLabel = UILabel().then { [weak self] in
    guard let self = self else { return }
    
    $0.font = .systemFont(ofSize: 16.0, weight: .bold)
    $0.textColor = .label
    $0.text = self.headerDateFormatter.string(from: Date())
  }
  
  private lazy var taskCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    let layout = UICollectionViewFlowLayout()
    
    $0.alwaysBounceVertical = true
    $0.collectionViewLayout = layout
    $0.backgroundColor = .systemBackground
    $0.register(
      TaskHeaderCell.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: TaskHeaderCell.identifier
    )
    $0.register(
      TaskCell.self,
      forCellWithReuseIdentifier: TaskCell.identifier
    )
    
  }
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    configureLayout()
    configureCalendar()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    calendarView.select(Date())
    self.selectedDay.accept(Date())
  }
  
  // MARK: - Initialize
  init(_ reactor: TodoViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Binding
  func bind(reactor: TodoViewReactor) {
    
    // action
    
    self.rx.viewDidLoad
      .map { Reactor.Action.load }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.selectedDay
      .map { Reactor.Action.selectedDay($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.selectedID
      .map { Reactor.Action.selectedId($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.toggleButton.rx.tap
      .map { Reactor.Action.tapToggle }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.taskCollectionView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        guard let self = self else { return }
        
        guard let editReactor = self.reactor?.reactorForTaskEdit(indexPath: indexPath) else { return }
        let id = editReactor.currentState.task.id
        editReactor.todoRelay = reactor.todoRelay
        self.selectedID.accept(id)
        
        let editVC = TaskEditViewController(editReactor)
        editVC.modalPresentationStyle = .custom
        editVC.transitioningDelegate = self
        self.present(editVC, animated: true)
      })
      .disposed(by: self.disposeBag)
  
    // state
    
    reactor.state.asObservable().map { $0.sections }
      .bind(to: self.taskCollectionView.rx.items(dataSource: self.dataSource))
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable().map { $0.isWeekScope }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] in
        guard let self = self else { return }
        if $0 == true {
          self.calendarView.setScope(.week, animated: true)

          self.headerDateFormatter.dateFormat = "YYYY년 MM월 W주차"
          self.toggleButton.setTitle("주", for: .normal)
          self.toggleButton.setImage(Icon.downIcon, for: .normal)
          self.headerLabel.text = self.headerDateFormatter.string(from: self.calendarView.currentPage)
          
        } else {
          self.calendarView.setScope(.month, animated: true)

          self.calendarView.scope = .month
          self.calendarView.setScope(.month, animated: true)
          self.headerDateFormatter.dateFormat = "YYYY년 MM월"
          self.toggleButton.setTitle("월", for: .normal)
          self.toggleButton.setImage(Icon.upIcon, for: .normal)
          self.headerLabel.text = self.headerDateFormatter.string(from: self.calendarView.currentPage)

        }
      })
      .disposed(by: self.disposeBag)

    // delegate
    
    taskCollectionView.rx.setDelegate(self)
      .disposed(by: self.disposeBag)
  }
}

// MARK: - CollectionView

extension TodoViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: self.view.frame.width, height: 48.0)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    return CGSize(width: 100.0, height: 40.0)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 0
  }
}

// MARK: - FSCalendar

extension TodoViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
  
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    self.selectedDay.accept(date)
  }
  
  func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    calendarView.snp.updateConstraints {
      $0.height.equalTo(bounds.height)
    }
    self.view.layoutIfNeeded()
  }
  
  func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    let currentPage = calendarView.currentPage
    
    headerLabel.text = headerDateFormatter.string(from: currentPage)
  }
  
  private func configureCalendar() {
    
    calendarView.delegate = self
    calendarView.dataSource = self
    
    calendarView.select(Date())
    
    calendarView.locale = Locale(identifier: "ko_KR")
    
    calendarView.appearance.headerDateFormat = "YYYY년 MM월 W주차"
    calendarView.appearance.headerTitleColor = .clear
    calendarView.appearance.headerTitleAlignment = .center
    calendarView.appearance.headerMinimumDissolvedAlpha = 0.0
    calendarView.appearance.headerTitleFont = .systemFont(ofSize: 18.0)
    calendarView.appearance.selectionColor = .defaultTintColor
    
    let offset: Double = (self.view.frame.width - ("YYYY년 MM월 W주차" as NSString)
      .size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)])
      .width - 16.0 ) / 2.0
    calendarView.appearance.headerTitleOffset = CGPoint(x: -offset, y: 0)
    
    calendarView.weekdayHeight = 36.0
    calendarView.headerHeight = 36.0
    
    calendarView.appearance.weekdayFont = .systemFont(ofSize: 14.0)
    calendarView.appearance.titleFont = .systemFont(ofSize: 14.0)
    calendarView.appearance.titleTodayColor = .label
    calendarView.appearance.titleDefaultColor = .secondaryLabel
    
    calendarView.appearance.todayColor = .clear
    calendarView.appearance.weekdayTextColor = .label
    
    calendarView.placeholderType = .none
    
    calendarView.scrollEnabled = true
    calendarView.scrollDirection = .horizontal
  }
  
  func getNextWeek(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: date)!
  }
  
  func getPreviousWeek(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: date)!
  }
  
  func getNextMonth(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .month, value: 1, to: date)!
  }
  
  func getPreviousMonth(date: Date) -> Date {
    return  Calendar.current.date(byAdding: .month, value: -1, to: date)!
  }
}

// MARK: - ViewControllerTransitioning

extension TodoViewController: UIViewControllerTransitioningDelegate {
  func presentationController(
    forPresented presented: UIViewController,
    presenting: UIViewController?,
    source: UIViewController
  ) -> UIPresentationController? {
    TaskEditPresentaionController(
      presentedViewController: presented,
      presenting: presenting
    )
  }
}

// MARK: - Method

extension TodoViewController {
  
  private func configureLayout() {
    
    navigationItem.title = "Todo"
    
    let calendarButtonStackView = UIStackView(arrangedSubviews: [
      leftButton,
      rightButton,
      toggleButton
    ]).then {
      $0.axis = .horizontal
      $0.distribution = .equalSpacing
      $0.spacing = 12.0
      
      toggleButton.snp.makeConstraints {
        $0.height.equalTo(28.0)
        $0.width.equalTo(60.0)
      }
    }
    
    [
      calendarView,
      calendarButtonStackView,
      headerLabel,
      taskCollectionView
    ].forEach { view.addSubview($0) }
    
    calendarView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.trailing.leading.equalToSuperview().inset(12.0)
      $0.height.equalTo(300.0)
    }
    
    calendarButtonStackView.snp.makeConstraints {
      $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
      $0.trailing.equalTo(calendarView.collectionView)
      $0.height.equalTo(28.0)
    }
    
    headerLabel.snp.makeConstraints {
      $0.centerY.equalTo(calendarView.calendarHeaderView.snp.centerY)
      $0.leading.equalTo(calendarView.collectionView)
    }
    
    taskCollectionView.snp.makeConstraints {
      $0.top.equalTo(calendarView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }
  
  // MARK: - Selector
  
  @objc func tapToggleButton() {
    if self.calendarView.scope == .month {
      self.calendarView.setScope(.week, animated: true)
      
      self.headerDateFormatter.dateFormat = "YYYY년 MM월 W주차"
      self.toggleButton.setTitle("주", for: .normal)
      self.toggleButton.setImage(Icon.downIcon, for: .normal)
      self.headerLabel.text = headerDateFormatter.string(from: calendarView.currentPage)
      
    } else {
      self.calendarView.setScope(.month, animated: true)
      self.headerDateFormatter.dateFormat = "YYYY년 MM월"
      self.toggleButton.setTitle("월", for: .normal)
      self.toggleButton.setImage(Icon.upIcon, for: .normal)
      self.headerLabel.text = headerDateFormatter.string(from: calendarView.currentPage)
    }
  }
  
  @objc func tapLeftButton() {
    if self.reactor?.currentState.isWeekScope == true {
      self.calendarView.setCurrentPage(getPreviousWeek(date: calendarView.currentPage), animated: true)
    } else {
      self.calendarView.setCurrentPage(getPreviousMonth(date: calendarView.currentPage), animated: true)
    }
  }
  
  @objc func tapRightButton() {
    if self.reactor?.currentState.isWeekScope == true {
      self.calendarView.setCurrentPage(getNextWeek(date: calendarView.currentPage), animated: true)
    } else {
      self.calendarView.setCurrentPage(getNextMonth(date: calendarView.currentPage), animated: true)
    }
  }
}
