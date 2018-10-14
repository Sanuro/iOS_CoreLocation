//
//  CLAnnotate+CoreDataProperties.swift
//  
//
//  Created by Katie  Lee on 10/13/18.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension CLAnnotate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CLAnnotate> {
        return NSFetchRequest<CLAnnotate>(entityName: "CLAnnotate")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?

}
