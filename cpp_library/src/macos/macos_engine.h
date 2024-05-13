#pragma once
#include "../general.h"
#include <objc/runtime.h>
#include <objc/message.h>
#include "macos_view_delegate.h"
#include "../rendering_engine.h"
#include "mtk_view_wrapper.h"

class MacOSEngine : public PlatformSpecificRenderingEngine
{
public:
    void InitializeRenderingEngine() override
    {
        std::cout << "initializing macos engine!" << std::endl;
        device = MTL::CreateSystemDefaultDevice();

        if (!device)
        {
            std::cout << "Failed to initialize macos rendering engine: metal not supported" << std::endl;
            return;
        }

        viewDelegate = std::make_unique<MacOSViewDelegate>(device, [&]()
                                                           { this->InternalUpdateFunc(); });

        std::cout << "Replacing rendering method!" << std::endl;

        oldMethod = MacFunctions::ReplaceDrawMethod(&MacOSEngine::DrawMethodOverride);
    };

    void ReceivePlatformSpecificViewPointer(void *view) override
    {
        mainView = view;
    }

    void UnloadRenderingEngine() override
    {
        std::cout << "unloading macos rendering engine!" << std::endl;

        if (viewDelegate)
        {
            viewDelegate->ResetRenderer();
        }

        for (auto &[key, val] : vertexShaders)
        {
            val->release();
        }
        vertexShaders.clear();
        for (auto &[key, val] : fragmentShaders)
        {
            val->release();
        }
        fragmentShaders.clear();

        viewDelegate.reset();

        if (device)
        {
            device->release();
        }

        MacFunctions::ReplaceDrawMethod(reinterpret_cast<void (*)(id, SEL, void *)>(oldMethod));
    };

    virtual bool LoadFragmentShader(std::string shaderName, ShaderCompilationResult &shaderSource) override
    {
        using NS::StringEncoding::UTF8StringEncoding;

        if (!shaderSource.jsonResources.contains("entryPoints"))
        {
            std::cerr << "Could not set fragment shader, no entry points found!" << "\n";
            return false;
        }

        if (shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main")
        {
            std::cerr << R"(Fragment shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return false;
        }

        NS::Error *error = nullptr;

        MTL::Library *fragmentShaderLibrary = nullptr;

        fragmentShaderLibrary = device->newLibrary(NS::String::string(shaderSource.shaderText.c_str(), NS::StringEncoding::UTF8StringEncoding), nullptr, &error);

        if (!fragmentShaderLibrary)
        {
            std::cerr << error->localizedDescription()->utf8String() << "\n";
            fragmentShaderLibrary = nullptr;
            return false;
        }

        if (fragmentShaders.find(shaderName) != fragmentShaders.end())
        {
            UnloadVertexShader(shaderName);
        }
        fragmentShaders[shaderName] = fragmentShaderLibrary;

        return true;
    }

    virtual bool LoadVertexShader(std::string shaderName, ShaderCompilationResult &shaderSource) override
    {
        using NS::StringEncoding::UTF8StringEncoding;

        if (!shaderSource.jsonResources.contains("entryPoints"))
        {
            std::cerr << "Could not set vertex shader, no entry points found!" << "\n";
            return false;
        }

        if (shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main")
        {
            std::cerr << R"(Vertex shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return false;
        }

        NS::Error *error = nullptr;

        MTL::Library *vertexShaderLibrary = nullptr;

        vertexShaderLibrary = device->newLibrary(NS::String::string(shaderSource.shaderText.c_str(), UTF8StringEncoding), nullptr, &error);

        if (!vertexShaderLibrary)
        {
            std::cerr << error->localizedDescription()->utf8String() << "\n";
            vertexShaderLibrary = nullptr;
            return false;
        }

        if (vertexShaders.find(shaderName) != vertexShaders.end())
        {
            UnloadVertexShader(shaderName);
        }
        vertexShaders[shaderName] = vertexShaderLibrary;

        return true;
    }

    virtual bool UnloadVertexShader(std::string shaderName) override
    {
        if (vertexShaders.find(shaderName) != vertexShaders.end())
        {
            vertexShaders.at(shaderName)->release();
            vertexShaders.erase(shaderName);
            return true;
        }
        return false;
    }

    virtual bool UnloadFragmentShader(std::string shaderName) override
    {
        if (fragmentShaders.find(shaderName) != fragmentShaders.end())
        {
            fragmentShaders.at(shaderName)->release();
            fragmentShaders.erase(shaderName);
            return true;
        }
        return false;
    }

    void *GetPlatformSpecificPointer() override
    {
        return NS::Value::value(mainView);
    };

private:
    static void DrawMethodOverride(id self, SEL _cmd, void *view)
    {
        if (RenderingEngine::GetPlatformSpecificEngine())
        {
            MacOSViewDelegate *delegate = reinterpret_cast<MacOSEngine *>(RenderingEngine::GetPlatformSpecificEngine())->viewDelegate.get();
            if (delegate)
            {
                std::cout << "Drawing in view c++!!!" << std::endl;
                delegate->drawInMTKView((MTK::View *)view);
            }
        }
    }

    std::unordered_map<std::string, MTL::Library *> vertexShaders;
    std::unordered_map<std::string, MTL::Library *> fragmentShaders;

    std::unique_ptr<MacOSViewDelegate> viewDelegate = {};
    void *mainView = nullptr;
    IMP oldMethod = []() {};
    MTL::Device *device = nullptr;
};