import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate {
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var pickerView: UIPickerView!
	
	// Realmインスタンスを取得する
	let realm = try! Realm()
	
	// DB内のタスクが格納されるリスト。
	// 日付近い順\順でソート：降順
	// 以降内容をアップデートするとリスト内は自動的に更新される。
	var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",
	                                                       ascending: false)
	
	var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id",
	                                                               ascending: true)
	var filterdTaskArray = try! Realm().objects(Task.self).filter("categoryId = 0")
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		tableView.delegate = self
		tableView.dataSource = self
		pickerView.delegate = self
		pickerView.dataSource = self
		
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: UITableViewDataSourceプロトコルのメソッド
	// データの数（＝セルの数）を返すメソッド
	func tableView(_ tableView: UITableView,
	               numberOfRowsInSection section: Int) -> Int {
		return taskArray.count
	}

	// 各セルの内容を返すメソッド
	func tableView(_ tableView: UITableView,
	               cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// 再利用可能な cell を得る
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
		                                         for: indexPath as IndexPath)
		
		// Cellに値を設定する
		let task = taskArray[indexPath.row]
		cell.textLabel?.text = task.title
		
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm"
		let dateString: String = formatter.string(from: task.date as Date)
		
		let category = try! Realm().objects(Category.self).filter("id = \(task.categoryId)")[0]
		
		cell.detailTextLabel?.text = "\(dateString)  \(category.name)"
		
		return cell
	}
	
	// MARK: UITableViewDelegateプロトコルのメソッド
	// 各セルを選択した時に実行されるメソッド
	func tableView(_ tableView: UITableView,
	               didSelectRowAt indexPath: IndexPath){
		performSegue(withIdentifier: "cellSegue", sender: nil)
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
			
			// 削除されたタスクを取得する
			let task = self.taskArray[indexPath.row]
			
			// ローカル通知をキャンセルする
			let center = UNUserNotificationCenter.current()
			center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

			
			// データベースから削除する
			try! realm.write {
				self.realm.delete(self.taskArray[indexPath.row])
				tableView.deleteRows(at: [indexPath as IndexPath],
				                     with: UITableViewRowAnimation.fade)
			}
			
			// 未通知のローカル通知一覧をログ出力
			center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
				for request in requests {
					print("/---------------")
					print(request)
					print("---------------/")
				}
			}
			
		}
	}
	
	
	// UIPickerViewの列の数
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	
	// UIPickerViewの行の数
	func pickerView(_ pickerView: UIPickerView,
	                numberOfRowsInComponent component: Int) -> Int {
		return categoryArray.count
	}
	
	
	// UIPickerViewに表示する配列
	func pickerView(_ pickerView: UIPickerView,
	                titleForRow row: Int,
	                forComponent component: Int) -> String? {
		
		return categoryArray[row].name
	}
	
	
	// UIPickerViewが選択されたときの処理
	func pickerView(_ pickerView: UIPickerView,
	                didSelectRow row: Int,
	                inComponent component: Int) {

		self.filterdTaskArray = self.realm.objects(Task.self).filter("categoryId = \(categoryArray[row].id)")
	}
	
	
	@IBAction func filterButton(_ sender: Any) {
		self.taskArray = self.filterdTaskArray
		tableView.reloadData()
	}

	
	@IBAction func unfilterButton(_ sender: Any) {
		self.taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date",
		                                                        ascending: false)
		tableView.reloadData()
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let inputViewController: InputViewController = segue.destination as! InputViewController
		if segue.identifier == "cellSegue" {
			let indexPath = self.tableView.indexPathForSelectedRow
			inputViewController.provTask["id"] = taskArray[indexPath!.row].id
			inputViewController.provTask["title"] = taskArray[indexPath!.row].title
			inputViewController.provTask["contents"] = taskArray[indexPath!.row].contents
			inputViewController.provTask["date"] = taskArray[indexPath!.row].date
			inputViewController.provTask["categoryId"] = taskArray[indexPath!.row].categoryId
		} else {
			if taskArray.count != 0 {
				inputViewController.provTask["id"] = taskArray.max(ofProperty: "id")! + 1
			} else {
				inputViewController.provTask["id"] = 0
			}
			inputViewController.provTask["title"] = ""
			inputViewController.provTask["contents"] = ""
			inputViewController.provTask["date"] = NSDate()
			inputViewController.provTask["categoryId"] = 0
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		pickerView.reloadAllComponents()
	}
	
	@IBAction func unwind(_ segue: UIStoryboardSegue) {
	}
	
	

}























// end

