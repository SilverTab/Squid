//
//  String.swift
//  Squid
//
//  Created by Oliver Borchert on 9/22/19.
//

import Foundation

extension String {
    
    internal func indent(spaces: Int, skipLines: Int = 0) -> String {
        return self
            .split { c in c == "\n" }
            .enumerated()
            .map { i, line in
                i < skipLines ? line : String.init(repeating: " ", count: spaces) + line
            }.joined(separator: "\n")
    }
    
    internal func prefixed(with prefix: String) -> String {
        return self
            .split { c in c == "\n" }
            .map { line in prefix + line }
            .joined(separator: "\n")
    }
    
    internal func truncate(to max: Int) -> String {
        if self.count > max {
            return self.prefix(max - 3) + "..."
        }
        return self
    }
}
