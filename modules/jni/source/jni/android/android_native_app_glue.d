module jni.android.android_native_app_glue;

/*
 * Copyright (C) 2010 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import core.runtime : rt_init, rt_term;
import core.stdc.errno : errno;
import core.stdc.stdarg : va_list, va_start;
import core.stdc.stdlib : free, malloc;
import core.stdc.string : memcpy, memset, strerror;
import core.sys.posix.pthread, core.sys.posix.unistd : close, pipe, read, write;

import jni.android.input, jni.android.native_window, jni.android.rect : ARect;
import jni.android.configuration, jni.android.log, jni.android.looper, jni.android.native_activity;

version (Android) @system:

/**
 * The native activity interface provided by <android/native_activity.h>
 * is based on a set of application-provided callbacks that will be called
 * by the Activity's main thread when certain events occur.
 *
 * This means that each one of this callbacks _should_ _not_ block, or they
 * risk having the system force-close the application. This programming
 * model is direct, lightweight, but constraining.
 *
 * The 'android_native_app_glue' static library is used to provide a different
 * execution model where the application can implement its own main event
 * loop in a different thread instead. Here's how it works:
 *
 * 1/ The application must provide a function named "android_main()" that
 *    will be called when the activity is created, in a new thread that is
 *    distinct from the activity's main thread.
 *
 * 2/ android_main() receives a pointer to a valid "android_app" structure
 *    that contains references to other important objects, e.g. the
 *    ANativeActivity obejct instance the application is running in.
 *
 * 3/ the "android_app" object holds an ALooper instance that already
 *    listens to two important things:
 *
 *      - activity lifecycle events (e.g. "pause", "resume"). See APP_CMD_XXX
 *        declarations below.
 *
 *      - input events coming from the AInputQueue attached to the activity.
 *
 *    Each of these correspond to an ALooper identifier returned by
 *    ALooper_pollOnce with values of LOOPER_ID_MAIN and LOOPER_ID_INPUT,
 *    respectively.
 *
 *    Your application can use the same ALooper to listen to additional
 *    file-descriptors.  They can either be callback based, or with return
 *    identifiers starting with LOOPER_ID_USER.
 *
 * 4/ Whenever you receive a LOOPER_ID_MAIN or LOOPER_ID_INPUT event,
 *    the returned data will point to an android_poll_source structure.  You
 *    can call the process() function on it, and fill in android_app.onAppCmd
 *    and android_app.onInputEvent to be called for your own processing
 *    of the event.
 *
 *    Alternatively, you can call the low-level functions to read and process
 *    the data directly...  look at the process_cmd() and process_input()
 *    implementations in the glue to see how to do this.
 *
 * See the sample named "native-activity" that comes with the NDK with a
 * full usage example.  Also look at the JavaDoc of NativeActivity.
 */

/**
 * Data associated with an ALooper fd that will be returned as the "outData"
 * when that source has data ready.
 */
struct android_poll_source {
    // The identifier of this source.  May be LOOPER_ID_MAIN or
    // LOOPER_ID_INPUT.
    int id;

    // The android_app this ident is associated with.
    android_app* app;

    // Function to call to perform the standard processing of data from
    // this source.
    void function(android_app*, android_poll_source*) process;
}

/**
 * This is the interface for the standard glue code of a threaded
 * application.  In this model, the application's code is running
 * in its own thread separate from the main thread of the process.
 * It is not required that this thread be associated with the Java
 * VM, although it will need to be in order to make JNI calls any
 * Java objects.
 */
struct android_app {
    // The application can place a pointer to its own state object
    // here if it likes.
    void* userData;

    // Fill this in with the function to process main app commands (APP_CMD_*)
    void function(android_app*, int) onAppCmd;

    // Fill this in with the function to process input events.  At this point
    // the event has already been pre-dispatched, and it will be finished upon
    // return.  Return 1 if you have handled the event, 0 for any default
    // dispatching.
    int function(android_app*, AInputEvent*) onInputEvent;

    // The ANativeActivity object instance that this app is running in.
    ANativeActivity* activity;

    // The current configuration the app is running in.
    AConfiguration* config;

    // This is the last instance's saved state, as provided at creation time.
    // It is null if there was no state.  You can use this as you need; the
    // memory will remain around until you call android_app_exec_cmd() for
    // APP_CMD_RESUME, at which point it will be freed and savedState set to null.
    // These variables should only be changed when processing a APP_CMD_SAVE_STATE,
    // at which point they will be initialized to null and you can malloc your
    // state and place the information here.  In that case the memory will be
    // freed for you later.
    void* savedState;
    size_t savedStateSize;

