//
//  MyTableViewController.swift
//  Project-3-Word-Game
//
//  Created by Chasen Chamberlain on 3/5/18.
//  Copyright © 2018 Chasen Chamberlain. All rights reserved.
//

import UIKit

class MyTableViewController: UITableViewController, DataModelDelegate {
    
    var delegateID: String = "thing"
    func dataModelUpdated() {
        tableView.reloadData()
    }

    private static var cellreuseIdentifier = "MyTableViewController.DatasetItemsCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GameRecord.registerDelegate(self)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: MyTableViewController.cellreuseIdentifier )
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Accounts for the number of rows we will have
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard tableView == self.tableView, section == 0 else
        {
            return 0
        }
        return GameRecord.count
    }
    
    // Returns the information to display in the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < GameRecord.count
            else
        {
            return UITableViewCell()
        }
        
        // sorts my table view by finished or not
        DataModel.accessor.sortThings()
        
        var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: MyTableViewController.cellreuseIdentifier, for: indexPath)
        
        if cell.detailTextLabel == nil
        {
            cell = UITableViewCell(style: .value1, reuseIdentifier: MyTableViewController.cellreuseIdentifier)
        }
        
        if(GameRecord.entry(atIndex: indexPath.row).status == true)
        {
            cell.textLabel?.text = "Finished"
        }
        else
        {
            cell.textLabel?.text = "In Progress"
        }
        cell.detailTextLabel?.text = "Progress: \(GameRecord.entry(atIndex: indexPath.row).progress), Score: \(GameRecord.entry(atIndex: indexPath.row).score) "
        
        return cell
    }
    
    // When an alarm cell is clicked on, it launches the game board associated with it
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard tableView === self.tableView, indexPath.section == 0, indexPath.row < GameRecord.count else
        {
            return
        }
        
        // Transistion to the selected game
        let controller = GameViewController(theIndex: indexPath.row)
        navigationController?.pushViewController(controller, animated: true)
    }
}

