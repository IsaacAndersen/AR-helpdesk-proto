//
//  MealTableViewController.swift
//  AR-helpdesk-proto
//
//  Created by ANDERSEN, ISAAC L on 8/15/17.
//  Copyright © 2017 IsaacAndersen. All rights reserved.
//

import UIKit

enum Action {
    case Setup
    case Troubleshooting
    case Tutorial
    case Call
}

struct Scenario {
    let name: String
    let action: Action
    let description: String
    let emoji: String
}

class ScenarioTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var scenarios = [Scenario]();
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSampleScenarios()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenarios.count
    }
    
    private func loadSampleScenarios() {
        let scenario1 = Scenario(name: "Device Setup", action: .Setup, description: "I need help installing new hardware or attaching new devices to my current setup.", emoji: "📺")
        let scenario2 = Scenario(name: "Software Errors", action: .Troubleshooting, description: "I'm getting an error or black screen on my set-top box and I'd like help troubleshooting.", emoji: "👾")
        let scenario3 = Scenario(name: "Tutorial", action: .Tutorial, description: "I don't know how to use my DVR or don't understand some features.", emoji: "🤷‍♂️")
        let scenario4 = Scenario(name: "Other", action: .Call, description: "My issue isn't listed above and I'd like to speak to a customer support representative.", emoji: "🗣")
        
        scenarios += [scenario1, scenario2, scenario3, scenario4]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ScenarioTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScenarioTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ScenarioTableViewCell.")
        }
        
        let scenario = scenarios[indexPath.row]
        
        cell.titleLabel.text = scenario.name
        cell.emojiLabel.text = scenario.emoji
        cell.descriptionLabel.text = scenario.description

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = scenarios[indexPath.row].action
        switch (action) {
        case .Setup:
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ARScene") as! ViewController
            self.navigationController?.pushViewController(vc, animated: true)
            break
        case .Troubleshooting:
            break
        case .Tutorial:
            break
        case .Call:
            let supportPhone = 2069479349
            if let url = URL(string: "tel://\(supportPhone)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            break
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
//    {
//        print(indexPath.row)
////        if (indexPath.row == 0)
////        {
////
////            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("AddVC") as! addRecordViewController
////            self.navigationController?.pushViewController(vc, animated: true)
////        }
////        else
////        {
////            // Navigate on other view
////        }
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
