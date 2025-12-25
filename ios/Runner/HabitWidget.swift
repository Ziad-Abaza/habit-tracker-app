import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), title: "Today's Habits", content: "No habits yet")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), title: "Today's Habits", content: "Loading...")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.habit")
        let title = userDefaults?.string(forKey: "widget_title") ?? "Today's Habits"
        let content = userDefaults?.string(forKey: "widget_content") ?? "No habits for today"
        
        let entry = SimpleEntry(date: Date(), title: title, content: content)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let content: String
}

struct HabitWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}

@main
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habit Tracker")
        .description("Keep track of your today's habits.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
