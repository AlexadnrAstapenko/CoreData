//
//  ToDoListTVC.swift
//  CoreDataToDo
//
//  Created by Александр Астапенко on 28.04.22.
//

import CoreData
import UIKit

// MARK: - ToDoListTVC

class ToDoListTVC: UITableViewController {
    // MARK: Internal

    @IBOutlet var searchBar: UITableView!
    var filteredArr:[String] = []
    var allArray: [String] = []
    var searching:Bool?
    var selectedCategory: CategoryModel? {
        didSet {
            self.title = selectedCategory?.name
            loadItems()
        }
    }

    @IBAction func addNewItemAction(_: UIBarButtonItem) {
        addNewItem()
    }

    // MARK: - Table view data source

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if(searching ?? false){
                    return filteredArr.count
                }else{
                    return itemsArray.count
                }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        if(!(searching ?? false)){
            cell.textLabel?.text = itemsArray[indexPath.row].title
        }else{
            cell.textLabel?.text = filteredArr[indexPath.row]
        }
         
        return cell
    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        if(!(searching ?? false)){
//            cell.textLabel?.text = dataSourceArr[indexPath.row]
//        }else{
//            cell.textLabel?.text = filteredArr[indexPath.row]
//        }
//        return cell
//    }

    override func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: Private

    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var itemsArray = [Item]()

    private func addNewItem() {
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Item"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let textField = alert.textFields?.first,
               let text = textField.text,
               text != "",
               let self = self
            {
                let newItem = Item(context: self.context)
                newItem.title = text
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemsArray.append(newItem)
                self.allArray.append(newItem.title!)
                self.saveContext()
                self.tableView.insertRows(at: [IndexPath(row: self.itemsArray.count - 1, section: 0)], with: .automatic)
            }
        }

        alert.addAction(cancel)
        alert.addAction(addAction)
        present(alert, animated: true)
    }

    private func loadItems() {
        guard let name = selectedCategory?.name else { return }
        let categoryPredicate = NSPredicate(format: "parentCategory.name==\(name)")

        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = categoryPredicate

        do {
            itemsArray = try context.fetch(request)
        } catch {
            print("Error with load categories")
        }

        tableView.reloadData()
    }

    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error with save context")
        }
    }
}

// MARK: UISearchBarDelegate

extension ToDoListTVC: UISearchBarDelegate {
    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            filteredArr = allArray
        }else{
            filteredArr = allArray.filter{$0.contains(searchText)}
        }
        searching = true
        tableView.reloadData()
    }
}


