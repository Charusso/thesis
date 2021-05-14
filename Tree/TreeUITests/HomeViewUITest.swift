import XCTest

class HomeViewUITest: BaseUITest {
  override func setUp() {
    app.buttons["Home"].tap()
  }
  
  func testDefaultLevel() {
    XCTAssertTrue(app.staticTexts[" Level 1 "].exists)
    XCTAssertTrue(app.staticTexts["0 / 2,400"].exists)
  }
  
  func testUndefinedTagPresent() {
    let tagPicker = app.pickers["tag picker"]
    XCTAssertTrue(tagPicker.exists)
    print(tagPicker.staticTexts["Undefined"].exists)
  }
  
  func testSliderUpdatesTheTimer() {
    XCTAssertTrue(app.staticTexts["05:00"].exists)
    app.sliders["doing time"].adjust(toNormalizedSliderPosition: 0.5)
    XCTAssertTrue(app.staticTexts["40:00"].exists)
    app.sliders["doing time"].adjust(toNormalizedSliderPosition: 1)
    XCTAssertTrue(app.staticTexts["01:20:00"].exists)
  }
  
  func testStartButtonTriggersPauseAndStopButtons() {
    XCTAssertTrue(app.buttons["start"].exists)
    XCTAssertTrue(app.buttons["stop"].exists)
    XCTAssertFalse(app.buttons["stop"].isEnabled)
    
    app.buttons["start"].tap()
    XCTAssertTrue(app.buttons["pause"].exists)
    XCTAssertTrue(app.buttons["stop"].isEnabled)
  }
  
  func testProgression() {
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    app.buttons["start"].tap()
    sleep(1)
    XCTAssertEqual(app.staticTexts["normal timer"].label, "01:00",
                  "In test mode one second progress worth 1 minute.")
  }
  
  func testStopButtonTriggersAlert() {
    testStartButtonTriggersPauseAndStopButtons()
    app.buttons["stop"].tap()
    XCTAssertTrue(app.alerts["Session stop"].exists)
  }
  
  func testSessionStopAlert() {
    testStopButtonTriggersAlert()
    XCTAssertTrue(app.buttons["Cancel"].exists)
    app.buttons["Cancel"].tap()
    
    // Make a second progress.
    sleep(1)
    XCTAssertEqual(app.staticTexts["normal timer"].label, "01:00")
    
    // Idle while the alert is active.
    app.buttons["stop"].tap()
    sleep(1)
    XCTAssertEqual(app.staticTexts["normal timer"].label, "01:00",
                  "The active alert should pause the progression.")
    
    // Stop the session.
    app.buttons["stop"].tap()
    XCTAssertTrue(app.buttons["Yes"].exists)
    app.buttons["Yes"].tap()
    
    // Dismiss the finished task.
    app.swipeDown()
    
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00",
                  "The confirmed alert should stop the session.")
  }
  
  func testFinishTask() {
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    app.buttons["start"].tap()
    sleep(5)
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00",
                   "In test mode one second progress worth 1 minute.")
    
    XCTAssertTrue(app.buttons["confirm"].exists,
                  "After the task finished the user needs to confirm it.")
    app.buttons["confirm"].tap()
    
    // Dismiss the finished task.
    app.swipeDown()
    
    XCTAssertTrue(app.staticTexts["05:00"].exists,
                  "The confirmed task should stop the session.")
  }
  
  func testSessionProgressGrowingModeIncreaseAndThenDecrease() {
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    let treeProgress = app.progressIndicators["tree progress"]
    app.buttons["Growing"].tap()
    app.buttons["start"].tap()
    
    XCTAssertEqual(treeProgress.value as! String, "0%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "00:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "20%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "01:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(3)
    XCTAssertEqual(treeProgress.value as! String, "80%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "04:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "100%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "80%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "04:00")
    sleep(3)
    XCTAssertEqual(treeProgress.value as! String, "20%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "01:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "0%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "00:00")
    
    // Dismiss the unfinished task.
    sleep(1)
    app.swipeDown()
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00",
                  "The unfinished task should stop the session.")
  }
  
  func testSessionProgressPanickingModeDecreaseAndThenDecrease() {
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    let treeProgress = app.progressIndicators["tree progress"]
    app.buttons["Panicking"].tap()
    app.buttons["start"].tap()
    
    XCTAssertEqual(treeProgress.value as! String, "100%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "80%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "04:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(3)
    XCTAssertEqual(treeProgress.value as! String, "20%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "01:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "100%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "00:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "05:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "80%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "00:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "04:00")
    sleep(3)
    XCTAssertEqual(treeProgress.value as! String, "20%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "00:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "01:00")
    sleep(1)
    XCTAssertEqual(treeProgress.value as! String, "0%")
    XCTAssertEqual(app.staticTexts["normal timer"].label, "00:00")
    XCTAssertEqual(app.staticTexts["overflow timer"].label, "00:00")
    
    // Dismiss the unfinished task.
    sleep(1)
    app.swipeDown()
    XCTAssertEqual(app.staticTexts["normal timer"].label, "05:00",
                   "The unfinished task should stop the session.")
  }
  
  func testExperienceProgressUpdates() {
    testDefaultLevel()
    testFinishTask()
    XCTAssertTrue(app.staticTexts["50 / 2,400"].exists,
                  "Fives minutes of finished work worth 50 experience points.")
  }
  
  func testUnfinishedTaskGivesHalfExperiencePoints() {
    // Make a second progress.
    app.buttons["start"].tap()
    sleep(1)
    
    // Stop the session.
    app.buttons["stop"].tap()
    app.alerts["Session stop"].buttons["Yes"].tap()
    
    // Dismiss the finished task.
    app.swipeDown()
    
    XCTAssertTrue(app.staticTexts["5 / 2,400"].exists,
                  "One minute of unfinished work worth 5 experience points.")
  }
}
