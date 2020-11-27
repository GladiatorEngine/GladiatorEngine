//
//  ServerResponseHandler.swift
//  
//
//  Created by Pavel Kasila on 11/27/20.
//

import Foundation
import NIO
import NIOTLS

final class ServerResponseHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer
    private var numBytes = 0
    
    public func channelActive(context: ChannelHandlerContext) {
        print("Client connected to \(context.remoteAddress!)")
        
        // We are connected. It's time to send the message to the server to initialize the ping-pong sequence.
        let buffer = context.channel.allocator.buffer(string: "GNClient test")
        self.numBytes = buffer.readableBytes
        context.writeAndFlush(self.wrapOutboundOut(buffer), promise: nil)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let byteBuffer = self.unwrapInboundIn(data)
        self.numBytes -= byteBuffer.readableBytes

        if self.numBytes == 0 {
            let string = String(buffer: byteBuffer)
            print("Received: '\(string)' back from the server, closing channel.")
            context.close(promise: nil)
        }
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        print("error: ", error)

        // As we are not really interested getting notified on success or failure we just pass nil as promise to
        // reduce allocations.
        context.close(promise: nil)
    }
}
