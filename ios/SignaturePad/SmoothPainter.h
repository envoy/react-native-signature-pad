//
//  SmoothSignaturePainter.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/5/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignaturePainter.h"

@interface SmoothPainter : NSObject<SignaturePainter>

@property UpdateDirtyRectBlock updateDirtyRect;

@end
