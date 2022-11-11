//
//  Tickable.swift
//  App
//
//  Created by x on 11/11/2022.
//

import Foundation

class TickableObject: ObservableObject {
    @Published internal var _tick:Int = 0
    internal func tick() {
        self._tick += 1
    }
}
