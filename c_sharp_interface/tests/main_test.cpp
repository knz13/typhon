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



TEST_CASE("Testing General Templating") {
    SECTION("Testing IndexOfTopClass"){
        REQUIRE(Reflection::IndexOfTopClass<C,D,COther>() == 1);
        REQUIRE(Reflection::IndexOfTopClass<D,C,COther>() == 0);
        REQUIRE(Reflection::IndexOfTopClass<COther,C,D>() == 2);
    }
}