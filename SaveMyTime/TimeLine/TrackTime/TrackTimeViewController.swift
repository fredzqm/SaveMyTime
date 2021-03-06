//
//  TrackTimeViewController.swift
//  SaveMyTime
//
//  Created by Fred Zhang on 5/10/18.
//  Copyright © 2018 Yuan zhou. All rights reserved.
//

import UIKit
import SKFontAwesomeIconPickerView
import Firebase
import UserNotifications

class TrackTimeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var firebaseActivityRef: CollectionReference!
    var listener: ListenerRegistration!
    
    var activities: [Activity]!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activities = []
        self.firebaseActivityRef = Firestore.firestore().collection("user").document(getloggedInUid()).collection("activity")
        self.setUpListener()
    }
    
    func setUpListener() {
        self.listener?.remove()
        self.listener = self.firebaseActivityRef.addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching quotes.  error: \(error!.localizedDescription)")
                return
            }
            self.activities = [Activity]()
            for doc in snapshot.documents {
                let activity = Activity(data: doc.data(), id:doc.documentID)
                self.activities.append(activity)
                self.collectionView.reloadData()
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.activities!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let activityCell = collectionView.dequeueReusableCell(withReuseIdentifier: "activityCell", for: indexPath) as! ActivityCollectionViewCell
        activityCell.display(self.activities[indexPath.row])
        return activityCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedActivity = self.activities[indexPath.row]
        let firebaseRecordRef = Firestore.firestore().collection("user").document(getloggedInUid()).collection("timeLine")
        firebaseRecordRef.order(by: "start", descending:true)
            .limit(to: 1)
            .getDocuments(completion: { (snapshot, error) in
                if let snapshot = snapshot {
                    if !snapshot.documents.isEmpty {
                        let doc = snapshot.documents[0]
                        let record = Record(data: doc.data(), id: doc.documentID)
                        if record.categoryId == selectedActivity.id {
                            record.numTracked = record.numTracked+1
                            record.end = Date()
                            firebaseRecordRef.document(record.id!).updateData(record.data)
                        } else {
                            record.categoryId = selectedActivity.id
                            record.start = record.end
                            record.end = Date()
                            record.numTracked = 1
                            firebaseRecordRef.addDocument(data: record.data)
                        }
                    } else {
                        firebaseRecordRef.addDocument(data:
                            ["start": Date().addingTimeInterval(-100),
                             "end": Date(),
                             "numTracked": 1,
                             "categoryId": selectedActivity.id])
                    }
                    self.tabBarController?.selectedIndex = 0
                    
                    // schedule a notification to remind
                    let content = UNMutableNotificationContent()
                    content.title = "Notification Title"
                    content.subtitle = "Notification Subtitle"
                    content.body = "Some notification body information to be displayed."
                    content.badge = 1
                    content.sound = UNNotificationSound.default()
                    
                    let timeTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1*60, repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: timeTrigger)
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("\(error.localizedDescription)")
                            // Do something with error
                        } else {
                            print("successful")
                            // Request was added successfully
                        }
                    }
                }
            })
    }
}

