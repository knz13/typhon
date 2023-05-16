#pragma once
#include "../general.h"
#include "../shader_compiler.h"

class MacOSRenderer {
public:
    MacOSRenderer(MTL::Device* device) {
        this->device = device;
        this->commandQueue = device->newCommandQueue();
    };

    ~MacOSRenderer() {
        if(vertexPositionBuffer){
            vertexPositionBuffer->release();
        }
        if(colorBuffer){
            colorBuffer->release();
        }
        if(renderPipelineState){
            renderPipelineState->release();
        }
        if(commandQueue){
            commandQueue->release();
        }
        if(device){
            device->release();
        }
    }



    void SetFragmentShader(MTL::Library* fragmentShader) {
        fragmentShaderLibrary = fragmentShader;
    }
    void SetVertexShader(MTL::Library* vertexShader) {
        vertexShaderLibrary = vertexShader;
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
            
            //renderCommandEncoder->setRenderPipelineState(renderPipelineState);

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

        renderPipelineDescriptor->release();
        desc->release();
        fragmentFunction->release();
        vertexFunction->release();
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