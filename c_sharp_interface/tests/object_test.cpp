#include <iostream>
#include "catch2/catch_test_macros.hpp"
#include "../src/object.h"




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


TEST_CASE("Components testing") {
    Object obj(ECSRegistry::CreateEntity());


    REQUIRE(!obj.HasAnyOf<SomeComponent>());
    REQUIRE(!obj.HasAllOf<SomeComponent>());
    REQUIRE(obj.GetComponentsNames().size() == 0);

    obj.AddComponent<SomeComponent>();

    REQUIRE(obj.HasAnyOf<SomeComponent>());
    REQUIRE(obj.HasAllOf<SomeComponent>());

    Component* comp = obj.GetComponent<SomeComponent>();

    REQUIRE(comp != nullptr);

    ECSRegistry::Clear();

}
