#include "game_object_traits.h"



namespace Traits {

    std::map<int64_t,UpdatePayload> HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate;
    std::map<int64_t,SpriteAnimationData> UsesSpriteAnimationInternals::objectsToBeRendered;
}