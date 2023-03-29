#pragma once
#include "gameobject.h"
#include "reflection.h"
#include "reflection_checks.h"


DEFINE_HAS_SIGNATURE(has_ai_func,T::AI, void (T::*)());



template<typename... DerivedClasses>
class NPC : public DeriveFromGameObject<NPC<DerivedClasses...>,DerivedClasses...>
{
public:

private:
    template<typename A>
    void CallAIOnDerived() {
        if constexpr (has_ai_func<A>::value){
            A::AI();
        }
    }

    void Update(double dt){


        (CallAIOnDerived<DerivedClasses>(),...);
    };
    
};