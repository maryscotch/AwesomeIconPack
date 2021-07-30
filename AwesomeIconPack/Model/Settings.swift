import Foundation

class Settings {
    var settingItem: String
    var itemImagePath: String
    
    init(settingItem: String, itemImagePath: String) {
        self.settingItem = settingItem
        self.itemImagePath = itemImagePath
    }
}

class SettingsModel {
    var settingItemData: [Settings]
    
    init() {
        self.settingItemData = [
            Settings(settingItem: "How to use icon images", itemImagePath: "Settings/howto"),
            Settings(settingItem: "Buy Premium", itemImagePath: "Settings/purchase"),
            Settings(settingItem: "Restore", itemImagePath: "Settings/restore"),
            Settings(settingItem: "Share App", itemImagePath: "Settings/share"),
            Settings(settingItem: "Rate this App", itemImagePath: "Settings/rate"),
            Settings(settingItem: "Contact Developer", itemImagePath: "Settings/contact"),
            Settings(settingItem: "Privacy Policy", itemImagePath: "Settings/privacyPolicy"),
        ]
    }
    
    func getAll() -> [Settings] {
        return self.settingItemData
    }
}
