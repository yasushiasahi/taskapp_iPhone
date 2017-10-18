import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	var task: Task!
	let realm = try! Realm()
	
	var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "name",
	                                                               ascending: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		
		tableView.delegate = self
		tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: UITableViewDataSourceプロトコルのメソッド
	// データの数（＝セルの数）を返すメソッド
	func tableView(_ tableView: UITableView,
	               numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
	}
	
	// 各セルの内容を返すメソッド
	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
		                                         for: indexPath as IndexPath)
		let category = categoryArray[indexPath.row]
		cell.textLabel?.text = category.name
		return cell
	}
	
	// MARK: UITableViewDelegateプロトコルのメソッド
	// 各セルを選択した時に実行されるメソッド
	func tableView(_ tableView: UITableView,
	               didSelectRowAt indexPath: IndexPath){
	}
	
	// セルが削除が可能なことを伝えるメソッド
	func tableView(_ tableView: UITableView,
	               editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	// Delete ボタンが押された時に呼ばれるメソッド
	func tableView(_ tableView: UITableView,
	               commit editingStyle: UITableViewCellEditingStyle,
	               forRowAt indexPath: IndexPath ) {
		if editingStyle == UITableViewCellEditingStyle.delete {

		}
	}
	
	
	@IBAction func addCategoryButton(_ sender: Any) {
		let category: Category = Category()
		try! realm.write {
			category.name = self.textField.text!
			if categoryArray.count != 0 {
				category.id = categoryArray.max(ofProperty: "id")! + 1
			}
			self.realm.add(category, update: true)
		}
		tableView.reloadData()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let inputViewController: InputViewController = segue.destination as! InputViewController
		inputViewController.task = task
	}

}
