//
//  ViewController.swift
//  SimpleFileManager
//
//  Created by Надежда Зенкова on 03.08.2020.
//  Copyright © 2020 Надежда Зенкова. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    @IBOutlet var filesTableView: UITableView!
    
    let fileManager = FileManagerService()
    var filesData = [File?]()
    var directoryName = "Documents"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSampleFiles()
        filesData = fileManager.getListOfFiles(from: directoryName)
        setNavigationItems()
        filesTableView.delegate = self
        filesTableView.dataSource = self
        filesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilesCell")
    }
    
    
    private func setNavigationItems() {
        let addDirectoryItem = UIBarButtonItem(image: UIImage(named: "addDirectory"), style: .plain, target: self, action: #selector(addDirectory))
        let addFileItem = UIBarButtonItem(image: UIImage(named: "addFile"), style: .plain, target: self, action: #selector(addFile))
        self.navigationItem.title = directoryName
        self.navigationItem.setRightBarButtonItems([addFileItem, addDirectoryItem], animated: true)
    }
    
    @objc private func addDirectory() {
        let alertController = UIAlertController(title: "Directory name", message: nil, preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {  _ in
            if let name = alertController.textFields?.first?.text {
                self.createDirectory(name: name)
            }
            else {
                print("No name")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        alertController.addTextField(configurationHandler: { textField in })
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func addFile() {
        let alertController = UIAlertController(title: "File name", message: nil, preferredStyle: .alert)
        let createAction = UIAlertAction(title: "Create", style: .default, handler: {  _ in
            if let name = alertController.textFields?.first?.text {
                self.createFile(name: name)
            }
            else {
                print("No name")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        alertController.addAction(createAction)
        alertController.addAction(cancelAction)
        alertController.addTextField(configurationHandler: { textField in })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filesData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilesCell", for: indexPath)
        cell.imageView?.image = filesData[indexPath.row]?.isDirectory ?? false ? UIImage(named: "directory") : UIImage(named: "file")
        cell.textLabel?.text = filesData[indexPath.row]?.name
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let file = filesData[indexPath.row] else { return }
        if file.isDirectory {
            guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as? ViewController else { return }
            destinationController.directoryName = file.name
            self.navigationController?.pushViewController(destinationController, animated: true)
        } else {
            guard let destinationController = self.storyboard?.instantiateViewController(withIdentifier: "fileDetailsVC") as? FileDetailsViewController else { return }
            destinationController.fileText = fileManager.readFile(at: self.directoryName, withName: file.name)
            self.navigationController?.pushViewController(destinationController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { action,view,completion in
            self.fileManager.deleteFile(at: self.filesData[indexPath.row]?.path)
            self.filesData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        })
        
        deleteAction.backgroundColor = .systemRed
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    private func setupSampleFiles() {        
        fileManager.createDirectory(withName: "Directory 1", in: "Documents")
        fileManager.createDirectory(withName: "Directory 2", in: "Documents")
        fileManager.createDirectory(withName: "Directory 3", in: "Documents")
        fileManager.createDirectory(withName: "Directory 4", in: "Documents")
        fileManager.writeFile(containing: "Hello world!", to: "", withName: "File 1")
        fileManager.writeFile(containing: "Hello world!", to: "", withName: "File 2")
        fileManager.writeFile(containing: "Hello world!", to: "", withName: "File 3")
    }
    
    private func createFile(name: String) {
        fileManager.writeFile(containing: "Hello world!", to: directoryName, withName: name)
        filesData = fileManager.getListOfFiles(from: directoryName)
        self.filesTableView.reloadData()
        
    }
    
    private func createDirectory(name: String) {
        //let nameIsAlreadyUsed = filesData.contains(where: { $0?.name == name })
        fileManager.createDirectory(withName: name, in: directoryName)
        filesData = fileManager.getListOfFiles(from: directoryName)
        self.filesTableView.reloadData()
    }

}

