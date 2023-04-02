#pragma once
#include "../engine.h"


class FlyingTreant : public DerivedFromGameObject<FlyingTreant,
        Traits::HasUpdate<FlyingTreant>,
        Traits::UsesAI<FlyingTreant>,
        Traits::HasVelocity<FlyingTreant>,
        Traits::HasPosition
    > {
public:
    void Update(double dt) {
        std::cout << "my position now is " << position.x << "," << position.y << std::endl;
    }

    void AI() {
        if(Engine::IsKeyPressed(InputKey::D)) {
            position += Vector2f(0.1,0);
        }
        if(Engine::IsKeyPressed(InputKey::A)) {
            position += Vector2f(-0.1,0);
        }

    }


};