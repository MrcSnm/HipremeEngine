module hip.windowing.platforms.x11lib.x11;

version(Android){}
else version(Posix)
    version = X11;
version(X11):

import hip.windowing.platforms.x11lib.glx;
import core.stdc.config;

extern(C):


/**
*   I'll define here a minimal set of x11 functions.
*/
alias XID = c_ulong;
alias Atom = c_ulong;
alias VisualID = c_ulong;
alias Time = c_ulong;

struct _XGC;
alias GC = _XGC*;
struct Depth;
struct ScreenFormat;
struct _XrmHashBucketRec;
struct _XPrivate;
struct XExtData;
alias XErrorHandler = extern(C) nothrow @nogc int function(Display*, XErrorEvent*);
struct _XDisplay
{
	import core.stdc.config:c_ulong;
    XExtData* ext_data;                                 /* hook for extension to hang data                              */
    _XPrivate* private1;
    int fd;                                             /* Network socket.                                              */
    int private2;
    int proto_major_version;                            /* major version of server's X protocol */
    int proto_minor_version;                            /* minor version of servers X protocol */
    char* vendor;                                       /* vendor of the server hardware */
    XID private3;
    XID private4;
    XID private5;
    int private6;
    extern (C) nothrow XID function(_XDisplay*) resource_alloc;             /* allocator function */
    int char_order;                                     /* screen char order, LSBFirst, MSBFirst */
    int bitmap_unit;                                    /* padding and data requirements */
    int bitmap_pad;                                     /* padding requirements on bitmaps */
    int bitmap_bit_order;                               /* LeastSignificant or MostSignificant */
    int nformats;                                       /* number of pixmap formats in list */
    ScreenFormat* pixmap_format;                        /* pixmap format list */
    int private8;
    int release;                                        /* release of the server */
    _XPrivate* private9, private10;
    int qlen;                                           /* Length of input event queue */
    c_ulong  last_request_read;                         /* seq number of last event read */
    c_ulong  request;                                   /* sequence number of last request. */
    XPointer private11;
    XPointer private12;
    XPointer private13;
    XPointer private14;
    uint max_request_size;                          /* maximum number 32 bit words in request*/
    _XrmHashBucketRec* db;
    extern (C) nothrow int function( _XDisplay* )private15;
    char* display_name;                             /* "host:display" string used on this connect*/
    int default_screen;                             /* default screen for operations */
    int nscreens;                                   /* number of screens on this server*/
    Screen* screens;                                /* pointer to list of screens */
    c_ulong motion_buffer;                          /* size of motion buffer */
    c_ulong private16;
    int min_keycode;                                /* minimum defined keycode */
    int max_keycode;                                /* maximum defined keycode */
    XPointer private17;
    XPointer private18;
    int private19;
    char* xdefaults;                                /* contents of defaults from server */
    /* there is more to this structure, but it is private to Xlib */
}
alias Display = _XDisplay;
alias _XPrivDisplay = _XDisplay*;

struct Screen
{
    XExtData *ext_data;             /* hook for extension to hang data */
    Display* display;      /* back pointer to display structure */
    Window root;                    /* root window ID */
    int width, height;              /* width and height of screen */
    int mwidth, mheight;            /* width and height of in millimeters */
    int ndepths;                    /* number of depths possible */
    Depth *depths;                  /* list of allowable depths on the screen */
    int root_depth;                 /* bits per pixel */
    Visual *root_visual;            /* root visual */
    GC default_gc;                  /* GC for the root root visual */
    Colormap cmap;                  /* default colormap */
    uint white_pixel;
    uint black_pixel;      /* white and black pixel values */
    int max_maps, min_maps;         /* max and min colormaps */
    int backing_store;              /* Never, WhenMapped, Always */
    Bool save_unders;
    long root_input_mask;           /* initial root input mask */
}

struct XVisualInfo
{
 	Visual* visual;
 	VisualID visualid;
 	int screen_num;
 	uint depth;
 	int class_;
 	c_ulong  red_mask;  
 	c_ulong  green_mask;  
	c_ulong  blue_mask;  
 	int colormap_size; /* Same as map_entries member of Visual */
 	int bits_per_rgb;
}

