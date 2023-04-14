#pragma once
#include "reflection_checks.h"
#include "general.h"


DEFINE_HAS_SIGNATURE(has_initialize_statically, T::InitializeStatically, void (*)(void));


namespace Reflection {

    class NullClassHelper {


    };

    class InitializedStaticallyStorage {
    public:
        static std::map<int64_t,std::function<void()>> functionsFromDerivedClasses;
    };


    template<typename Derived>
    class IsInitializedStatically {
    private:

    public:

        IsInitializedStatically()
        {
            if constexpr (has_initialize_statically<Derived>::value){
                if(InitializedStaticallyStorage::functionsFromDerivedClasses.find(HelperFunctions::GetClassID<Derived>()) == InitializedStaticallyStorage::functionsFromDerivedClasses.end()){
                    InitializedStaticallyStorage::functionsFromDerivedClasses[HelperFunctions::GetClassID<Derived>()] = [](){
                            Derived::InitializeStatically();
                    };
                }
            }
        }
        

    };



    template<typename T>
    class UsesTexture : public IsInitializedStatically<UsesTexture<T>> { 
    public:
        const std::string texturePath;

        UsesTexture() : texturePath("sprites/" + HelperFunctions::GetClassNameString<T>() + ".png") {
        }

    };





}