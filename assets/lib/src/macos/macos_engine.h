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
        viewDelegate = std::make_unique<MacOSViewDelegate>(mainView->device());
        mainView->setClearColor(MTL::ClearColor(1,0,0,1));
        mainView->setDelegate(viewDelegate.get());
        std::cout << "loaded macos engine!" << std::endl;
    };
    void UnloadRenderingEngine() override {
        std::cout << "unloading macos rendering engine!" << std::endl;
        if(mainView){
            mainView->release();
        }
        if(device){
            device->release();
        }
        viewDelegate.reset();
    };
   

    void SetFragmentShader(ShaderCompilationResult& shaderSource) override {
        if(viewDelegate && viewDelegate.get()->GetRenderer() != nullptr){
            viewDelegate.get()->GetRenderer()->SetFragmentShader(shaderSource);
        }
    }
    void SetVertexShader(ShaderCompilationResult& shaderSource) override {
        if(viewDelegate && viewDelegate.get()->GetRenderer() != nullptr){
            viewDelegate.get()->GetRenderer()->SetVertexShader(shaderSource);
        }
    }

    void* GetPlatformSpecificPointer() override  {
        return mainView;
    };

    

private:
    

  
    std::unique_ptr<MacOSViewDelegate> viewDelegate = {};
    MTK::View* mainView = nullptr;
    MTL::Device* device = nullptr;

};