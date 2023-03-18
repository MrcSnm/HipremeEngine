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
void HipremeDesktopGameLoop(void);
void HipremeDestroy(void);

#endif /* hipreme_engine_h */
