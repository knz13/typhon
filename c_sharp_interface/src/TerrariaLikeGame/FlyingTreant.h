#pragma once
#include "../engine.h"

class FlyingTreant : public DerivedFromGameObject<FlyingTreant,
        Traits::HasUpdate<FlyingTreant>,
        Traits::UsesAI<FlyingTreant>
    > {
public:
    void Update(double dt) {
        std::cout << "Calling update for flying treant!" << std::endl;
    }

    void AI() {
        std::cout << "Calling ai for flying treant!" << std::endl;

    }


};