#pragma once
#include "game_object.h"
#include "generic_reflection.h"

DEFINE_HAS_SIGNATURE(has_update_function,T::Update,void (T::*) (double));
DEFINE_HAS_SIGNATURE(has_ai_function,T::AI, void (T::*) ());
DEFINE_HAS_SIGNATURE(has_find_frame_function,T::FindFrame,void (T::*)(int));

namespace Traits {

    template<typename... DerivedClasses> 
    class HasUpdate;

    template<>
    class HasUpdate<Reflection::NullClassHelper>;

    class HasUpdateTag {
    public:
        yael::event_sink<void(double)> OnUpdate() {
            return onUpdateLauncher.Sink();
        }

    private:

        yael::event_launcher<void(double)> onUpdateLauncher;

        template<typename... DerivedClasses> 
        friend class HasUpdate;

    
    };

    

    template<typename... DerivedClasses> 
    class HasUpdate : public HasOnBeingBaseOfObject<HasUpdate<DerivedClasses...>,DerivedClasses...>,public HasUpdateTag {

    public:
        
    private:
        void ExecuteOnObjectCreation(GameObject* ptr);


        void functionToCallOnUpdate(double dt) {
            (CallUpdateForOneType<DerivedClasses>(dt),...);
        }

        template<typename A>
        void CallUpdateForOneType(double dt) {
            //std::cout << "Calling update for " << HelperFunctions::GetClassNameString<A>() << std::endl;
            if constexpr (has_update_function<A>::value) {
                static_cast<A*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->Update(dt);
            }
        }


        friend class HasOnBeingBaseOfObject<HasUpdate<DerivedClasses...>,DerivedClasses...>;

        friend class Engine;

    };

    struct UpdatePayload {
        std::function<void(double)> updateFunction;

        void operator()(double dt) const {
            updateFunction(dt);
        }
    };

    template<typename... Others>
    constexpr bool CheckIfDerivedFromUpdate() {
        return (std::is_base_of<HasUpdateTag,Others>::value || ...);
    };

    template<>
    class HasUpdate<Reflection::NullClassHelper> {
    public:
        static std::map<entt::entity,UpdatePayload> objectsThatNeedUpdate;
    };


    template<typename... DerivedClasses>
    void HasUpdate<DerivedClasses...>::ExecuteOnObjectCreation(GameObject* ptr) {
        
        UpdatePayload payload;
        payload.updateFunction = [=](double dt){
            this->onUpdateLauncher.EmitEvent(dt);
            

            this->functionToCallOnUpdate(dt);
        };

        HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate[ptr->Handle()] = payload;

        ptr->OnBeingDestroyed().Connect([=](){
            HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.erase(ptr->Handle());
        });

        
    }

    
    template<typename... DerivedClasses>
    class ConditionedOnUpdate {
    public:
        ConditionedOnUpdate() {
            static_assert(CheckIfDerivedFromUpdate<DerivedClasses...>(),"You've used a class that is derived from ConditionedOnUpdate without also deriving from HasUpdate, please add it");
        }

    protected:
        yael::event_sink<void(double)> OnUpdate() {
            return static_cast<HasUpdateTag*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->OnUpdate();
        }


    };

    template<typename... DerivedClasses>
    class UsesAI : 
        public ConditionedOnUpdate<UsesAI<DerivedClasses...>,DerivedClasses...>
    {

        private:
            void functionToCallOnUpdate(double dt) {
                (CheckIfHasFunction<DerivedClasses>(),...);
            }
        public:

            void Create() {
                std::cout << "Calling on create for UsesAI!" << std::endl;
                functionHash = this->OnUpdate().Connect([this](double dt){
                    this->functionToCallOnUpdate(dt);
                });

            }

            UsesAI() {
            };

            void Destroy() {
                this->OnUpdate().Disconnect(functionHash);
                std::cout << "Calling destroy for UsesAI!" << std::endl;
            }

        private:
            size_t functionHash = 0;


            template<typename A>
            void CheckIfHasFunction() {
                if constexpr (has_ai_function<A>::value){
                    static_cast<A*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->AI();
                }
            }

    };  

