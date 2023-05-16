
#include <iostream>
#include <algorithm>
#include "catch2/catch_test_macros.hpp"
#include "../src/engine.h"
#include "../src/object.h"
#include <algorithm>


TEST_CASE("Get Class Name testing") {
    REQUIRE(strcmp(HelperFunctions::GetClassNameStringCompileTime<Engine>(),"Engine")==0);
    REQUIRE(HelperFunctions::GetClassNameString<Component>() == "Component");
    REQUIRE(HelperFunctions::GetClassNameString<Object>() == "Object");
}

TEST_CASE("Initial object testing") {
    Object obj(ECSRegistry::CreateEntity());

    REQUIRE(obj.Valid());

    REQUIRE(!obj.HasParent());

    ECSRegistry::Clear();
}

TEST_CASE("Object parenting") {
    Object obj(ECSRegistry::CreateEntity());
    Object objTwo(ECSRegistry::CreateEntity());


    REQUIRE(!objTwo.HasParent());
    REQUIRE(!obj.HasParent());
    REQUIRE(obj.NumberOfChildren() == 0);
    REQUIRE(objTwo.NumberOfChildren() == 0);

    obj.AddChild(objTwo);

    REQUIRE(objTwo.HasParent());
    REQUIRE(!obj.HasParent());
    REQUIRE(obj.IsMyChild(objTwo));
    REQUIRE(objTwo.IsChildOf(obj));
    REQUIRE(obj.NumberOfChildren() == 1);
    REQUIRE(objTwo.NumberOfChildren() == 0);

    objTwo.RemoveFromParent();

    REQUIRE(!objTwo.HasParent());
    REQUIRE(!obj.HasParent());
    REQUIRE(!obj.IsMyChild(objTwo));
    REQUIRE(!objTwo.IsChildOf(obj));
    REQUIRE(obj.NumberOfChildren() == 0);

    ECSRegistry::Clear();
}


class SomeComponent : public MakeComponent<SomeComponent> {
public:

    int someValue = -1;
    int someOtherValue = 3;
};

TEST_CASE("Component names") {
    Engine::Initialize();

    Engine::Unload();
}

TEST_CASE("Components testing") {
    Engine::Initialize();
    Object obj = Engine::CreateObject();

    
    REQUIRE(!obj.HasAnyOf<SomeComponent>());
    REQUIRE(!obj.HasAllOf<SomeComponent>());
    REQUIRE(obj.GetComponentsNames().size() == 0);

    obj.AddComponent<SomeComponent>();

    REQUIRE(obj.HasAnyOf<SomeComponent>());
    REQUIRE(obj.HasAllOf<SomeComponent>());

    Component* comp = obj.GetComponent<SomeComponent>();

    REQUIRE(comp != nullptr);
    static_cast<SomeComponent*>(comp)->someValue = -1;

    REQUIRE(obj.GetComponent<SomeComponent>()->someValue == -1);

    Engine::Unload();

}


TEST_CASE("For multiple objects") {

    std::vector<Object> objects;
    Object parent;

    REQUIRE(!parent.Valid());

    parent = Object(ECSRegistry::CreateEntity());

    REQUIRE(parent.Valid());

    for(int i = 0;i< 100; i++){
        Object temp = Object(ECSRegistry::CreateEntity());
        REQUIRE(temp.AddComponent<SomeComponent>());
        temp.GetComponent<SomeComponent>()->someValue = i;
        objects.push_back(temp);
    }

    REQUIRE(ECSRegistry::Get().alive() == 101);

    for(auto& obj : objects) {
        obj.SetParent(parent);
    }

    auto& someObj = *Random::get(objects);
    REQUIRE(someObj.IsChildOf(parent));


    REQUIRE(parent.NumberOfChildren() == 100);

    parent.RemoveChildren();    

    REQUIRE(parent.NumberOfChildren() == 0);

    auto& obj = *Random::get(objects);

    REQUIRE(obj.HasComponent<SomeComponent>());

    REQUIRE(obj.GetComponent<SomeComponent>()->someValue == std::distance(objects.begin(),std::find(objects.begin(),objects.end(),obj)));

    REQUIRE(!obj.IsChildOf(parent));


    ECSRegistry::Clear();

}

class NamedComponent : public MakeComponent<NamedComponent> {

};

TEST_CASE("Components from names") {
    NamedComponent();
    Engine::Initialize();


    Object obj = Object(ECSRegistry::CreateEntity());

    auto resolved = entt::resolve(entt::hashed_string("NamedComponent"));
    REQUIRE(resolved.operator bool());
    auto func = entt::resolve(entt::hashed_string("NamedComponent")).func(entt::hashed_string("AddComponent"));
    REQUIRE(func);
    func.invoke({},obj.ID());

    REQUIRE(obj.HasComponent<NamedComponent>());

    Engine::Unload();

}


