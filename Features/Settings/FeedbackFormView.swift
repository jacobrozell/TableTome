import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Structured suggestion form — opens Mail with a pre-filled message to the developer.
struct FeedbackFormView: View {
    @Environment(\.openURL) private var openURL
    @Environment(BannerCenter.self) private var banner

    @State private var category: FeedbackCategory = .improvement
    @State private var specificItem = ""
    @State private var summary = ""
    @State private var details = ""
    @State private var showMailSheet = false
    @State private var showMailUnavailable = false

    private var draft: FeedbackDraft {
        FeedbackDraft(
            category: category,
            specificItem: specificItem,
            summary: summary,
            details: details
        )
    }

    var body: some View {
        Form {
            Section {
                Text(
                    String(
                        localized: """
                        Tell me what to add or fix — paint swatches, basing products, armies, rules, new modes, \
                        or anything that would make Tabletome better. Your email app opens with a draft ready to send.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Section {
                Picker(String(localized: "Category"), selection: $category) {
                    ForEach(FeedbackCategory.allCases) { option in
                        Label(option.label, systemImage: option.systemImage).tag(option)
                    }
                }
                .formNavigationPickerStyle()
            } header: {
                Text(String(localized: "What is this about?"))
            }

            Section {
                TextField(category.specificItemLabel, text: $specificItem, prompt: Text(category.specificItemPlaceholder))
                    .textInputAutocapitalization(.words)
                    .accessibilityIdentifier("feedback.specificItem")
                TextField(String(localized: "Summary"), text: $summary, prompt: Text(category.summaryPlaceholder))
                    .textInputAutocapitalization(.sentences)
                    .accessibilityIdentifier("feedback.summary")
            } header: {
                Text(String(localized: "Your suggestion"))
            } footer: {
                Text(String(localized: "Summary is required. Be as specific as you can — names and sources help."))
            }

            Section {
                TextField(
                    String(localized: "Details"),
                    text: $details,
                    prompt: Text(category.detailsPlaceholder),
                    axis: .vertical
                )
                .lineLimit(4...12)
                .accessibilityIdentifier("feedback.details")
            } header: {
                Text(String(localized: "Extra detail"))
            } footer: {
                Text(category.detailsPlaceholder)
            }

            Section {
                Button {
                    sendFeedback()
                } label: {
                    Label(String(localized: "Send feedback"), systemImage: "paperplane.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .disabled(!draft.isValid)
                .accessibilityIdentifier("feedback.send")
            } footer: {
                Text(
                    String(
                        localized: """
                        Opens your mail app addressed to the developer. Nothing is sent until you tap Send in Mail.
                        """
                    )
                )
            }
        }
        .navigationTitle(String(localized: "Suggest something"))
        .navigationBarTitleDisplayMode(.inline)
        .tabBarScrollInset()
        #if canImport(MessageUI)
        .sheet(isPresented: $showMailSheet) {
            MailComposeView(
                recipients: [AppSupport.feedbackEmail],
                subject: AppSupport.mailSubject(for: draft),
                body: AppSupport.mailBody(for: draft)
            ) {
                showMailSheet = false
            }
        }
        #endif
        .alert(String(localized: "Mail isn’t set up"), isPresented: $showMailUnavailable) {
            Button(String(localized: "Copy message")) {
                #if canImport(UIKit)
                UIPasteboard.general.string = AppSupport.mailBody(for: draft)
                #endif
                banner.show(String(localized: "Feedback copied — paste into an email to send"))
            }
            Button(String(localized: "Open Mail app")) {
                openURL(AppSupport.mailtoURL(for: draft))
            }
            Button(String(localized: "Cancel"), role: .cancel) {}
        } message: {
            Text(
                String(
                    localized: """
                    Add a mail account in Settings, or copy the draft and paste it into any email app to \
                    \(AppSupport.feedbackEmail).
                    """
                )
            )
        }
    }

    private func sendFeedback() {
        guard draft.isValid else { return }
        if AppSupport.canSendMail {
            showMailSheet = true
        } else {
            showMailUnavailable = true
        }
    }
}
