import Foundation

public class DistanceManager {
    public static let shared = DistanceManager()
    
    public var dataSource: [String: [Atom]] = [:] //distance: [Atoms]
    public var clusterDataSource:[String: [AnyObject]] = [:] //cluster - atom/ cl - cl
    public init() {}
    
    
    var atomDict: [String: [Atom]] = [:]
    var atomPairs: [String: String] = [:]
    
    public func generateDataSource(atoms: [Atom], accuracy: Int) {
        
        print("Distance manager: generating datasource")
        for i in 0..<atoms.count {
            for j in 0..<atoms.count {
                if i == j {
                    continue
                }
                if self.atomDict[atoms[i].name] == nil {
                    self.atomDict[atoms[i].name] = []
                }
                //check atoms for j atom
                if self.atomDict[atoms[j].name] == nil {
                    self.atomDict[atoms[j].name] = []
                }
                if self.atomDict[atoms[j].name]?.contains(atoms[i]) == true && self.atomDict[atoms[j].name]?.indexOf(atoms[i]) < accuracy {
                    continue
                }
                
                if checkTransition(atoms[j].name, to: atoms[i].name) {
                    continue
                }
                
                self.atomDict[atoms[i].name]?.append(atoms[j])
            }
            
            self.atomDict[atoms[i].name]?.sortInPlace({ (firstAtom, secondAtom) -> Bool in
                return atoms[i].distanceTo(another: firstAtom) < atoms[i].distanceTo(another: secondAtom)
            })
            for k in 0..<accuracy {
                if k >= self.atomDict[atoms[i].name]?.count {
                    break
                }
                let nearestAtom = self.atomDict[atoms[i].name]![k]
                let doubleDistance = atoms[i].distanceTo(another: nearestAtom)
                let generatedKey = generateFinalKeyFor(doubleDistance)
                self.dataSource[generatedKey] = [atoms[i], nearestAtom]
                //print(atoms[i].name, " to ", nearestAtom, " distance: ", doubleDistance)
                self.atomPairs[atoms[i].name] = nearestAtom.name
            }
            
        }
        
        print("Distance manager: end generating datasource")
        // print("Distance manager: items: ", self.dataSource)
    }
    
    func checkTransition(from: String?, to: String?) -> Bool {
        if from == nil {
            return false
        } else if self.atomPairs[from!] == nil {
            return false
        }
        let array = self.atomPairs.filter() {$0.0 == from}
        for (_, next) in array {
            if next == to {
                return true
            } else {
                return checkTransition(next, to: to)
            }
        }
        return false
    }
    
    func addValue(from cluster: Cluster, toAtom: Atom) -> String {
        let doubleValue = cluster.distanceTo(toAtom)
        let uniqueKey = generateFinalKeyFor(doubleValue)
        self.clusterDataSource[uniqueKey] = [cluster, toAtom] // from here get pairs cluster, atom
        SortedDistanceManager.shared.appendDistance(uniqueKey)
        return uniqueKey
    }
    
    func addValue(from cluster: Cluster, toCluster: Cluster) -> String {
        let doubleValue = cluster.distance(toCluster)
        let uniqueKey = generateFinalKeyFor(doubleValue)
        self.clusterDataSource[uniqueKey] = [cluster, toCluster] // from here get pairs cluster, cluster
        SortedDistanceManager.shared.appendDistance(uniqueKey)
        return uniqueKey
    }
    
    func generateFinalKeyFor(value: Double) -> String {
        var stringValue = "\(value)"
        let charactersCount = stringValue.containsString(".") ? stringValue.characters.count - 1 : stringValue.characters.count
        
        let freeSpace = 16 - charactersCount
        for _ in 0..<freeSpace {
            stringValue = stringValue.stringByAppendingString("0000")
        }
        var temp = ""
        for i in 0..<999 {
            temp = stringValue.stringByAppendingString("\(i)")
            if self.dataSource[temp] == nil && self.clusterDataSource[temp] == nil {
                return temp
            }
        }
        return ""
    }
}