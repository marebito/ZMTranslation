//
//  ZMDragDropView.m
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/9/4.
//  Copyright © 2018 Yuri Boyka. All rights reserved.
//

#import "ZMDragDropView.h"

@interface ZMDragDropView ()
@property(nonatomic, assign) BOOL isDragIn;
@end

@implementation ZMDragDropView

- (NSDragOperation)draggingEntered:(id)sender
{
    _isDragIn = YES;
    [self setNeedsDisplay:YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id)sender
{
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id)sender
{
    _isDragIn = NO;
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id)sender
{
    if ([sender draggingSource] != self)
    {
        NSArray* filePaths = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        if (self.delegate && [self.delegate respondsToSelector:@selector(dragDropViewFileList:)]) {
            [self.delegate dragDropViewFileList:filePaths];
        }
        NSLog(@"文件地址%@", filePaths);
    }
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);

    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];

    if (_isDragIn)
    {
        [[NSColor colorWithDeviceWhite:1.0 alpha:0.5] setFill];
        NSRectFill(dirtyRect);
    }
}
- (void)dealloc { self.delegate = nil; }
@end
