#pragma once
#include "../general.h"
#include "macos_renderer.h"


class MacOSViewDelegate : public MTK::ViewDelegate {
public:
    explicit MacOSViewDelegate(MTL::Device* device) : renderer(new MacOSRenderer(device)) {

    }

    MacOSRenderer* GetRenderer() {
        return renderer.get();
    };

    ~MacOSViewDelegate() override { };

    void drawInMTKView(MTK::View *pView) override {
        renderer.get()->Draw(pView);
    };

private:
    std::unique_ptr<MacOSRenderer> renderer{nullptr};
};


