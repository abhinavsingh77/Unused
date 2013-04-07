//
//  AppDelegate.h
//  UnUsedImages
//
//  Created by Abhinav Singh on 4/4/13.
//  Copyright (c) 2013 Vercingetorix Technologies Pvt. Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>


@interface AppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate> {

    IBOutlet NSButton *btn_search;
    IBOutlet NSButton *btn_folder;
    IBOutlet NSPathControl *projectPath;
    
    NSMutableDictionary *outlineDictionary;
    NSMutableArray *outlineFoldersArray;
    
    NSMutableArray *unusedFoldersArray;
    NSMutableDictionary *unusedDictionary;
    
    NSMutableArray *usedFoldersArray;
    NSMutableDictionary *usedDictionary;
    
    NSURL *projectUrl;
    
    NSArray *imagesExt;
    NSArray *extToSearch;
    
    IBOutlet NSButton *btn_showInFinder;
    IBOutlet NSSegmentedControl *segControl;
    IBOutlet NSOutlineView *imgNamesOutlineView;
    IBOutlet NSScrollView *tableScrollView;
    IBOutlet IKImageView *previewView;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction) searchClicked:(id)sender;
- (IBAction) selectFolderClicked:(id)sender;
- (IBAction) segmentControlChanged:(NSSegmentedControl*)sender;

- (IBAction) showInFinderClicked:(NSButton*)sender;

@end
