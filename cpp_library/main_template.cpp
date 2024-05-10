#include "src/engine/engine.h"
#include "src/engine/rendering_engine.h"
#include "src/features/project_selection/project_selection_canvas.h"
// INIT_MAIN_CPP
using namespace Typhon;
int main()
{

    //__INITIALIZE__INTERNALS__STATICALLY__

    Engine::Initialize();

    RenderingEngine::SetCurrentCanvas(std::make_shared<ProjectSelectionCanvas>());

    while (RenderingEngine::isRunning())
    {
        RenderingEngine::HandleEvents();

        RenderingEngine::Render();
    }

    Engine::Unload();

    return 0;
}
