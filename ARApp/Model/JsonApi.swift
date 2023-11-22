import Foundation

class JsonApi {
    func getObjects(completion:@escaping ([Objects]) -> ()) {
        guard let url = URL(string: "https://raw.githubusercontent.com/kindredgroup/ARApp/master/data.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let objects = try! JSONDecoder().decode([Objects].self, from: data!)
            DispatchQueue.main.async {
                completion(objects)
                print("Received Data")
                print(objects)
            }
        }
        .resume()
    }
}
