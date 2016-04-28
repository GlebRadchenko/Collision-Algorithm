import Foundation
import UIKit

public class ViewManager {
    public static let shared = ViewManager()
    public init(){}
    
    public var zoom = MainManager.shared.zoomValue
    var shift: Double {
        get {
            return 950 / self.zoom
        }
    }
    
    public var view: UIView?
    
    var clusterSubLayers: [CAShapeLayer] = []
    var atomSublayers: [CAShapeLayer] = []
    var linesSublayer: [CAShapeLayer] = []
    
    public func drawAtoms(atoms: [Atom]) {
        atomSublayers.forEach() {$0.removeFromSuperlayer()}
        atomSublayers = []
        let visibleAtoms = atoms.filter() {$0.hidden == false}
        for atom in visibleAtoms {
            drawCircle((atom.x + 900) / zoom - shift, y: (atom.y + 900) / zoom, radius: CGFloat(atom.radius), view: self.view!, flag: 0)
        }
        
    }
    
    public func drawClusters(clusters: [Cluster]) {
        clusterSubLayers.forEach() {$0.removeFromSuperlayer()}
        clusterSubLayers = []
        for cluster in clusters {
            drawCircle((cluster.x + 900) / zoom - shift, y: (cluster.y + 900) / zoom, radius: CGFloat(cluster.radius), view: self.view!, flag: 1)
        }
    }
    
    func drawCircle(x: Double, y: Double, radius: CGFloat, view: UIView, flag: Int) -> CAShapeLayer {
        let circle = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circle.CGPath
        if radius <= 15.0 {
            shapeLayer.fillColor = UIColor.redColor().CGColor
        } else {
            shapeLayer.fillColor = UIColor.darkGrayColor().CGColor
        }
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        shapeLayer.lineWidth = 0.5
        view.layer.addSublayer(shapeLayer)

        switch flag {
        case 1:
            clusterSubLayers.append(shapeLayer)
        default:
            atomSublayers.append(shapeLayer)
        }
        
        return shapeLayer
    }
    func drawLine(x1: Double, y1: Double, x2: Double, y2: Double, flag: Int) {
        let line = UIBezierPath()
        line.moveToPoint(CGPoint(x: x1, y: y1))
        line.addLineToPoint(CGPoint(x: x2, y: y2))
        line.closePath()
        let shapelayer = CAShapeLayer()
        shapelayer.path = line.CGPath
        
        switch flag {
        case 0:
            shapelayer.strokeColor = UIColor.blackColor().CGColor
            shapelayer.lineWidth = 0.3
        case 1:
            shapelayer.strokeColor = UIColor.greenColor().CGColor
            shapelayer.lineWidth = 0.5
        case 2:
            shapelayer.strokeColor = UIColor.redColor().CGColor
            shapelayer.lineWidth = 0.6
        default:
            break
        }
        self.linesSublayer.append(shapelayer)
        self.view!.layer.addSublayer(shapelayer)
    }
    
    public func drawLines(data: [String: [AnyObject]]) {
        linesSublayer.forEach() {$0.removeFromSuperlayer()}
        linesSublayer = []
        for (_, pair) in data {
            if let cluster = pair.first as? Cluster, atom = pair.last as? Atom {
                drawLine((cluster.x + 900) / zoom - shift, y1: (cluster.y + 900) / zoom , x2: (atom.x + 900) / zoom - shift, y2: (atom.y + 900) / zoom,flag: 1)
            }
            if let cluster = pair.first as? Cluster, another = pair.last as? Cluster {
                drawLine((cluster.x + 900) / zoom - shift, y1: (cluster.y + 900) / zoom , x2: (another.x + 900) / zoom - shift, y2: (another.y + 900) / zoom, flag: 2)
            }
        }
        let dataSource = DistanceManager.shared.dataSource
        
        for (_, pair) in dataSource {
            if let cluster = pair.first, another = pair.last {
                drawLine((cluster.x + 900) / zoom - shift, y1: (cluster.y + 900) / zoom , x2: (another.x + 900) / zoom - shift, y2: (another.y + 900) / zoom, flag: 0)
            }
        }
    }
    
    public func drawSlider(view: UIView) {
        let slider = UISlider(frame: CGRect(x: 10, y: view.frame.height - 50, width: view.frame.width - 20, height: 40))
        slider.minimumValue = Float(MainManager.shared.zoomValue)
        slider.maximumValue = 20.0
        slider.addTarget(self, action: #selector(ViewManager.valueChanged(_:)), forControlEvents: .ValueChanged)
        view.addSubview(slider)
    }
    @objc func valueChanged(slider: UISlider) {
        let mainManager = MainManager.shared
        self.zoom = Double(slider.value)
        mainManager.zoomValue = Double(slider.value)
        mainManager.processData()
    }
}