    // The ALooper associated with the app's thread.
    ALooper* looper;

    // When non-null, this is the input queue from which the app will
    // receive user input events.
    AInputQueue* inputQueue;

    // When non-null, this is the window surface that the app can draw in.
    ANativeWindow* window;

    // Current content rectangle of the window; this is the area where the
    // window's content should be placed to be seen by the user.
    ARect contentRect;

    // Current state of the app's activity.  May be either APP_CMD_START,
    // APP_CMD_RESUME, APP_CMD_PAUSE, or APP_CMD_STOP; see below.
    int activityState;

    // This is non-zero when the application's NativeActivity is being
    // destroyed and waiting for the app thread to complete.
    int destroyRequested;

    // -------------------------------------------------
    // Below are "private" implementation of the glue code.

    pthread_mutex_t mutex;
    pthread_cond_t cond;

    int msgread;
    int msgwrite;

    pthread_t thread;

    android_poll_source cmdPollSource;
    android_poll_source inputPollSource;

    int running;
    int stateSaved;
    int destroyed;
    int redrawNeeded;
    AInputQueue* pendingInputQueue;
    ANativeWindow* pendingWindow;
    ARect pendingContentRect;
}

enum {
    /**
     * Looper data ID of commands coming from the app's main thread, which
     * is returned as an identifier from ALooper_pollOnce().  The data for this
     * identifier is a pointer to an android_poll_source structure.
     * These can be retrieved and processed with android_app_read_cmd()
     * and android_app_exec_cmd().
     */
    LOOPER_ID_MAIN = 1,

    /**
     * Looper data ID of events coming from the AInputQueue of the
     * application's window, which is returned as an identifier from
     * ALooper_pollOnce().  The data for this identifier is a pointer to an
     * android_poll_source structure.  These can be read via the inputQueue
     * object of android_app.
     */
    LOOPER_ID_INPUT = 2,

    /**
     * Start of user-defined ALooper identifiers.
     */
    LOOPER_ID_USER = 3,
}

enum {
    /**
     * Command from main thread: the AInputQueue has changed.  Upon processing
     * this command, android_app.inputQueue will be updated to the new queue
     * (or null).
     */
    APP_CMD_INPUT_CHANGED,

    /**
     * Command from main thread: a new ANativeWindow is ready for use.  Upon
     * receiving this command, android_app.window will contain the new window
     * surface.
     */
    APP_CMD_INIT_WINDOW,

    /**
     * Command from main thread: the existing ANativeWindow needs to be
     * terminated.  Upon receiving this command, android_app.window still
     * contains the existing window; after calling android_app_exec_cmd
     * it will be set to null.
     */
    APP_CMD_TERM_WINDOW,

    /**
     * Command from main thread: the current ANativeWindow has been resized.
     * Please redraw with its new size.
     */
    APP_CMD_WINDOW_RESIZED,

    /**
     * Command from main thread: the system needs that the current ANativeWindow
     * be redrawn.  You should redraw the window before handing this to
     * android_app_exec_cmd() in order to avoid transient drawing glitches.
     */
    APP_CMD_WINDOW_REDRAW_NEEDED,

    /**
     * Command from main thread: the content area of the window has changed,
     * such as from the soft input window being shown or hidden.  You can
     * find the new content rect in android_app::contentRect.
     */
    APP_CMD_CONTENT_RECT_CHANGED,

    /**
     * Command from main thread: the app's activity window has gained
     * input focus.
     */
    APP_CMD_GAINED_FOCUS,

    /**
     * Command from main thread: the app's activity window has lost
     * input focus.
     */
    APP_CMD_LOST_FOCUS,

    /**
     * Command from main thread: the current device configuration has changed.
     */
    APP_CMD_CONFIG_CHANGED,

    /**
     * Command from main thread: the system is running low on memory.
     * Try to reduce your memory use.
     */
    APP_CMD_LOW_MEMORY,

    /**
     * Command from main thread: the app's activity has been started.
     */
    APP_CMD_START,

    /**
     * Command from main thread: the app's activity has been resumed.
     */
    APP_CMD_RESUME,

    /**
     * Command from main thread: the app should generate a new saved state
     * for itself, to restore from later if needed.  If you have saved state,
     * allocate it with malloc and place it in android_app.savedState with
     * the size in android_app.savedStateSize.  The will be freed for you
     * later.
     */
    APP_CMD_SAVE_STATE,

