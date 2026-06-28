import SwiftData

/// Post-1.0 SwiftData migration plan scaffold. Pre-release builds wipe incompatible stores instead.
enum HobbySchemaMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [HobbySchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

enum HobbySchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [
            Army.self, ArmyUnit.self, SquadMember.self, HobbyPaint.self, AppConfiguration.self,
            ModelPhoto.self, StageEvent.self,
            Roster.self, RosterEntry.self,
        ]
    }
}
