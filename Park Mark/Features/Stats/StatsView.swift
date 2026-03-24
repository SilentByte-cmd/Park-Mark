import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var parkingStore: ParkingSpotStore

    @StateObject private var viewModel = StatsViewModel()

    private var summary: StatsViewModel.Summary {
        viewModel.buildSummary(spots: parkingStore.spots)
    }

    var body: some View {
        ZStack {
            PPGradientBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Insights")
                        .font(.largeTitle.weight(.bold))
                    Text("Every number reflects your real saved sessions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if summary.totalSpots == 0 {
                        PPEmptyState(
                            iconName: "chart.line.uptrend.xyaxis",
                            title: "Insights will appear soon",
                            message: "Save a few parking sessions to unlock trends, averages, and usage patterns.",
                            actionTitle: nil,
                            action: nil
                        )
                    } else {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            PPStatMetricCard(
                                title: "Total saves",
                                value: "\(summary.totalSpots)",
                                caption: "Lifetime records"
                            )
                            PPStatMetricCard(
                                title: "Active",
                                value: "\(summary.activeSpots)",
                                caption: "Open sessions"
                            )
                            PPStatMetricCard(
                                title: "Favorites",
                                value: "\(summary.favoriteSpots)",
                                caption: "Pinned spots"
                            )
                            PPStatMetricCard(
                                title: "This week",
                                value: "\(summary.weekCount)",
                                caption: "New records"
                            )
                            PPStatMetricCard(
                                title: "This month",
                                value: "\(summary.monthCount)",
                                caption: "New records"
                            )
                            PPStatMetricCard(
                                title: "Top type",
                                value: summary.mostUsedType?.displayName ?? "—",
                                caption: "Most frequent"
                            )
                        }

                        if let average = summary.averageCompletedDuration {
                            PPCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Average session")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    Text(viewModel.formatDuration(average))
                                        .font(.title2.weight(.bold))
                                    Text("Based on completed sessions with an end time.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } else {
                            PPCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Average session")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.secondary)
                                    Text("End a session to unlock averages.")
                                        .font(.headline.weight(.semibold))
                                    Text("Mark a spot as found to build calm, honest insights.")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        trendCard(summary: summary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Stats")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func trendCard(summary: StatsViewModel.Summary) -> some View {
        PPCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Signal")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(interpretation(for: summary))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(ParkingInsightTips.tips[min(summary.totalSpots, ParkingInsightTips.tips.count - 1)])
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func interpretation(for summary: StatsViewModel.Summary) -> String {
        if summary.activeSpots > 1 {
            return "You have more than one active session. End the ones you no longer need to keep history tidy."
        }
        if summary.weekCount > max(1, summary.monthCount / 4) {
            return "This week has been busy—your saves are keeping pace with real life."
        }
        if summary.favoriteSpots > summary.totalSpots / 2 {
            return "You lean on favorites, which means Park Pin is learning your trusted places."
        }
        return "Steady usage builds calmer returns—keep saving the details that matter."
    }
}
