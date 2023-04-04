#pragma once
#include "gameobject.h"
#include "generic_reflection.h"
#include <map>



namespace Reflection {


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
    class AddToHierarchyMenu : public  IsInitializedStatically<AddToHierarchyMenu<T>> {

    public:
        static void InitializeStatically() {
            std::string name = HelperFunctions::GetClassNameString<T>();
            if(GameObjectMiddleMan::menuOptionsStringToOnClick.find(name) != GameObjectMiddleMan::menuOptionsStringToOnClick.end()){
                return;
            } 

            std::cout << "adding to hierarchy menu: " << name << std::endl;
            
            GameObjectMiddleMan::menuOptionsIDtoString[HelperFunctions::GetIDFromString<T>()] = name;
            GameObjectMiddleMan::menuOptionsStringToOnClick[name] = [](){
                GameObject::CreateNewGameObject<T>();
            };


        }

    };

}