import RealmSwift

class Category: Object {
	// 管理用 ID。プライマリーキー
	dynamic var id = 0
	
	// 名前
	dynamic var name = ""
	
	/**
	id をプライマリーキーとして設定
	*/
	override static func primaryKey() -> String? {
		return "id"
	}
}
