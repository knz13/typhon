#pragma once
#include "../engine.h"


class FlyingTreant : public DerivedFromGameObject<FlyingTreant,
        Traits::HasUpdate<FlyingTreant>,
        Traits::UsesAI<FlyingTreant>,
        Traits::HasVelocity<FlyingTreant>,
        Traits::HasPosition,
        Traits::UsesSpriteAnimation<FlyingTreant>
    > {
public:

    void SetDefaults() {
        std::cout << "calling set defaults for flying treant!" << std::endl;
        width = 32;
        height = 32;
        scale = 2;
        anchor = Anchor::Center;
    }

    void Update(double dt) {
        std::cout << "my position now is " << position.x << "," << position.y << std::endl;
    }
    
    void AI() {
        if(Engine::IsKeyPressed(InputKey::D)) {
            position += Vector2f(1,0);
        }
        if(Engine::IsKeyPressed(InputKey::A)) {
            position += Vector2f(-1,0);
        }

    }

    void FindFrame(int frameHeight) {

    };

};