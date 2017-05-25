import UIKit

class MGridVisorDetailItemMatch:MGridVisorDetailItem
{
    let credits:Int
    let title:String?
    private let kCellHeight:CGFloat = 280
    
    init(model:MGridAlgoHostileItem)
    {
        let reusableIdentifier:String = VGridVisorDetailCellMatch.reusableIdentifier
        credits = model.credits
        title = model.matchTitle
        
        super.init(
            reusableIdentifier:reusableIdentifier,
            cellHeight:kCellHeight)
    }
}
