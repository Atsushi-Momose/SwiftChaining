//
//  TableCustomCell.swift
//

import UIKit
import Chaining

struct CustomCellData: CellData {
    let canEdit = false
    let canMove = false
    let canTap = false
    let cellIdentifier = "CustomCell"
    
    var number: ValueHolder<Int>
    
    init(number: Int) {
        self.number = ValueHolder(number)
    }
}

class TableCustomCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    private var labelAdapter: KVOAdapter<UILabel, String?>!
    private var stepperAdapter: KVOAdapter<UIStepper, Double>!
    
    private var pool = ObserverPool()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.labelAdapter = KVOAdapter(self.label, keyPath: \UILabel.text)
        self.stepperAdapter = KVOAdapter(self.stepper, keyPath: \UIStepper.value)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.pool.invalidate()
    }
}

extension TableCustomCell: CellDataSettable {
    func set(cellData: CellData) {
        self.pool.invalidate()
        
        guard let customCellData = cellData as? CustomCellData else {
            fatalError()
        }
        
        self.pool += customCellData.number.chain().to { String($0) }.receive(self.labelAdapter).sync()
        self.pool += customCellData.number.chain().to { Double($0) }.receive(self.stepperAdapter).sync()
        self.pool += self.stepperAdapter.chain().to { Int($0) }.receive(customCellData.number).sync()
    }
}
