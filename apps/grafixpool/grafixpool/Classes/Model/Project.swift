//
//  Project.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/4/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}

extension Project {
    static func createDefault(_ context: NSManagedObjectContext) {
        let project = Project(context: context)
        project.code = "default"
    }
    static func last(context: NSManagedObjectContext) -> Project {
        return recentProjects(context).first!
    }
    static func recentProjectNames(_ context: NSManagedObjectContext) -> [String] {
        let projects = recentProjects(context)
        var result = projects.map { $0.code! }
        result[result.count - 1] = NSLocalizedString("default-project", comment: "")
        return result
    }
    private static func defaultProject(_ context: NSManagedObjectContext) -> Project {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code == %@", "default")
        fetchRequest.fetchLimit = 1
        do {
            let project = try context.fetch(fetchRequest)
            return project.first!
        } catch {
            fatalError("Failed to fetch default project: \(error)")
        }
    }
    private static func recentProjects(_ context: NSManagedObjectContext) -> [Project] {
        var projects: [Project] = []
        let d = defaultProject(context)

        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "code != %@", d.code!)
        let bookingDateSort = NSSortDescriptor(key: "code", ascending: false)
        fetchRequest.sortDescriptors = [bookingDateSort]
        do {
            projects = try context.fetch(fetchRequest)
        } catch {
            fatalError("Failed to fetch projects: \(error)")
        }
        projects.insert(d, at: projects.count)
        return projects
    }

    static func isLoaded(_ context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<Project> = Project.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            fatalError("Failed to fetch projects: \(error)")
        }
    }
}
