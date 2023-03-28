#pragma once
#include "gameobject.h"
#include "reflection_checks.h"

namespace Reflection {



    class NullClassHelper {


    };




    DEFINE_HAS_SIGNATURE(has_initialize_statically, T::InitializeStatically, void (*)(void));

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
        static void InitializeDerivedClasses() {
            std::cout << "initializing static classes! len = " << InitializedStaticallyStorage::functionsFromDerivedClasses.size()<< std::endl;
            for(const auto& func : InitializedStaticallyStorage::functionsFromDerivedClasses){
                func();
            }
        }

        IsInitializedStatically()
        {
            
            
            (void)m;
        }
        

    };

    template<typename T>
    class UsesStaticDefaults { 

        static int m;

    public:
        UsesStaticDefaults()
        {
            (void)m;
        }
    };

    template<typename T>
    int UsesStaticDefaults<T>::m = ([](){
            
        GameObjectMiddleMan::staticDefaultsFuncs.push_back([](){T::SetStaticDefaults();});

        return 0;
    })();


    template<typename T>
    class HasKeyCallbacks { 


        static int m;
    public:
        virtual void OnKeyPressed(InputKey key){

        }

        HasKeyCallbacks() {
            (void)m;
        }

    };

    template<typename T>
    int HasKeyCallbacks<T>::m = [] (){
        std::cout << "Registered class as having key callbacks " << HelperFunctions::GetClassNameString<T>() << std::endl;
        GameObjectMiddleMan::classesThatHaveHasKeyCallbacks[HelperFunctions::GetClassNameString<T>()] = [](GameObjectMiddleMan* obj,InputKey k){
            static_cast<T*>(obj)->OnKeyPressed(k);
        };

        return 0;
    }();

    template<typename T>
    class UsesTexture : public IsInitializedStatically<UsesTexture<T>> { 
        
    public:
        static void InitializeStatically() {
            std::cout << "Initializing statically for uses texture with class " << HelperFunctions::GetClassNameString<T>() << std::endl;
        }


        UsesTexture() {
            static_assert(std::is_base_of<GameObject,T>::value,"Can only derive from UsesTexture if already derived from GameObject");
        }

    };



    template<typename T>
    class AddToHierarchyMenu : public  IsInitializedStatically<AddToHierarchyMenu<T>> {

    public:
        static void InitializeStatically() {
            std::string name = HelperFunctions::GetClassNameString<T>();
            if(GameObjectMiddleMan::menuOptionsStringToOnClick.find(name) != GameObjectMiddleMan::menuOptionsStringToOnClick.end()){
                return;
            } 

            std::cout << "adding to hierarchy menu: " << name << std::endl;

            GameObjectMiddleMan::menuOptionsIDtoString[Random::get()] = name;
            GameObjectMiddleMan::menuOptionsStringToOnClick[name] = [](){
                GameObject::CreateNewGameObject<T>();
            };


        }

    };

}