import Foundation
import Asterism

struct PushRequest: Request {
  var headers: [String : String]? = nil
  var showLogs: Bool? = true
  var statusCodes: [Int]? = nil
  
  var methodType: RequestType {
    .post
  }
  
  var url: String {
    "https://actionable.darkworks.io/pushAction"
  }
  
  let dataToSend: String
  
  var type: ContentType {
    let push = PushData(id: UUID().uuidString, date: String(Date().timeIntervalSince1970), receivedData: dataToSend)
    let data = try! JSONEncoder().encode(push)
    return .json(data)
  }
  
}

struct PushData: Codable {
  let id: String
  let date: String
  let receivedData: String
}