struct Visual;
alias Status = int;
alias KeyCode = ubyte;
alias KeySym = XID;
alias Bool = int;
alias XPointer = char*;
alias Drawable = XID;
alias Cursor = XID;
alias Colormap = XID;
alias Pixmap = XID;
alias Window = XID;
enum None = 0;
enum True = 1;
enum False = 0;
enum AllocNone = 0;
enum AllocAll = 1;

/*****************************************************************
 * ERROR CODES 
 *****************************************************************/

enum Success		= 0;	/* everything's okay */
enum BadRequest	    = 1;	/* bad request code */
enum BadValue	    = 2;	/* int parameter out of range */
enum BadWindow	    = 3;	/* parameter not a Window */
enum BadPixmap	    = 4;	/* parameter not a Pixmap */
enum BadAtom		= 5;	/* parameter not an Atom */
enum BadCursor	    = 6;	/* parameter not a Cursor */
enum BadFont		= 7;	/* parameter not a Font */
enum BadMatch	    = 8;	/* parameter mismatch */
enum BadDrawable	= 9;	/* parameter not a Pixmap or Window */
enum BadAccess	    = 10;	/* depending on context:
				             - key/button already grabbed
				             - attempt to free an illegal 
				               cmap entry 
				            - attempt to store into a read-only 
				               color map entry.
 				            - attempt to modify the access control
				               list from other than the local host.
				            */
enum BadAlloc	       = 11;	/* insufficient resources */
enum BadColor	       = 12;	/* no such colormap */
enum BadGC		       = 13;	/* parameter not a GC */
enum BadIDChoice	   = 14;	/* choice not in range or already used */
enum BadName		   = 15;	/* font or color name doesn't exist */
enum BadLength	       = 16;	/* Request length incorrect */
enum BadImplementation = 17;	/* server is defective */

enum ScreenOfDisplay(Display* dpy, int scr){return &(cast(_XPrivDisplay)(dpy)).screens[scr];}
enum DefaultScreenOfDisplay(Display* dpy){return ScreenOfDisplay(dpy,DefaultScreen(dpy));}
enum DisplayOfScreen(Screen* s){return s.display;}

enum BlackPixel(Display* dpy, int  scr)
{
    return ScreenOfDisplay(dpy,scr).black_pixel;
}
enum WhitePixel(Display* dpy, int scr)
{
    return ScreenOfDisplay(dpy,scr).white_pixel;
}
enum DefaultScreen(Display* dpy){return (cast(_XPrivDisplay)dpy).default_screen;}
enum RootWindow(Display* dpy, int scr){return ScreenOfDisplay(dpy,scr).root;}
enum RootWindowOfScreen(Screen* s){return s.root;}


struct XSetWindowAttributes 
{
	Pixmap background_pixmap;	/* background, None, or ParentRelative */
	c_ulong  background_pixel;	/* background pixel */ 
	Pixmap border_pixmap;		/* border of the window or CopyFromParent */
	c_ulong  border_pixel;	/* border pixel value */ 
	int bit_gravity;		/* one of bit gravity values */
	int win_gravity;		/* one of the window gravity values */
	int backing_store;		/* NotUseful, WhenMapped, Always */
	c_ulong  backing_planes;	/* planes to be preserved if possible */ 
	c_ulong  backing_pixel;	/* value to use in restoring planes */ 
	Bool save_under;		/* should bits under be saved? (popups) */
	long event_mask;		/* set of events that should be saved */
	long do_not_propagate_mask;	/* set of events that should not propagate */
	Bool override_redirect;		/* boolean value for override_redirect */
	Colormap colormap;		/* color map to be associated with window */
	Cursor cursor;			/* cursor to be displayed (or None) */
}


