//
//  RecentKey.swift
//  Dot
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import DotCore

struct RecentKey: Hashable {
    let paths: [NotePath]
    let revision: Int
}