    /**
     * Command from main thread: the app's activity has been paused.
     */
    APP_CMD_PAUSE,

    /**
     * Command from main thread: the app's activity has been stopped.
     */
    APP_CMD_STOP,

    /**
     * Command from main thread: the app's activity is being destroyed,
     * and waiting for the app thread to clean up and exit before proceeding.
     */
    APP_CMD_DESTROY,
}

/**
 * This is the function that application code must implement, representing
 * the main entry to the app.
 */
extern(C) void android_main(android_app* app);

private:
int LOGI(const(char)* warning) { return __android_log_print(android_LogPriority.ANDROID_LOG_INFO, "threaded_app", warning); }
int LOGE(const(char)* fmt, ...) {
    va_list arg_list;
    va_start(arg_list, fmt);
    return __android_log_print(android_LogPriority.ANDROID_LOG_ERROR, "threaded_app", fmt, arg_list);
}

/* For debug builds, always enable the debug traces in this library */
int LOGV(const(char)* fmt, ...) {
    debug {
        va_list arg_list;
        va_start(arg_list, fmt);
        return __android_log_print(android_LogPriority.ANDROID_LOG_VERBOSE, "threaded_app", fmt, arg_list);
    } else
        return 0;
}

void free_saved_state(android_app* android_app) {
    pthread_mutex_lock(&android_app.mutex);
    if (android_app.savedState != null) {
        free(android_app.savedState);
        android_app.savedState = null;
        android_app.savedStateSize = 0;
    }
    pthread_mutex_unlock(&android_app.mutex);
}

void print_cur_config(android_app* android_app) {
    char[2] lang, country;
    AConfiguration_getLanguage(android_app.config, lang.ptr);
    AConfiguration_getCountry(android_app.config, country.ptr);

    LOGV("Config: mcc=%d mnc=%d lang=%c%c cnt=%c%c orien=%d touch=%d dens=%d "
          ~ "keys=%d nav=%d keysHid=%d navHid=%d sdk=%d size=%d long=%d "
          ~ "modetype=%d modenight=%d",
            AConfiguration_getMcc(android_app.config),
            AConfiguration_getMnc(android_app.config),
            lang[0], lang[1], country[0], country[1],
            AConfiguration_getOrientation(android_app.config),
            AConfiguration_getTouchscreen(android_app.config),
            AConfiguration_getDensity(android_app.config),
            AConfiguration_getKeyboard(android_app.config),
            AConfiguration_getNavigation(android_app.config),
            AConfiguration_getKeysHidden(android_app.config),
            AConfiguration_getNavHidden(android_app.config),
            AConfiguration_getSdkVersion(android_app.config),
            AConfiguration_getScreenSize(android_app.config),
            AConfiguration_getScreenLong(android_app.config),
            AConfiguration_getUiModeType(android_app.config),
            AConfiguration_getUiModeNight(android_app.config));
}

public:
/**
 * Call when ALooper_pollAll() returns LOOPER_ID_MAIN, reading the next
 * app command message.
 */
byte android_app_read_cmd(android_app* android_app) {
    byte cmd;
    if (read(android_app.msgread, &cmd, cmd.sizeof) == cmd.sizeof) {
        switch (cmd) {
            case APP_CMD_SAVE_STATE:
                free_saved_state(android_app);
                break;
            default:
                break;
        }
        return cmd;
    } else {
        LOGE("No data on command pipe!");
    }
    return -1;
}

/**
 * Call with the command returned by android_app_read_cmd() to do the
 * initial pre-processing of the given command.  You can perform your own
 * actions for the command after calling this function.
 */
