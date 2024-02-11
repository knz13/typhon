/*
 * Copyright 2011-2019 Branimir Karadzic. All rights reserved.
 * License: https://github.com/bkaradzic/bgfx#license-bsd-2-clause
 */
#include "src/engine/engine.h"
#include "src/engine/rendering_engine.h"

int main()
{
    Engine::Initialize();

    while (RenderingEngine::isRunning())
    {
        RenderingEngine::HandleEvents();

        RenderingEngine::Render();
    }

    Engine::Unload();

    return 0;
}
