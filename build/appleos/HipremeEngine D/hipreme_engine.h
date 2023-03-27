//
//  hipreme_engine.h
//  HipremeEngine
//
//  Created by Marcelo Silva  on 05/03/23.
//

#ifndef hipreme_engine_h
#define hipreme_engine_h
#import <Metal/Metal.h>

int HipremeMain(int windowWidth, int windowHeight);
void HipremeRender(void);
bool HipremeUpdate(float deltaTime);
void HipremeDestroy(void);

void HipInputOnTouchPressed(unsigned int id_, float x, float y);
void HipInputOnTouchMoved(unsigned int id_, float x, float y);
void HipInputOnTouchReleased(unsigned int id_, float x, float y);
void HipInputOnTouchScroll(float x, float y, float z);
void HipInputOnKeyDown(unsigned int virtualKey);
void HipInputOnKeyUp(unsigned int virtualKey);
void HipInputOnGamepadConnected(unsigned char id_, unsigned char type);
void HipInputOnGamepadDisconnected(unsigned char id_, unsigned char type);
void HipOnRendererResize(int x, int y);



#endif /* hipreme_engine_h */
