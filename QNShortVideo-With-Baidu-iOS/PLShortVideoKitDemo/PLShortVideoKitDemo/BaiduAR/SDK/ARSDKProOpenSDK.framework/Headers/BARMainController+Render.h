//
//  BARMainController+Render.h
//  AR-ASIHttpRequest
//
//  Created by Asa on 2018/9/28.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARMainController.h"

typedef enum : NSUInteger {
    BARPipelineImageView = 0,
    BARPipelineFramebuffer,
} BARPipeline;

@interface BARMainController (Render)

/**
 设置输出格式
 @param type 0:图像 1：framebuffer
 */
- (void)setPipeline:(BARPipeline)type;

- (void)setRenderCompleteBlock:(void (^)(BARImageFramebuffer *framebuffer, CMTime sampleBufferTime))block;
- (void)setRenderSampleBufferCompleteBlock:(void (^)(CMSampleBufferRef sampleBuffer, id extraData))block;

- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation;
- (void)stopEngine;
- (void)clearRender;

@end

