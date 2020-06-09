//
//  AddShowViewController.swift
//  upcomingtv
//
//  Created by Daniel on 6/7/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class AddShowViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var dataSource: [UTV.Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        loadData()
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

        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

extension AddShowViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let s = dataSource[section]
        return s.items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        let s = dataSource[indexPath.section]
        if let item = s.items?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.inMyList ? .checkmark : .none
        }

        return cell
    }

}

private extension AddShowViewController {

    func loadData() {
        let url = Tmdb.tvURL(kind: .on_the_air)
        url?.tmdbGet(completion: { (result: Result<TvSearch, NetError>) in
            guard case .success(let r) = result else { return }

            self.dataSource = r.dataSource
            self.tableView.reloadData()
//            print(r)
        })
    }

}

private extension TvSearch {

    var dataSource: [UTV.Section] {
        let items = results.map { UTV.Item(id: $0.id, title: $0.name, subtitle: "todo2") }
        let section = UTV.Section(items: items)
        return [section]
    }

}

struct UTV {

    struct Section {
        var items: [Item]?
    }

    struct Item: Codable {
        var id: Int?
        var title: String?
        var subtitle: String?
    }

}

extension UTV.Item: Equatable {

    static func ==(lhs: UTV.Item, rhs: UTV.Item) -> Bool {
        return lhs.id == rhs.id
    }

}

private extension UTV.Item {

    var inMyList: Bool {
        let mylist = MyList().list

        let filtered = mylist.filter { $0.id ?? 0 == id ?? 0 }

        return filtered.count > 0
    }

}

extension URL {

    func tmdbGet<T: Codable>(completion: @escaping (Result<T, NetError>) -> Void) {
        print("get: \(self.absoluteString)")

        let session = URLSession.shared
        session.dataTask(with: self) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(.failure(.session))
                }

                return
            }

            guard let unwrapped = data else {
                DispatchQueue.main.async {
                    completion(.failure(.data))
                }

                return
            }

            guard let result = try? JSONDecoder().decode(T.self, from: unwrapped) else {
                DispatchQueue.main.async {
                    completion(.failure(.json))
                }
                return
            }

            DispatchQueue.main.async {
                completion(.success(result))
            }
        }.resume()
    }

}

enum NetError: Error {
    case data
    case json
    case session
}

struct MyList {

    var list: [UTV.Item] = UserDefaultsConfig.list {
        didSet {
            UserDefaultsConfig.list = list
        }
    }

}

private struct UserDefaultsConfig {

    @UserDefault("list", defaultValue: [])
    fileprivate static var list: [UTV.Item]

}
