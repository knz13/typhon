#include <iostream>
#include "catch2/catch_test_macros.hpp"
#include "../src/engine.h"


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

        REQUIRE(Engine::AliveObjects() == 0);

        GameObject& obj = Engine::CreateNewGameObject<GameObject>();


        REQUIRE(Engine::AliveObjects() == 1);
        REQUIRE(obj.Valid());

        Engine::Unload();

        REQUIRE(Engine::AliveObjects() == 0);
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

        GameObject& obj = Engine::CreateNewGameObject<GameObject>();

        Engine::RemoveGameObject(obj);

        REQUIRE(Engine::AliveObjects() == 0);
        REQUIRE(!obj.Valid());

        Engine::Unload();
    }

    SECTION("GameObject Removal By Handle") {
        Engine::Initialize();

        GameObject& obj = Engine::CreateNewGameObject<GameObject>();

        Engine::RemoveGameObject(obj.Handle());

        REQUIRE(Engine::AliveObjects() == 0);
        REQUIRE(!obj.Valid());

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

        E& obj = Engine::CreateNewGameObject<E>();

        REQUIRE(obj.ClassName() == "E");

        REQUIRE(obj.Valid());

        Engine::Unload();
    }

    SECTION("Create GameObject from class name") {

        Engine::Initialize();

        GameObject* obj = Engine::CreateNewGameObject("E");

        REQUIRE(obj != nullptr);

        REQUIRE(obj->ClassName() == "E");

        REQUIRE(obj->Valid());

        Engine::Unload();
    }

    SECTION("GameObject Create function") {
        Engine::Initialize();

        REQUIRE(E().someValue == 0);

        REQUIRE(Engine::CreateNewGameObject<E>().someValue == 2);

        Engine::Unload();
    }

    SECTION("GameObject Destroy function") {
        E::someValueOnDestroy = 0;
        Engine::Initialize();

        REQUIRE(E::someValueOnDestroy == 0);

        E& obj = Engine::CreateNewGameObject<E>();
        
        REQUIRE(E::someValueOnDestroy == 0);

        Engine::RemoveGameObject(obj);

        REQUIRE(E::someValueOnDestroy == -1);

        Engine::Unload();
    }

    SECTION("OnDestroy event") {
        Engine::Initialize();

        std::string someString = "ababa";
        E& obj = Engine::CreateNewGameObject<E>();
        obj.OnBeingDestroyed().Connect([&](){
            someString = "abracadabra";
        });

        REQUIRE(someString == "ababa");

        Engine::RemoveGameObject(obj);

        REQUIRE(someString == "abracadabra");

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


TEST_CASE("Traits testing") {

    SECTION("Simple trait") {
        Engine::Initialize();

        G& obj = Engine::CreateNewGameObject<G>();

        Engine::Unload();
    }

    SECTION("Update trait") {
        Engine::Initialize();

        F& obj = Engine::CreateNewGameObject<F>();
        REQUIRE(obj.someValue == 0);

        Engine::Update(0.0f);

        REQUIRE(obj.someValue == 1);

        Engine::Update(0.0f);

        REQUIRE(obj.someValue == 2);

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
    
        
        SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        REQUIRE(obj.someInsideValue == 0);

        
        std::string serializationData = Engine::SerializeCurrent();
        
        REQUIRE(obj.someInsideValue == 1);
        
        Engine::Unload();
    }   

    SECTION("Testing actual serialization") {
        Engine::Initialize();

        SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        json serializationData = Engine::SerializeCurrentJSON();

        REQUIRE(serializationData.contains("Objects"));

        REQUIRE(serializationData.at("Objects").at(0).contains("SerializationClassA"));

        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassA").contains("someInsideValue"));

        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassA").at("someInsideValue").get<int>() == 1);


        Engine::Unload();
    }


    SECTION("Simple deserialization") {

        Engine::Initialize();

        SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        
        json serializationData = Engine::SerializeCurrentJSON();


        Engine::Unload();
        Engine::Initialize();


        REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassA>()){
            REQUIRE(obj->someInsideValue == 1);
        }

        Engine::Unload();
    }

    SECTION("Trait Serialization/Deserialization") {

        Engine::Initialize();

        SerializationClassA& obj = Engine::CreateNewGameObject<SerializationClassA>();
        obj.traitData = -4;
        
        json serializationData = Engine::SerializeCurrentJSON();





        Engine::Unload();
        Engine::Initialize();


       REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassA>()){
            REQUIRE(obj->someInsideValue == 1);
        } 

        Engine::Unload(); 
    }


    SECTION("Internal serialization/deserialization") {

        Engine::Initialize();

        SerializationClassB& obj = Engine::CreateNewGameObject<SerializationClassB>();
        
        REQUIRE(obj.someOtherValue == -2);
        
        json serializationData = Engine::SerializeCurrentJSON();
        REQUIRE(obj.someOtherValue == 10);

        REQUIRE(serializationData.at("Objects").at(0).contains("SerializationClassB"));
        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassB").contains("someOtherValue"));
        REQUIRE(serializationData.at("Objects").at(0).at("SerializationClassB").at("someOtherValue").get<int>() == 10);
        

        Engine::Unload();
        Engine::Initialize();


       REQUIRE(Engine::DeserializeToCurrent(serializationData.dump()));

        REQUIRE(Engine::AliveObjects() == 1);

        for(auto obj : Engine::View<SerializationClassB>()){
            REQUIRE(obj->someOtherValue == 10);
        } 

        Engine::Unload(); 
    }

}

