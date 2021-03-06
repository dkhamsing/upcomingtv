//
//  Tmdb.swift
//
//  Created by Daniel on 5/5/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

private extension Tmdb {

    struct Constant {
        static let apiKey = "GET API KEY"
        static let host = "api.themoviedb.org"
        static let imageBaseUrl = "https://image.tmdb.org/t/p/"
    }

}

struct Tmdb {

    static func collectionURL(collectionId: Int?) -> URL? {
        guard let collectionId = collectionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.collection)/\(collectionId)"

        return urlComponents.url
    }

    static func searchURL(type: SearchType, query: String) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.search)\(type.rawValue)"
        
        let genreQueryItem = URLQueryItem(name: "query", value: query)
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]
        
        return urlComponents.url
    }

    static func moviesURL(genreId: Int?) -> URL? {
        guard let genreId = genreId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "with_genres", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func moviesURL(productionId: Int?) -> URL? {
        guard let genreId = productionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "with_companies", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func moviesURL(sortedBy: String?) -> URL? {
        guard let sortedBy = sortedBy else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.discover

        let genreQueryItem = URLQueryItem(name: "sort_by", value: sortedBy)
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(genreId: Int?) -> URL? {
        guard let genreId = genreId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_genres", value: String(genreId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(networkId: Int?) -> URL? {
        guard let networkId = networkId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_networks", value: String(networkId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func tvURL(productionId: Int?) -> URL? {
        guard let networkId = productionId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = Path.tvDiscover

        let genreQueryItem = URLQueryItem(name: "with_companies", value: String(networkId))
        urlComponents.queryItems = [ Tmdb.keyQueryItem, genreQueryItem ]

        return urlComponents.url
    }

    static func movieURL(movieId: Int?) -> URL? {
        guard let movieId = movieId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.movie)/\(movieId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "credits,videos,external_ids,recommendations,similar")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func personURL(personId: Int?) -> URL? {
        guard let personId = personId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.person)/\(personId)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "movie_credits,tv_credits,external_ids")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

    static func tvURL(tvId: Int?, append: Bool = true) -> URL? {
        guard let tvId = tvId else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(tvId)"

        var qi = [Tmdb.keyQueryItem ]
        if append {
            let appendQueryItem = URLQueryItem(name: "append_to_response", value: "credits,external_ids,recommendations,videos")
            qi.append(appendQueryItem)
        }

        urlComponents.queryItems = qi

        return urlComponents.url
    }

    static func tvURL(tvId: Int?, seasonNumber: Int?) -> URL? {
        guard
            let tvId = tvId,
            let seasonNumber = seasonNumber else { return nil }

        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(tvId)/season/\(seasonNumber)"

        let appendQueryItem = URLQueryItem(name: "append_to_response", value: "credits")
        urlComponents.queryItems = [ Tmdb.keyQueryItem, appendQueryItem ]

        return urlComponents.url
    }

}

extension Tmdb {

    static func castProfileUrl(path: String?, size: ProfileSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func mediaPosterUrl(path: String?, size: PosterSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

    static func stillImageUrl(path: String?, size: StillSize) -> URL? {
        guard
            let path = path,
            let url = URL(string: "\(Constant.imageBaseUrl)\(size.rawValue)\(path)") else { return nil }

        return url
    }

}

enum PosterSize: String {
    case tiny = "w92"
    case small = "w154"
    case medium = "w185"
    case large = "w342"
    case xl = "w500"
    case xxl = "w780"
}

enum ProfileSize: String {
    case small = "w45"
    case medium = "w185"
    case large = "h632"
}

enum StillSize: String {
    case small = "w92"
    case medium = "w185"
    case large = "w300"
    case original = "original"
}

extension Tmdb {

    enum TvType: String, CaseIterable {
        case
        popular,
        top_rated,
        airing_today,
        on_the_air

        var title: String {
            switch self {
            case .popular:
                return self.rawValue.capitalized

            case .airing_today:
                return "Airing Today"

            case .on_the_air:
                return "On The Air"

            case .top_rated:
                return "Top Rated"
            }
        }
    }

    enum MoviesType: String, CaseIterable {
        case
        popular,
        top_rated,
        now_playing,
        upcoming

        var title: String {
            switch self {
            case .popular, .upcoming:
                return self.rawValue.capitalized

            case .now_playing:
                return "Now Playing"

            case .top_rated:
                return "Top Rated"
            }
        }

        var tv: TvType {
            switch self {
            case .popular:
                return .popular
            case .top_rated:
                return .top_rated
            case .now_playing:
                return .airing_today
            case .upcoming:
                return .on_the_air
            }
        }
    }

    static func moviesURL(kind: MoviesType) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.movie)/\(kind.rawValue)"

        return urlComponents.url
    }

    static var peoplePopularURL: URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.person)/popular"

        return urlComponents.url
    }

    static func tvURL(kind: TvType) -> URL? {
        var urlComponents = baseComponents
        urlComponents.path = "\(Path.tv)/\(kind.rawValue)"

        return urlComponents.url
    }

}

extension Tmdb {
    enum SearchType: String {
        case movie, person, tv
    }

    static let separator = " · "

    static let voteThreshold = 10

    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter
    }
}

private extension Tmdb {

    enum Path {
        static let collection = "/3/collection"
        static let discover = "/3/discover/movie"
        static let movie = "/3/movie"
        static let person = "/3/person"
        static let search = "/3/search/"
        static let tv = "/3/tv"
        static let tvDiscover = "/3/discover/tv"
    }

    static var baseComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Constant.host
        urlComponents.queryItems = [ Tmdb.keyQueryItem ]

        return urlComponents
    }

    static var keyQueryItem: URLQueryItem {
        return URLQueryItem(name: "api_key", value: Constant.apiKey)
    }

}
