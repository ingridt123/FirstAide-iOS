//
//  MenuTableViewController.swift
//  PCSA
//  Slide Menu
//
//  Created by Chamika Weerasinghe on 6/7/16.
//  Copyright © 2016 Peacecorps. All rights reserved.
//

import UIKit

class MenuTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageLogo: UIImageView!
    
    
    // The number of elements in the data source
    var total = 0
    
    // The identifier for the parent cells.
    let parentCellIdentifier = "ParentCell"
    
    // The identifier for the child cells.
    let childCellIdentifier = "ChildCell"
    
    // The data source
    var dataSource: [Parent]!
    
    // Define wether can exist several cells expanded or not.
    let numberOfCellsExpanded: NumberOfCellExpanded = .one
    
    // Constant to define the values for the tuple in case of not exist a cell expanded.
    let NoCellExpanded = (-1, -1)
    
    // The index of the last cell expanded and its parent.
    var lastCellExpanded : (Int, Int)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate=self
        self.tableView.dataSource=self
        self.setInitialDataSource()
        self.lastCellExpanded = NoCellExpanded
        
        let width = revealViewController().view.frame.width
        
        revealViewController().rearViewRevealWidth = width * 0.8
    }
    
    
    /**
     Set the initial data for test the table view.
     
     - parameter parents: The number of parents cells
     - parameter childs:  Then maximun number of child cells per parent.
     */
    fileprivate func setInitialDataSource() {
        
        //TODO: Load data from plist and use MVVM
        dataSource = [Parent(state: .collapsed, childs: [String](), title: Constants.GET_HELP_NOW),
                      Parent(state: .collapsed, childs: [String](), title: Constants.CIRCLE_OF_TRUST),
                      Parent(state: .collapsed, childs: [
                        Constants.PERSONAL_SECURITY_STRATEGIES,
                        Constants.RADAR,
                        Constants.COPING_WITH_UNWANTED,
                        Constants.TACTICS_OF_SEXUAL_PREDATORS,
                        Constants.BYSTANDER_INTERVENTION,
                        Constants.SAFETY_PLAN_BASICS,
                        Constants.SAFETY_PLAN_WORKSHEET
                        ], title: Constants.SAFETY_TOOLS),
                      Parent(state: .collapsed, childs: [
                        Constants.BENEFITS_OF_SEEKING_STAFF,
                        Constants.AVAILABLE_SERVICES_AFTER_SEXUAL_ASSAULT,
                        Constants.PEACE_CORPS_COMMITMENT_TO_VICTIM,
                        Constants.WHAT_TO_DO_AFTER_ASSAULT,
                        Constants.CONFIDENTIALITY,
                        Constants.PEACE_CORPS_MYTHBUSTERS
                        ], title: Constants.SUPPORTING_SERVICES),
                      Parent(state: .collapsed, childs: [
                        Constants.WAS_IT_SEXUAL_ASSAULT,
                        Constants.SEXUAL_ASSAULT_COMMON_QUESTIONS,
                        Constants.IMPACT_SEXUAL_ASSAULT,
                        Constants.SEXUAL_HARRASSMENT,
                        Constants.HELPING_FRIEND_OR_COMMUNITY_MEMBER
                        ], title: Constants.SEXUAL_ASSAULT_AWARENESS),
                      Parent(state: .collapsed, childs: [
                        Constants.PEACE_COPRS_POLICY_SEXUAL_ASSAULT,
                        Constants.GLOSSARY,
                        Constants.FURTHER_RESOURCES
                        ], title: Constants.POLICIES_AND_GLOSSARY)
        ]
        self.total = dataSource.count;
    }
    
    /**
     Expand the cell at the index specified.
     
     - parameter index: The index of the cell to expand.
     */
    fileprivate func expandItemAtIndex(_ index : Int, parent: Int) {
        
        // the data of the childs for the specific parent cell.
        let currentSubItems = self.dataSource[parent].childs
        
        // update the state of the cell.
        self.dataSource[parent].state = .expanded
        
        // position to start to insert rows.
        var insertPos = index + 1
        
        let indexPaths = (0..<currentSubItems.count).map { _ -> IndexPath in
            let indexPath = IndexPath(row: insertPos, section: 0)
            insertPos += 1
            return indexPath
        }
        
        // insert the new rows
        self.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        
        // update the total of rows
        self.total += currentSubItems.count
    }
    
    /**
     Collapse the cell at the index specified.
     
     - parameter index: The index of the cell to collapse
     */
    fileprivate func collapseSubItemsAtIndex(_ index : Int, parent: Int) {
        
        var indexPaths = [IndexPath]()
        
        let numberOfChilds = self.dataSource[parent].childs.count
        
        // update the state of the cell.
        self.dataSource[parent].state = .collapsed
        
        guard index + 1 <= index + numberOfChilds else { return }
        
        // create an array of NSIndexPath with the selected positions
        indexPaths = (index + 1...index + numberOfChilds).map { IndexPath(row: $0, section: 0)}
        
        // remove the expanded cells
        self.tableView.deleteRows(at: indexPaths, with: UITableViewRowAnimation.fade)
        
        // update the total of rows
        self.total -= numberOfChilds
    }
    
    /**
     Update the cells to expanded to collapsed state in case of allow severals cells expanded.
     
     - parameter parent: The parent of the cell
     - parameter index:  The index of the cell.
     */
    fileprivate func updateCells(_ parent: Int, index: Int) {
        
        switch (self.dataSource[parent].state) {
            
        case .expanded:
            self.collapseSubItemsAtIndex(index, parent: parent)
            self.lastCellExpanded = NoCellExpanded
            
        case .collapsed:
            switch (numberOfCellsExpanded) {
            case .one:
                // exist one cell expanded previously
                if self.lastCellExpanded != NoCellExpanded {
                    
                    let (indexOfCellExpanded, parentOfCellExpanded) = self.lastCellExpanded
                    
                    self.collapseSubItemsAtIndex(indexOfCellExpanded, parent: parentOfCellExpanded)
                    
                    // cell tapped is below of previously expanded, then we need to update the index to expand.
                    if parent > parentOfCellExpanded {
                        let newIndex = index - self.dataSource[parentOfCellExpanded].childs.count
                        self.expandItemAtIndex(newIndex, parent: parent)
                        self.lastCellExpanded = (newIndex, parent)
                    }
                    else {
                        self.expandItemAtIndex(index, parent: parent)
                        self.lastCellExpanded = (index, parent)
                    }
                }
                else {
                    self.expandItemAtIndex(index, parent: parent)
                    self.lastCellExpanded = (index, parent)
                }
            case .several:
                self.expandItemAtIndex(index, parent: parent)
            }
        }
    }
    
    /**
     Find the parent position in the initial list, if the cell is parent and the actual position in the actual list.
     
     - parameter index: The index of the cell
     
     - returns: A tuple with the parent position, if it's a parent cell and the actual position righ now.
     */
    fileprivate func findParent(_ index : Int) -> (parent: Int, isParentCell: Bool, actualPosition: Int) {
        
        var position = 0, parent = 0
        guard position < index else { return (parent, true, parent) }
        
        var item = self.dataSource[parent]
        
        repeat {
            
            switch (item.state) {
            case .expanded:
                position += item.childs.count + 1
            case .collapsed:
                position += 1
            }
            
            parent += 1
            
            // if is not outside of dataSource boundaries
            if parent < self.dataSource.count {
                item = self.dataSource[parent]
            }
            
        } while (position < index)
        
        // if it's a parent cell the indexes are equal.
        if position == index {
            return (parent, position == index, position)
        }
        
        item = self.dataSource[parent - 1]
        return (parent - 1, position == index, position - item.childs.count - 1)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.total
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : MenuTableViewCell!
        
        let (parent, isParentCell, actualPosition) = self.findParent((indexPath as NSIndexPath).row)
        
        if !isParentCell {
            cell = tableView.dequeueReusableCell(withIdentifier: childCellIdentifier, for: indexPath) as! MenuTableViewCell
            cell.childTitle!.text = self.dataSource[parent].childs[(indexPath as NSIndexPath).row - actualPosition - 1]
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: parentCellIdentifier, for: indexPath) as! MenuTableViewCell
            cell.title!.text = self.dataSource[parent].title
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (parent, isParentCell, actualPosition) = self.findParent((indexPath as NSIndexPath).row)
        
        if isParentCell {
            self.presentComponentViewController((indexPath as NSIndexPath).row)
            
        }else {
            presentChildViewController(self.dataSource[parent].childs[(indexPath as NSIndexPath).row - actualPosition - 1])
            return
        }
        
        self.tableView.beginUpdates()
        self.updateCells(parent, index: (indexPath as NSIndexPath).row)
        self.tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func presentComponentViewController(_ index: Int){
        var viewIdentifier:String
        switch index {
        case 0:
            viewIdentifier = "GET_HELP_NOW"
        case 1:
            viewIdentifier = "CIRCLE_OF_TRUST"
        default:
            viewIdentifier = ""
        }
        
        navigateToViewController(viewIdentifier)
    }

    func presentChildViewController(_ value: String){
        var viewIdentifier:String
        switch value {
        // Safety Tools
        case Constants.PERSONAL_SECURITY_STRATEGIES:
            viewIdentifier = ""
        case Constants.RADAR:
            viewIdentifier = "RADAR"
        case Constants.COPING_WITH_UNWANTED:
            viewIdentifier = "COPING_WITH_UNWANTED"
        case Constants.TACTICS_OF_SEXUAL_PREDATORS:
            viewIdentifier = "TACTICS_OF_SEXUAL_PREDATORS"
        case Constants.BYSTANDER_INTERVENTION:
            viewIdentifier = "BYSTANDER_INTERVENTION"
        case Constants.SAFETY_PLAN_BASICS:
            viewIdentifier = "SAFETY_PLAN_BASICS"
        case Constants.SAFETY_PLAN_WORKSHEET:
            viewIdentifier = "SAFETY_PLAN_WORKSHEET"
            
        // Supporting Services
        case Constants.BENEFITS_OF_SEEKING_STAFF:
            viewIdentifier = "BENEFITS_OF_SEEKING_STAFF"
        case Constants.AVAILABLE_SERVICES_AFTER_SEXUAL_ASSAULT:
            viewIdentifier = "AVAILABLE_SERVICES_AFTER_SEXUAL_ASSAULT"
        case Constants.PEACE_CORPS_COMMITMENT_TO_VICTIM:
            viewIdentifier = "PEACE_CORPS_COMMITMENT_TO_VICTIM"
        case Constants.WHAT_TO_DO_AFTER_ASSAULT:
            viewIdentifier = "WHAT_TO_DO_AFTER_ASSAULT"
        case Constants.CONFIDENTIALITY:
            viewIdentifier = "CONFIDENTIALITY"
        case Constants.PEACE_CORPS_MYTHBUSTERS:
            viewIdentifier = "PEACE_CORPS_MYTHBUSTERS"
            
        // Sexual Assault Awareness
        case Constants.WAS_IT_SEXUAL_ASSAULT:
            viewIdentifier = "WAS_IT_SEXUAL_ASSAULT"
        case Constants.SEXUAL_ASSAULT_COMMON_QUESTIONS:
            viewIdentifier = "SEXUAL_ASSAULT_COMMON_QUESTIONS"
        case Constants.IMPACT_SEXUAL_ASSAULT:
            viewIdentifier = "IMPACT_SEXUAL_ASSAULT"
        case Constants.SEXUAL_HARRASSMENT:
            viewIdentifier = "SEXUAL_HARRASSMENT"
        case Constants.HELPING_FRIEND_OR_COMMUNITY_MEMBER:
            viewIdentifier = "HELPING_FRIEND_OR_COMMUNITY_MEMBER"
        
        default:
            viewIdentifier = ""
        }
        
        navigateToViewController(viewIdentifier)
    }
    
    func navigateToViewController(_ viewIdentifier:String){
        if(!viewIdentifier.isEmpty){
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: viewIdentifier)
            let nav = revealViewController().frontViewController as! UINavigationController
            nav.pushViewController(viewController!, animated: true)
            revealViewController().revealToggle(animated: true)
        }
    }
    
}
