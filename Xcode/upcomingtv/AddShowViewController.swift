//
//  AddShowViewController.swift
//  upcomingtv
//
//  Created by Daniel on 6/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

protocol DidUpdateFavorites {
    func didUpdateFavorites()
}

class AddShowViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var delegate: DidUpdateFavorites?
    private var dataSource: [UTV.Section] = []
    private var query: String = ""
    private var kind: Tmdb.TvType = .on_the_air

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
        loadData(kind)
    }

}

extension AddShowViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let s = dataSource[indexPath.section]
        guard let item = s.items?[indexPath.row] else { return }

        var mylist = MyList()
        var list = mylist.list

        if item.inMyList {
            if let index = list.firstIndex(of: item) {
                list.remove(at: index)
            }
        }
        else {
            list.append(item)
        }

        mylist.list = list

        delegate?.didUpdateFavorites()

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

extension AddShowViewController: UITableViewDataSource {

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
            cell.accessoryType = item.inMyList ? .checkmark : .none
        }

        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.textColor = .secondaryLabel

        return cell
    }

}

extension AddShowViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard
            let text = searchController.searchBar.text,
            text.count > 2 else { return }

        query = text

        /// Credits: https://stackoverflow.com/questions/24330056/how-to-throttle-search-based-on-typing-speed-in-ios-uisearchbar
        /// to limit network activity, reload half a second after last key press.
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(loadSearch), object: nil)
        perform(#selector(loadSearch), with: nil, afterDelay: 0.5)
    }

}

private extension AddShowViewController {

    func loadData(_ kind: Tmdb.TvType) {
        let url = Tmdb.tvURL(kind: kind)
        url?.get { (result: Result<TvSearch, NetError>) in
            guard case .success(let r) = result else { return }

            self.dataSource = r.dataSource(header: kind.title)
            self.tableView.reloadData()
        }
    }

    @objc
    func loadSearch() {
        let url = Tmdb.searchURL(type: .tv, query: query)
        url?.get { (result: Result<TvSearch, NetError>) in
            guard case .success(let r) = result else { return }

            self.dataSource = r.dataSource(header: "Search")
            self.tableView.reloadData()
        }
    }

    func setup() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
    }

}

private extension TV {

    var firstAirDateDisplay: String? {
        guard
            let f = first_air_date,
            let index = f.firstIndex(of: "-") else { return nil }

        return String(f[..<index])
    }

    var countryDisplay: String? {
        guard
            let c = origin_country?.first,
            c != "US" else { return nil }

        return c
    }

    var overviewDisplay: String? {
        guard
            let o = overview,
            o != "" else { return nil }

        return o
    }

    var item: UTV.Item {
        var sub: [String] = []
        
        if let value = firstAirDateDisplay {
            sub.append(value)
        }

        if let value = countryDisplay {
            sub.append(value)
        }

        if let value = overviewDisplay {
            sub.append(value)
        }

        return UTV.Item(id: id, title: name, subtitle: sub.joined(separator: " - "))
    }

}

private extension TvSearch {

    func dataSource(header: String) -> [UTV.Section] {
        let items = results.map { $0.item }
        let section = UTV.Section(header: header, items: items)

        return [section]
    }

}

private extension UTV.Item {

    var inMyList: Bool {
        let mylist = MyList().list
        
        return mylist.contains(self)
    }

}
