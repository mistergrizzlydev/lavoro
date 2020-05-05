//
//  MyScheduleViewController.swift
//  Lavoro
//
//  Created by Manish on 30/04/20.
//  Copyright © 2020 Manish. All rights reserved.
//

import UIKit
import KVKCalendar
import SnapKit

class MyScheduleViewController: BaseViewController {
    @IBOutlet weak var calendarParentView: UIView!
    @IBOutlet weak var monthLabel: UILabel!
    private var selectDate: Date = {
        return Date()
    }()
    
    private var events = [Event]()
    
    private lazy var style: Style = {
        var style = Style()
        style.month.isHiddenSeporator = false
        style.timeline.widthTime = 40
        style.timeline.offsetTimeX = 2
        style.timeline.offsetLineLeft = 2
        style.timeline.startFromFirstEvent = false
        style.followInSystemTheme = true
        style.timeline.offsetTimeY = 40
        style.timeline.offsetEvent = 3
        style.timeline.currentLineHourWidth = 40
        style.allDay.isPinned = true
        style.startWeekDay = .sunday
        style.timeHourSystem = .twelveHour
        style.event.isEnableMoveEvent = true
        style.headerScroll.isHiddenTitleDate = true
        return style
    }()

    private lazy var calendarView: CalendarView = {
        let calendar = CalendarView(frame: calendarParentView.bounds, date: selectDate, style: style)
        calendar.delegate = self
        calendar.dataSource = self
        return calendar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        calendarParentView.addSubview(calendarView)
        calendarView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        calendarView.reloadData()
        monthLabel.text = selectDate.toString(dateFormat: "MMMM")
    }
    
    @IBAction func todayButtonTap() {
        calendarView.scrollTo(Date())
    }

}
extension MyScheduleViewController: CalendarDelegate {
    func didChangeEvent(_ event: Event, start: Date?, end: Date?) {
    }
    
    func didAddEvent(_ date: Date?) {
        print(date ?? Date())
    }
    
    func didSelectDate(_ date: Date?, type: CalendarType, frame: CGRect?) {
        selectDate = date ?? Date()
        monthLabel.text = selectDate.toString(dateFormat: "MMMM")
        calendarView.reloadData()
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        print(type, event)
        switch type {
        default:
            break
        }
    }
    
    func didSelectMore(_ date: Date, frame: CGRect?) {
        print(date)
    }
    
    func eventViewerFrame(_ frame: CGRect) {
    }
}

extension MyScheduleViewController: CalendarDataSource {
    func eventsForCalendar() -> [Event] {
        return events
    }
    
    private var dates: [Date] {
        return [1, 3, 5].compactMap({ Calendar.current.date(byAdding: .day, value: $0, to: Date()) })
    }
    
    func willDisplayDate(_ date: Date?, events: [Event]) -> DateStyle? {
        guard let selectDate = dates.first(where: { $0.year == date?.year && $0.month == date?.month && $0.day == date?.day }) else { return nil }
        
        let dateStyle = DateStyle(date: selectDate, backgroundColor: EventColor(.systemOrange))
        return dateStyle
    }
}