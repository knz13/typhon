#pragma once
#include "../general.h"


class MacOSEngine {
public:
    static void Unload(){
        std::cout << "Unloading macos engine!" << std::endl;
    }
    static void Initialize() {
        MTL::Device* device = MTL::CreateSystemDefaultDevice();
        if(!device){
            std::cout << "metal is not supported on this device!" << std::endl;
        }
        
        std::cout << "continuing metal initialization" << std::endl;
        
        device->release(); 
    };

    static void ReceiveNSViewPointer(void* viewPtr) {
        if(viewPtr == nullptr){
            Unload();
        }
        else {
            mainView = (NS::View*)viewPtr;
            Initialize();
        }
    };

private:
    static NS::View* mainView;

};