//
//  SignaturePainter.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Line.h"

@protocol SignaturePainter

/// Add a line and return it
- (id<Line>) addLine;

@end
