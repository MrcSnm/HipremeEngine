// D import file generated from 'source\sdl\event\dispatcher.d'
module sdl.event.dispatcher;
private 
{
	import sdl.event.handlers.keyboard;
	import bindbc.sdl;
	public 
	{
		import systems.input;
		class EventDispatcher
		{
			SDL_Event e;
			ulong frameCount;
			KeyboardHandler* keyboard = null;
			protected void delegate(uint width, uint height)[] resizeListeners;
			this(KeyboardHandler* kb)
			{
				keyboard = kb;
				HipInput.newController();
			}
			bool hasQuit = false;
			void handleEvent();
			void addOnResizeListener(void delegate(uint width, uint height) onResize);
			void postUpdate();
		}
	}
}