void android_app_pre_exec_cmd(android_app* android_app, byte cmd) {
    switch (cmd) {
        case APP_CMD_INPUT_CHANGED:
            LOGV("APP_CMD_INPUT_CHANGED\n");
            pthread_mutex_lock(&android_app.mutex);
            if (android_app.inputQueue != null) {
                AInputQueue_detachLooper(android_app.inputQueue);
            }
            android_app.inputQueue = android_app.pendingInputQueue;
            if (android_app.inputQueue != null) {
                LOGV("Attaching input queue to looper");
                AInputQueue_attachLooper(android_app.inputQueue,
                        android_app.looper, LOOPER_ID_INPUT, null,
                        &android_app.inputPollSource);
            }
            pthread_cond_broadcast(&android_app.cond);
            pthread_mutex_unlock(&android_app.mutex);
            break;

        case APP_CMD_INIT_WINDOW:
            LOGV("APP_CMD_INIT_WINDOW\n");
            pthread_mutex_lock(&android_app.mutex);
            android_app.window = android_app.pendingWindow;
            pthread_cond_broadcast(&android_app.cond);
            pthread_mutex_unlock(&android_app.mutex);
            break;

        case APP_CMD_TERM_WINDOW:
            LOGV("APP_CMD_TERM_WINDOW\n");
            pthread_cond_broadcast(&android_app.cond);
            break;

        case APP_CMD_RESUME:
        case APP_CMD_START:
        case APP_CMD_PAUSE:
        case APP_CMD_STOP:
            LOGV("activityState=%d\n", cmd);
            pthread_mutex_lock(&android_app.mutex);
            android_app.activityState = cmd;
            pthread_cond_broadcast(&android_app.cond);
            pthread_mutex_unlock(&android_app.mutex);
            break;

        case APP_CMD_CONFIG_CHANGED:
            LOGV("APP_CMD_CONFIG_CHANGED\n");
            AConfiguration_fromAssetManager(android_app.config,
                    android_app.activity.assetManager);
            print_cur_config(android_app);
            break;

        case APP_CMD_DESTROY:
            LOGV("APP_CMD_DESTROY\n");
            android_app.destroyRequested = 1;
            break;
        default:
            break;
    }
}

/**
 * Call with the command returned by android_app_read_cmd() to do the
 * final post-processing of the given command.  You must have done your own
 * actions for the command before calling this function.
 */
void android_app_post_exec_cmd(android_app* android_app, byte cmd) {
    switch (cmd) {
        case APP_CMD_TERM_WINDOW:
            LOGV("APP_CMD_TERM_WINDOW\n");
            pthread_mutex_lock(&android_app.mutex);
            android_app.window = null;
            pthread_cond_broadcast(&android_app.cond);
            pthread_mutex_unlock(&android_app.mutex);
            break;

        case APP_CMD_SAVE_STATE:
            LOGV("APP_CMD_SAVE_STATE\n");
            pthread_mutex_lock(&android_app.mutex);
            android_app.stateSaved = 1;
            pthread_cond_broadcast(&android_app.cond);
            pthread_mutex_unlock(&android_app.mutex);
            break;

        case APP_CMD_RESUME:
            free_saved_state(android_app);
            break;
        default:
            break;
    }
}

/**
 * Dummy function you can call to ensure glue code isn't stripped.
 */
void app_dummy() {

}

private:
void android_app_destroy(android_app* android_app) {
    LOGV("android_app_destroy!");
    free_saved_state(android_app);
    pthread_mutex_lock(&android_app.mutex);
    if (android_app.inputQueue != null) {
        AInputQueue_detachLooper(android_app.inputQueue);
    }
    AConfiguration_delete(android_app.config);
    android_app.destroyed = 1;
    pthread_cond_broadcast(&android_app.cond);
    pthread_mutex_unlock(&android_app.mutex);
    // Can't touch android_app object after this.
}

void process_input(android_app* app, android_poll_source* source) {
    AInputEvent* event = null;
    while (AInputQueue_getEvent(app.inputQueue, &event) >= 0) {
        LOGV("New input event: type=%d\n", AInputEvent_getType(event));
        if (AInputQueue_preDispatchEvent(app.inputQueue, event)) {
            continue;
        }
        int handled = 0;
        if (app.onInputEvent != null) handled = app.onInputEvent(app, event);
        AInputQueue_finishEvent(app.inputQueue, event, handled);
    }
}

void process_cmd(android_app* app, android_poll_source* source) {
    byte cmd = android_app_read_cmd(app);
    android_app_pre_exec_cmd(app, cmd);
    if (app.onAppCmd != null) app.onAppCmd(app, cmd);
    android_app_post_exec_cmd(app, cmd);
}

extern(C) void* android_app_entry(void* param) {
    android_app* android_app = cast(android_app*)param;

    android_app.config = AConfiguration_new();
    AConfiguration_fromAssetManager(android_app.config, android_app.activity.assetManager);

    print_cur_config(android_app);

    android_app.cmdPollSource.id = LOOPER_ID_MAIN;
    android_app.cmdPollSource.app = android_app;
    android_app.cmdPollSource.process = &process_cmd;
    android_app.inputPollSource.id = LOOPER_ID_INPUT;
    android_app.inputPollSource.app = android_app;
    android_app.inputPollSource.process = &process_input;

    ALooper* looper = ALooper_prepare(ALOOPER_PREPARE_ALLOW_NON_CALLBACKS);
    ALooper_addFd(looper, android_app.msgread, LOOPER_ID_MAIN, ALOOPER_EVENT_INPUT, null,
            &android_app.cmdPollSource);
    android_app.looper = looper;

    pthread_mutex_lock(&android_app.mutex);
    android_app.running = 1;
    pthread_cond_broadcast(&android_app.cond);
    pthread_mutex_unlock(&android_app.mutex);

    rt_init();
    android_main(android_app);
    rt_term();

    android_app_destroy(android_app);
    return null;
}