struct XWindowAttributes
{
    int x, y;
    /* location of window */
    int width, height;
    /* width and height of window */
    int border_width;
    /* border width of window */
    int depth;
    /* depth of window */
    Visual *visual;
    /* the associated visual structure */
    Window root;
    /* root of screen containing window */
    int class_;
    /* InputOutput, InputOnly*/
    int bit_gravity;
    /* one of the bit gravity values */
    int win_gravity;
    /* one of the window gravity values */
    int backing_store;
    /* NotUseful, WhenMapped, Always */
    c_ulong  backing_planes;/* planes to be preserved if possible */ 
    c_ulong  backing_pixel;/* value to be used when restoring planes */ 
    Bool save_under;
    /* boolean, should bits under be saved? */
    Colormap colormap;
    /* color map to be associated with window */
    Bool map_installed;
    /* boolean, is color map currently installed*/
    int map_state;
    /* IsUnmapped, IsUnviewable, IsViewable */
    long all_event_masks;
    /* set of events all people have interest in*/
    long your_event_mask;
    /* my event mask */
    long do_not_propagate_mask;/* set of events that should not propagate */
    Bool override_redirect;
    /* boolean value for override-redirect */
    Screen *screen;

    /* back pointer to correct screen */

}
struct XWindowChanges
{
    int x, y;
    int width, height;
    int border_width;
    Window sibling;
    int stack_mode;
}

/*
 * Definitions of specific events.
 */
struct XKeyEvent
{
	int type;		/* of event */
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window it is reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	uint state;	/* key or button mask */
	uint keycode;	/* detail */
	Bool same_screen;	/* same screen flag */
}
alias  XKeyPressedEvent = XKeyEvent;
alias  XKeyReleasedEvent = XKeyEvent;
enum ShiftMask   =     1; // Shift
enum LockMask    =     2; // Caps Lock
enum ControlMask =     4; // Ctrl
enum Mod1Mask    =     8; // Alt
enum Mod2Mask    =    16; // Num Lock
enum Mod3Mask    =    32; // Scroll Lock
enum Mod4Mask    =    64; // Windows
enum Mod5Mask    =   128; // ???


struct XButtonEvent
{
	int type;		/* of event */
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window it is reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	uint state;	/* key or button mask */
	uint button;	/* detail */
	Bool same_screen;	/* same screen flag */
}
alias XButtonPressedEvent = XButtonEvent;
alias XButtonReleasedEvent = XButtonEvent;

struct XMotionEvent 
{
	int type;		/* of event */
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	uint state;	/* key or button mask */
	char is_hint;		/* detail */
	Bool same_screen;	/* same screen flag */
}
alias XPointerMovedEvent = XMotionEvent;

struct XCrossingEvent {
	int type;		/* of event */
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;	        /* "event" window reported relative to */
	Window root;	        /* root window that the event occurred on */
	Window subwindow;	/* child window */
	Time time;		/* milliseconds */
	int x, y;		/* pointer x, y coordinates in event window */
	int x_root, y_root;	/* coordinates relative to root */
	int mode;		/* NotifyNormal, NotifyGrab, NotifyUngrab */
	int detail;
	/*
	 * NotifyAncestor, NotifyVirtual, NotifyInferior,
	 * NotifyNonlinear,NotifyNonlinearVirtual
	 */
	Bool same_screen;	/* same screen flag */
	Bool focus;		/* boolean focus */
	uint state;	/* key or button mask */
}
alias XEnterWindowEvent =  XCrossingEvent;
alias XLeaveWindowEvent =  XCrossingEvent;

struct XFocusChangeEvent {
	int type;		/* FocusIn or FocusOut */
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;		/* window of event */
	int mode;		/* NotifyNormal, NotifyWhileGrabbed,
				   NotifyGrab, NotifyUngrab */
	int detail;
	/*
	 * NotifyAncestor, NotifyVirtual, NotifyInferior,
	 * NotifyNonlinear,NotifyNonlinearVirtual, NotifyPointer,
	 * NotifyPointerRoot, NotifyDetailNone
	 */
}
alias XFocusInEvent = XFocusChangeEvent;
alias XFocusOutEvent = XFocusChangeEvent;

/* generated on EnterWindow and FocusIn  when KeyMapState selected */
struct XKeymapEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	char[32] key_vector;
}

struct XExposeEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	int x, y;
	int width, height;
	int count;		/* if non-zero, at least this many more */
}

