import Foundation

class DateHandler: ObservableObject {
  enum IntervalKind: String, CaseIterable { case Day, Week, Month, Year }

  @Published var selectedInterval: IntervalKind = IntervalKind.Week
  @Published var selectedDate = Date()
  
  let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = NSLocale(localeIdentifier: "en_US") as Locale
    return calendar
  }()
  
  func enumerateDates(_ callback: (Date) -> Void) {
    let interval = selectedDateInterval
    let components = traversalComponents
    
    calendar.enumerateDates(
      startingAfter: interval.start,
      matching: components,
      matchingPolicy: .nextTime) { date, _, isStop in
      if let date = date, date <= interval.end {
        callback(date)
      } else {
        isStop = true
      }
    }
  }
  
  func matchingDates(_ date1: Date, _ date2: Date) -> Bool {
    calendar.dateComponents(allComponents, from: date1)
      == calendar.dateComponents(allComponents, from: date2)
  }
  
  func resetDate() {
    selectedDate = Date()
  }
  
  func traverseForwards() {
    selectedDate = getNextDate()
  }
  
  func traverseBackwards() {
    selectedDate = getPreviousDate()
  }
  
  var selectedDayIsToday: Bool {
    calendar.dateComponents([.year, .month, .day], from: Date())
      == calendar.dateComponents([.year, .month, .day], from: selectedDate)
  }
  
  var displayDate: String {
    // Extracting the components as strings.
    let year = String(calendar.component(.year, from: selectedDate))
    let month = calendar.shortMonthSymbols[
      calendar.component(.month, from: selectedDate) - 1]
    let weekStartDateComponents =
      calendar.dateComponents([.yearForWeekOfYear, .weekOfYear],
                              from: selectedDate)
    let weekStartDate = calendar.date(from: weekStartDateComponents)!
    let weekEndDate =
      calendar.date(byAdding: .day, value: 6, to: weekStartDate)!
    
    let weekStartMonth = calendar.shortMonthSymbols[
      calendar.component(.month, from: weekStartDate) - 1]
    let weekStartDay = String(calendar.component(.day, from: weekStartDate))
    let weekStart = "\(weekStartMonth) \(weekStartDay)"
    
    let weekEndMonth = calendar.shortMonthSymbols[
      calendar.component(.month, from: weekEndDate) - 1]
    let weekEndDay = String(calendar.component(.day, from: weekEndDate))
    let weekEnd = "\(weekEndMonth) \(weekEndDay)"
    
    let day = calendar.component(.day, from: selectedDate)
    
    // Combine the strings to create the display date.
    switch selectedInterval {
      case .Day:
        return "\(month) \(day), \(year)"
      case .Week:
        return "\(weekStart) - \(weekEnd), \(year)"
      case .Month:
        return "\(month) \(year)"
      case .Year:
        return year
    }
  }
  
  /// Returns the step for traversing the timeline based on the 'selectedInterval'.
  var timelineStep: Calendar.Component {
    switch selectedInterval {
      case .Day:
        return .day
      case .Week:
        return .weekOfYear
      case .Month:
        return .month
      case .Year:
        return .year
    }
  }
  
  /// Returns the date to traverse the timeline backwards.
  func getPreviousDate() -> Date {
    calendar.date(byAdding: timelineStep, value: -1, to: selectedDate)!
  }
  
  /// Returns the date to traverse the timeline forwards.
  func getNextDate() -> Date {
    calendar.date(byAdding: timelineStep, value: 1, to: selectedDate)!
  }
  
  var isNextDateOverflow: Bool {getNextDate() > Date()}
  
  /// All the components to represent the interesting parts of the date.
  var allComponents: Set<Calendar.Component> {
    switch selectedInterval {
      case .Day:
        return [.year, .month, .day, .weekOfYear, .hour]
      case .Week:
        return [.year, .month, .day, .weekOfYear]
      case .Month:
        return [.year, .month, .day]
      case .Year:
        return [.year, .month]
    }
  }
  
  var traversalComponents: DateComponents {
    switch selectedInterval {
      case .Day:
        return DateComponents(minute: 0)
      case .Week:
        return DateComponents(hour: 0)
      case .Month:
        return DateComponents(hour: 0)
      case .Year:
        return DateComponents(weekdayOrdinal: 1)
    }
  }
  
  func getDateLabel(_ date: Date) -> String {
    switch selectedInterval {
      case .Day:
        return String(calendar.component(.hour, from: date))
      case .Week:
        return calendar.shortWeekdaySymbols[
          calendar.component(.weekday, from: date) - 1]
      case .Month:
        return String(calendar.component(.day, from: date))
      case .Year:
        return String(calendar.component(.month, from: date))
    }
  }
  
  /// It creates a traversable date interval around the 'selectedDate' date.
  ///
  /// - Parameters:
  ///   - startComponents: The set of components to create the beginning of
  ///   the date. For example to create the beginning of the year one could
  ///   specify '[.year]' to obtain the year granularity of 'selectedDate' date.
  ///   - offsetComponent: The decrement of the start date. It is useful
  ///   to offset the date by a specific granularity in order to make the date
  ///   range traversable. For example to create the beginning of a traversable
  ///   year to traverse each month we need to use '.month'.
  ///   - rangeComponent: The range granularity to obtain the end date. For
  ///   example to create a year long range we need to use '.year'.
  ///
  /// - Returns: The date interval of the start date to the end date.
  private func selectedDateInterval(
    startComponents: Set<Calendar.Component>,
    offsetComponent: Calendar.Component,
    rangeComponent: Calendar.Component) -> DateInterval {
    var startDate = calendar.date(
      from: calendar.dateComponents(startComponents, from: selectedDate))!
    startDate = calendar.date(
      byAdding: offsetComponent, value: -1, to: startDate)!
    let endDate = calendar.date(
      byAdding: rangeComponent, value: 1, to: startDate)!
    
    return DateInterval(start: startDate, end: endDate)
  }
  
  /// It creates a traversable date interval based on the 'selectedInterval'.
  var selectedDateInterval: DateInterval {
    switch selectedInterval {
      case .Day:
        return selectedDateInterval(
          startComponents: [.year, .month, .day],
          offsetComponent: .hour,
          rangeComponent: .day)
      // ...
      case .Week:
        return selectedDateInterval(
          startComponents: [.yearForWeekOfYear, .weekOfYear],
          offsetComponent: .hour,
          rangeComponent: .weekOfYear)
      case .Month:
        return selectedDateInterval(
          startComponents: [.year, .month],
          offsetComponent: .day,
          rangeComponent: .month)
      case .Year:
        return selectedDateInterval(
          startComponents: [.year],
          offsetComponent: .month,
          rangeComponent: .year)
    }
  }
}
