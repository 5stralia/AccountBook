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

final class ABAPI {
    let db: Firestore
    
    init(db: Firestore) {
        self.db = db
    }
    
    func createGroup(_ creatingGroup: GroupDocumentModel, uid: String) -> Completable {
        return self.documentID(creatingGroup, uid: uid)
            .flatMapCompletable { documentID in
                self.addGroup(to: uid, documentID: documentID)
            }
    }
    
    private func documentID(_ creatingGroup: GroupDocumentModel, uid: String) -> Single<String> {
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
                            try docRef.collection("members").document().setData(
                                from: MemberDocumentModel(uid: uid,
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
    
    func group(groupID: String) -> Single<GroupDocumentModel?> {
        return Single.create { single in
            let docRef = self.db.collection("groups").document(groupID)
            docRef.getDocument { document, error in
                if let error = error {
                    single(.failure(error))
                } else if let document = document, document.exists {
                    do {
                        if let group = try document.data(as: GroupDocumentModel.self) {
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
    
    func groupIDs(uid: String) -> Single<[String]> {
        return Single.create { single in
            let docRef = self.db.collection("users").document(uid)
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
    
    func requestAccounts(gid: String) -> Single<[AccountDocumentModel]> {
        return Single.create { single in
            let docRef = self.db.collection("groups").document(gid)
            docRef.collection("accounts").getDocuments() { querySnapshot, error in
                if let error = error {
                    return single(.failure(error))
                } else {
                    let accountDocumentModels = querySnapshot!.documents.compactMap {
                        try? $0.data(as: AccountDocumentModel.self)
                    }
                    return single(.success(accountDocumentModels))
                }
            }
            
            return Disposables.create { }
        }
    }
}

