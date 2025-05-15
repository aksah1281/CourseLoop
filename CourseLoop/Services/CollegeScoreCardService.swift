//
//  CollegeScoreCardService.swift
//  CourseLoop
//
//  Created by Akash Patel on 4/19/25.
//

import Foundation
import Combine

// College model for API responses
struct College: Identifiable, Decodable {
    var id: String
    var name: String
    var city: String?
    var state: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "school.name"
        case city = "school.city"
        case state = "school.state"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle id that could be either a number or string
        if let idInt = try? container.decode(Int.self, forKey: .id) {
            self.id = String(idInt)
        } else {
            self.id = try container.decode(String.self, forKey: .id)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.city = try container.decodeIfPresent(String.self, forKey: .city)
        self.state = try container.decodeIfPresent(String.self, forKey: .state)
    }
}

// Response structure for the API
struct CollegeResponse: Decodable {
    var metadata: Metadata
    var results: [College]
    
    struct Metadata: Decodable {
        var total: Int
        var page: Int
        var per_page: Int
        
        enum CodingKeys: String, CodingKey {
            case total
            case page
            case per_page
        }
    }
}

// API Service class - simplified
class CollegeScoreCardService {
    private let apiKey = "opdGmXi102f1WftMaWgsqKvrQoMe67a28rbFuLfM"
    private let baseURL = "https://api.data.gov/ed/collegescorecard/v1/schools"
    private let fields = "id,school.name,school.city,school.state"
    
    private var cancellables = Set<AnyCancellable>()
    
    func searchColleges(query: String, completion: @escaping ([College]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }
        
        let urlString = "\(baseURL)?api_key=\(apiKey)&fields=\(fields)&school.name=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CollegeResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    print("Error fetching colleges: \(error)")
                    completion([])
                case .finished:
                    break
                }
            }, receiveValue: { response in
                completion(response.results)
            })
            .store(in: &cancellables)
    }
}
