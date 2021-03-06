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
        return self.documentID(creatingGroup: creatingGroup, uid: uid)
            .flatMapCompletable { documentID in
                self.addGroup(to: uid, documentID: documentID)
            }
    }
    
    private func documentID(creatingGroup: GroupDocumentModel, uid: String) -> Single<String> {
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
                                                          role: [.read, .write, .manage])) { setUserError in
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
            let docRef = self.db.collection("users").document(uid)
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
    
    func requestAccounts(gid: String, startDate: Date? = nil, endDate: Date? = nil) -> Single<[AccountDocumentModel]> {
        return Single.create { single in
            let docRef = self.db.collection("groups").document(gid)
            let ref = docRef.collection("accounts")
            var query: Query?
            if let startDate = startDate {
                query = ref.whereField("date", isGreaterThan: startDate)
            }
            if let endDate = endDate {
                query = (query ?? ref).whereField("date", isLessThan: endDate)
            }
            (query ?? ref)
                .order(by: "date")
                .getDocuments() { querySnapshot, error in
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
    
    func append(gid: String, account: AccountDocumentModel) -> Completable {
        return Completable.create { completable in
            let docRef = self.db.collection("groups").document(gid).collection("accounts").document()
            do {
                try docRef.setData(from: account) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                }
            } catch let err {
                completable(.error(err))
            }
            
            return Disposables.create { }
        }
    }
    
    func requestMembers(gid: String) -> Single<[MemberDocumentModel]> {
        return Single.create { single in
            let docRef = self.db.collection("groups").document(gid)
            docRef.collection("members").getDocuments() { querySnapshot, error in
                if let error = error {
                    return single(.failure(error))
                } else {
                    let memberDocumentModels = querySnapshot!.documents.compactMap {
                        try? $0.data(as: MemberDocumentModel.self)
                    }
                    return single(.success(memberDocumentModels))
                }
            }
            
        return Disposables.create { }
        }
    }
    
    func add(gid: String, member: MemberDocumentModel) -> Completable {
        return Completable.create { completable in
            let docRef = self.db.collection("groups")
                .document(gid)
                .collection("members")
                .document()
            do {
                try docRef.setData(from: member) { error in
                    if let error = error {
                        completable(.error(error))
                    } else {
                        completable(.completed)
                    }
                }
            } catch let err {
                completable(.error(err))
            }
            
            return Disposables.create { }
        }
    }
    
    func createInvitation(gid: String) -> Single<String> {
        return Single.create { single in
            let invitation = InvitationModel(isUsed: false, expired: Date().forwardMonth(1), gid: gid)
            
            let docRef = self.db.collection("invitations")
                .document()
            do {
                try docRef.setData(from: invitation) { error in
                    if let error = error {
                        single(.failure(error))
                    } else {
                        single(.success(docRef.documentID))
                    }
                }
            } catch let err {
                single(.failure(err))
            }
            
            return Disposables.create { }
        }
    }
    
    struct AlreadyUsedError: Error { }
    func requestJoin(id: String, member: MemberDocumentModel) -> Completable {
        return Completable.create { completable in
            let invitationRef = self.db.collection("invitations").document(id)
            
            self.db.runTransaction({ transaction, errorPointer in
                let invitationDoc: DocumentSnapshot
                do {
                    try invitationDoc = transaction.getDocument(invitationRef)
                    guard let invitation = try invitationDoc.data(as: InvitationModel.self)
                    else {
                        let error = NSError(domain: "requestInvitation",
                                            code: -1,
                                            userInfo: [
                                                NSLocalizedDescriptionKey: "초대장 가져오기 에러"
                                            ])
                        errorPointer?.pointee = error
                        return nil
                    }
                    
                    if invitation.isUsed {
                        errorPointer?.pointee = AlreadyUsedError() as NSError
                        return nil
                    }
                    
                    let userRef = self.db.collection("users")
                        .document(member.uid)
                    let userDoc = try transaction.getDocument(userRef)
                    let groups = (userDoc.data()?["groups"] as? [String]) ?? []
//                    else {
//                        let error = NSError(domain: "requestInvitation",
//                                            code: -2,
//                                            userInfo: [
//                                                NSLocalizedDescriptionKey: "그룹 가져오기 에러"
//                                            ])
//                        errorPointer?.pointee = error
//                        return nil
//                    }
                    
                    let memberRef = self.db.collection("groups")
                        .document(invitation.gid)
                        .collection("members")
                        .document()
                    try transaction.setData(from: member, forDocument: memberRef)
                    
                    transaction.updateData(["groups": groups + [invitation.gid]], forDocument: userRef)
                } catch let error as NSError {
                    errorPointer?.pointee = error
                    return nil
                }
                
                transaction.updateData(["isUsed": true], forDocument: invitationRef)
                
                return nil
            }) { object, error in
                if let error = error {
                    completable(.error(error))
                } else {
                    completable(.completed)
                }
            }

            return Disposables.create { }
        }
    }
 
    func registerIfNewUser(uid: String) -> Completable {
        return Completable.create { completable in
            let docRef = self.db.collection("users").document(uid)
            docRef.getDocument() { document, error in
                if let document = document, document.exists {
                    completable(.completed)
                } else {
                    docRef.setData([
                        "groups": [String]()
                    ]) { err in
                        if let err = err {
                            completable(.error(err))
                        } else {
                            completable(.completed)
                        }
                    }
                }
            }
            
            return Disposables.create { }
        }
    }
    
}
