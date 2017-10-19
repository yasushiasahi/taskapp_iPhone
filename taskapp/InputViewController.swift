import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
	
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var contentsTextView: UITextView!
	@IBOutlet weak var datePicker: UIDatePicker!
	
	let realm = try! Realm()
	var provTask: [String : Any] = [:]
	

    override func viewDidLoad() {
        super.viewDidLoad()
		// 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
		let _: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		
		setView()
    }

	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func dismissKeyboard() {
		// キーボードを閉じる
		view.endEditing(true)
	}
	
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "createSegue" {
			let task: Task = Task()
			
			task.id = provTask["id"] as! Int
			task.categoryId = provTask["categoryId"] as! Int
			
			task.title = self.titleTextField.text!
			task.contents = self.contentsTextView.text
			task.date = self.datePicker.date as NSDate
			
			try! realm.write {
				realm.add(task, update: true)
			}
			
			setNotification(task: task)
		} else if segue.identifier == "chooseCategorySegue" {
			provTask["title"] = self.titleTextField.text!
			provTask["contents"] = self.contentsTextView.text
			provTask["date"] = self.datePicker.date as NSDate
			
			let categoryViewController: CategoryViewController = segue.destination as! CategoryViewController
			categoryViewController.provTask = provTask
		}
	}
	
	
	@IBAction func cutegoryButton(_ sender: Any) {
	}
	
	@IBAction func makeButton(_ sender: Any) {
	}
	
	
	@IBAction func unwind(_ segue: UIStoryboardSegue) {
		setView()
	}
	
	
	// タスクのローカル通知を登録する
	func setNotification(task: Task) {
		let content = UNMutableNotificationContent()
		content.title = task.title
		content.body = task.contents
		content.sound = UNNotificationSound.default()
		
		// ローカル通知が発動するtrigger（日付マッチ）を作成
		let calender = NSCalendar.current
		let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute],
		                                             from: task.date as Date)
		let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents,
		                                                 repeats: false)
		
		// identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
		let request = UNNotificationRequest.init(identifier: String(task.id),
		                                         content: content,
		                                         trigger: trigger)
		// ローカル通知を登録
		let center = UNUserNotificationCenter.current()
		center.add(request) { (error) in print(error ?? "ローカル通知登録 OK") }
		
		// 未通知のローカル通知一覧をログ出力
		center.getPendingNotificationRequests {
			(requests: [UNNotificationRequest]) in for request in requests {
				print("/----------------")
				print(request)
				print("/----------------")
			}
		}
		
	}
	
	
	func getCategoryName(categoryId: Int) -> String {
		return self.realm.objects(Category.self).filter("id = \(categoryId)")[0].name
	}
	
	
	func setView() {
		categoryLabel.text = getCategoryName(categoryId: provTask["categoryId"] as! Int)
		titleTextField.text = provTask["title"] as? String
		contentsTextView.text = provTask["contents"] as? String
		datePicker.date = provTask["date"] as! Date
	}
	
	
	func printInfo() {
		print("========================================================")
		print(provTask["id"] as! Int)
		print(provTask["categoryId"] as! Int)
		print(provTask["title"] as? String)
		print(provTask["contents"] as? String)
		print(provTask["date"] as! Date)
		print("========================================================")
	}
	
}
