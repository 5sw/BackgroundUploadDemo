//
//  ViewController.swift
//  BackgroundUpload
//
//  Created by Sven Weidauer on 27.03.18.
//  Copyright © 2018 Sven Weidauer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var counter: UILabel!
    @IBOutlet weak var log: UITextView!

    lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "de.5sw.test")
        config.waitsForConnectivity = true
        config.isDiscretionary = true
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.register(defaults: ["uploadcount": 0, "log": ""])
        let count = UserDefaults.standard.integer(forKey: "uploadcount")
        counter.text = String.localizedStringWithFormat("Completed: %d", count)

        log.text = UserDefaults.standard.string(forKey: "log") ?? ""

        writeLog("Loaded view")
    }

    func updateCount() {
        let count = UserDefaults.standard.integer(forKey: "uploadcount") + 1
        UserDefaults.standard.set(count, forKey: "uploadcount")
        counter.text = String.localizedStringWithFormat("Completed: %d", count)
    }

    var handler: (() -> Void)?

    func handleBackgroundEvents(identifier: String, handler: @escaping () -> Void) {
        writeLog("Handling background events for configuration \(identifier)")
        self.handler = handler
        _ = self.session
    }

    func writeLog(_ text: String) {
        let date = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let message = "[\(date)]: \(text)\n" + (log.text ?? "")

        log.text = message
        UserDefaults.standard.set(message, forKey: "log")
    }

    @IBAction func startDownload(_ sender: UIButton) {
        writeLog("Starting next upload")
        let count = UserDefaults.standard.integer(forKey: "uploadcount")
        let text = """
            Upload \(count):
            Some data to upload here...
            """
        var url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let filename = "upload-\(count).txt"
        url.appendPathComponent(filename)
        try! text.write(to: url, atomically: true, encoding: .utf8)
        let request = URLRequest(url: URL(string:"https://hookb.in/ZMNGe4gP")!)
        session.uploadTask(with: request, fromFile: url).resume()
    }
}

extension ViewController: URLSessionDataDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        handler?()
        handler = nil
        writeLog("Done with background session")
    }



    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            writeLog("Failed upload: \(error)")
        } else {
            writeLog("Finished upload")
        }
        updateCount()
    }
}
