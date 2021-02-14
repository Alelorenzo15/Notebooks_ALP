//
//  HelperDateFormater.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 13/2/21.
//

import Foundation
import CoreData

enum HelperDateFormatter {
    static var format: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
    
    static func textFrom(date: Date) -> String {
        return format.string(from: date)
    }
}

