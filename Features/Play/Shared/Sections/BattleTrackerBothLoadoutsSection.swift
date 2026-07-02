import SwiftUI
import TabletomeDomain

struct BattleTrackerBothLoadoutsSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let playerOneRegimentAbility: ArmyRuleOption?
    let playerTwoRegimentAbility: ArmyRuleOption?
    let playerOneEnhancement: ArmyRuleOption?
    let playerTwoEnhancement: ArmyRuleOption?
    var playerOneSecondary: ArmyRuleOption? = nil
    var playerTwoSecondary: ArmyRuleOption? = nil
    let playerIsAttacker: (Bool) -> Bool
    let ruleSections: [RuleSection]
    let gameSystemId: GameSystemId

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneArmy: SpearheadArmy?,
        playerTwoArmy: SpearheadArmy?,
        playerOneRegimentAbility: ArmyRuleOption?,
        playerTwoRegimentAbility: ArmyRuleOption?,
        playerOneEnhancement: ArmyRuleOption?,
        playerTwoEnhancement: ArmyRuleOption?,
        playerOneSecondary: ArmyRuleOption? = nil,
        playerTwoSecondary: ArmyRuleOption? = nil,
        playerIsAttacker: @escaping (Bool) -> Bool,
        ruleSections: [RuleSection],
        gameSystemId: GameSystemId
    ) {
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.playerOneArmy = playerOneArmy
        self.playerTwoArmy = playerTwoArmy
        self.playerOneRegimentAbility = playerOneRegimentAbility
        self.playerTwoRegimentAbility = playerTwoRegimentAbility
        self.playerOneEnhancement = playerOneEnhancement
        self.playerTwoEnhancement = playerTwoEnhancement
        self.playerOneSecondary = playerOneSecondary
        self.playerTwoSecondary = playerTwoSecondary
        self.playerIsAttacker = playerIsAttacker
        self.ruleSections = ruleSections
        self.gameSystemId = gameSystemId
    }

    init(
        playerOneName: String,
        playerTwoName: String,
        playerOneArmy: SpearheadArmy?,
        playerTwoArmy: SpearheadArmy?,
        playerOneRegimentAbility: ArmyRuleOption?,
        playerTwoRegimentAbility: ArmyRuleOption?,
        playerOneEnhancement: ArmyRuleOption?,
        playerTwoEnhancement: ArmyRuleOption?,
        playerOneSecondary: ArmyRuleOption? = nil,
        playerTwoSecondary: ArmyRuleOption? = nil,
        playerIsAttacker: @escaping (Bool) -> Bool,
        ruleSections: [RuleSection],
        gameSystemId: String
    ) {
        self.init(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            playerOneArmy: playerOneArmy,
            playerTwoArmy: playerTwoArmy,
            playerOneRegimentAbility: playerOneRegimentAbility,
            playerTwoRegimentAbility: playerTwoRegimentAbility,
            playerOneEnhancement: playerOneEnhancement,
            playerTwoEnhancement: playerTwoEnhancement,
            playerOneSecondary: playerOneSecondary,
            playerTwoSecondary: playerTwoSecondary,
            playerIsAttacker: playerIsAttacker,
            ruleSections: ruleSections,
            gameSystemId: GameSystemId(resolving: gameSystemId)
        )
    }

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                if let army = playerOneArmy {
                    LoadoutSummaryCard(
                        playerName: playerOneName,
                        armyName: army.name,
                        regimentAbility: playerOneRegimentAbility,
                        enhancement: playerOneEnhancement,
                        secondaryObjective: playerOneSecondary,
                        battleTacticDeckName: playContext.capabilities.showsBattleTacticDecks ? army.name : nil,
                        isAttacker: playerIsAttacker(true)
                    )
                    warscrollLink(for: army)
                }
                if let army = playerTwoArmy {
                    LoadoutSummaryCard(
                        playerName: playerTwoName,
                        armyName: army.name,
                        regimentAbility: playerTwoRegimentAbility,
                        enhancement: playerTwoEnhancement,
                        secondaryObjective: playerTwoSecondary,
                        battleTacticDeckName: playContext.capabilities.showsBattleTacticDecks ? army.name : nil,
                        isAttacker: playerIsAttacker(false)
                    )
                    warscrollLink(for: army)
                }
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "Both Loadouts"), systemImage: "person.2.fill")
                .font(.headline)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.bothLoadouts")
    }

    @ViewBuilder
    private func warscrollLink(for army: SpearheadArmy) -> some View {
        let showsRoster = usesCatalogUnitReference(for: army)
        if showsRoster {
            NavigationLink(value: ArmyRosterLink(gameSystemId: gameSystemId.rawValue, armyId: army.id)) {
                Label(
                    unitRosterLinkTitle,
                    systemImage: "doc.richtext"
                )
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("battleTracker.warscrolls.\(army.id)")
        }
    }

    private func usesCatalogUnitReference(for army: SpearheadArmy) -> Bool {
        if playContext.usesGuidedBattleTracker || playContext.capabilities.usesPatrolFormatRules {
            return !army.units.isEmpty
        }
        return army.units.contains(where: \.hasWarscroll)
    }

    private var unitRosterLinkTitle: String {
        playContext.armyUnitRosterLinkTitle
    }
}
