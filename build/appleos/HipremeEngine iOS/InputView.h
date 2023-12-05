//
//  InputView.h
//  HipremeEngine
//
//  Created by Marcelo Silva  on 27/03/23.
//

#ifndef InputView_h
#define InputView_h

#import <MetalKit/MetalKit.h>
#import <UIKit/UIKit.h>
@interface InputView : UIView

- (instancetype) initWithFrameAndView:(CGRect)frame view:(MTKView*)view;
@end

#endif /* InputView_h */
