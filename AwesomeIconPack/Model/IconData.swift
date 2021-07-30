import Foundation

struct IconData: Codable {
    var theme: [IconDetail]
    var premiumImage: [String]
    var tutorial: [String]
}

struct IconDetail: Codable {
    var themeName: String
    var isPaid : Bool
    var themeImage: String
    var icons: CategorizedIcons
    var wallpapers: [String]

    struct  CategorizedIcons: Codable{
        var Utilities: [String]
        var SNS: [String]
        var Entertainment: [String]
        var Shopping: [String]
        var Money: [String]
        var Work: [String]
        var Others: [String]
    }
}

class Load: NSObject {
    func loadJson(fromURLString urlString: String,
                          completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                if let data = data {
                    completion(.success(data))
                }
            }
            urlSession.resume()
        }
    }

    func parse(jsonData: Data) -> IconData? {
        do {
            let decodedData = try JSONDecoder().decode(IconData.self, from: jsonData)
            return decodedData
        } catch let error as NSError {
            print("decode error: \(error.localizedDescription)" )
            return nil
        }
    }
}
