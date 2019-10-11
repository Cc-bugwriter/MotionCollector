// Copyright © 2019 Brad Howes. All rights reserved.

import os
import UIKit
import CoreData

/**
 UITableViewController that shows entries for all known RecordingInfo instances. Supports left and right swiping for
 actions per row, and editing of cells to delete past recordings.
 */
final class RecordingsTableViewController: UITableViewController, SegueHandler {

    @IBOutlet weak var editButton: UIBarButtonItem!

    /**
     Enumeration of the segues that can come from this controller.
     */
    enum SegueIdentifier: String {

        /**
         The embedded segue for the embedded UITableViewController
         */
        case embedRecordingsTableView = "embedRecordingsTableView"
    }

    private var dataSource: TableViewDataSource<RecordingsTableViewController>!

     /// Obtain the number of rows in the table.
    public var count: Int { return dataSource.count }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

// MARK: - TableViewDataSourceDelegate

extension RecordingsTableViewController: TableViewDataSourceDelegate {

    /**
     Configure a cell to show the values from a given RecordingInfo

     - parameter cell: the cell to render into
     - parameter object: the RecordingInfo instance to render
     */
    func configure(_ cell: RecordingInfoTableViewCell, for object: RecordingInfo) {
        RecordingInfoCellConfigurator.configure(cell: cell, with: object)
    }

    /**
     Determine if the given row can be deleted.

     - parameter indexPath: index of the row to check
     - returns: true if the row can be deleted
     */
    func canDelete(_ indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 || !UIApplication.appDelegate.isRecording
    }

    /**
     Delete a row.

     - parameter obj: the RecordingInfo instance to delete
     - parameter at: the row representing the recording
     */
    func delete(_ obj: RecordingInfo, at: IndexPath) {
        obj.delete()
    }
}

// MARK: - Swipe Actions of UITableViewDelegate

extension RecordingsTableViewController {

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let recordingInfo = dataSource.object(at: indexPath)
        guard !recordingInfo.isRecording else { return .none }
        return tableView.isEditing ? .delete : .none
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !isEditing else { return nil }
        let recordingInfo = dataSource.object(at: indexPath)
        return RecordingInfoCellConfigurator.makeLeadingSwipeActions(at: indexPath, with: recordingInfo,
                                                                     cell: tableView.cellForRow(at: indexPath))
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let recordingInfo = dataSource.object(at: indexPath)
        return RecordingInfoCellConfigurator.makeTrailingSwipeActions(vc: self, at: indexPath, with: recordingInfo)
    }
}

// MARK: - Private

extension RecordingsTableViewController {

    private func setupTableView() {
        guard let managedContext = UIApplication.appDelegate.recordingInfoManagedContext else { fatalError("nil recordingInfoManagedContext") }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        let request = RecordingInfo.sortedFetchRequest
        request.fetchBatchSize = 40
        request.returnsObjectsAsFaults = false
        let frc = NSFetchedResultsController(fetchRequest: request,managedObjectContext: managedContext,
                                             sectionNameKeyPath: nil, cacheName: nil)
        dataSource = TableViewDataSource(tableView: tableView, cellIdentifier: "RecordingInfo",
                                         fetchedResultsController: frc, delegate: self)
    }
}
