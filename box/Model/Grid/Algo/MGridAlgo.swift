import Foundation
import CoreLocation

class MGridAlgo
{
    static let kMaxDistance:CLLocationDistance = 1000
    let factory:MGridAlgoFactory
    private weak var controller:CGrid?
    private(set) var items:[MGridAlgoItem]
    private(set) var nearItems:[MGridAlgoItem]?
    
    init()
    {
        factory = MGridAlgoFactory()
        items = []
    }
    
    //MARK: private
    
    private func filterNear(
        fromItems:[MGridAlgoItem],
        location:CLLocation,
        renderReady:Bool) -> [MGridAlgoItem]
    {
        var near:[MGridAlgoItem] = []
        
        for item:MGridAlgoItem in fromItems
        {
            item.distanceTo(
                location:location,
                renderReady:renderReady)
            
            guard
                
                let itemDistance:CLLocationDistance = item.distance
                
            else
            {
                continue
            }
            
            if itemDistance < MGridAlgo.kMaxDistance
            {
                near.append(item)
            }
        }
        
        return near
    }
    
    private func loadFirebaseBugs(userLocation:CLLocation)
    {
        FMain.sharedInstance.db.listenOnce(
            path:FDb.algoBug,
            nodeType:FDbAlgoHostileBug.self)
        { [weak self] (node:FDbProtocol?) in
            
            var items:[MGridAlgoItemHostileBug] = []
            
            if let bugs:FDbAlgoHostileBug = node as? FDbAlgoHostileBug
            {
                let bugIds:[String] = Array(bugs.items.keys)
                
                for bugId:String in bugIds
                {
                    guard
                        
                        let bug:FDbAlgoHostileBugItem = bugs.items[bugId]
                        
                    else
                    {
                        continue
                    }
                    
                    let item:MGridAlgoItemHostileBug = MGridAlgoItemHostileBug(
                        firebaseId:bugId,
                        firebaseBug:bug)
                    
                    items.append(item)
                }
            }
            
            self?.firebaseBugsLoaded(
                items:items,
                userLocation:userLocation)
        }
    }
    
    private func firebaseBugsLoaded(
        items:[MGridAlgoItem],
        userLocation:CLLocation)
    {
        let nearBugs:[MGridAlgoItem] = filterNear(
            fromItems:items,
            location:userLocation,
            renderReady:false)
        
        let forceCreation:Bool
        
        if nearBugs.count > 0
        {
            forceCreation = false
        }
        else
        {
            forceCreation = true
        }
        
        if let bug:MGridAlgoItemHostileBug = factory.createBug(
            location:userLocation,
            force:forceCreation)
        {
            self.items.append(bug)
        }
        
        self.items.append(contentsOf:items)
        loadFirebaseAids(userLocation:userLocation)
    }
    
    private func loadFirebaseAids(userLocation:CLLocation)
    {
        FMain.sharedInstance.db.listenOnce(
            path:FDb.algoAid,
            nodeType:FDbAlgoAid.self)
        { [weak self] (node:FDbProtocol?) in
            
            var items:[MGridAlgoItemAid] = []
            
            if let aids:FDbAlgoAid = node as? FDbAlgoAid
            {
                let aidIds:[String] = Array(aids.items.keys)
                
                for aidId:String in aidIds
                {
                    guard
                        
                        let aid:FDbAlgoAidItem = aids.items[aidId]
                        
                    else
                    {
                        continue
                    }
                    
                    let item:MGridAlgoItemAid = MGridAlgoItemAid(
                        firebaseId:aidId,
                        firebaseAid:aid)
                    
                    items.append(item)
                }
            }
            
            self?.firebaseAidsLoaded(
                items:items,
                userLocation:userLocation)
        }
    }
    
    private func firebaseAidsLoaded(
        items:[MGridAlgoItem],
        userLocation:CLLocation)
    {
        if let aid:MGridAlgoItemAid = factory.createAid(location:userLocation)
        {
            self.items.append(aid)
        }
        
        self.items.append(contentsOf:items)
        controller?.algosLoaded()
    }
    
    //MARK: public
    
    func loadAlgo(
        userLocation:CLLocation,
        controller:CGrid)
    {
        self.controller = controller
        nearItems = nil
        items = []
        
        DispatchQueue.global(qos:DispatchQoS.QoSClass.background).async
        { [weak self] in
            
            self?.loadFirebaseBugs(userLocation:userLocation)
        }
    }
    
    func filterNearItems(userLocation:CLLocation)
    {
        nearItems = filterNear(
            fromItems:items,
            location:userLocation,
            renderReady:true)
    }
}
