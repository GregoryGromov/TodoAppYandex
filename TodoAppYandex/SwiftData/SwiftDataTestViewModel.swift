import Foundation
import SwiftUI

// ModelContainer хранится внутри FileCache, инициализируется в момент создания FileCache.
// FileCache содержит метод insert(_ todoItem: TodoItem) — добавить TodoItem в бд.
// FileCache содержит метод fetch() — получить все сохраненные TodoItem в бд.
// FileCache содержит метод delete(_ todoItem: TodoItem) — удалить TodoItem в бд.
// FileCache содержит метод update(_ todoItem: TodoItem) — обновить TodoItem в бд.

@Observable
class SwiftDataTestViewModel {

}
