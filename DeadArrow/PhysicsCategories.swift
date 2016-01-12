//
//  PhysicsCategories.swift
//  DeadArrow
//
//  Created by Hesedel on 1/11/16.
//  Copyright © 2016 Pajaron Creative. All rights reserved.
//

enum PhysicsCategories:UInt32 {
    case none    = 0b0000
    case field   = 0b0001
    case wall    = 0b0010
    case arrow   = 0b0100
    case monster = 0b1000
    case all     = 0b1111
}
