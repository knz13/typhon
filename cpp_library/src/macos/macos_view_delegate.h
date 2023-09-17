#pragma once
#include "../general.h"
#include "macos_renderer.h"


class MacOSViewDelegate  {
public:
    explicit MacOSViewDelegate(MTL::Device* device,std::function<void()> func) : renderer(new MacOSRenderer(device)),updateFunction(func) {
    }

    MacOSRenderer* GetRenderer() {
        return renderer.get();
    };
    
    ~MacOSViewDelegate()  { 
        renderer.reset();
    };

    
    void ResetRenderer() {
        renderer.reset();
    }

    void drawInMTKView(MTK::View *pView)  {

        //update
        updateFunction();

        //draw
        if(renderer){
            renderer.get()->Draw(pView);
        }
    };

private:
    std::function<void()> updateFunction = [](){};
    std::unique_ptr<MacOSRenderer> renderer{nullptr};
};


