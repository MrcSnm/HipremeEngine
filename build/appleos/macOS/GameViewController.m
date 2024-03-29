//
//  GameViewController.m
//  HipremeEngine macOS
//
//  Created by Marcelo Silva  on 18/02/23.
//

#import "GameViewController.h"
#import "Renderer.h"
#import "InputView.h"
#import "hipreme_engine.h"

@implementation GameViewController
{
    MTKView *_view;
    InputView* inputView;
    Renderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _view = (MTKView *)self.view;
    inputView = [[InputView alloc] initWithFrameAndView:_view.frame view:_view];

    _view.device = MTLCreateSystemDefaultDevice();

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
        return;
    }
    [_view addSubview:inputView];
    [inputView becomeFirstResponder];

    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];
    
    


    _view.delegate = _renderer;
}



@end
