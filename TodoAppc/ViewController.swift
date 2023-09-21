//
//  ViewController.swift
//  TodoAppc
//
//  Created by YEOMI on 2023/09/19.
//

import UIKit

class ViewController: UIViewController {
    var tableView: UITableView!
    var addButton: UIBarButtonItem!
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem?
    var longPressGesture: UILongPressGestureRecognizer?
    var tasks = [Task]() {
        didSet { //tasks 배열에 할일이 추가될 때마다 유저 디폴트에 할일이 저장
            self.saveTasks()
        }
    }// Task 배열 생성
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTableView()
        addNaviView()
        self.loadTasks() // 유저 디폴트에 저장된 할일을 앱을 껏다 켜도 다시 불러와주는 것
    }
    
    func addTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        tableView.addGestureRecognizer(longPressGesture!)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func addNaviView() {
        addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(tapAddButton(_:)))
        navigationItem.rightBarButtonItem = addButton
        editButton = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(tapEditButton(_:)))
        doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTap))
        navigationItem.leftBarButtonItem = editButton
    }
    //"Done" 버튼을 탭했을 때 호출되는 메서드
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true) //done 버튼을 누르면 edit에서 빠져나오도록 함.
        print("2")
    }
    // "Edit" 버튼을 탭했을 때 호출되는 메서드
    @objc func tapEditButton(_ sender: UIBarButtonItem){
        guard !self.tasks.isEmpty else {return}
        // "Done" 버튼을 네비게이션 바 왼쪽에 표시하고 테이블 뷰를 편집 모드로 변경
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true)
        print("1")
    }
    // "Add" 버튼을 탭했을 때 호출되는 메서드
    @objc func tapAddButton(_ sender: UIBarButtonItem) {
        // UIAlertController를 사용하여 할 일을 입력하는 팝업을 표시
        let alert = UIAlertController(title: "할 일 등록", message: "할 일을 입력해주세요.", preferredStyle: .alert)
        // "등록" 버튼을 생성하고 클로저를 사용하여 할 일을 추가
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            //등록버튼을 눌렀을 때 텍스트필드에 있는 값을 가져올 수 있다.
            // 텍스트필드는 배열인데 하나만 넣었기 때문에 [0]로 접근함.
            self?.tableView.reloadData() //add된 할 일들을 테이블뷰에 새로 업로드 해주는 것
        })
        // "취소" 버튼을 생성
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        // UIAlertController에 버튼을 추가
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        // UIAlertController에 텍스트 필드를 추가하여 사용자 입력을 받기
        alert.addTextField(configurationHandler: {textField in textField.placeholder = "할 일을 입력해주세요."})
        // UIAlertController를 화면에 표시
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleLongPress(_ gestureRecognizer : UILongPressGestureRecognizer ){
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                if !tableView.isEditing {
                    let task = tasks[indexPath.row]
                    let alert = UIAlertController(title: "할 일 변경", message: "변경할 내용을 입력해주세요.", preferredStyle: .alert)
                    alert.addTextField{textField in
                        textField.text = task.title
                    }
                    let saveButton = UIAlertAction(title: "변경", style: .default) { [weak self] _ in
                        if let textField = alert.textFields?.first, let newText = textField.text {
                            self?.tasks[indexPath.row].title = newText
                            self?.tableView.reloadData()
                        }
                    }
                    
                    let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                    
                    alert.addAction(cancelButton)
                    alert.addAction(saveButton)
                    present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    // 할 일 목록을 UserDefaults에 저장하는 메서드
    func saveTasks(){
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    // UserDefaults에서 할 일 목록을 불러오는 메서드
    func loadTasks(){
        let userDefalts = UserDefaults.standard
        guard let data = userDefalts.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }
        
    }
}
// UITableViewDataSource 프로토콜을 채택한 확장(extension)
extension ViewController: UITableViewDataSource{
    // 테이블 뷰의 행 수를 반환하는 메서드
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
        }
    
    // 테이블 뷰의 각 셀을 구성하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
    UITableViewCell {
        // 재사용 가능한 셀을 가져오고 해당 셀에 할 일 정보를 표시
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //사용하지 않는 메모리를 낭비하지 않기 위해서 dequeneResuableCell을 이용해서 셀을 재사용
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        //셀 표시됐을 때 체크마크
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType =  .none
        }
        return cell
        }
    // commit for row at 메서드 구현
    // 삭제버튼 눌렀을때, 삭제버튼이 눌린 셀이 어떤 셀인지 알려주는 메서드
    func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        self.tasks.remove(at: indexPath.row) // remove cell 알려주는 것
        tableView.deleteRows(at: [indexPath], with: .automatic)
        //automatic 애니메이션을 설정하게 되면, 삭제 버튼을 눌러서 삭제 가능, 스와이프 삭제도 가능
        if self.tasks.isEmpty {
            self.doneButtonTap() // done버튼 메서드를 호출해서 편집모드를 빠져나오게 구현
        }
    }
    //할 일의 순서를 바꿀 수 있는 기능 구현
    //move row at 메서드를 구현 : 행이 다른 위치로 변경되면, souceIndexPath 파라미터를 통해 어디에 있었는지 알려주고, destinationIndexPath 파라미터를 통해 어디로 이동했는지 알려줌
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // talbe뷰 셀이 재정렬 되면, 할일을 저장하는 배열도 재정렬 되어야 함
        // 따라서 테이블뷰 셀이 재정렬된 순서대로, tasks 배열도 재정렬 해줘야해서 아래 처럼 구현
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks
    }
}

extension ViewController: UITableViewDelegate {
    // 메서드 정의 : 셀을 선택하였을 때 어떤 셀이 선택되었는지 알려주는 메서드 : didSelectRowAt
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tasks 배열 요소에 접근해서, done이 true이면 false가 되게 만들어주고, false면 true 가 되게 만들어줄 것.
        var task = self.tasks[indexPath.row]
        task.done = !task.done   // 반대가 되게해줌
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}

