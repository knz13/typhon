#pragma once
#include "../general.h"
#include "macos_view_delegate.h"
#include "../rendering_engine.h"

class MacOSEngine : public PlatformSpecificRenderingEngine {
public:
    


   

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

    void ReceivePlatformSpecificViewPointer(void* viewPtr) override {
        if(viewPtr == nullptr){
            Unload();
        }
        else {
            mainView = (MTK::View*)viewPtr;
            Initialize();
        }
    };

private:
    void Unload(){
        std::cout << "Unloading macos engine!" << std::endl;
        
        viewDelegate.reset();
        mainView = nullptr;
    }
    void Initialize() {
        std::cout << "initializing macos engine!" << std::endl;
        viewDelegate = std::make_unique<MacOSViewDelegate>(mainView->device());
        mainView->setDelegate(viewDelegate.get());
    };

    std::unique_ptr<MacOSViewDelegate> viewDelegate = {};
    MTK::View* mainView = nullptr;

};