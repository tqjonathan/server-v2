import Socket
import Foundation

let port = 7667



do {
    let serverSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
    try serverSocket.listen(on: port)
    print("Listening on \(port)")
    var buffer = Data(capacity: 1000)
    repeat {
        var (bytesRead, clientAddress) = try serverSocket.readDatagram(into: &buffer)
        if let address = clientAddress {
            let (clientHostname, clientPort) = Socket.hostnameAndPort(from: address)!
            let dataType = buffer.withUnsafeBytes {
                String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)
            }
            if dataType == "string" {
                buffer.removeAll()
                (bytesRead,_) = try serverSocket.readDatagram(into: &buffer)
                let mess = buffer.withUnsafeBytes {
                    String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)
                }
                if mess != ""{
                    print("Received length \(bytesRead) from \(clientHostname):\(clientPort)")
                    print("> Client: \(mess)")
                    let reply = "\n> Server: \(mess)\n"
                    try serverSocket.write(from: reply, to: address)//devuelve el mensaje al cliente
                }

            }else{
                buffer.removeAll()
                (bytesRead,_) = try serverSocket.readDatagram(into: &buffer)
                let mess = buffer.withUnsafeBytes {
                    $0.load(as: Int.self)
                }
                // print("Received length \(bytesRead) from \(clientHostname):\(clientPort)")
                print("> Client: \(mess)")
                let reply = "\n> Server: \(mess)\n"
                try serverSocket.write(from: reply, to: address)//devuelve el mensaje al cliente
            }

        }
        buffer.removeAll()
    } while true
} catch let error {
    print("Connection error: \(error)")
}