template<typename... Derived>
class A {

};

template<typename... Derived>
class B : public A<B<Derived...>,Derived...> {

};



class C {

};

class COther {

};


class D : public C,public COther {
    
};

int globalValue = 0;

class InitializedStaticallyTest : public Reflection::IsInitializedStatically<InitializedStaticallyTest> {
public:
    static void InitializeStatically() {
        globalValue = 1;
    };
};

class GameObjectDerived : public DerivedFromGameObject<GameObjectDerived> {

};




TEST_CASE("Testing General Templating And Engine Methods") {
    SECTION("Testing IndexOfTopClass"){
        REQUIRE(Reflection::IndexOfTopClass<C,D,COther>() == 1);
        REQUIRE(Reflection::IndexOfTopClass<D,C,COther>() == 0);
        REQUIRE(Reflection::IndexOfTopClass<COther,C,D>() == 2);
    }

    SECTION("Engine initialization and unload") {
        Engine::Initialize();

        Engine::Unload();

    }

    SECTION("Initialize statically test"){
        InitializedStaticallyTest();

        REQUIRE(globalValue == 0);

        Engine::Initialize();
        

        REQUIRE(globalValue == 1);


        Engine::Unload();
    }

    
    

    SECTION("GameObject Removal") {
        Engine::Initialize();
/* 
        GameObject& obj = Engine::CreateNewGameObject<GameObject>();

        Engine::RemoveGameObject(obj);

        REQUIRE(Engine::AliveObjects() == 0);
        REQUIRE(!obj.Valid()); */

        Engine::Unload();
    }

    SECTION("GameObject Removal By Handle") {
        Engine::Initialize();

        /* GameObject& obj = Engine::CreateNewGameObject<GameObject>();

        Engine::RemoveGameObject(obj.Handle());

        REQUIRE(Engine::AliveObjects() == 0);
        REQUIRE(!obj.Valid());
 */
        Engine::Unload();
    }

    SECTION("Keys pressed") {
        Engine::PushKeyDown(Keys::Key::A);

        REQUIRE(Engine::IsKeyPressed(Keys::Key::A));

        REQUIRE(!Engine::IsKeyPressed(Keys::Key::B));
    }

    
}


class E : public DerivedFromGameObject<E> {

public:

    void Create() {
        someValue = 2;
    };

    void Destroy() {
        someValueOnDestroy = -1;
    };

    int someValue = 0;
    static inline int someValueOnDestroy = 0;
};

TEST_CASE("Testing GameObject derivation") {
    SECTION("GameObject creation") {
        E();
        Engine::Initialize();

       /*  E& obj = Engine::CreateNewGameObject<E>();

        REQUIRE(obj.ClassName() == "E");

        REQUIRE(obj.Valid());
 */
        Engine::Unload();
    }

    SECTION("Create GameObject from class name") {

        Engine::Initialize();

       /*  GameObject* obj = Engine::CreateNewGameObject("E");
        
        REQUIRE(obj != nullptr);

        REQUIRE(obj->ClassName() == "E");

        REQUIRE(obj->Valid()); */

        Engine::Unload();
    }

    SECTION("GameObject Create function") {
        Engine::Initialize();

        REQUIRE(E().someValue == 0);
/* 
        REQUIRE(Engine::CreateNewGameObject<E>().someValue == 2);
 */
        Engine::Unload();
    }

    SECTION("GameObject Destroy function") {
        E::someValueOnDestroy = 0;
        Engine::Initialize();

       /*  REQUIRE(E::someValueOnDestroy == 0);

        E& obj = Engine::CreateNewGameObject<E>();
        
        REQUIRE(E::someValueOnDestroy == 0);

        Engine::RemoveGameObject(obj);

        REQUIRE(E::someValueOnDestroy == -1);
 */
        Engine::Unload();
    }

    SECTION("OnDestroy event") {
        Engine::Initialize();

       /*  std::string someString = "ababa";
        E& obj = Engine::CreateNewGameObject<E>();
        obj.OnBeingDestroyed().Connect([&](){
            someString = "abracadabra";
        });

        REQUIRE(someString == "ababa");

        Engine::RemoveGameObject(obj);

        REQUIRE(someString == "abracadabra");
 */
        Engine::Unload();
    }

    

}

class F : public DerivedFromGameObject<F,
    Traits::HasUpdate<F>
    > {
public:
    void Update(double dt) {
        someValue += 1;
    }

    int someValue = 0;

};

