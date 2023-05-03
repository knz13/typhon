#pragma once
#include "../general.h"

class MacOSRenderer {
public:
    MacOSRenderer(MTL::Device* device) {
        this->device = device;
        this->commandQueue = device->newCommandQueue();
    };

    ~MacOSRenderer() {
        this->commandQueue->release();
    }

    void SetFragmentShader(ShaderPlatformSpecificCompilationResult& shaderSource) {
        using NS::StringEncoding::UTF8StringEncoding;

        if(!shaderSource.jsonResources["entryPoints"]) {
            std::cerr << "Could not set fragment shader, no entry points found!" << "\n";
            return;
        }
        if(shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main") {
            std::cerr << R"(Fragment shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return;
        }

        NS::Error* error = nullptr; 

        if(fragmentShaderLibrary != nullptr){
            fragmentShaderLibrary->release();
            fragmentShaderLibrary = nullptr;
        }
        fragmentShaderLibrary = device->newLibrary( NS::String::string(shaderSource.shaderText.c_str(),UTF8StringEncoding),nullptr, &error);


        if(!fragmentShaderLibrary) {
            std::cerr << error->localizedDescription()->utf8String() << "\n";
            fragmentShaderLibrary = nullptr;
            return;
        }


    }
    void SetVertexShader(ShaderPlatformSpecificCompilationResult& shaderSource) {
        using NS::StringEncoding::UTF8StringEncoding;

        if(!shaderSource.jsonResources["entryPoints"]) {
            std::cerr << "Could not set vertex shader, no entry points found!" << "\n";
            return;
        }
        if(shaderSource.jsonResources["entryPoints"][0]["name"].get<std::string>() != "main") {
            std::cerr << R"(Vertex shader could not be loaded. Please make sure that all shaders use "main" as their only entry point)" << "\n";
            return;
        }

        NS::Error* error = nullptr;
        if(vertexShaderLibrary != nullptr){
            vertexShaderLibrary->release();
            vertexShaderLibrary = nullptr;
        }
        vertexShaderLibrary = device->newLibrary( NS::String::string(shaderSource.shaderText.c_str(),UTF8StringEncoding),nullptr, &error);
        if(!vertexShaderLibrary) {
            std::cerr << error->localizedDescription()->utf8String() << "\n";
            vertexShaderLibrary = nullptr;
            return;
        }

    }
    
    void Draw(MTK::View* view) {
        NS::AutoreleasePool* pool = NS::AutoreleasePool::alloc()->init();

        //get the current command buffer object to encode commands for execution in the GPU
        auto* commandBuffer = commandQueue->commandBuffer();
        //get the current render pass descriptor that will be populated with different render targets and their information
        auto* renderPassDescriptor = view->currentRenderPassDescriptor();
        //encodes the renderPass descriptor into actually commands
        auto* renderCommandEncoder = commandBuffer->renderCommandEncoder(renderPassDescriptor);
        if(renderPipelineState != nullptr){

            
            


        }
        //YOU SHALL NOT ENCODE ANYMORE - end encoding
        renderCommandEncoder->endEncoding();
        //tell gpu we got something to draw
        commandBuffer->presentDrawable(view->currentDrawable());
        //this ain't a marriage, commit to the damn draw
        commandBuffer->commit();

        pool->release();
    };

    void RemakeRenderPipeline() {
        using NS::StringEncoding::UTF8StringEncoding;

        NS::Error* error;
        if(vertexShaderLibrary == nullptr || fragmentShaderLibrary == nullptr){
            std::cerr << "Called RemakeRenderPipeline without having vertex and fragment shaders attached!" << "\n";
            assert(false);
            return;
        }

        MTL::Function* vertexFunction = vertexShaderLibrary->newFunction( NS::String::string("main0", UTF8StringEncoding));
        MTL::Function* fragmentFunction = fragmentShaderLibrary->newFunction( NS::String::string("main0", UTF8StringEncoding));

        MTL::VertexDescriptor* desc = MTL::VertexDescriptor::alloc()->init();
        
        desc->attributes()->object(0)->setFormat(MTL::VertexFormatFloat3);
        desc->attributes()->object(0)->setOffset(0);
        desc->attributes()->object(0)->setBufferIndex(0);
        desc->attributes()->object(1)->setFormat(MTL::VertexFormatFloat3);
        desc->attributes()->object(1)->setOffset(sizeof(float[3]));
        desc->attributes()->object(1)->setBufferIndex(0);
        desc->layouts()->object(0)->setStride(sizeof(float[6]));

        MTL::RenderPipelineDescriptor* renderPipelineDescriptor = MTL::RenderPipelineDescriptor::alloc()->init();
        //in a render pass we use this vertex function
        renderPipelineDescriptor->setVertexFunction( vertexFunction );
        //in a render pass we use this fragment function
        renderPipelineDescriptor->setFragmentFunction( fragmentFunction );

        renderPipelineDescriptor->setVertexDescriptor(desc);
        
        renderPipelineDescriptor->colorAttachments()->object(0)->setPixelFormat( MTL::PixelFormat::PixelFormatBGRA8Unorm_sRGB );

        if(renderPipelineState != nullptr) {
            renderPipelineState->release();
            renderPipelineState = nullptr;
        }
        renderPipelineState = device->newRenderPipelineState( renderPipelineDescriptor, &error );

        if (!renderPipelineState){
            renderPipelineState = nullptr;
            std::cerr << error->localizedDescription()->utf8String()<< "\n";
            assert(false);
        }

        desc->release();
        vertexFunction->release();
        fragmentFunction->release();
        renderPipelineDescriptor->release();
    };


private:


    MTL::Library* vertexShaderLibrary = nullptr;
    MTL::Library* fragmentShaderLibrary = nullptr;
    MTL::RenderPipelineState* renderPipelineState = nullptr;
    MTL::Device* device = nullptr;
    MTL::Buffer* vertexPositionBuffer = nullptr;
    MTL::Buffer* colorBuffer = nullptr;
    MTL::CommandQueue* commandQueue = nullptr;

};