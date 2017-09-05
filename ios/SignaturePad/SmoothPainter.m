//
//  SmoothSignaturePainter.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SmoothPainter.h"
#import "SmoothLine.h"

@implementation SmoothPainter

-(id<Line>)addLine {
    __weak SmoothPainter *weakSelf = self;
    SmoothLine *line = [[SmoothLine alloc] initWithUpdateDirtyRectBlock:^(CGRect rect) {
        if (weakSelf && weakSelf.updateDirtyRect) {
            weakSelf.updateDirtyRect(rect);
        }
    }];
    return line;
}

@end
