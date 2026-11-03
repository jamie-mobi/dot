//
//  RecentKey.swift
//  Opal
//
//  Created by Jamie Le Souef on 03/11/2026.
//

import OpalCore

struct RecentKey: Hashable {
    let paths: [NotePath]
    let revision: Int
}
