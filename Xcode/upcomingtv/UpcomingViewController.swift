//
//  UpcomingViewController.swift
//  upcomingtv
//
//  Created by Daniel on 6/8/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class UpcomingViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var dataSource: [UTV.Section] = []

    @IBAction func addAction(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addvc = storyboard.instantiateViewController(withIdentifier: "AddShowViewController") as! AddShowViewController
        addvc.delegate = self
        let navc = UINavigationController(rootViewController: addvc)
        present(navc, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super .viewDidLoad()

        loadData()
    }
    
}

extension UpcomingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let s = dataSource[indexPath.section]

        guard let item = s.items?[indexPath.row] else { return }

        let ac = UIAlertController.init(title: nil, message: "Would you like to delete this?", preferredStyle: .actionSheet)

        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = tableView.cellForRow(at: indexPath)
        }

        ac.addAction(
            UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
                self.updateTable(item: item, indexPath: indexPath)
                self.updateMyList(item)
            })
        )
        ac.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        present(ac, animated: true, completion: nil)
    }

}

extension UpcomingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let s = dataSource[section]
        return s.header
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = dataSource[section]
        return s.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "id")

        let s = dataSource[indexPath.section]
        if let item = s.items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.subtitle
        }

        cell.detailTextLabel?.textColor = .secondaryLabel

        return cell
    }

}

extension UpcomingViewController: DidUpdateFavorites {

    func didUpdateFavorites() {
        loadData()
    }

}

private extension UpcomingViewController {

    func updateMyList(_ item: UTV.Item) {
        var mylist = MyList()
        var list = mylist.list

        if let index = list.firstIndex(of: item) {
            list.remove(at: index)
        }

        mylist.list = list
    }

    func updateTable(item: UTV.Item, indexPath: IndexPath) {
        var updated = dataSource
        var section = updated[indexPath.section]
        var items = section.items
        if let i = items?.firstIndex(of: item) {
            items?.remove(at: i)
        }
        section.items = items

        if items?.count ?? 0 == 0 {
            section.header = nil
        }
        updated[indexPath.section] = section
        dataSource = updated

        tableView.deleteRows(at: [indexPath], with: .automatic)
        if items?.count ?? 0 == 0 {
            tableView.reloadSections([indexPath.section], with: .automatic)
        }
    }

}

private extension UpcomingViewController {

    func getUpdatedItem(group: DispatchGroup, url: URL?, item: UTV.Item, completion: @escaping (UTV.Item) -> Void) {
        print("getting data for \(item.title ?? "")")
        group.enter()
        url?.get { (r: Result<TV, NetError>) in
            guard case .success(let result) = r else { return }

            var u = item
            u.subtitle = result.network 
            u.nextEpisode = result.next_episode_to_air

            completion(u)
            group.leave()
        }
    }

    func getNextEpisode(_ items: [UTV.Item]) {
        let group = DispatchGroup()

        var updated: [UTV.Item] = []

        for item in items {
            let url = Tmdb.tvURL(tvId: item.id, append: false)
            if item.nextEpisode == nil {
                getUpdatedItem(group: group, url: url, item: item) { (u) in
                    updated.append(u)
                }
            }
            else if let inPast = item.nextEpisode?.inPast,
                inPast {
                getUpdatedItem(group: group, url: url, item: item) { (u) in
                    updated.append(u)
                }
            }
            else {
                updated.append(item)
            }
        }

        group.notify(queue: .main) {
            self.dataSource = UTV.Section.dataSource(updated)
            self.tableView.reloadData()

            var mylist = MyList()
            mylist.list = updated
        }
    }

    func loadData() {
        let items = MyList().list
        getNextEpisode(items)
    }

}

private extension Date {

    var numberOfDaysFromNow: Int? {
        let calendar = Calendar.current

        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: self)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }

}

private extension Episode {

    var inPast : Bool {
        let df = Tmdb.dateFormatter
        guard let date = df.date(from: air_date ?? "") else { return true }

        return date.numberOfDaysFromNow ?? 0 < 0
    }

}

/// Credits: https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/
private extension Sequence where Iterator.Element: Hashable {

    var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }

}

private extension String {

    var display: String? {
        let df = Tmdb.dateFormatter
        guard let date = df.date(from: self) else { return nil }

        df.dateFormat = "EEEE, MMM d"
        let formatted = df.string(from: date)
        return formatted
    }

    var inDays: String? {
        let df = Tmdb.dateFormatter
        guard let date = df.date(from: self) else { return nil }

        switch date.numberOfDaysFromNow {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "In \(date.numberOfDaysFromNow ?? 0) days (\(display ?? ""))"
        }
    }

    var upcoming: String {
        guard let inDays = inDays else { return "No upcoming episode" }

        return inDays
    }

}

private extension TV {

    var network: String? {
        return networks?.first?.name
    }

}

private extension UTV.Section {

    static func dataSource(_ items: [UTV.Item]) -> [UTV.Section] {
        let dates = items
            .sorted { $0.nextEpisode?.air_date ?? "" < $1.nextEpisode?.air_date ?? "" }
            .map { $0.nextEpisode?.air_date ?? "" }
            .unique

        var sections: [UTV.Section] = []
        for date in dates {
            let items = items.filter { $0.nextEpisode?.air_date ?? "" == date }
            if items.count > 0 {
                let sorted = items.sorted { $0.title ?? "" < $1.title ?? "" }
                let s = UTV.Section(header: date.upcoming, items: sorted)
                sections.append(s)
            }
        }

        return sections
    }

}
