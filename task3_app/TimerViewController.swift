//
//  ViewController.swift
//  task3_app
//
//  Created by Recep Uyduran on 31.08.2023.
//

import UIKit

enum PickerValueType: CaseIterable {
    case minute, second
}

class TimerViewController: UIViewController {

    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var setResetButton: UIButton!

    private var minutesDataLoop = Array(0...59)
    private var secondsDataLoop = Array(0...59)
    private var timer: Timer?
    private var remaniningSeconds = 0
    private var isPlaying = false
    private var didTimerStart = false
    private var remainingSecondsWhenPaused = 0
    private let current = UNUserNotificationCenter.current()
    private let content = UNMutableNotificationContent()
    private let pickerTypes = PickerValueType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    @IBAction private func playPauseButtonTapped(_ sender: UIButton) {
        isPlaying.toggle()

        if isPlaying {
            startCount()
        } else {
            pauseCount()
        }

        updatePlayPauseButtonTitle()
    }

    @objc private func updateTimer() {
        if remaniningSeconds > 0 {
            remaniningSeconds -= 1

        } else {
            notificationRequst()
            timer?.invalidate()
        }
        updateTimerLabel()
    }

    private func updatePlayPauseButtonTitle() {
        let buttonTitle = isPlaying ? "Pause" : "Play"
        playPauseButton.setTitle(buttonTitle, for: .normal)
    }

    private func startCount() {
        if isPlaying && didTimerStart {
            remaniningSeconds = remainingSecondsWhenPaused
        }

        didTimerStart = true

        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(updateTimer),
            userInfo: nil,
            repeats: true
        )
    }

    private func pauseCount() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            remainingSecondsWhenPaused = remaniningSeconds
        }
    }

    private func updateTimerLabel() {
        let labelMinutes = remaniningSeconds / 60
        let minuteAsString = String(format:"%02d", labelMinutes)
        let labelSeconds = remaniningSeconds % 60
        let secondAsString = String(format:"%02d", labelSeconds)
        timerLabel.text = minuteAsString + " : " + secondAsString
    }

    private func applicationDidEnterBackground(_ application: UIApplication) {
        if timer != nil && isPlaying {
            startCount()
        }
    }

    @IBAction private  func setResetButtonTapped(_ sender: UIButton) {
        resetStatus()
    }

    private func resetStatus() {
        didTimerStart = false
        if isPlaying {
            pauseCount()
            isPlaying = false
            updatePlayPauseButtonTitle()
        }
        remaniningSeconds = 0
        updateTimerLabel()

        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
}


extension TimerViewController {

    private func notificationRequst() {
        content.title = "Timer has elapsed!"
        content.subtitle = "Alarm"
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("task2.mp3"))

        let timeInterval: TimeInterval = 1
        triggerRequest(timeInterval: timeInterval)

    }

    private func triggerRequest(
        timeInterval: TimeInterval,
        isRepeat: Bool = false
    ) {
        let uuidString = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: isRepeat)
        let request = UNNotificationRequest(
            identifier: uuidString,
            content: content,
            trigger: trigger
        )

        resetStatus()

        current.add(request) { error in
            if(error == nil){
                print("successfully")
            }else{
                print("error")
            }
        }
    }

}

extension TimerViewController:
    UIPickerViewDelegate,
        UIPickerViewDataSource
{
    func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return pickerTypes.count
    }

    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        switch pickerTypes[component] {
            case .minute: return minutesDataLoop.count
            case .second: return secondsDataLoop.count
        }
    }

    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        switch pickerTypes[component] {
            case .minute: return String(format: "%02d", minutesDataLoop[row])
            case .second: return String(format: "%02d", secondsDataLoop[row])
        }
    }

    func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {
        if !didTimerStart {
            let selectedMinute = minutesDataLoop[pickerView.selectedRow(inComponent: 0)]
            let minuteAsString = String(format:"%02d", selectedMinute)
            let selectedSecond = secondsDataLoop[pickerView.selectedRow(inComponent: 1)]
            let secondAsString = String(format: "%02d", selectedSecond)

            timerLabel.text = minuteAsString + " : " + secondAsString
            remaniningSeconds = selectedMinute * 60 + selectedSecond
        }
    }
}