    class HasPosition {
    public:
        const Vector2f& GetPosition() {return position;};
    protected:
        Vector2f position = Vector2f(0,0);


        template<typename T>
        friend class HasVelocity;
    };

    template <typename T>
    class HasVelocity : public ConditionedOnUpdate<HasVelocity<T>,T> {
        public:
            void Create() {
                std::cout << "Calling on create for HasVelocity!" << std::endl;
                functionHash = this->OnUpdate().Connect([this](double dt) {
                    static_cast<HasPosition*>(static_cast<T*>(this))->position += this->velocity;
                });

            }
            

            HasVelocity() {
                static_assert(std::is_base_of<HasPosition,T>::value,"To use HasVelocity you need to also derive from HasPosition");
            }


            void Destroy() {
                this->OnUpdate().Disconnect(functionHash);
                std::cout << "Calling destroy for HasVelocity!" << std::endl;
            }
        protected:
            Vector2f velocity = Vector2f(0,0);
        private:
            size_t functionHash = -1;

    };

    struct SpriteAnimationData {
        GameObject* objectPointer = nullptr;
        int* width = nullptr;
        int* height = nullptr;
        int* x = nullptr;
        int* y = nullptr;
        Anchor* anchor = nullptr;
        double* scale = nullptr;
        double* angle = nullptr;

        SpriteAnimationData(GameObject* ptr,int* w,int* h,int* x,int* y,Anchor* anchor,double* scale,double* angle) : objectPointer(ptr),width(w),height(h),x(x),y(y),anchor(anchor),scale(scale),angle(angle) {};
        SpriteAnimationData() {};
    };

   
    struct UsesSpriteAnimationInternals {
        static std::map<entt::entity,SpriteAnimationData> objectsToBeRendered;
    };  

    struct SpriteAnimationFrame {
        int x = 0;
        int y = 0;
    };



    template<typename... DerivedClasses>
    class UsesSpriteAnimation : public ConditionedOnUpdate<UsesSpriteAnimation<DerivedClasses...>,DerivedClasses...>
    {

        private:
            void functionToCallOnUpdate(double dt) {
                (CallFindFrameForOne<DerivedClasses>(),...);
            }
        public:

            void Create() { 
                functionHash = this->OnUpdate().Connect([this](double dt) mutable {
                    this->functionToCallOnUpdate(dt);
                });
                UsesSpriteAnimationInternals::objectsToBeRendered[static_cast<GameObject*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->Handle()] = SpriteAnimationData(
                    static_cast<GameObject*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this)),
                    &width,
                    &height,
                    &frame.x,
                    &frame.y,
                    &anchor,
                    &scale,
                    &angle
                );
            };


            void Destroy() {
                this->OnUpdate().Disconnect(functionHash);
                UsesSpriteAnimationInternals::objectsToBeRendered.erase(static_cast<GameObject*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->Handle());
            }

            UsesSpriteAnimation() {
                static_assert(std::is_base_of<HasPosition,NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>>::value,"In order to use sprite animation, please derive from HasPosition");
            }
        protected:
            SpriteAnimationFrame frame;
            int width = -1;
            int height = -1;
            double scale = 1.0f;
            double angle = 0.0f;
            Anchor anchor = Anchor::TopLeft;


        private:
            size_t functionHash = 0;

            template<typename A>
            void CallFindFrameForOne() {
                if constexpr (has_find_frame_function<A>::value){
                    static_cast<A*>(static_cast<NthTypeOf<IndexOfTopClass<DerivedClasses...>(),DerivedClasses...>*>(this))->FindFrame(height);
                }
            }

            friend class Engine;

    };





}