struct XGraphicsExposeEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Drawable drawable;
	int x, y;
	int width, height;
	int count;		/* if non-zero, at least this many more */
	int major_code;		/* core is CopyArea or CopyPlane */
	int minor_code;		/* not defined in the core */
}

struct XNoExposeEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Drawable drawable;
	int major_code;		/* core is CopyArea or CopyPlane */
	int minor_code;		/* not defined in the core */
}

struct XVisibilityEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	int state;		/* Visibility state */
}

struct XCreateWindowEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;		/* parent of the window */
	Window window;		/* window id of window created */
	int x, y;		/* window location */
	int width, height;	/* size of window */
	int border_width;	/* border width */
	Bool override_redirect;	/* creation should be overridden */
}

struct XDestroyWindowEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
}

struct XUnmapEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Bool from_configure;
}

struct XMapEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Bool override_redirect;	/* boolean, is override set... */
}

struct XMapRequestEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
}

struct XReparentEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	Window parent;
	int x, y;
	Bool override_redirect;
}

struct XConfigureEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	Bool override_redirect;
}

struct XGravityEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	int x, y;
}

struct XResizeRequestEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	int width, height;
}

struct XConfigureRequestEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
	int x, y;
	int width, height;
	int border_width;
	Window above;
	int detail;		/* Above, Below, TopIf, BottomIf, Opposite */
	c_ulong  value_mask; 
}

struct XCirculateEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window event;
	Window window;
	int place;		/* PlaceOnTop, PlaceOnBottom */
}

struct XCirculateRequestEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window parent;
	Window window;
	int place;		/* PlaceOnTop, PlaceOnBottom */
}

struct XPropertyEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom atom;
	Time time;
	int state;		/* NewValue, Deleted */
}

struct XSelectionClearEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom selection;
	Time time;
}

struct XSelectionRequestEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window owner;
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;
	Time time;
}

struct XSelectionEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window requestor;
	Atom selection;
	Atom target;
	Atom property;		/* ATOM or None */
	Time time;
}

struct XColormapEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Colormap colormap;	/* COLORMAP or None */
	Bool c_new;
	int state;		/* ColormapInstalled, ColormapUninstalled */
}

struct XClientMessageEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;
	Atom message_type;
	int format;
	union DataUnion {
		char[20] b;
		short[10] s;
		long[5] l;
    }
    DataUnion data;

}

struct XMappingEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;	/* Display the event was read from */
	Window window;		/* unused */
	int request;		/* one of MappingModifier, MappingKeyboard,
				   MappingPointer */
	int first_keycode;	/* first keycode */
	int count;		/* defines range of change w. first_keycode*/
}

struct XErrorEvent
{
	int type;
	Display *display;	/* Display the event was read from */
	XID resourceid;		/* resource id */
	c_ulong  serial;	/* serial number of failed request */ 
	ubyte error_code;	/* error code of failed request */
	ubyte request_code;	/* Major op-code of failed request */
	ubyte minor_code;	/* Minor op-code of failed request */
}

struct XAnyEvent
{
	int type;
	c_ulong  serial;	/* # of last request processed by server */ 
	Bool send_event;	/* true if this came from a SendEvent request */
	Display *display;/* Display the event was read from */
	Window window;	/* window on which event was requested in event mask */
}


/***************************************************************
 *
 * GenericEvent.  This event is the standard event for all newer extensions.
 */

struct XGenericEvent
{
    int            type;         /* of event. Always GenericEvent */
    c_ulong   serial;       /* # of last request processed */ 
    Bool           send_event;   /* true if from SendEvent request */
    Display        *display;     /* Display the event was read from */
    int            extension;    /* major opcode of extension that caused the event */
    int            evtype;       /* actual event type. */
}

struct XGenericEventCookie
{
    int            type;         /* of event. Always GenericEvent */
    c_ulong   serial;       /* # of last request processed */ 
    Bool           send_event;   /* true if from SendEvent request */
    Display        *display;     /* Display the event was read from */
    int            extension;    /* major opcode of extension that caused the event */
    int            evtype;       /* actual event type. */
    uint   cookie;
    void           *data;
}

struct XComposeStatus
{
    XPointer compose_ptr;
    int chars_matched;
}

