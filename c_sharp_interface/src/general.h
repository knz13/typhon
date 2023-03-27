#pragma once



template<typename T>
using deleted_unique_ptr = std::unique_ptr<T,std::function<void(T*)>>;


typedef int64_t (*CreateGameObjectFunc)();
typedef void (*FindFrameFunc)(int64_t);
typedef void (*SetDefaultsFunc)(int64_t);
typedef void (*AIFunc)(int64_t);
typedef void (*UpdateFunc)(int64_t,double);
typedef void (*PreDrawFunc)(int64_t);
typedef void (*PostDrawFunc)(int64_t);