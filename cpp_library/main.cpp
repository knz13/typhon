/*
 * Copyright 2011-2019 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */
#include "src/engine/engine.h"
#include "src/engine/rendering_engine.h"
#include "src/features/project_selection/project_selection_canvas.h"
#include "src/vendor/ixwebsocket/ixwebsocket/IXNetSystem.h"
#include "src/vendor/ixwebsocket/ixwebsocket/IXWebSocket.h"
#include "src/vendor/ixwebsocket/ixwebsocket/IXUserAgent.h"
#include "src/vendor/ixwebsocket/ixwebsocket/IXWebSocketServer.h"

int main()
{
    int port = 9090;
    std::string host("0.0.0.0"); // If you need this server to be accessible on a different machine, use "0.0.0.0"
    ix::WebSocketServer server(port, host);

    server.setOnClientMessageCallback([](std::shared_ptr<ix::ConnectionState> connectionState, ix::WebSocket &webSocket, const ix::WebSocketMessagePtr &msg)
                                      {
    // The ConnectionState object contains information about the connection,
    // at this point only the client ip address and the port.
    std::cout << "Remote ip: " << connectionState->getRemoteIp() << std::endl;

    if (msg->type == ix::WebSocketMessageType::Open)
    {
        std::cout << "New connection" << std::endl;

        // A connection state object is available, and has a default id
        // You can subclass ConnectionState and pass an alternate factory
        // to override it. It is useful if you want to store custom
        // attributes per connection (authenticated bool flag, attributes, etc...)
        std::cout << "id: " << connectionState->getId() << std::endl;

        // The uri the client did connect to.
        std::cout << "Uri: " << msg->openInfo.uri << std::endl;

        std::cout << "Headers:" << std::endl;
        for (auto it : msg->openInfo.headers)
        {
            std::cout << "\t" << it.first << ": " << it.second << std::endl;
        }
    }
    else if (msg->type == ix::WebSocketMessageType::Message)
    {
        // For an echo server, we just send back to the client whatever was received by the server
        // All connected clients are available in an std::set. See the broadcast cpp example.
        // Second parameter tells whether we are sending the message in binary or text mode.
        // Here we send it in the same mode as it was received.
        std::cout << "Received: " << msg->str << std::endl;

        webSocket.send(msg->str, msg->binary);
    } });

    auto res = server.listen();
    if (!res.first)
    {
        std::cout << "Server cannot listen on port " << port << std::endl;
        // Error handling
        return 1;
    }

    // Per message deflate connection is enabled by default. It can be disabled
    // which might be helpful when running on low power devices such as a Rasbery Pi
    server.disablePerMessageDeflate();

    // Run the server in the background. Server can be stoped by calling server.stop()
    server.start();

    // Block until server.stop() is called.
    server.wait();

        /* Engine::Initialize();

    RenderingEngine::SetCurrentCanvas(std::make_shared<ProjectSelectionCanvas>());

    while (RenderingEngine::isRunning())
    {
        RenderingEngine::HandleEvents();

        RenderingEngine::Render();
    }

    Engine::Unload(); */

    return 0;
}
