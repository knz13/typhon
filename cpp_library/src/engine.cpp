#include "engine.h"
#include "crunch_texture_packer.h"
#include <filesystem>
#include <fstream>
#include "rendering_engine.h"
#include "component/make_component.h"
#include "component/default_components/transform.h"
#include "auxiliary_libraries_helpers/auxiliary_library.h"

namespace fs = std::filesystem;

Vector2f Engine::mousePosition;
std::map<std::string, TextureAtlasImageProperties> Engine::textureAtlas;
std::bitset<std::size(Keys::IndicesOfKeys)> EngineInternals::keysPressed;
std::function<void(double, double, int64_t, int64_t, int64_t, int64_t, double, double, double, double)> EngineInternals::enqueueRenderFunc = [](double, double, int64_t, int64_t, int64_t, int64_t, double, double, double, double) {};
std::function<void()> EngineInternals::onChildrenChangedFunc = []() {};
bool Engine::isInitialized = false;

void Engine::Initialize()
{
    std::cout << "initializing engine!" << std::endl;
    if (isInitialized)
    {
        Engine::Unload();
    }

    for (auto &[key, func] : Reflection::InitializedStaticallyStorage::functionsFromDerivedClasses)
    {
        func();
    }

    for (auto func : AuxiliaryLibrariesInternals::initializeFunctions)
    {
        func();
    }

    textureAtlas = CreateTextureAtlasFromImages();

    RenderingEngine::InitializeEngine();
    RenderingEngine::SetUpdateFunction(&Engine::Update);

    Engine::isInitialized = true;
}

void Engine::Unload()
{

    RenderingEngine::UnloadEngine();

    for (auto func : AuxiliaryLibrariesInternals::unloadFunctions)
    {
        func();
    }

    Clear();

    Engine::isInitialized = false;
}

std::vector<std::string> Engine::GetImagePathsFromLibrary()
{
    std::vector<std::string> inputs;
    try
    {

        for (const auto &file : fs::directory_iterator(
                 fs::path(HelperStatics::projectPath) / fs::path("build") / fs::path("images")))
        {
            inputs.push_back(file.path().string());
        }
    }
    catch (exception &e)
    {
        // std::cout << "Error found while loading image paths from library:\n" << e.what() << std::endl;
    }
    return inputs;
}

const std::map<std::string, TextureAtlasImageProperties> &Engine::GetTextureAtlas()
{
    return textureAtlas;
}
void EngineInternals::SetMousePosition(Vector2f mousePos)
{
    Engine::mousePosition = mousePos;
}

std::string Engine::GetPathToAtlas()
{

    fs::path atlasPath = fs::path(HelperStatics::projectPath) / fs::path("build") / fs::path("texture_atlas");
    std::filesystem::create_directories(atlasPath);

    return (atlasPath).string() + "/";
}

void Engine::Update(double dt)
{

    /* for(const auto& [handle,func] : Traits::HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate) {
        func(dt);
    }  */

    /* for(const auto& [handle,spriteData] : Traits::UsesSpriteAnimationInternals::objectsToBeRendered) {
        auto& properties = Engine::textureAtlas[spriteData.objectPointer->className];

        double anchorX,anchorY;

        if(spriteData.anchor->type == "TopLeft") {
            anchorX = 0;
            anchorY = 0;
        }
        else if (spriteData.anchor->type == "Top") {
            anchorX = (*spriteData.width)/2;
            anchorY = 0;
        }
        else if (spriteData.anchor->type == "TopRight") {
            anchorX = (*spriteData.width);
            anchorY = 0;
        }
        else if (spriteData.anchor->type == "CenterLeft") {
            anchorX = 0;
            anchorY = (*spriteData.height)/2;
        }
        else if (spriteData.anchor->type == "Center") {
            anchorX = (*spriteData.width)/2;
            anchorY = (*spriteData.height)/2;
        }
        else if (spriteData.anchor->type == "CenterRight") {
            anchorX = (*spriteData.width);
            anchorY = (*spriteData.height)/2;
        }
        else if (spriteData.anchor->type == "BottomLeft") {
            anchorX = 0;
            anchorY = (*spriteData.height);
        }
        else if (spriteData.anchor->type == "Bottom") {
            anchorX = (*spriteData.width)/2;
            anchorY = (*spriteData.height);
        }
        else if (spriteData.anchor->type == "BottomRight") {
            anchorX = (*spriteData.width);
            anchorY = (*spriteData.height);
        }
        else {
            anchorX = 0;
            anchorY = 0;
        }



        const Vector2f& position = dynamic_cast<Traits::HasPosition*>(spriteData.objectPointer)->GetPosition();
        EngineInternals::enqueueRenderFunc(
            position.x,
            position.y,
            (*spriteData.width) == -1? properties.width : *spriteData.width,
            (*spriteData.height) == -1? properties.height : *spriteData.height,
            properties.xPos + (*spriteData.x),
            properties.yPos + (*spriteData.y),
            anchorX,
            anchorY,
            *spriteData.scale,
            *spriteData.angle
        );
    } */
}

