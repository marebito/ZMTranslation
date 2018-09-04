//
//  ZMDragDropView.h
//  ZMTranslation
//
//  Created by Yuri Boyka on 2018/9/4.
//  Copyright © 2018 Yuri Boyka. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ZMDragDropViewDelegate <NSObject>
-(void)dragDropViewFileList:(NSArray*)fileList;
@end

@interface ZMDragDropView : NSView <NSDraggingDestination>
@property(assign) id<ZMDragDropViewDelegate> delegate;
@end


