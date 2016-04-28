import Foundation

public class SortedDistanceManager {
    public static let shared = SortedDistanceManager()
    
    public var atomsDataSource: [String] = [] // unique keys for atoms
    public var collisionDistance: Double = 32
    
    var lastDistance = 0.0
    var lastZoom = MainManager.shared.zoomValue
    
    public init() {}
    
    public func generateDataSource(distances: [String]) {
        //print("SortedDistanceManager manager: generating datasource")
        
        self.atomsDataSource = distances.sort({ (first, second) -> Bool in
            let firstDouble = Double(first)!
            let secondDouble = Double(second)!
            return firstDouble < secondDouble
        })
        //print("SortedDistanceManager manager: end generating datasource")
    }
    
    func appendDistance(uniqueKey: String) {
        let doubleValue = Double(uniqueKey)!
        
        if self.atomsDataSource.count == 0 {
            self.atomsDataSource.append(uniqueKey)
            return
        }
        
        if doubleValue <= Double(self.atomsDataSource.first!)! {
            self.atomsDataSource.insert(uniqueKey, atIndex: 0)
            return
        }
        if doubleValue >= Double(self.atomsDataSource.last!)! {
            self.atomsDataSource.insert(uniqueKey, atIndex: self.atomsDataSource.count)
            return
        }
        
        for i in 0..<self.atomsDataSource.count - 1 {
            let currentValue = Double(self.atomsDataSource[i])
            let nextValue = Double(self.atomsDataSource[i + 1])
            if currentValue == doubleValue {
                self.atomsDataSource.insert(uniqueKey, atIndex: i)
                return
            }
            if currentValue < doubleValue && doubleValue <= nextValue {
                self.atomsDataSource.insert(uniqueKey, atIndex: i + 1)
                return
            }
        }
    }
    
    public func getDistances(for zoom: Double) -> [String] {
        var filteredPins: [String] = []
        
        if lastZoom == zoom {
            return []
        }
        
        if lastZoom < zoom {
            //clust
            filteredPins = self.atomsDataSource.filter() {Double($0)! / zoom <= collisionDistance && Double($0)! > self.lastDistance}
        } else {
            //disclust
            filteredPins = self.atomsDataSource.filter() {Double($0)! <= self.lastDistance}
            ClustersManager.shared.clusters.removeAll()
            ClustersManager.shared.relations.removeAll()
            
            //load new datasource
            var uniqueDistances: [String] = []
            let distanceManager = DistanceManager.shared
            for (key, _) in distanceManager.dataSource {
                uniqueDistances.append(key)
            }
            self.generateDataSource(uniqueDistances)
            DistanceManager.shared.clusterDataSource.removeAll()
            let visiblePins = self.atomsDataSource.filter() {Double($0)! > self.lastDistance}
            self.showVisiblePins(visiblePins)
        }
        
        
        self.lastZoom = zoom
        self.lastDistance = self.collisionDistance * zoom
        
        return filteredPins
    }
    func showVisiblePins(keys: [String]) {
        let pinsPairs = DistanceManager.shared.dataSource
        for key in keys {
            let pair = pinsPairs[key]
            pair?.forEach() {$0.hidden = false}

        }
    }
}