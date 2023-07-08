#pragma once

#include "../general.h"
#include <objc/runtime.h>
#include <objc/message.h>

namespace MacFunctions {
    template <typename _Ret, typename... _Args>
    _NS_INLINE _Ret SendMessage(const void* pObj, SEL selector, _Args... args)
    {
    #if (defined(__i386__) || defined(__x86_64__))
        if constexpr (std::is_floating_point<_Ret>())
        {
            using SendMessageProcFpret = _Ret (*)(const void*, SEL, _Args...);

            const SendMessageProcFpret pProc = reinterpret_cast<SendMessageProcFpret>(&objc_msgSend_fpret);

            return (*pProc)(pObj, selector, args...);
        }
        else
    #endif // ( defined( __i386__ )  || defined( __x86_64__ )  )
    #if !defined(__arm64__)
            if constexpr (doesRequireMsgSendStret<_Ret>())
        {
            using SendMessageProcStret = void (*)(_Ret*, const void*, SEL, _Args...);

            const SendMessageProcStret pProc = reinterpret_cast<SendMessageProcStret>(&objc_msgSend_stret);
            _Ret                       ret;

            (*pProc)(&ret, pObj, selector, args...);

            return ret;
        }
        else
    #endif // !defined( __arm64__ )
        {
            using SendMessageProc = _Ret (*)(const void*, SEL, _Args...);

            const SendMessageProc pProc = reinterpret_cast<SendMessageProc>(&objc_msgSend);

            return (*pProc)(pObj, selector, args...);
        }
    }

    IMP ReplaceDrawMethod(void (*func)(id,SEL,void*)) {

        const char* className = "MTKDelegateReplacement";  
        Class mtkViewReplacementClass = objc_getClass(className);
        std::cout << "mtkViewReplacement found = " << (mtkViewReplacementClass != nullptr) << std::endl;
        if (mtkViewReplacementClass != nullptr) {
            const char* methodName = "drawInMTKView:";
            SEL mySelector = sel_getUid(methodName);

            Method method = class_getInstanceMethod(mtkViewReplacementClass, mySelector);
            if (method != nullptr) {
                std::cout << "Substituting method!" << std::endl;
                const char* types = method_getTypeEncoding(method);
                return class_replaceMethod(mtkViewReplacementClass, mySelector, (IMP)func, types);
            }
        }     
        return [](){};
    }

    void ReplaceDrawMethod(IMP myFunc) {
        const char* className = "MTKDelegateReplacement";  
        Class mtkViewReplacementClass = objc_getClass(className);
        std::cout << "mtkViewReplacement found = " << (mtkViewReplacementClass != nullptr) << std::endl;
        if (mtkViewReplacementClass != nullptr) {
            const char* methodName = "drawInMTKView:";
            SEL mySelector = sel_getUid(methodName);

            Method method = class_getInstanceMethod(mtkViewReplacementClass, mySelector);
            if (method != nullptr) {
                std::cout << "Substituting method!" << std::endl;
                const char* types = method_getTypeEncoding(method);
                class_replaceMethod(mtkViewReplacementClass, mySelector, myFunc, types);
            }
        }     
    }
}