enum {
    NoEventMask          = 0,
    KeyPressMask         = 1L << 0,
    KeyReleaseMask       = 1L << 1,
    KeymapStateMask      = 1L << 14,
    ExposureMask         = 1L << 15,
    VisibilityChangeMask = 1L << 16,
    ResizeRedirectMask   = 1L << 18,
    ButtonPressMask      = 1L << 2,
    ButtonReleaseMask    = 1L << 3,
    EnterWindowMask      = 1L << 4,
    LeaveWindowMask      = 1L << 5,
    PointerMotionMask    = 1L << 6,
    PointerMotionHintMask= 1L << 7,
    Button1MotionMask    = 1L << 8,
    Button2MotionMask    = 1L << 9,
}

enum KeyPress		= 2;
enum KeyRelease		= 3;
enum ButtonPress		= 4;
enum ButtonRelease		= 5;
enum MotionNotify		= 6;
enum EnterNotify		= 7;
enum LeaveNotify		= 8;
enum FocusIn			= 9;
enum FocusOut		= 10;
enum KeymapNotify		= 11;
enum Expose			= 12;
enum GraphicsExpose		= 13;
enum NoExpose		= 14;
enum VisibilityNotify	= 15;
enum CreateNotify		= 16;
enum DestroyNotify		= 17;
enum UnmapNotify		= 18;
enum MapNotify		= 19;
enum MapRequest		= 20;
enum ReparentNotify		= 21;
enum ConfigureNotify		= 22;
enum ConfigureRequest	= 23;
enum GravityNotify		= 24;
enum ResizeRequest		= 25;
enum CirculateNotify		= 26;
enum CirculateRequest	= 27;
enum PropertyNotify		= 28;
enum SelectionClear		= 29;
enum SelectionRequest	= 30;
enum SelectionNotify		= 31;
enum ColormapNotify		= 32;
enum ClientMessage		= 33;
enum MappingNotify		= 34;
enum GenericEvent		= 35;
enum LASTEvent		= 36	/* must be bigger than any event # */;

enum InputOutput = 1;
enum InputOnly   = 2;
enum CWX		   = (1<<0);
enum CWY	       = (1<<1);
enum CWWidth	   = (1<<2);
enum CWHeight	   = (1<<3);
enum CWBorderWidth = (1<<4);
enum CWSibling	   = (1<<5);
enum CWStackMode   = (1<<6);

enum CWBackPixmap		= (1L<<0);
enum CWBackPixel		= (1L<<1);
enum CWBorderPixmap		= (1L<<2);
enum CWBorderPixel		= (1L<<3);
enum CWBitGravity		= (1L<<4);
enum CWWinGravity		= (1L<<5);
enum CWBackingStore		= (1L<<6);
enum CWBackingPlanes	= (1L<<7);
enum CWBackingPixel		= (1L<<8);
enum CWOverrideRedirect	= (1L<<9);
enum CWSaveUnder		= (1L<<10);
enum CWEventMask		= (1L<<11);
enum CWDontPropagate	= (1L<<12);
enum CWColormap		    = (1L<<13);
enum CWCursor		    = (1L<<14);

union XEvent 
{
    int type;		/* must not be changed; first element */
	XAnyEvent xany;
	XKeyEvent xkey;
	XButtonEvent xbutton;
	XMotionEvent xmotion;
	XCrossingEvent xcrossing;
	XFocusChangeEvent xfocus;
	XExposeEvent xexpose;
	XGraphicsExposeEvent xgraphicsexpose;
	XNoExposeEvent xnoexpose;
	XVisibilityEvent xvisibility;
	XCreateWindowEvent xcreatewindow;
	XDestroyWindowEvent xdestroywindow;
	XUnmapEvent xunmap;
	XMapEvent xmap;
	XMapRequestEvent xmaprequest;
	XReparentEvent xreparent;
	XConfigureEvent xconfigure;
	XGravityEvent xgravity;
	XResizeRequestEvent xresizerequest;
	XConfigureRequestEvent xconfigurerequest;
	XCirculateEvent xcirculate;
	XCirculateRequestEvent xcirculaterequest;
	XPropertyEvent xproperty;
	XSelectionClearEvent xselectionclear;
	XSelectionRequestEvent xselectionrequest;
	XSelectionEvent xselection;
	XColormapEvent xcolormap;
	XClientMessageEvent xclient;
	XMappingEvent xmapping;
	XErrorEvent xerror;
	XKeymapEvent xkeymap;
	XGenericEvent xgeneric;
	XGenericEventCookie xcookie;
	long[24] pad;
}




