import Foundation

class JsonApi {
    func getUserComments(completion:@escaping ([Comments]) -> ()) {
        guard let url = URL(string: "https://raw.githubusercontent.com/kindredgroup/ARApp/master/data.json") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            let comments = try! JSONDecoder().decode([Comments].self, from: data!)
            print(comments)
            
            DispatchQueue.main.async {
                completion(comments)
            }
        }
        .resume()
    }
}
