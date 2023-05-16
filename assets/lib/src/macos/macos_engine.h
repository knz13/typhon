#pragma once
#include "../general.h"
#include "macos_view_delegate.h"
#include "../rendering_engine.h"

class MacOSEngine : public PlatformSpecificRenderingEngine {
public:
    

    void InitializeRenderingEngine() override {
        std::cout << "initializing macos engine!" << std::endl;
        device = MTL::CreateSystemDefaultDevice();
        if(!device){
            std::cout << "Failed to initialize macos rendering engine: metal not supported" << std::endl;
            return;
        }
        CGRect rect = CGRect();
        rect.origin = CGPoint();
        rect.origin.x = 0;
        rect.origin.y = 0;
        rect.size.width = 10;
        rect.size.height = 10;
        mainView = MTK::View::alloc()->init(rect,device);
        viewDelegate = std::make_unique<MacOSViewDelegate>(mainView->device(),[&](){
            std::cout << "Calling update!" << std::endl;
            this->CallUpdateFunc();
        });
        mainView->setClearColor(MTL::ClearColor(0,0,0,1));
        mainView->setDelegate(viewDelegate.get());
        
    };
    void UnloadRenderingEngine() override {
        std::cout << "unloading macos rendering engine!" << std::endl;
        if(mainView){
            mainView->release();
        }
        for(auto& [key,val] : vertexShaders){
            val->release();
        }
        vertexShaders.clear();
        for(auto& [key,val] : fragmentShaders){
            val->release();
        }
        fragmentShaders.clear();
        if(device){
            device->release();
        }

        viewDelegate.reset();
        
    };
   
    virtual bool LoadFragmentShader(std::string shaderName,ShaderCompilationResult& shaderSource) override {
        using NS::StringEncoding::UTF8StringEncoding;

        
        if(!shaderSource.jsonResources.contains("entryPoints")) {
            std::cerr << "Could not set fragment shader, no entry points found!" << "\n";
            return false;
        }
        
        if(shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main") {
            std::cerr << R"(Fragment shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return false;
        }

        NS::Error* error = nullptr; 

        
        MTL::Library* fragmentShaderLibrary = nullptr;
        
        fragmentShaderLibrary = device->newLibrary( NS::String::string(shaderSource.shaderText.c_str(),UTF8StringEncoding),nullptr, &error);

        if(!fragmentShaderLibrary) {    
            std::cerr << error->localizedDescription()->utf8String() << "\n";   
            fragmentShaderLibrary = nullptr;    
            return false; 
        }   

        if(fragmentShaders.find(shaderName) != fragmentShaders.end()){
            UnloadVertexShader(shaderName);
        }
        fragmentShaders[shaderName] = fragmentShaderLibrary;

        return true;
    }

    virtual bool LoadVertexShader(std::string shaderName,ShaderCompilationResult& shaderSource) override {
        using NS::StringEncoding::UTF8StringEncoding;

        if(!shaderSource.jsonResources.contains("entryPoints")) {
            std::cerr << "Could not set vertex shader, no entry points found!" << "\n";
            return false;
        }

        if(shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main") {
            std::cerr << R"(Vertex shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return false;
        }

        NS::Error* error = nullptr;
        

        MTL::Library* vertexShaderLibrary = nullptr;
        
        vertexShaderLibrary = device->newLibrary( NS::String::string(shaderSource.shaderText.c_str(),UTF8StringEncoding),nullptr, &error);
        
        if(!vertexShaderLibrary) {
            std::cerr << error->localizedDescription()->utf8String() << "\n";
            vertexShaderLibrary = nullptr;
            return false;
        }

        if(vertexShaders.find(shaderName) != vertexShaders.end()){
            UnloadVertexShader(shaderName);
        }
        vertexShaders[shaderName] = vertexShaderLibrary;

        return true;
    }

    virtual bool UnloadVertexShader(std::string shaderName) override {
        if(vertexShaders.find(shaderName) != vertexShaders.end()){
            vertexShaders.at(shaderName)->release();
            vertexShaders.erase(shaderName);
            return true;
        }
        return false;
    }

    virtual bool UnloadFragmentShader(std::string shaderName) override {
       if(fragmentShaders.find(shaderName) != fragmentShaders.end()){
            fragmentShaders.at(shaderName)->release();
            fragmentShaders.erase(shaderName);
            return true;
        }
        return false;
    }

    void* GetPlatformSpecificPointer() override  {      
        return mainView;        
    };      
    
private:
    std::unordered_map<std::string,MTL::Library*> vertexShaders;
    std::unordered_map<std::string,MTL::Library*> fragmentShaders;

  
    std::unique_ptr<MacOSViewDelegate> viewDelegate = {};
    MTK::View* mainView = nullptr;
    MTL::Device* device = nullptr;

};