import Foundation
import UIKit

public class Atom: NSObject {
    public var x: Double = 0.0
    public var y: Double = 0.0
    
    public var hidden = false
    
    public var name: String = ""
    let radius: Double = 15.0
    
    override public var description: String {
        return "\(self.name)"
    }
    
    public init(x: Double, y: Double, name: String) {
        self.x = x
        self.y = y
        self.name = name
        //self.z = z
    }
    
    public func distanceTo(another atom: Atom) -> Double {
        let powX = pow(self.x - atom.x, 2)
        let powY = pow(self.y - atom.y, 2)
        let distance = sqrt(powX + powY)
        return distance
    }
}
public func ==(lhs: Atom, rhs: Atom) -> Bool {
    return lhs.name == rhs.name
}