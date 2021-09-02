//
//  Database.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/01.
//

import Foundation

import Firebase

final class Database {
    let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func createTest() {
        var ref: DocumentReference? = nil
        ref = self.db.collection("groups").addDocument(data: [
            "test": "test"
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
}
