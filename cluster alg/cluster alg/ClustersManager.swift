import Foundation

public class ClustersManager
{
    public static let shared = ClustersManager()
    public var clusters: [Cluster] = []
    public var relations: [String: Cluster] = [:] // pin name : cluster
    public var maxDistance: Double?
    
    
    public init() {}
    
    public func processClusters(with distances: [String]) -> [String] {
        if distances.count == 0 {
            return []
        }
        var distances = distances
        
        self.maxDistance = SortedDistanceManager.shared.lastDistance
        if let uniqueKey = distances.first {
            //first priority - check atom and cluster
            let pinsPairs = DistanceManager.shared.dataSource
            let clusterPairs = DistanceManager.shared.clusterDataSource
            if let pair = clusterPairs[uniqueKey] {
                // print("got first pair:")
                if var clusterA = pair.first as? Cluster, clusterB = pair.last as? Cluster {
                    // print("got two clusters:")
                    for atom in clusterA.atoms {
                        if self.relations[atom.name] != clusterA && self.relations[atom.name] != nil {
                            clusterA = self.relations[atom.name]!
                            break
                        }
                    }
                    for atom in clusterB.atoms {
                        if self.relations[atom.name] != clusterB && self.relations[atom.name] != nil {
                            clusterB = self.relations[atom.name]!
                            break
                        }
                    }
                    if clusterA == clusterB {
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    }
                    let currentDistance = Double(uniqueKey)
                    let newDistance = clusterA.distance(clusterB)
                    if currentDistance < newDistance && newDistance > self.maxDistance {
                        //recalculate data
                        let distanceManager = DistanceManager.shared
                        distanceManager.addValue(from: clusterA, toCluster: clusterB)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    } else {
                        //print("merge")
                        clusterB.atoms.forEach() {self.relations[$0.name] = clusterA}
                        clusterA.addPinsFrom(clusterB)
                        if let index = self.clusters.indexOf(clusterB) {
                            self.clusters.removeAtIndex(index)
                        }
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    }
                }
                if var cluster = pair.first as? Cluster, let pin = pair.last as? Atom {
                    for atom in cluster.atoms {
                        if self.relations[atom.name] != cluster && self.relations[atom.name] != nil {
                            cluster = self.relations[atom.name]!
                            break
                        }
                    }
                    if let clusterB = self.relations[pin.name] {
                        if clusterB == cluster {
                            distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                            return distances
                        }
                        let newDistance = cluster.distance(clusterB)
                        let currentDistance = Double(uniqueKey)!
                        //if new distance from parent cluster to cluster greater than maxdistance - add new data
                        if currentDistance < newDistance && newDistance > self.maxDistance {
                            let distanceManager = DistanceManager.shared
                            distanceManager.addValue(from: cluster, toCluster: clusterB)
                            distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                            return distances
                        } else {
                            //merge clusters
                            clusterB.atoms.forEach() {self.relations[$0.name] = cluster}
                            cluster.addPinsFrom(clusterB)
                            pin.hidden = true
                            if let index = self.clusters.indexOf(clusterB) {
                                self.clusters.removeAtIndex(index)
                            }
                            distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                            return distances
                        }
                    } else {
                        //pin not in cluster
                        let newDistance = cluster.distanceTo(pin)
                        let currentDistance = Double(uniqueKey)!
                        
                        if currentDistance < newDistance && newDistance > self.maxDistance {
                            let distanceManager = DistanceManager.shared
                            distanceManager.addValue(from: cluster, toAtom: pin)
                            distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                            return distances
                        } else {
                            //add pin to cluster
                            cluster.atoms.append(pin)
                            self.relations[pin.name] = cluster
                            pin.hidden = true
                            distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                            return distances
                        }
                    }
                }
            }
            //second priority - atom and atom
            if let pair = pinsPairs[uniqueKey] {
                let nodeA = pair.first!
                let nodeB = pair.last!
                var nodeAIsInCluster = false
                var nodeACluster: Cluster?
                if let cluster = self.relations[nodeA.name] {
                    nodeAIsInCluster = true
                    nodeACluster = cluster
                    nodeA.hidden = true
                }
                var nodeBIsInCluster = false
                var nodeBCluster: Cluster?
                if let cluster = self.relations[nodeB.name] {
                    nodeBIsInCluster = true
                    nodeBCluster = cluster
                    nodeB.hidden = true
                }
                if nodeACluster == nodeBCluster && nodeBCluster != nil && nodeACluster != nil {
                    distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                    return distances
                }
                if nodeAIsInCluster && !nodeBIsInCluster {
                    let currentDistance = Double(uniqueKey)!
                    let newDistance = nodeACluster!.distanceTo(nodeB)
                    if currentDistance < newDistance && newDistance > self.maxDistance {
                        let distanceManager = DistanceManager.shared
                        distanceManager.addValue(from: nodeACluster!, toAtom: nodeB)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    } else {
                        nodeB.hidden = true
                        self.relations[nodeB.name] = nodeACluster
                        nodeACluster?.atoms.append(nodeB)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    }
                } else if !nodeAIsInCluster && nodeBIsInCluster {
                    let currentDistance = Double(uniqueKey)!
                    let newDistance = nodeBCluster!.distanceTo(nodeA)
                    if currentDistance < newDistance && newDistance > self.maxDistance {
                        let distanceManager = DistanceManager.shared
                        distanceManager.addValue(from: nodeBCluster!, toAtom: nodeA)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    } else {
                        nodeA.hidden = true
                        self.relations[nodeA.name] = nodeBCluster
                        nodeBCluster?.atoms.append(nodeA)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    }
                } else if nodeAIsInCluster && nodeBIsInCluster {
                    let currentDistance = Double(uniqueKey)
                    let newDistance = nodeACluster?.distance(nodeBCluster!)
                    if currentDistance < newDistance && newDistance > self.maxDistance {
                        let distanceManager = DistanceManager.shared
                        distanceManager.addValue(from: nodeACluster!, toCluster: nodeBCluster!)
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    } else {
                        nodeBCluster!.atoms.forEach() {self.relations[$0.name] = nodeACluster}
                        nodeACluster!.addPinsFrom(nodeBCluster!)
                        if let index = self.clusters.indexOf(nodeBCluster!) {
                            self.clusters.removeAtIndex(index)
                        }
                        distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                        return distances
                    }
                } else {
                    let newCluster = Cluster()
                    newCluster.atoms.appendContentsOf([nodeA, nodeB])
                    nodeA.hidden = true
                    nodeB.hidden = true
                    self.relations[nodeA.name] = newCluster
                    self.relations[nodeB.name] = newCluster
                    self.clusters.append(newCluster)
                    distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                    return distances
                }
            } else {
                distances.removeAtIndex(self.getIndex(of: uniqueKey, inData: distances))
                return distances
            }
        }
        print("ERROR END")
        return []
    }
    
    func getIndex(of element: String, inData: [String]) -> Int {
        if let index = inData.indexOf(element) {
            return index
        } else {
            print("0")
            return 0
        }
    }
    
    func mergeData(first: [String], second: [String]) -> [String] {
        var data = first
        data.appendContentsOf(second)
        data.sortInPlace { (first, second) -> Bool in
            return Double(first)! < Double(second)!}
        return data
    }
}


public enum ZoomState {
    case ZoomIn, ZoomOut, None
}