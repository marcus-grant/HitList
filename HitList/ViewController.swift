//
//  ViewController.swift
//  HitList
//
//  Created by Marcus Grant on 6/1/16.
//  Copyright © 2016 Marcus Grant. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    // Now use managed objects called "people" to store them as persisted entities
    var people = [NSManagedObject]()

    // old version where the names list wasn't a managed object model to show how
    // storing with memory doesn't persist the app's data on reboot of app or phone
    //var names = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //name the view being controlled
        title = "\"The List\""
        //register the tableview within this view-controller so that the controller knows to deque cells of type UITableViewCell and that it does so with the identifier "Cell"
        tableView.registerClass(UITableViewCell.self,
                                forCellReuseIdentifier: "Cell")
    }


    //MARK: UITableViewDataSource
    // The tableview definition func that needs to be defined to tell the controller
    // the number of rows to produce, and to satisfy the UITableViewDataSource proto
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // Now use the NSManagedObject array to define list dataSource
        return people.count
    }

    // The second UITableViewDataSource protocol func that defines how each cell
    // is configured. Each cell gets dequed, it's textLabel gets defined by the 
    // name of each Person entity within the people[] array and is then returned
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {

            let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")

            // Each row now represents a "Person" from our list of NSManagedObj's
            let person = people[indexPath.row]

            // Since each person is a managedObject, we use valueForKey("name")
            // inorder to grab the attribute "name"'s value to use in the cell
            // CoreData uses Key Value Coding to store objects.
            // Since
            cell!.textLabel!.text = person.valueForKey("name") as? String
            return cell!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Since whenever the tableView is being updated at startup
        // it will need to know what people are stored in CoreData
        // First access the managedContext from appDelegate
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        // Then create a reference "managedContext" to its managedObjectContext
        let managedContext = appDelegate.managedObjectContext

        // Next create a fetch request for entities of type "Person" within the context
        let fetchRequest = NSFetchRequest(entityName: "Person")

        // Create an error to catch any problems with storing or retrieving from CoreData
        //var error: NSError?

        do {
            people = try managedContext.executeRequest(fetchRequest) as! [Person]
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")

        }

        // Finally, attempt to fetch and store the entities within people[] array to,
        // which is the array that populates the tableView


//        do {
//            let results =
//                try managedContext.executeRequest(fetchRequest)
//            people = results as! [NSManagedObject]
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
    }

    @IBAction func addName(sender: AnyObject) {
        //Create the modal UIAlertController view that will be used to add names
        let addNameAlert = UIAlertController(title: "New Name",
                                             message: "Add a new name",
                                             preferredStyle: .Alert)


        // Create the UIAlertAction that will be used with the alertController
        // to save a new name entered in the dialog view
        let saveAlertAction =
            UIAlertAction(title: "Save",
                          style: .Default,
                          handler: { (action: UIAlertAction) -> Void in

                            // The Action Handler parameter is where we...
                            // read the first textfield that will be defined later
                            let textField = addNameAlert.textFields!.first
                            // Using CoreData now as DataSource
                            //self.names.append(textField!.text!)
                            // Instead use saveName() func to handle saving to src
                            self.saveName(textField!.text!)
                            // Reload the dataSource of tableView
                            self.tableView.reloadData()
            })


        // Create the cancel action for when you don't actually wish to add a name
        // in the alert view
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default)
        {
            (action: UIAlertAction) -> Void in
        }


        // Create a text field with blank block that won't be used for configuring the textfield
        addNameAlert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }

        // Add the defined actions save and cancel to the addNameAlert
        addNameAlert.addAction(saveAlertAction)
        addNameAlert.addAction(cancelAction)

        // Present the newly defined alert controller as the final action when pressed
        presentViewController(addNameAlert,
                              animated: true,
                              completion: nil)
    }

    func saveName(name: String){
        // First get the Managed Object Context our data is stored in.
        // The context is basically a scratchpad within memory where data resides
        // before getting stored using the persistant store controller with save()
        // To do this the appDelegate gets referenced as appDelegate where the
        // context is stored using the CoreDataStack
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext

        // Usually I create functions within the ManagedObjectModels Class defnition
        // to handle changes to the managedContext but since this is such a simple
        // app it's going to be handled in here
        // This is done with the NSManagedObject initializer init(entity)
        let entity =
            NSEntityDescription.entityForName("Person",
                                              inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!,
                                     insertIntoManagedObjectContext: managedContext)

        // Now that an entity has been referenced as the var "person",
        // the passed var "name" is assigned to the person as a Key Value Code
        person.setValue(name, forKey: "name")

        // Next make sure that the updated managedContext is saved as with the
        // persistant store by using the ManagedObjectContext func save().
        // Use a do-try-catch block to handle any potential save errors just incase
        // Then append this new person to memory within the VC using people[] array
        do {
            try managedContext.save()
            people.append(person)
        } catch let error {
            print("Failed to save to context: \(error), \(error.userInfo)")
        }
    
    }
}






