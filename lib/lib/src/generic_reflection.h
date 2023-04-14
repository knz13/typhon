#pragma once
#include "reflection_checks.h"
#include "general.h"


DEFINE_HAS_SIGNATURE(has_initialize_statically, T::InitializeStatically, void (*)(void));


namespace Reflection {

    class NullClassHelper {


    };

    class InitializedStaticallyStorage {
    public:
        static std::vector<std::function<void()>> functionsFromDerivedClasses;
    };


    template<typename Derived>
    class IsInitializedStatically {
        static inline int m = [](){
            
            

            if constexpr (has_initialize_statically<Derived>::value){
                InitializedStaticallyStorage::functionsFromDerivedClasses.push_back(
                    [](){
                        Derived::InitializeStatically();
                    }
                );
            }
            return 0;   
        }();



    protected:


    public:
        

        IsInitializedStatically()
        {
            
            (void)m;
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