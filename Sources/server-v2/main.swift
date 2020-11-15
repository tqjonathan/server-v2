import Socket
import Foundation
let port = 7667

struct Point {
    var x: Double
    var y: Double
}

do {
    let serverSocket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
    try serverSocket.listen(on: port)
    print("Listening on \(port)")
    var buffer = Data(capacity: 1000)
    repeat {
        let (bytesRead, clientAddress) = try serverSocket.readDatagram(into: &buffer)
        if let address = clientAddress {
            let (clientHostname, clientPort) = Socket.hostnameAndPort(from: address)!
            print("Received length \(bytesRead) from \(clientHostname):\(clientPort)")
            
            var offset = 0
            let str = buffer.withUnsafeBytes {
                String(cString: $0.bindMemory(to: UInt8.self).baseAddress!)
            }
            offset += str.count + 1
            print("String: \(str)")
            print("Current offset: \(offset)")

            var number = 0
            var count = MemoryLayout<Int>.size
            var bytesCopied = withUnsafeMutableBytes(of: &number) {
                buffer.copyBytes(to: $0, from: offset..<offset+count)
            }
            assert(bytesCopied == count)
            offset += count

            print("Number: \(number)")
            print("Current offset: \(offset)")
            var point = Point(x: 0, y: 0)
            count = MemoryLayout<Point>.size
            bytesCopied = withUnsafeMutableBytes(of: &point) {
                buffer.copyBytes(to: $0, from: offset..<offset+count)
            }
            assert(bytesCopied == count)
            offset += count
            print("Point: \(point)")


        }
        buffer.removeAll()
    } while true
} catch let error {
    print("Connection error: \(error)")
}