import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
	
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var titleTextField: UITextField!
	@IBOutlet weak var contentsTextView: UITextView!
	@IBOutlet weak var datePicker: UIDatePicker!
	
	let realm = try! Realm()
	var task: Task!
	

    override func viewDidLoad() {
        super.viewDidLoad()
		
		// 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
//		let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		
//		if let category = realm.object(ofType: Category.self, forPrimaryKey: "0") {
//			categoryLabel.text = category.name
//		}
		
		let categoryArray = try! Realm().objects(Category.self).filter("id = \(task.categoryId)")
		categoryLabel.text = categoryArray[0].name
		titleTextField.text = task.title
		contentsTextView.text = task.contents
		datePicker.date = task.date as Date
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func dismissKeyboard() {
		// キーボードを閉じる
		view.endEditing(true)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		try! realm.write {
			
			self.task.title = self.titleTextField.text!
			self.task.contents = self.contentsTextView.text
			self.task.date = datePicker.date as NSDate
			self.realm.add(self.task, update: true)
		}
		
		setNotification(task: task)
		
		super.viewWillDisappear(animated)
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		let categoryViewController: CategoryViewController = segue.destination as! CategoryViewController
			categoryViewController.task = self.task
	}

}