// --------------------------------------------------------------------
// Native activity interaction (called from main thread)
// --------------------------------------------------------------------

android_app* android_app_create(ANativeActivity* activity,
        void* savedState, size_t savedStateSize) {
    android_app* andro_app = cast(android_app*)malloc(android_app.sizeof);
    memset(andro_app, 0, android_app.sizeof);
    andro_app.activity = activity;

    pthread_mutex_init(&andro_app.mutex, null);
    pthread_cond_init(&andro_app.cond, null);

    if (savedState != null) {
        andro_app.savedState = malloc(savedStateSize);
        andro_app.savedStateSize = savedStateSize;
        memcpy(andro_app.savedState, savedState, savedStateSize);
    }

    int[2] msgpipe;
    if (pipe(msgpipe)) {
        LOGE("could not create pipe: %s", strerror(errno));
        return null;
    }
    andro_app.msgread = msgpipe[0];
    andro_app.msgwrite = msgpipe[1];

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    pthread_create(&andro_app.thread, &attr, &android_app_entry, andro_app);

    // Wait for thread to start.
    pthread_mutex_lock(&andro_app.mutex);
    while (!andro_app.running) {
        pthread_cond_wait(&andro_app.cond, &andro_app.mutex);
    }
    pthread_mutex_unlock(&andro_app.mutex);

    return andro_app;
}

void android_app_write_cmd(android_app* android_app, byte cmd) {
    if (write(android_app.msgwrite, &cmd, cmd.sizeof) != cmd.sizeof) {
        LOGE("Failure writing android_app cmd: %s\n", strerror(errno));
    }
}

void android_app_set_input(android_app* android_app, AInputQueue* inputQueue) {
    pthread_mutex_lock(&android_app.mutex);
    android_app.pendingInputQueue = inputQueue;
    android_app_write_cmd(android_app, APP_CMD_INPUT_CHANGED);
    while (android_app.inputQueue != android_app.pendingInputQueue) {
        pthread_cond_wait(&android_app.cond, &android_app.mutex);
    }
    pthread_mutex_unlock(&android_app.mutex);
}

void android_app_set_window(android_app* android_app, ANativeWindow* window) {
    pthread_mutex_lock(&android_app.mutex);
    if (android_app.pendingWindow != null) {
        android_app_write_cmd(android_app, APP_CMD_TERM_WINDOW);
    }
    android_app.pendingWindow = window;
    if (window != null) {
        android_app_write_cmd(android_app, APP_CMD_INIT_WINDOW);
    }
    while (android_app.window != android_app.pendingWindow) {
        pthread_cond_wait(&android_app.cond, &android_app.mutex);
    }
    pthread_mutex_unlock(&android_app.mutex);
}

void android_app_set_activity_state(android_app* android_app, byte cmd) {
    pthread_mutex_lock(&android_app.mutex);
    android_app_write_cmd(android_app, cmd);
    while (android_app.activityState != cmd) {
        pthread_cond_wait(&android_app.cond, &android_app.mutex);
    }
    pthread_mutex_unlock(&android_app.mutex);
}

void android_app_free(android_app* android_app) {
    pthread_mutex_lock(&android_app.mutex);
    android_app_write_cmd(android_app, APP_CMD_DESTROY);
    while (!android_app.destroyed) {
        pthread_cond_wait(&android_app.cond, &android_app.mutex);
    }
    pthread_mutex_unlock(&android_app.mutex);

    close(android_app.msgread);
    close(android_app.msgwrite);
    pthread_cond_destroy(&android_app.cond);
    pthread_mutex_destroy(&android_app.mutex);
    free(android_app);
}

extern(C) void onDestroy(ANativeActivity* activity) {
    LOGV("Destroy: %p\n", activity);
    android_app_free(cast(android_app*)activity.instance);
}

extern(C) void onStart(ANativeActivity* activity) {
    LOGV("Start: %p\n", activity);
    android_app_set_activity_state(cast(android_app*)activity.instance, APP_CMD_START);
}

