/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module systems.game;
private import sdl.event.dispatcher;
private import sdl.event.handlers.keyboard;
private import sdl.loader;
import view;

class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    KeyboardHandler keyboard;
    Scene[] scenes;
    bool hasFinished;

    this()
    {
        keyboard = new KeyboardHandler();
        keyboard.addKeyListener(SDLK_ESCAPE, new class Key
        {
            override void onDown(){hasFinished = true;}
            override void onUp(){}
        });
        dispatcher = new EventDispatcher(&keyboard);
        dispatcher.addOnResizeListener((uint width, uint height)
        {
            HipRenderer.width = width;
            HipRenderer.height = height;
            foreach (Scene s; scenes)
                s.onResize(width, height);
        });

        import view.testscene;
        import view.uwptest;
        Scene testscene = new SpriteTestScene();
    	testscene.init();
        scenes~= testscene;

    }

    bool update()
    {
        dispatcher.handleEvent();
        if(hasFinished || dispatcher.hasQuit)
            return false;
        keyboard.update();
        // foreach(s; scenes)
        //     s.update();

        return true;
    }
    void render()
    {
        foreach (Scene s; scenes)
            s.render();
    }
    void postUpdate()
    {
        dispatcher.postUpdate();
    }
}