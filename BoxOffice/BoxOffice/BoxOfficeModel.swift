//
//  BoxOfficeModel.swift
//  BoxOffice
//
//  Created by 신승아 on 2022/08/22.
//

import Foundation
import RealmSwift

class BoxOffice: Object {
    
    @Persisted var movieTitle: String
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(movieTitle: String) {
        self.init()
        self.movieTitle = movieTitle
    }
}
