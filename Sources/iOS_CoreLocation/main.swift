import Foundation
import Alamofire

if let accountSID = ProcessInfo.processInfo.environment["ACb6c0bd9c0d0c11b1a3fdeb58155e9c26"],
    let authToken = ProcessInfo.processInfo.environment["cb0a0209127d60edc8deb39f696242e4"] {
    
    let url = "https://api.twilio.com/2010-04-01/Accounts/\(accountSID)/Messages"
    let parameters = ["From": "5864603960", "To": "2488607630", "Body": "Hello from Swift!"]
    
    Alamofire.request(url, method: .post, parameters: parameters)
        .authenticate(user: accountSID, password: authToken)
        .responseJSON { response in
            debugPrint(response)
    }
    
    RunLoop.main.run()
}
