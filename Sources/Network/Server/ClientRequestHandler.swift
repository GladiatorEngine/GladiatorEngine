//
//  ClientRequestHandler.swift
//  
//
//  Created by Pavel Kasila on 11/28/20.
//

import Foundation
import NIO

private final class ClientRequestHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        context.write(data, promise: nil)
    }

    func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }
}
