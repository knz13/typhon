#pragma once
#include "game_object.h"
#include "generic_reflection.h"

DEFINE_HAS_SIGNATURE(has_update_function,T::Update,void (T::*) (double));
DEFINE_HAS_SIGNATURE(has_ai_function,T::AI, void (T::*) ());

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


        template<typename A>
        void CallUpdateForOneType(double dt) {
            //std::cout << "Calling update for " << HelperFunctions::GetClassNameString<A>() << std::endl;
            if constexpr (has_update_function<A>::value) {
                static_cast<A*>(this)->Update(dt);
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
            

            (CallUpdateForOneType<DerivedClasses>(dt),...);
        };

        HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate[ptr->Handle()] = payload;

        ptr->OnBeingDestroyed().Connect([=](){
            HasUpdate<Reflection::NullClassHelper>::objectsThatNeedUpdate.erase(ptr->Handle());
        });

        
    }

    namespace {

        template<typename T,typename... Others>
        constexpr bool DerivedFromAllOthers() {
            return (std::is_base_of<T,Others>::value && ...);
        }

        template<typename T,typename... Others>
        constexpr int IndexOfTopClassInternal(const int i) {
            if (i > sizeof...(Others)){
                return -1;
            }
            if constexpr (DerivedFromAllOthers<T,Others...>()) {
                return i;
            }
            return IndexOfTopClassInternal<Others...,T>(i+1);
        }
    }

    template<typename... Others>
    constexpr int IndexOfTopClass() {
        return IndexOfTopClassInternal<Others...>(0);
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
        public ConditionedOnUpdate<DerivedClasses...>
    {
        public:

            void Create() {
                std::cout << "Calling on create for UsesAI!" << std::endl;
                functionHash = this->OnUpdate().Connect([this](double dt){
                    (CheckIfHasFunction<DerivedClasses>(),...);
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
                    static_cast<A*>(this)->AI();
                }
            }

    };


    template<typename... DerivedClasses>
    class UsesSpriteAnimation
    {
        public:
            void ExecuteOnObjectCreation(GameObject* ptr);
        
    };







}