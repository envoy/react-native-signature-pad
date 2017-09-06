//
//  ReactNativeSignaturePad.m
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/6/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SignaturePadWrapper.h"

@implementation SignaturePadWrapper

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initCallback];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCallback];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initCallback];
    }
    return self;
}

- (void)initCallback {
   __weak SignaturePadWrapper *weakSelf = self;
    self.onUpdateSignature = ^(CGFloat count, CGFloat length) {
        if (weakSelf) {
            weakSelf.onUpdate(@{
                @"count": [NSNumber numberWithFloat:count],
                @"length": [NSNumber numberWithFloat:length]
            });
        }
    };
}

@end
