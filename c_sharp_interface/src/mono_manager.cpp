#include "mono_manager.h"



MonoManager::MonoManager()  {

    if(!mono::init("mono",true)){
        _initialized = false;
        return;
    }

    _domain = std::unique_ptr<mono::mono_domain>(new mono::mono_domain("typhon_domain"));

    shaderc_compiler_t compiler =  shaderc_compiler_initialize();
    
    if(compiler == NULL){
        std::cout << "compiler is null!" << std::endl;
    }

};

bool MonoManager::initialized()  {

    return _initialized;
}