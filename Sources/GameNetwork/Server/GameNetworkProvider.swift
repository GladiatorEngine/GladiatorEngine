//
//  GameNetworkProvider.swift
//  
//
//  Created by Pavel Kasila on 11/28/20.
//

import GRPC
import NIO

class GameNetworkProvider: GameNetwork_GreeterProvider {
    var interceptors: GameNetwork_GreeterServerInterceptorFactoryProtocol?

    func sayHello(request: GameNetwork_HelloRequest, context: StatusOnlyCallContext) -> EventLoopFuture<GameNetwork_HelloReply> {
        let recipient = request.name.isEmpty ? "stranger" : request.name
        let response = GameNetwork_HelloReply.with {
          $0.message = "Hello \(recipient)!"
        }
        return context.eventLoop.makeSucceededFuture(response)
    }
}
