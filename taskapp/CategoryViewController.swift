import UIKit
import RealmSwift

class CategoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tableView: UITableView!
	
	let realm = try! Realm()
	var provTask: [String : Any] = [:]
	var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id",
	                                                               ascending: true)

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
	
	
	func tableView(_ tableView: UITableView,
	               numberOfRowsInSection section: Int) -> Int {
		return categoryArray.count
	}
	

	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
		                                         for: indexPath as IndexPath)
		let category = categoryArray[indexPath.row]
		cell.textLabel?.text = category.name
		
		if category.id == provTask["categoryId"] as! Int {
			cell.backgroundColor = .cyan
		} else {
			cell.backgroundColor = .white
		}
		
		return cell
	}
	

	func tableView(_ tableView: UITableView,
	               didSelectRowAt indexPath: IndexPath){
		let indexPath = self.tableView.indexPathForSelectedRow
		provTask["categoryId"] = categoryArray[indexPath!.row].id
		print("[categoryArray[indexPath!.row].id] --> \(categoryArray[indexPath!.row].id)")
		performSegue(withIdentifier: "inputSegue", sender: nil)
	}
	

	func tableView(_ tableView: UITableView,
	               editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
		return UITableViewCellEditingStyle.delete
	}
	
	
	// Delete ボタンが押された時に呼ばれるメソッド
	func tableView(_ tableView: UITableView,
	               commit editingStyle: UITableViewCellEditingStyle,
	               forRowAt indexPath: IndexPath ) {
		if editingStyle == UITableViewCellEditingStyle.delete {
			
			let categoryId = self.categoryArray[indexPath.row].id
			let taskArray = self.realm.objects(Task.self).filter("id = \(categoryId)")
			
			try! realm.write {
				for task in taskArray {
					task.categoryId = 0
				}
				
				self.realm.delete(self.categoryArray[indexPath.row])
				tableView.deleteRows(at: [indexPath as IndexPath],
				                     with: UITableViewRowAnimation.fade)
			}
		}
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let inputViewController: InputViewController = segue.destination as! InputViewController
		inputViewController.provTask = provTask
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

}
