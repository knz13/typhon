#pragma once
#include "game_object.h"

namespace Traits {

    template<typename... DerivedClasses> 
    class HasUpdate : public HasOnBeingBaseOfObject<HasUpdate<DerivedClasses...>> {
    public:
        void ExecuteOnObjectCreation() {
            std::cout << "hi!" << std::endl;
        }

    };




}