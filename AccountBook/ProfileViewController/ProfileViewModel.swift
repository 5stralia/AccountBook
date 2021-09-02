//
//  ProfileViewModel.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/29.
//

import Foundation

class ProfileViewModel: ViewModel, ViewModelType {
    struct Input {
        
    }
    struct Output {
        
    }
    
    let database: Database
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    init(database: Database) {
        self.database = database
        
        super.init()
    }
    
    func test() {
        self.database.createTest()
    }
}
