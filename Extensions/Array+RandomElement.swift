//
//  Array+RandomElement.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/21/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import Foundation

extension Array {
    var shuffle: [Element] {
        var elements = self
        for index in indices {
            let anotherIndex = Int(arc4random_uniform(UInt32(elements.count - index))) + index
            anotherIndex != index ? swap(&elements[index], &elements[anotherIndex]) : ()
        }
        return elements
    }
    mutating func shuffled() {
        self = shuffle
    }
    var chooseOne: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    func choose(n: Int) -> [Element] {
        return Array(shuffle.prefix(n))
    }
}