extern(C) void onResume(ANativeActivity* activity) {
    LOGV("Resume: %p\n", activity);
    android_app_set_activity_state(cast(android_app*)activity.instance, APP_CMD_RESUME);
}

extern(C) void* onSaveInstanceState(ANativeActivity* activity, size_t* outLen) {
    android_app* android_app = cast(android_app*)activity.instance;
    void* savedState = null;

    LOGV("SaveInstanceState: %p\n", activity);
    pthread_mutex_lock(&android_app.mutex);
    android_app.stateSaved = 0;
    android_app_write_cmd(android_app, APP_CMD_SAVE_STATE);
    while (!android_app.stateSaved) {
        pthread_cond_wait(&android_app.cond, &android_app.mutex);
    }

    if (android_app.savedState != null) {
        savedState = android_app.savedState;
        *outLen = android_app.savedStateSize;
        android_app.savedState = null;
        android_app.savedStateSize = 0;
    }

    pthread_mutex_unlock(&android_app.mutex);

    return savedState;
}

extern(C) void onPause(ANativeActivity* activity) {
    LOGV("Pause: %p\n", activity);
    android_app_set_activity_state(cast(android_app*)activity.instance, APP_CMD_PAUSE);
}

extern(C) void onStop(ANativeActivity* activity) {
    LOGV("Stop: %p\n", activity);
    android_app_set_activity_state(cast(android_app*)activity.instance, APP_CMD_STOP);
}

extern(C) void onConfigurationChanged(ANativeActivity* activity) {
    android_app* android_app = cast(android_app*)activity.instance;
    LOGV("ConfigurationChanged: %p\n", activity);
    android_app_write_cmd(android_app, APP_CMD_CONFIG_CHANGED);
}

extern(C) void onLowMemory(ANativeActivity* activity) {
    android_app* android_app = cast(android_app*)activity.instance;
    LOGV("LowMemory: %p\n", activity);
    android_app_write_cmd(android_app, APP_CMD_LOW_MEMORY);
}

extern(C) void onWindowFocusChanged(ANativeActivity* activity, int focused) {
    LOGV("WindowFocusChanged: %p -- %d\n", activity, focused);
    android_app_write_cmd(cast(android_app*)activity.instance,
            focused ? APP_CMD_GAINED_FOCUS : APP_CMD_LOST_FOCUS);
}

extern(C) void onNativeWindowCreated(ANativeActivity* activity, ANativeWindow* window) {
    LOGV("NativeWindowCreated: %p -- %p\n", activity, window);
    android_app_set_window(cast(android_app*)activity.instance, window);
}

extern(C) void onNativeWindowDestroyed(ANativeActivity* activity, ANativeWindow* window) {
    LOGV("NativeWindowDestroyed: %p -- %p\n", activity, window);
    android_app_set_window(cast(android_app*)activity.instance, null);
}

extern(C) void onInputQueueCreated(ANativeActivity* activity, AInputQueue* queue) {
    LOGV("InputQueueCreated: %p -- %p\n", activity, queue);
    android_app_set_input(cast(android_app*)activity.instance, queue);
}

extern(C) void onInputQueueDestroyed(ANativeActivity* activity, AInputQueue* queue) {
    LOGV("InputQueueDestroyed: %p -- %p\n", activity, queue);
    android_app_set_input(cast(android_app*)activity.instance, null);
}

public:
extern(C) void ANativeActivity_onCreate(ANativeActivity* activity,
        void* savedState, size_t savedStateSize) {
    LOGV("Creating: %p\n", activity);
    activity.callbacks.onDestroy = &onDestroy;
    activity.callbacks.onStart = &onStart;
    activity.callbacks.onResume = &onResume;
    activity.callbacks.onSaveInstanceState = &onSaveInstanceState;
    activity.callbacks.onPause = &onPause;
    activity.callbacks.onStop = &onStop;
    activity.callbacks.onConfigurationChanged = &onConfigurationChanged;
    activity.callbacks.onLowMemory = &onLowMemory;
    activity.callbacks.onWindowFocusChanged = &onWindowFocusChanged;
    activity.callbacks.onNativeWindowCreated = &onNativeWindowCreated;
    activity.callbacks.onNativeWindowDestroyed = &onNativeWindowDestroyed;
    activity.callbacks.onInputQueueCreated = &onInputQueueCreated;
    activity.callbacks.onInputQueueDestroyed = &onInputQueueDestroyed;

    activity.instance = android_app_create(activity, savedState, savedStateSize);
}