void EngineInternals::PushKeyDown(int64_t key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(), Keys::IndicesOfKeys.end(), key);

    if (indexOfKey == Keys::IndicesOfKeys.end())
    {
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 1;
}

void EngineInternals::PushKeyUp(int64_t key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(), Keys::IndicesOfKeys.end(), key);

    if (indexOfKey == Keys::IndicesOfKeys.end())
    {
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 0;
}

bool Engine::IsKeyPressed(Keys::Key key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(), Keys::IndicesOfKeys.end(), key);

    return EngineInternals::keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()];
}

std::map<std::string, TextureAtlasImageProperties> Engine::CreateTextureAtlasFromImages()
{
    std::vector<std::string> inputs = Engine::GetImagePathsFromLibrary();

    if (inputs.size() == 0)
    {
        return {};
    }

    Crunch::PackFromFolder(inputs, GetPathToAtlas(), "atlas", Crunch::CrunchOptions::optVerbose | Crunch::CrunchOptions::optJson);

    std::ifstream stream(GetPathToAtlas() + "atlas.json");

    std::stringstream sstream;

    sstream << stream.rdbuf();

    std::string sstreamRead = sstream.str();

    HelperFunctions::ReplaceAll(sstreamRead, "\\", "\\\\");

    try
    {

        json data = json::parse(sstreamRead);

        std::map<std::string, TextureAtlasImageProperties> outMap;

        for (auto &texture : data["textures"][0]["images"])
        {
            outMap[texture["n"]] = TextureAtlasImageProperties(
                texture["n"].get<std::string>(),
                texture["w"].get<int>(),
                texture["h"].get<int>(),
                texture["x"].get<int>(),
                texture["y"].get<int>());
        }

        return outMap;
    }
    catch (std::exception &e)
    {

        std::cout << "Error found while loading atlas:\n"
                  << e.what() << std::endl;

        return {};
    }
}

std::string Engine::SerializeCurrent()
{

    return Engine::SerializeCurrentJSON().dump();
}

json Engine::SerializeCurrentJSON()
{
    json finalData = json();

    // TODO

    return finalData;
}

bool Engine::DeserializeToCurrent(std::string scene)
{

    try
    {
        json sceneData = json::parse(scene);

        // TODO

        return true;
    }
    catch (std::exception &e)
    {
        std::cout << "Error while deserializing to current engine:\n"
                  << e.what() << std::endl;
        return false;
    }
}

Typhon::Object Engine::CreateObject(std::string name)
{
    Typhon::Object obj{ECSRegistry::CreateEntity()};
    obj.AddComponent<Transform>();
    if (name != "")
    {
        obj.SetName(name);
        obj.AddTag<ObjectInternals::ParentlessTag>();
        EngineInternals::onChildrenChangedFunc();
        return obj;
    }
    obj.AddTag<ObjectInternals::ParentlessTag>();
    EngineInternals::onChildrenChangedFunc();
    return {ECSRegistry::CreateEntity()};
}