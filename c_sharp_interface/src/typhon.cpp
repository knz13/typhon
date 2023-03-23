#include <iostream>
#include <stdint.h>
#include "typhon.h"
#include "mono_manager.h"
#include "monopp/mono_domain.h"



bool initializeMono() {
    
    return MonoManager::getInstance().initialized();

}

