import Foundation
import UIKit

public class Cluster: NSObject {
    public var x: Double = 0
    public var y: Double = 0
    var radius = 16.0
    
    public var atoms: [Atom] = [] {
        didSet {
            self.recalculatePosition()
        }
    }
    override public var description: String {
        return self.atoms.description
    }
    
    public override init() {}
    
    public func recalculatePosition() {
        if self.atoms.count == 0 {
            self.x = 0
            self.y = 0
            self.radius = 16
            return
        }
        let averageX = self.atoms.reduce(0.0, combine: {$0 + $1.x}) / Double(self.atoms.count)
        let averageY = self.atoms.reduce(0.0, combine: {$0 + $1.y}) / Double(self.atoms.count)
        self.x = averageX
        self.y = averageY
        self.radius = 16 
    }
    
    public func distanceTo(atom: Atom) -> Double {
        let powX = pow(self.x - atom.x, 2)
        let powY = pow(self.y - atom.y, 2)
        let distance = sqrt(powX + powY)
        return distance
    }
    
    public func distance(cluster: Cluster) -> Double {
        let powX = pow(self.x - cluster.x, 2)
        let powY = pow(self.y - cluster.y, 2)
        let distance = sqrt(powX + powY)
        return distance
    }
    
    public func addPinsFrom(cluster: Cluster) {
        self.atoms.appendContentsOf(cluster.atoms)
    }
}
public func ==(lhs: Cluster, rhs: Cluster) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.radius == rhs.radius && lhs.atoms == rhs.atoms
}