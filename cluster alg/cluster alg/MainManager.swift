import Foundation
import UIKit

public class MainManager {
    public static let shared = MainManager()
    public var atoms: [Atom] = []
    public var accuracy = 1
    public var zoomValue: Double = 0.5
    public var atomsMap:[String: Atom] = [:]
    public init() {}

    public func generateManagersDataSource() {
        print("generating")
        self.createAtomsDict()
        let viewManager = ViewManager.shared
        let distanceManager = DistanceManager.shared
        distanceManager.generateDataSource(self.atoms, accuracy: accuracy)
        viewManager.drawAtoms(self.atoms)
        
        var uniqueDistances: [String] = []
        for (key, _) in distanceManager.dataSource {
            uniqueDistances.append(key)
        }
        
        let sortedDistanceManager = SortedDistanceManager.shared
        sortedDistanceManager.generateDataSource(uniqueDistances)
        
        
        let distanceArray = sortedDistanceManager.getDistances(for: self.zoomValue)
        ClustersManager.shared.processClusters(with: distanceArray)
        viewManager.drawAtoms(self.atoms)
    }
    func createAtomsDict() {
        for atom in self.atoms {
            self.atomsMap[atom.name] = atom
        }
    }
    func processData() {
        let distanceManager = DistanceManager.shared
        let viewManager = ViewManager.shared
        let sortManager = SortedDistanceManager.shared
        var distanceArray = sortManager.getDistances(for: self.zoomValue)
        
        while !distanceArray.isEmpty {
            distanceArray = ClustersManager.shared.processClusters(with: distanceArray)
        }
        viewManager.drawAtoms(self.atoms)
        viewManager.drawClusters(ClustersManager.shared.clusters)
        viewManager.drawLines(distanceManager.clusterDataSource)
    }
    
}