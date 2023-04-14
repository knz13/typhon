#include "engine.h"
#include "game_object_traits.h"
#include "crunch_texture_packer.h"
#include "shader_compiler.h"
#include <filesystem>
#include <fstream>

namespace fs = std::filesystem;

Vector2f Engine::mousePosition;
std::map<std::string,TextureAtlasImageProperties> Engine::textureAtlas;
std::unordered_map<entt::entity,std::shared_ptr<GameObject>> Engine::aliveObjects;
std::bitset<std::size(Keys::IndicesOfKeys)> Engine::keysPressed;
std::function<void(double,double,int64_t,int64_t,int64_t,int64_t,double,double,double,double)> EngineInternals::enqueueRenderFunc;
bool Engine::isInitialized = false;

void Engine::Initialize()
{   
    if(isInitialized){
        Engine::Unload();
    }
    std::cout << "initializing engine in c++" << std::endl;

    ShaderCompiler::getInstance();    
    
    for(auto& [key,func] : Reflection::InitializedStaticallyStorage::functionsFromDerivedClasses){
        func();
    }

    std::cout << "trying texture packer" << std::endl;
    textureAtlas = CreateTextureAtlasFromImages();
    
    std::cout << "finished texture packer!" << std::endl;
    Engine::isInitialized = true;
}

void Engine::Unload()
{   

    std::cout << "calling unload!" << std::endl;
    auto iter = aliveObjects.begin();
    while(iter != aliveObjects.end()){
        const auto& [key,value] = *iter;
        RemoveGameObject(key);
        iter = aliveObjects.begin();
    }

    GameObject::instantiableClasses.clear();
    GameObject::instantiableClassesIDs.clear();
    GameObject::instantiableClassesNames.clear();
    Engine::isInitialized = false;
}

std::vector<std::string> Engine::GetImagePathsFromLibrary()
{
    std::vector<std::string> inputs;
    try {

        for(const auto& file : fs::directory_iterator(
            fs::path(HelperStatics::projectPath) / fs::path("build") / fs::path("images")))
        {
            inputs.push_back(file.path().string());
        }
    }
    catch(exception& e) {
        std::cout << "Error found while loading image paths from library:\n" << e.what() << std::endl;
    }
    return inputs;
}

const std::map<std::string, TextureAtlasImageProperties> &Engine::GetTextureAtlas()
{
    return textureAtlas;
}

std::string Engine::GetPathToAtlas()
{

    fs::path atlasPath = fs::path(HelperStatics::projectPath) / fs::path("build") / fs::path("texture_atlas");
    std::filesystem::create_directories(atlasPath);
    std::cout << "atlas path = " << atlasPath.string() << std::endl;

    return (atlasPath).string() + "/";
}

void Engine::Update(double dt)
{
    for(const auto& [handle,func] : Traits::HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate) {
        func(dt);
    } 

    for(const auto& [handle,spriteData] : Traits::UsesSpriteAnimationInternals::objectsToBeRendered) {
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
    }

}

void Engine::PushKeyDown(int64_t key)
{      
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);
    
    if(indexOfKey == Keys::IndicesOfKeys.end()){
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 1;
}

void Engine::PushKeyUp(int64_t key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);
    
    if(indexOfKey == Keys::IndicesOfKeys.end()){
        std::cout << "tried to push a key into the keys pressed stack with a wrong id!" << std::endl;
    }
    keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()] = 0;
}

bool Engine::IsKeyPressed(Keys::Key key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);

    return keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()];
}

std::map<std::string,TextureAtlasImageProperties> Engine::CreateTextureAtlasFromImages()
{
    std::vector<std::string> inputs = Engine::GetImagePathsFromLibrary();
    
    if(inputs.size() == 0){
        return {};
    }
    std::cout << "inputs = " << std::endl;
    for(const auto& val : inputs) {
        std::cout << val << std::endl;
    }
    Crunch::PackFromFolder(inputs,GetPathToAtlas(),"atlas",Crunch::CrunchOptions::optVerbose | Crunch::CrunchOptions::optJson);
    
    std::ifstream stream(GetPathToAtlas() + "atlas.json");

    try {

    json data = json::parse(stream);

    std::map<std::string,TextureAtlasImageProperties> outMap;

    for(auto& texture : data["textures"][0]["images"]){
        outMap[texture["n"]] = TextureAtlasImageProperties(
            texture["n"].get<std::string>(),
            texture["w"].get<int>(),
            texture["h"].get<int>(),
            texture["x"].get<int>(),
            texture["y"].get<int>()
        );
    }

    return outMap;
    }
    catch(std::exception& e) {

        std::cout << "Error found while loading atlas:\n" << e.what()<<std::endl;

        return {};
    }

}
