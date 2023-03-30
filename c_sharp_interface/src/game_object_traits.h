#pragma once
#include "game_object.h"
#include "generic_reflection.h"

namespace Traits {

    template<typename... DerivedClasses> 
    class HasUpdate;

    template<>
    class HasUpdate<Reflection::NullClassHelper>;

    template<typename... DerivedClasses> 
    class HasUpdate : public HasOnBeingBaseOfObject<HasUpdate<DerivedClasses...>> {
    public:
        void ExecuteOnObjectCreation(GameObject* ptr);
    private:
        friend class Engine;

    };


    template<>
    class HasUpdate<Reflection::NullClassHelper> {
    public:
        static std::vector<entt::entity> objectsThatNeedUpdate;
    };


    template<typename... DerivedClasses>
    void HasUpdate<DerivedClasses...>::ExecuteOnObjectCreation(GameObject* ptr) {
        std::cout << "executing on object creation for has update!" << std::endl;
        
        HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.push_back(ptr->Handle());
        
        ptr->OnBeingDestroyed().Connect([=](){
            HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.erase(
                std::find(
                    HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.begin(),
                    HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.end(),
                    ptr->Handle()
                )
            );
        });
    }
}