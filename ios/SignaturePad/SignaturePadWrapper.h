//
//  ReactNativeSignaturePad.h
//  SignaturePad
//
//  Created by Fang-Pen Lin on 9/6/17.
//  Copyright © 2017 Envoy. All rights reserved.
//

#import "SignaturePad.h"

#import <React/RCTComponent.h>

@interface SignaturePadWrapper : SignaturePad

@property (nullable, copy) RCTBubblingEventBlock onUpdate;

@end
