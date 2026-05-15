//
//  ListView.swift
//

import SwiftUI
import SwiftData

struct ListView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(AppSettings.self) private var settings
    @Query(filter: #Predicate<TodoItem> { $0.scheduledDate == nil && !$0.isCompleted }, sort: \TodoItem.completedAt, order: .reverse) private var items: [TodoItem]
    @State private var showAdd = false
    @State private var selectedItem: TodoItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if items.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(items) { item in
                                ListTaskCard(item: item, onTap: { selectedItem = item })
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            ctx.delete(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .padding(.bottom, 100)
                    }
                }
            }
            .background(Color.white)
            .navigationTitle("List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "FF4D4D"))
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddTaskView() }
            .sheet(item: $selectedItem) { item in
                DetailView(item: item)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(hex: "6B6B6B"))
            Text("No Tasks")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))
            Text("Add tasks to plan later")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B6B6B"))
            Spacer()
        }
    }
}

struct ListTaskCard: View {
    @Bindable var item: TodoItem
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .stroke(Color(hex: "E5E5E5"), lineWidth: 2)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "0A0A0A"))

                HStack(spacing: 8) {
                    Label("\(item.estimatedMinutes)m", systemImage: "clock")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "6B6B6B"))

                    Text(item.category)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: categoryColor))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: categoryColor).opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var categoryColor: String {
        switch item.category {
        case "Home": return "22C55E"
        case "Personal": return "3B82F6"
        case "Work": return "F97316"
        default: return "A855F7"
        }
    }
}

#Preview { ListView().environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }
