import SwiftUI

struct BoxIdentificationSciFiSizeStep: View {
    let onSelect: (BoxIdentificationSheet.SciFiBoxKind) -> Void

    var body: some View {
        Section {
            ForEach(BoxIdentificationSheet.SciFiBoxKind.allCases) { kind in
                Button {
                    onSelect(kind)
                } label: {
                    Text(kind.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } header: {
            Text(String(localized: "What size box?"))
        }
    }
}
