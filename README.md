# IMPORTANT



func setupData() {

        let json : [String: Any] = ["title": "ABC", "dict": ["1":"First", "2":"Second"]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: "http://ip.jsontest.com/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
        }
        
        task.resume()
    }
