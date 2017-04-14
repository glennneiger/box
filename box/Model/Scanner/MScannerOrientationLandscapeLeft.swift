import Foundation

class MScannerOrientationLandscapeLeft:MScannerOrientation
{   
    override func itemPosition(
        userHeading:Float,
        moveVertical:Float,
        itemHeading:Float) -> MetalPosition?
    {
        let positionX:Float
        let positionY:Float
        
        if userHeading >= 0
        {
            let inversedHeading:Float
            
            if userHeading >= k180Deg
            {
                inversedHeading = k360Deg - userHeading
            }
            else
            {
                inversedHeading = -userHeading
            }
            
            let headingMultiplied:Float  = inversedHeading * kHorizontalMultiplier
            positionY = -(headingMultiplied + itemHeading)
        }
        else
        {
            let headingMultiplied:Float = userHeading * kHorizontalMultiplier
            positionY = -(itemHeading - headingMultiplied)
        }
        
        positionX = moveVertical
        
        let position:MetalPosition = MetalPosition(
            positionX:positionX,
            positionY:positionY)
        
        return position
    }
}