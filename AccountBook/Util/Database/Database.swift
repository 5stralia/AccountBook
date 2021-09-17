//
//  Database.swift
//  AccountBook
//
//  Created by 최호주 on 2021/09/01.
//

import Foundation

import Firebase
import FirebaseFirestoreSwift
import RxSwift

final class Database {
    let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func createGroup(_ creatingGroup: Group, uid: String) -> Completable {
        return self.documentID(creatingGroup, uid: uid)
            .flatMapCompletable { documentID in
                self.addGroup(to: uid, documentID: documentID)
            }
    }
    
    private func documentID(_ creatingGroup: Group, uid: String) -> Single<String> {
        return Single.create { single in
            do {
                let docRef: DocumentReference = self.db.collection("groups").document()
                try docRef.setData(from: creatingGroup) { error in
                    if let error = error {
                        Crashlytics.crashlytics().log("Error adding document: \(error)")
                        Crashlytics.crashlytics().record(error: NSError(domain: "Create Group Fail",
                                                                        code: -1,
                                                                        userInfo: nil))
                        
                        single(.failure(error))
                        
                    } else {
                        do {
                            try docRef.collection("Users").document().setData(
                                from: GroupUser(uid: uid,
                                                name: "그룹장",
                                                unpaid_amount: 0,
                                                role: [.admin, .manager])) { setUserError in
                                if let setUserError = setUserError {
                                    single(.failure(setUserError))
                                } else {
                                    single(.success(docRef.documentID))
                                }
                            }
                        } catch let error {
                            single(.failure(error))
                        }
                    }
                }
            } catch let error {
                single(.failure(error))
            }
            
            return Disposables.create { }
        }
    }
    
    private func addGroup(to uid: String, documentID: String) -> Completable {
        return Completable.create { completable in
            let docRef = self.db.collection("Users").document(uid)
            docRef.getDocument { document, error in
                if let document = document, document.exists {
                    docRef.updateData([
                        "groups": FieldValue.arrayUnion([documentID])
                    ]) { updateError in
                        if let updateError = updateError {
                            completable(.error(updateError))
                        } else {
                            completable(.completed)
                        }
                    }
                } else {
                    docRef.setData([
                        "groups": [documentID]
                    ]) { setDataError in
                        if let setDataError = setDataError {
                            completable(.error(setDataError))
                        } else {
                            completable(.completed)
                        }
                    }
                }
            }
            
            return Disposables.create { }
        }
    }
    
    func currentGroup(uid: String) -> Single<Group?> {
        return self.groupIDs(uid: uid)
            .flatMap { [weak self] in
                guard let self = self else { return Single.never() }
                if let id = $0.first {
                    return self.group(groupID: id)
                } else {
                    return Single.just(nil)
                }
            }
    }
    
    private func group(groupID: String) -> Single<Group?> {
        return Single.create { single in
            let docRef = self.db.collection("groups").document(groupID)
            docRef.getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                } else if let document = document, document.exists {
                    do {
                        if let group = try document.data(as: Group.self) {
                            single(.success(group))
                        } else {
                            single(.failure(DatabaseError.decodingFail))
                        }
                        
                    } catch let error {
                        single(.failure(error))
                    }
                }
            }
            
            return Disposables.create { }
        }
    }
    
    private func groupIDs(uid: String) -> Single<[String]> {
        return Single.create { single in
            let docRef = self.db.collection("Users").document(uid)
            docRef.getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                    
                } else if let document = document, document.exists {
                   if let groupIDs = document.data()?["groups"] as? [String] {
                    single(.success(groupIDs))
                   } else {
                    single(.failure(DatabaseError.decodingFail))
                   }
                    
                } else {
                    single(.success([]))
                }
            }
            
            return Disposables.create { }
        }
    }
}

