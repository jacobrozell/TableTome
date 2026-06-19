import SwiftUI
import TabletomeDomain

/// Combat Patrol mission rules and scoring — curated from bundled rule sections.
struct CombatPatrolMissionsReferenceView: View {
    let ruleSections: [RuleSection]
    var gameSystemId: String = GameSystemId.wh40k10eCp.rawValue

    private var missionsSection: RuleSection? {
        ruleSections.first { $0.id == "cp-missions" }
    }

    private var scoringSection: RuleSection? {
        ruleSections.first { $0.id == "cp-scoring" }
    }

    private var securingSection: RuleSection? {
        ruleSections.first { $0.id == "cp-securing" }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                Text(
                    String(
                        localized: """
                        Combat Patrol uses six missions with fixed deployment maps. Roll a D6 or pick one \
                        before setup — start with Clash of Patrols for your first game.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                if let missionsSection {
                    sectionBlock(title: missionsSection.title, content: missionsSection.content)
                }

                if let securingSection {
                    sectionBlock(title: securingSection.title, content: securingSection.content)
                }

                if let scoringSection {
                    sectionBlock(title: scoringSection.title, content: scoringSection.content)
                }

                ForEach(relatedMissionSections) { section in
                    NavigationLink(value: RuleSectionLink(gameSystemId: gameSystemId, sectionId: section.id)) {
                        Label(section.title, systemImage: "map")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .accessibilityIdentifier("guide.missions.section.\(section.id)")
                }
            }
            .padding(DesignTokens.Spacing.md)
            .readableContentWidth()
        }
        .navigationTitle(String(localized: "Combat Patrol Missions"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("guide.combatPatrolMissions")
    }

    private var relatedMissionSections: [RuleSection] {
        ruleSections.filter { section in
            section.id.hasPrefix("cp-mission-")
        }
        .sorted { $0.order < $1.order }
    }

    private func sectionBlock(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
