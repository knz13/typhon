#include "game_object_traits.h"



namespace Traits {

    std::map<entt::entity,UpdatePayload> HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate;
    std::map<entt::entity,GameObject*> UsesSpriteAnimationInternals::objectsToBeRendered;
}