namespace Traits {
    class SomeTrait {
    public: 
        void Create() {
            
        };

        void Destroy() {

        };
    };
}

class G : public DerivedFromGameObject<G,Traits::SomeTrait> {};

class H : public DerivedFromGameObject<H> {
public:
    static std::string TitleOnEditor() {
        return "Class H";
    } 


    void Serialize(json& json){

    }
};



TEST_CASE("Traits testing") {

    SECTION("Simple trait") {
        Engine::Initialize();

       /*  G& obj = Engine::CreateNewGameObject<G>();
 */
        Engine::Unload();
    }

    SECTION("Update trait") {
        Engine::Initialize();

       /*  F& obj = Engine::CreateNewGameObject<F>();
        REQUIRE(obj.someValue == 0);

        Engine::Update(0.0f);

        REQUIRE(obj.someValue == 1);

        Engine::Update(0.0f);

        REQUIRE(obj.someValue == 2);
 */
        Engine::Unload();
    }

}



class SomeTraitToBeSerialized {
public:

    int traitData = -2;

    void Serialize(json& json) {
        json["traitData"] = traitData;
    }


    void Deserialize(const json& json){
        if(json.contains("traitData")){
            json.at("traitData").get_to(traitData);
        }
    }

};

class SerializationClassA : public DerivedFromGameObject<SerializationClassA,SomeTraitToBeSerialized> {
public:

    int someInsideValue = 0;


    void Serialize(json& json) {
        
        someInsideValue = 1;

        json["someInsideValue"] = someInsideValue;

    }

    void Deserialize(const json& json) {
        if(json.contains("someInsideValue")){
            json.at("someInsideValue").get_to(someInsideValue);
        }
    }
};


class SerializationClassB : public DerivedFromGameObject<SerializationClassB>{
public:
    int someOtherValue = -2;
    
    void InternalSerialize(json& json) {
        someOtherValue = 10;
        json["someOtherValue"] = someOtherValue;
    };

    void InternalDeserialize(const json& json){
        json.at("someOtherValue").get_to(someOtherValue);
    };
    
};

TEST_CASE("Serialization/Deserialization") {

    SECTION("Testing method call") {
        Engine::Initialize();
    
        
        /* SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        REQUIRE(obj.someInsideValue == 0);

        
        std::string serializationData = Engine::SerializeCurrent();
        
        REQUIRE(obj.someInsideValue == 1);
         */
        Engine::Unload();
    }   

    SECTION("Testing actual serialization") {
        Engine::Initialize();

       /*  SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        json serializationData = Engine::SerializeCurrentJSON();

        REQUIRE(serializationData.contains("Objects"));

        REQUIRE(serializationData.at("Objects").at(0).contains("SerializationClassA"));

        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassA").contains("someInsideValue"));

        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassA").at("someInsideValue").get<int>() == 1);

 */
        Engine::Unload();
    }


    SECTION("Simple deserialization") {

        Engine::Initialize();
/* 
        SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        json serializationData = Engine::SerializeCurrentJSON();


        Engine::Unload();
        Engine::Initialize();


        REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassA>()){
            REQUIRE(obj->someInsideValue == 1);
        } */

        Engine::Unload();
    }

    SECTION("Trait Serialization/Deserialization") {

        Engine::Initialize();

       /*  SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        obj.traitData = -4;
        
        json serializationData = Engine::SerializeCurrentJSON();


        std::cout << serializationData.dump() << std::endl;


        Engine::Unload();
        Engine::Initialize();


       REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassA>()){
            REQUIRE(obj->someInsideValue == 1);
        }  */

        Engine::Unload(); 
    }


    SECTION("Internal serialization/deserialization") {

        Engine::Initialize();

        /* SerializationClassB& obj = Engine::CreateNewGameObject<SerializationClassB>();
        
        REQUIRE(obj.someOtherValue == -2);
        
        json serializationData = Engine::SerializeCurrentJSON();
        REQUIRE(obj.someOtherValue == 10);

        REQUIRE(serializationData.at("Objects").at(0).contains("SerializationClassB"));
        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassB").contains("someOtherValue"));
        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassB").at("someOtherValue").get<int>() == 10);
         */

        Engine::Unload();
        Engine::Initialize();

/* 
       REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassB>()){
            REQUIRE(obj->someOtherValue == 10);
        }  */

        Engine::Unload(); 
    }

    SECTION("Editor title testing"){

        Engine::Initialize();

        /* Engine::CreateNewGameObject<H>();

        json serializationData = Engine::SerializeCurrentJSON();

        std::cout << serializationData.dump() << std::endl;
 */
        Engine::Unload();

    }
}

