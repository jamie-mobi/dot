//
//  CommandSection.swift
//  Dot
//
//  Created by Jamie Le Souef on 06/11/2026.
//

struct CommandSection: Identifiable, Hashable {
    // MARK: - Properties

    let title: String
    let commands: [AppCommand]

    // MARK: - Identifiable

    var id: String {
        title
    }

    // MARK: - Make

    static func sections(ordered: [AppCommand], recent: [String], isFiltering: Bool) -> [CommandSection] {
        guard isFiltering == false else {
            return ordered.isEmpty ? [] : [CommandSection(title: "", commands: ordered)]
        }

        let recentCommands = ordered.filter { recent.contains($0.id) }
        var sections = recentCommands.isEmpty ? [] : [CommandSection(title: String(localized: "Recent"), commands: recentCommands)]
        var groups: [String] = []
        for command in AppCommand.allCases where groups.contains(command.group) == false {
            groups.append(command.group)
        }
        for group in groups {
            let commands = ordered.filter { $0.group == group && recentCommands.contains($0) == false }
            if commands.isEmpty == false {
                sections.append(CommandSection(title: group, commands: commands))
            }
        }
        return sections
    }
}
