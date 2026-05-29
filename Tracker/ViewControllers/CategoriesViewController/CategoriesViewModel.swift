import Foundation

final class CategoriesViewModel {
    
    //MARK: - Binding
    
    var onCategoriesChanged: (() -> Void)?
    
    //MARK: - Properties
    
    private let categoryStore: TrackerCategoryStore
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    var selectedCategory: TrackerCategory?
    
    //MARK: - init
    
    init(categoryStore: TrackerCategoryStore, selectedCategory: TrackerCategory?) {
        self.categoryStore = categoryStore
        self.selectedCategory = selectedCategory
    }
    
    //MARK: - Other functions
    
    func fetchCategories() {
        categories = categoryStore.fetchCategories()
    }
    
    func addCategory(title: String) {
        do {
            try categoryStore.addCategory(title: title)
            fetchCategories()
        } catch {
            print("Ошибка при добавлении категории")
        }
    }
    
    func deleteCategory(at index: Int) {
        let category = categories[index]
        
        do {
            try categoryStore.deleteCategory(category)
            fetchCategories()
        } catch {
            print("Ошибка при удалении категории")
        }
    }
    
    func updateCategory(at index: Int, newTitle: String) {
        let oldTitle = categories[index].categoryTittle
        
        do {
            try categoryStore.updateCategory(oldTitle: oldTitle, newTitle: newTitle)
            fetchCategories()
        } catch {
            print("Ошибка при обновлении категории")
        }
    }
    
    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategoriesChanged?()
    }
    
    func isSelected(at index: Int) -> Bool {
        categories[index].categoryTittle == selectedCategory?.categoryTittle
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    
    
    
    
}
