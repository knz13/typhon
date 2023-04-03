#include "engine.h"
#include "TerrariaLikeGame/FlyingTreant.h"
#include "game_object_traits.h"
#include "crunch_texture_packer.h"
#include <filesystem>

namespace fs = std::filesystem;

Vector2f Engine::mousePosition;
std::unordered_map<entt::entity,std::shared_ptr<GameObject>> Engine::aliveObjects;
std::bitset<std::size(Keys::IndicesOfKeys)> Engine::keysPressed;


void Engine::Initialize()
{
    std::cout << "initializing engine in c++" << std::endl;
    Engine::CreateNewGameObject<FlyingTreant>();

    std::cout << "trying texture packer" << std::endl;

    
}

std::vector<std::string> Engine::GetImagePathsFromLibrary()
{
    std::vector<std::string> inputs;
    for(const auto& file : fs::directory_iterator(
        fs::path(HelperStatics::projectPath) / fs::path("Typhon") / fs::path("lib") / fs::path("images")))
    {
        inputs.push_back(file.path());
    }
    return inputs;
}

std::string Engine::GetPathToAtlas()
{

    fs::path atlasPath = fs::path(HelperStatics::projectPath) / fs::path("Typhon") / fs::path("lib") / fs::path("texture_atlas");
    std::filesystem::create_directory(atlasPath);

    return (atlasPath).string() + "/";
}

void Engine::Update(double dt)
{
    for(const auto& [handle,func] : Traits::HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate) {
        func(dt);
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

bool Engine::IsKeyPressed(InputKey key)
{
    auto indexOfKey = std::find(Keys::IndicesOfKeys.begin(),Keys::IndicesOfKeys.end(),key);

    return keysPressed[indexOfKey - Keys::IndicesOfKeys.begin()];
}

void Engine::CreateTextureAtlasFromImages()
{
    std::vector<std::string> inputs = Engine::GetImagePathsFromLibrary();
    
    Crunch::PackFromFolder(inputs,GetPathToAtlas(),"atlas",Crunch::CrunchOptions::optVerbose | Crunch::CrunchOptions::optJson);
    
    std::filesystem::
}
