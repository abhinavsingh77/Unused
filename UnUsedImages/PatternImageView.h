//
//  PatternImageView.h
//  EverestMAC
//
//  Created by Abhinav Singh on 18/09/12.
//  Copyright (c) 2012 abhinav.singh@vxtindia.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PatternImageView : NSView {
    
    NSInteger tag;
    NSColor *borderColor;
    NSColor *backgroundColor;
    NSString *patternImageName;
}

@property(nonatomic, assign) NSInteger tag;
@property(nonatomic, retain) NSColor *backgroundColor;
@property(nonatomic, retain) NSColor *borderColor;
@property(nonatomic, retain) NSString *patternImageName;

+ (void) showLoadingViewOnView:(NSView*)viOnLoad;
+ (void) removeLoadingFromView:(NSView*)viOnLoad;

    
@end