version(SharedX11)
{
	extern(C) nothrow @nogc __gshared
	{
		Display*  function(const(char)* display_name) XOpenDisplay;
		int function(Display* display) XCloseDisplay;
		
		Window function (Display *display,
		Window parent,
		int x, int y,
		uint width, uint height,
		uint border_width,
		ulong border,
		ulong background) XCreateSimpleWindow;

		Window function(
		Display* display,
		Window parent,
		int x, int y,
		uint width, uint height,
		uint border_width,
		int depth,
		uint _class,
		Visual* visual,
		c_ulong  valuemask, 
		XSetWindowAttributes* attributes
		) XCreateWindow;
		int function(Display *display, Window w) XClearWindow;
		int function(Display *display, Window w) XMapRaised;
		int function(Display *display, XEvent *event_return) XNextEvent;
		int function(Display *display, XEvent *event_return) XPeekEvent;
		int function(Display *display, Window w) XDestroyWindow;
		int function(Display *display, Window w, long event_mask) XSelectInput;
		Status function(Display* display, Window w, XWindowAttributes* win_attr) XGetWindowAttributes;
		int function(XMappingEvent *event_map) XRefreshKeyboardMapping;
		int function(XKeyEvent *event_struct, char *buffer_return, int bytes_buffer, KeySym *keysym_return, XComposeStatus *status_in_out) XLookupString;
		KeySym function(Display* display, typeof(XKeyEvent.keycode) keycode, int index) XKeycodeToKeysym;
		Colormap function(Display *display, Window w, Visual *visual, int alloc) XCreateColormap;
		int function(Display *display, Window w, const(char)* window_name) XStoreName;
		int function(Display* display,Window w,uint value_mask,XWindowChanges* values) XConfigureWindow;
		int function(void* data) XFree;
		int function(Display* display,Colormap colormap) XFreeColormap;
		int function (Display *display) XFlush;
		int function (Display *display, Bool discard) XSync;
		int function(XErrorHandler handler) XSetErrorHandler;
		Atom function (Display *display, const(char)* atom_name, Bool only_if_exists) XInternAtom;
		Status function(Display* display, Window w, Atom* protocols, int count) XSetWMProtocols;
		int function(Display* display) XPending;
	


		//GL
		XVisualInfo* function(Display* display,int screen,int* attribList) glXChooseVisual;
		GLXContext function(Display* display, XVisualInfo* vis, GLXContext shareList, Bool direct) glXCreateContext;
		Bool function(Display* dpy,GLXDrawable drawable, GLXContext ctx) glXMakeCurrent;
		void function(Display* dpy, GLXDrawable drawable) glXSwapBuffers;
		void function(Display* dpy, GLXContext ctx) glXDestroyContext;
		Bool function (Display * dpy, int * major,int * minor) glXQueryVersion;
		GLXFBConfig* function(Display * dpy,int screen,const(int)* attrib_list,int* nelements) glXChooseFBConfig;
		const (char)* function(	Display * dpy,int screen) glXQueryExtensionsString;
		void* function (const GLubyte* procName) glXGetProcAddressARB;
		GLXContext function(Display * dpy, GLXFBConfig config,int render_type,GLXContext share_list,Bool direct)  glXCreateNewContext;
		XVisualInfo* function(Display * dpy, GLXFBConfig config) glXGetVisualFromFBConfig;
		int function(Display* dpy, GLXFBConfig config,int attribute,int* value) glXGetFBConfigAttrib;
		Bool function(Display* dpy, GLXContext context) glXIsDirect;


	}
}
else
{
	extern(C) nothrow @nogc __gshared extern
	{
		Display* XOpenDisplay(const(char)* display_name);
		int  XCloseDisplay(Display* display);
		
		Window  XCreateSimpleWindow(Display* display,
		Window parent,
		int x, int y,
		uint width, uint height,
		uint border_width,
		ulong border,
		ulong background);

		Window XCreateWindow (
		Display* display,
		Window parent,
		int x, int y,
		uint width, uint height,
		uint border_width,
		int depth,
		uint _class,
		Visual* visual,
		c_ulong  valuemask, 
		XSetWindowAttributes* attributes
		);
		int  XClearWindow(Display *display, Window w);
		int  XMapRaised(Display *display, Window w);
		int  XNextEvent(Display *display, XEvent *event_return);
		int  XPeekEvent(Display *display, XEvent *event_return);
		int  XDestroyWindow(Display *display, Window w);
		int  XSelectInput(Display *display, Window w, long event_mask);
		Status  XGetWindowAttributes(Display* display, Window w, XWindowAttributes* win_attr);
		int  XRefreshKeyboardMapping(XMappingEvent *event_map);
		int  XLookupString(XKeyEvent *event_struct, char *buffer_return, int bytes_buffer, KeySym *keysym_return, XComposeStatus *status_in_out);
		KeySym XKeycodeToKeysym(Display* display, typeof(XKeyEvent.keycode) keycode, int index);
		
		Colormap  XCreateColormap(Display *display, Window w, Visual *visual, int alloc);
		int  XStoreName(Display *display, Window w, const(char)* window_name);
		int  XConfigureWindow(Display* display,Window w,uint value_mask,XWindowChanges* values);
		int  XFree(void* data);
		int  XFreeColormap(Display* display,Colormap colormap);
		int  XFlush(Display *display);
		int  XSync(Display *display, Bool discard);
		int  XSetErrorHandler(XErrorHandler handler);
		Atom XInternAtom(Display *display, const(char)* atom_name, Bool only_if_exists);
		Status XSetWMProtocols(Display* display, Window w, Atom* protocols, int count);
		int XPending(Display* display);


		//GL
		XVisualInfo* glXChooseVisual(Display* display,int screen,int* attribList);
		GLXContext  glXCreateContext(Display* display, XVisualInfo* vis, GLXContext shareList, Bool direct);
		Bool  glXMakeCurrent(Display* dpy,GLXDrawable drawable, GLXContext ctx);
		void  glXSwapBuffers(Display* dpy, GLXDrawable drawable);
		void  glXDestroyContext(Display* dpy, GLXContext ctx);
		Bool glXQueryVersion(Display * dpy, int * major,int * minor);
		GLXFBConfig* glXChooseFBConfig(Display * dpy,int screen,const(int)* attrib_list,int* nelements);
		const (char)* glXQueryExtensionsString(	Display * dpy,int screen);
		void *glXGetProcAddressARB(const(GLubyte)* procName);
		GLXContext glXCreateNewContext(	Display * dpy, GLXFBConfig config,int render_type,GLXContext share_list,Bool direct);
		XVisualInfo* glXGetVisualFromFBConfig(Display * dpy, GLXFBConfig config);
		int glXGetFBConfigAttrib(Display* dpy, GLXFBConfig config,int attribute,int* value);
		Bool glXIsDirect(Display* dpy, GLXContext context);


	}
}
version(SharedX11):

