//
//  ViewController.swift
//

import UIKit
import Chaining

class ChainViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var buttonAlias: UIControlAdapter<UIButton>!
    let didEnterBackgroundAlias = NotificationAdapter(UIApplication.didEnterBackgroundNotification)
    let willEnterForegroundAlias = NotificationAdapter(UIApplication.willEnterForegroundNotification)
    var labelTextAlias: KVOAdapter<UILabel, String?>!
    var textFieldAlias: KVOAdapter<UITextField, String?>!
    var pool = ObserverPool()
    
    let labelText = Holder<String>("launched")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttonAlias = UIControlAdapter(self.button, events: .touchUpInside)
        self.labelTextAlias = KVOAdapter(self.label, keyPath: \UILabel.text)
        self.textFieldAlias = KVOAdapter(self.textField, keyPath: \UITextField.text)
        
        self.pool += self.buttonAlias.chain().to { _ in String(Int.random(in: 0..<100)) }.receive(self.labelText).end()
        self.pool += self.labelText.chain().receive(self.labelTextAlias).sync()
        self.pool += self.labelText.chain().receive(self.textFieldAlias).sync()
        self.pool += self.textFieldAlias.chain().to { $0 ?? "nil" }.receive(self.labelText).sync()
        
        self.pool += self.didEnterBackgroundAlias.chain().do { value in print("didEnterBackground \(value)")}.end()
        self.pool += self.willEnterForegroundAlias.chain().do { value in print("willEnterForeground \(value)")}.end()
    }
}

extension ChainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

