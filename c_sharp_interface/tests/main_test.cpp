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

        REQUIRE(ECSRegistry::Get().valid(obj.Handle()));

        REQUIRE(Engine::AliveObjects() == 1);

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

