//
//  AppDelegate.m
//  UnUsedImages
//
//  Created by Abhinav Singh on 4/4/13.
//  Copyright (c) 2013 Vercingetorix Technologies Pvt. Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "PatternImageView.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    unusedFoldersArray = [NSMutableArray new];
    unusedDictionary = [NSMutableDictionary new];
    
    usedFoldersArray = [NSMutableArray new];
    usedDictionary = [NSMutableDictionary new];
    
    imagesExt = [NSArray arrayWithObjects:@"png",@"jpg", nil];
    extToSearch = [NSArray arrayWithObjects:@"m",@"h",@"xib",@"plist", nil];
    
    [tableScrollView setHidden:YES];
    [previewView setHidden:YES];
    [segControl setHidden:YES];
    [btn_showInFinder setHidden:YES];
    
    [previewView setHasHorizontalScroller:YES];
    [previewView setHasVerticalScroller:YES];
    
    [btn_search setEnabled:NO];
}

- (void) addloadingView {
    
    [PatternImageView showLoadingViewOnView:self.window.contentView];
}

- (void) removeLoadingView {
    
    [PatternImageView removeLoadingFromView:self.window.contentView];
}

- (IBAction) searchClicked:(id)sender {
    
    [tableScrollView setHidden:YES];
    [previewView setHidden:YES];
    [segControl setHidden:YES];
    [btn_showInFinder setHidden:YES];
    
    [self addloadingView];
    
    [usedDictionary removeAllObjects];
    [usedFoldersArray removeAllObjects];
    [unusedDictionary removeAllObjects];
    [unusedFoldersArray removeAllObjects];
    
    [self performSelectorInBackground:@selector(startSearchingIntoURL:) withObject:projectUrl];
}

- (IBAction) selectFolderClicked:(id)sender {
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setResolvesAliases:YES];
    [panel setCanChooseFiles:NO];
    
    NSInteger j = [panel runModal];
    if (j == NSOKButton) {
        
        NSURL *urlPath = [[panel URLs] objectAtIndex:0];
        projectUrl = urlPath;
        [projectPath setURL:urlPath];
        
        [btn_search setEnabled:YES];
        [btn_folder setEnabled:NO];
        
        [btn_search becomeFirstResponder];
    }
}

- (IBAction) segmentControlChanged:(NSSegmentedControl*)sender {

    if (sender.selectedSegment == 0) {
        
        outlineDictionary = usedDictionary;
        outlineFoldersArray = usedFoldersArray;
    }else {
        outlineDictionary = unusedDictionary;
        outlineFoldersArray = unusedFoldersArray;
    }
    
    [imgNamesOutlineView reloadData];
}

- (void) startSearchingIntoURL:(NSURL*)urlToSearch {
    
    NSMutableArray *allFilesToSearch = [NSMutableArray new];
    NSMutableArray *unUsedImages = [NSMutableArray new];
    NSMutableArray *usedImages = [NSMutableArray new];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enuma = [manager enumeratorAtPath:urlToSearch.path];
    
    NSString *file;
    while (file = [enuma nextObject]) {
        
        NSString *ext = file.pathExtension;
        if ([extToSearch containsObject:ext]) {
            
            //Add source files in which we have to search images.
            [allFilesToSearch addObject:file];
        }else if ( [imagesExt containsObject:ext] ) {
            
            //Add Images which we have to seach.
            if (![unUsedImages containsObject:file]) {
                [unUsedImages addObject:file];
            }
        }
    }
    
    for ( NSString *filesToSearch in allFilesToSearch ) {
        
        //Acctual path of the source file.
        NSString *acctualPath = [NSString stringWithFormat:@"%@/%@", projectUrl.path, filesToSearch];
        //Contents of that source file.
        NSString *strFile = [NSString stringWithContentsOfFile:acctualPath encoding:NSUTF8StringEncoding error:nil];
        for ( NSString *imgPath in unUsedImages ) {
            
            NSString *imgName = imgPath.lastPathComponent;
            NSString *imgExt = imgPath.pathExtension;
            
            NSString *withoutExt = [imgName stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@".%@", imgExt] withString:@""];
            if (strFile.length && [strFile rangeOfString:withoutExt].location != NSNotFound) {
                
                [usedImages addObject:imgPath];
                //also add its retina version
                for ( NSString *imgRetina in unUsedImages ) {
                    
                    NSString *imgRName = imgRetina.lastPathComponent;
                    if ([imgRName rangeOfString:@"@2x"].location != NSNotFound) {
                        if ([[imgRName stringByReplacingOccurrencesOfString:@"@2x" withString:@""] isEqualToString:imgName]) {
                            [usedImages addObject:imgRetina];
                            break;
                        }
                    }
                }
            }
        }
        
        [unUsedImages removeObjectsInArray:usedImages];
    }
    
    for ( NSString *imageFilePaths in unUsedImages ) {
        
        NSArray *arrCompo = [imageFilePaths pathComponents];
        if (arrCompo.count >= 2) {
            
            NSString *folderName = [arrCompo objectAtIndex:(arrCompo.count-2)];
            NSMutableArray *arrFolder = [unusedDictionary objectForKey:folderName];
            if (!arrFolder) {
                arrFolder = [NSMutableArray new];
                [unusedDictionary setObject:arrFolder forKey:folderName];
                [unusedFoldersArray addObject:folderName];
            }
            
            [arrFolder addObject:imageFilePaths];
        }else {
            
            NSMutableArray *arrBase = [unusedDictionary objectForKey:@"BaseFolder"];
            if (!arrBase) {
                arrBase = [NSMutableArray new];
                [unusedDictionary setObject:arrBase forKey:@"BaseFolder"];
                [unusedFoldersArray addObject:@"BaseFolder"];
            }
            [arrBase addObject:imageFilePaths];
        }
    }
    
    [unusedFoldersArray sortUsingSelector:@selector(compare:)];
    
    for ( NSString *keys in unusedDictionary ) {
        NSMutableArray *images = [unusedDictionary objectForKey:keys];
        [images sortUsingSelector:@selector(compare:)];
    }
    
    for ( NSString *imageFilePaths in usedImages ) {
        
        NSArray *arrCompo = [imageFilePaths pathComponents];
        if (arrCompo.count >= 2) {
            
            NSString *folderName = [arrCompo objectAtIndex:(arrCompo.count-2)];
            NSMutableArray *arrFolder = [usedDictionary objectForKey:folderName];
            if (!arrFolder) {
                arrFolder = [NSMutableArray new];
                [usedDictionary setObject:arrFolder forKey:folderName];
                [usedFoldersArray addObject:folderName];
            }
            
            [arrFolder addObject:imageFilePaths];
        }else {
            
            NSMutableArray *arrBase = [usedDictionary objectForKey:@"BaseFolder"];
            if (!arrBase) {
                arrBase = [NSMutableArray new];
                [usedDictionary setObject:arrBase forKey:@"BaseFolder"];
                [usedFoldersArray addObject:@"BaseFolder"];
            }
            [arrBase addObject:imageFilePaths];
        }
    }
    
    [usedFoldersArray sortUsingSelector:@selector(compare:)];
    
    for ( NSString *keys in usedDictionary ) {
        NSMutableArray *images = [usedDictionary objectForKey:keys];
        [images sortUsingSelector:@selector(compare:)];
    }
    
    [self performSelectorOnMainThread:@selector(projectSearchCompleted) withObject:nil waitUntilDone:NO];
}

