//
//  PatternImageView.m
//  EverestMAC
//
//  Created by Abhinav Singh on 18/09/12.
//  Copyright (c) 2012 abhinav.singh@vxtindia.com. All rights reserved.
//

#import "PatternImageView.h"

#define LOADING_BACK_COLOR [NSColor colorWithDeviceWhite:0.1 alpha:0.8]

@implementation PatternImageView
@synthesize patternImageName;
@synthesize borderColor, backgroundColor, tag;

+ (void) removeLoadingFromView:(NSView*)viOnLoad {
    [[viOnLoad viewWithTag:10033] removeFromSuperview];
}

+ (void) showLoadingViewOnView:(NSView*)viOnLoad {
    
    PatternImageView *loading = [viOnLoad viewWithTag:10033];
    if (!loading) {
        
        loading = [[PatternImageView alloc] initWithFrame:viOnLoad.bounds];
        loading.alphaValue = 0.5;
        loading.backgroundColor = LOADING_BACK_COLOR;
        loading.tag = 10033;
        [viOnLoad addSubview:loading];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    
    if (self.patternImageName) {
        
        NSSize size = [self bounds].size;
        
        NSImage *bigImage = [NSImage imageNamed:self.patternImageName];
        [bigImage setSize:size];
        [bigImage lockFocus];
        
        NSColor *backColor = [NSColor colorWithPatternImage:bigImage];
        [backColor set];
        
        [bigImage unlockFocus];
        
        [bigImage drawInRect:[self bounds] 
                    fromRect:NSZeroRect 
                   operation:NSCompositeSourceOver 
                    fraction:1.0f];
        
        if (self.borderColor) {
            NSBezierPath *border = [NSBezierPath bezierPathWithRect:self.bounds];
            [border setLineWidth:2];
            [self.borderColor setStroke];
            [border stroke];
        }
    }
    else {
        
        if (!self.backgroundColor) {
            self.backgroundColor = LOADING_BACK_COLOR;
        }
        
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
        
        CGFloat opacity = 0.1;
        CGBlendMode blendMode = kCGBlendModeMultiply;
        
       static CGImageRef noiseImageRef = nil;
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            
            NSUInteger width = 128, height = width;
            NSUInteger size = width*height;
            
            char *rgba = (char *)malloc(size);
            srand(115);
            for(NSUInteger i=0; i < size; ++i)
            {
                rgba[i] = rand()%200;
            }
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
            CGContextRef bitmapContext = CGBitmapContextCreate(rgba, width, height, 8, width, colorSpace, kCGImageAlphaNone);
            CFRelease(colorSpace);
            noiseImageRef = CGBitmapContextCreateImage(bitmapContext);
            CFRelease(bitmapContext);
            free(rgba);
        });
        
        CGContextSaveGState(context);
        CGContextSetAlpha(context, opacity);
        CGContextSetBlendMode(context, blendMode);
        
        if([[NSScreen mainScreen] respondsToSelector:@selector(backingScaleFactor)]){
            CGFloat scaleFactor = [[NSScreen mainScreen] backingScaleFactor];
            CGContextScaleCTM(context, 1/scaleFactor, 1/scaleFactor);
        }
        
        CGRect imageRect = (CGRect){CGPointZero, CGImageGetWidth(noiseImageRef), CGImageGetHeight(noiseImageRef)};
        CGContextDrawTiledImage(context, imageRect, noiseImageRef);
        CGContextRestoreGState(context);
    }
}

@end