package void* dl;

void loadX11()
{
    static bool hasStart = false;
    if(!hasStart)
    {
        import core.sys.linux.dlfcn;
        import core.stdc.stdio:printf;
		//There is some cases which seems X11 is able to load even when the 'dl' is null.
        dl = dlopen("X11", RTLD_LAZY); 
		// if(dl == null)
		// {
		// 	printf("Could not find libX11.so\n");
		// 	return;
		// }
        void* load_dl_func(const(char*) func)
        {
            void* ret =  dlsym(dl, func);
            if(ret == null)
                printf("Could not load %s:\n", func);
            return ret;
        }

        XOpenDisplay = cast(typeof(XOpenDisplay))load_dl_func("XOpenDisplay");
        XCloseDisplay = cast(typeof(XCloseDisplay))load_dl_func("XCloseDisplay");
        XCreateSimpleWindow = cast(typeof(XCreateSimpleWindow))load_dl_func("XCreateSimpleWindow");
        XCreateWindow = cast(typeof(XCreateWindow))load_dl_func("XCreateWindow");
        XClearWindow = cast(typeof(XClearWindow))load_dl_func("XClearWindow");
        XMapRaised = cast(typeof(XMapRaised))load_dl_func("XMapRaised");
        XNextEvent = cast(typeof(XNextEvent))load_dl_func("XNextEvent");
        XPeekEvent = cast(typeof(XPeekEvent))load_dl_func("XPeekEvent");
        XDestroyWindow = cast(typeof(XDestroyWindow))load_dl_func("XDestroyWindow");
        XSelectInput = cast(typeof(XSelectInput))load_dl_func("XSelectInput");
        XGetWindowAttributes = cast(typeof(XGetWindowAttributes))load_dl_func("XGetWindowAttributes");
        XRefreshKeyboardMapping = cast(typeof(XRefreshKeyboardMapping))load_dl_func("XRefreshKeyboardMapping");
        XLookupString = cast(typeof(XLookupString))load_dl_func("XLookupString");
		XKeycodeToKeysym = cast(typeof(XKeycodeToKeysym))load_dl_func("XKeycodeToKeysym");
        XCreateColormap = cast(typeof(XCreateColormap))load_dl_func("XCreateColormap");
        XStoreName = cast(typeof(XStoreName))load_dl_func("XStoreName");
        XConfigureWindow = cast(typeof(XConfigureWindow))load_dl_func("XConfigureWindow");
        XFree = cast(typeof(XFree))load_dl_func("XFree");
        XFreeColormap = cast(typeof(XFreeColormap))load_dl_func("XFreeColormap");
        XFlush = cast(typeof(XFlush))load_dl_func("XFlush");
        XSync = cast(typeof(XSync))load_dl_func("XSync");
        XSetErrorHandler = cast(typeof(XSetErrorHandler))load_dl_func("XSetErrorHandler");
        XInternAtom = cast(typeof(XInternAtom))load_dl_func("XInternAtom");
        XSetWMProtocols = cast(typeof(XSetWMProtocols))load_dl_func("XSetWMProtocols");
        XPending = cast(typeof(XPending))load_dl_func("XPending");
		

        glXChooseVisual = cast(typeof(glXChooseVisual))load_dl_func("glXChooseVisual");
        glXCreateContext = cast(typeof(glXCreateContext))load_dl_func("glXCreateContext");
        glXMakeCurrent = cast(typeof(glXMakeCurrent))load_dl_func("glXMakeCurrent");
        glXSwapBuffers = cast(typeof(glXSwapBuffers))load_dl_func("glXSwapBuffers");
        glXDestroyContext = cast(typeof(glXDestroyContext))load_dl_func("glXDestroyContext");
		glXQueryVersion = cast(typeof(glXQueryVersion))load_dl_func("glXQueryVersion");
		glXChooseFBConfig = cast(typeof(glXChooseFBConfig))load_dl_func("glXChooseFBConfig");
		glXQueryExtensionsString = cast(typeof(glXQueryExtensionsString))load_dl_func("glXQueryExtensionsString");
		glXGetProcAddressARB = cast(typeof(glXGetProcAddressARB))load_dl_func("glXGetProcAddressARB");
		glXCreateNewContext = cast(typeof(glXCreateNewContext))load_dl_func("glXCreateNewContext");
		glXGetVisualFromFBConfig = cast(typeof(glXGetVisualFromFBConfig))load_dl_func("glXGetVisualFromFBConfig");
		glXGetFBConfigAttrib = cast(typeof(glXGetFBConfigAttrib))load_dl_func("glXGetFBConfigAttrib");
		glXIsDirect = cast(typeof(glXIsDirect))load_dl_func("glXIsDirect");


        hasStart = true;
    }
}

void unloadX11()
{
	import core.stdc.stdio;
	import core.sys.linux.dlfcn;
	if(dl != null && !dlclose(dl))
		printf("Could not unload X11.\n");
}