- (void) projectSearchCompleted {
    
    segControl.selectedSegment = 1;
    
    outlineDictionary = unusedDictionary;
    outlineFoldersArray = unusedFoldersArray;
    
    [self removeLoadingView];
    
    [btn_search setTitle:@"Refresh"];
    
    [tableScrollView setHidden:NO];
    [previewView setHidden:NO];
    [segControl setHidden:NO];
    [btn_showInFinder setHidden:NO];
    
    [imgNamesOutlineView reloadData];
}

- (IBAction) showInFinderClicked:(NSButton*)sender {
    
    NSIndexSet *selected = [imgNamesOutlineView selectedRowIndexes];
    
    NSMutableArray *toOpenUrl = [NSMutableArray new];
    NSUInteger idx = [selected firstIndex];
    while (idx != NSNotFound) {
        
        id item = [imgNamesOutlineView itemAtRow:idx];
        if (![outlineFoldersArray containsObject:item]) {
            
            [toOpenUrl addObject:[projectUrl URLByAppendingPathComponent:item]];
        }
        
        idx = [selected indexGreaterThanIndex:idx];
    }
    
    NSLog(@"TOPen:%@", toOpenUrl);
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:toOpenUrl];
}

#pragma mark -
#pragma mark NSOutlineView Methods

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    
    if ([outlineFoldersArray containsObject:item]) {
        return YES;
    }else {
        return NO;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if (item == nil) {
        return [outlineFoldersArray count];
    }
    else {
        
        return [[outlineDictionary objectForKey:item] count];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    
    if (item == nil) {
        return [outlineFoldersArray objectAtIndex:index];
    }
    else {
        return [[outlineDictionary objectForKey:item] objectAtIndex:index];
    }
    
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item {
    
    return 30;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    
    NSTableCellView *reView = nil;
    if ([outlineFoldersArray containsObject:item]) {
        
        reView = [outlineView makeViewWithIdentifier:@"folderNamesCell" owner:self];
        
        NSTableCellView *cellView = (NSTableCellView *)reView;
        cellView.textField.stringValue = item;
    }else {
        
        reView = [outlineView makeViewWithIdentifier:@"imageNamesCell" owner:self];
        
        NSTableCellView *cellView = (NSTableCellView *)reView;
        
        NSString *completePath = item;
        cellView.textField.stringValue = completePath.lastPathComponent;
    }
    
    return reView;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification {

    NSIndexSet *selected = [imgNamesOutlineView selectedRowIndexes];
    if (selected.count == 1) {
        
        id item = [imgNamesOutlineView itemAtRow:[selected firstIndex]];
        if (![outlineFoldersArray containsObject:item]) {
            
            [previewView setImageWithURL:[projectUrl URLByAppendingPathComponent:item]];
            previewView.zoomFactor = 1.0f;
        }
    }
}

@end
