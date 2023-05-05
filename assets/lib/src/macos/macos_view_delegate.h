#pragma once
#include "../general.h"
#include "macos_renderer.h"


class MacOSViewDelegate : public MTK::ViewDelegate {
public:
    explicit MacOSViewDelegate(MTL::Device* device) {
        //std::cout << "Renderer location " << (void*)renderer.get() << std::endl;
    }

    MacOSRenderer* GetRenderer() {
        return renderer.get();
    };

    ~MacOSViewDelegate() override { 
        renderer.reset();
    };

    void drawInMTKView(MTK::View *pView) override {
        //renderer.get()->Draw(pView);
    };

private:
    std::unique_ptr<MacOSRenderer> renderer{nullptr};
};


