#include <psp2/touch.h>
#include <psp2/kernel/clib.h>

/// HipremeEngine functions.
void HipInputOnTouchPressed(unsigned int id, float x, float y);
void HipInputOnTouchMoved(unsigned int id, float x, float y);
void HipInputOnTouchReleased(unsigned int id, float x, float y);


///Will only poll front touch.

typedef struct HipTouch
{
    SceUInt8 vitaID;
} HipTouch;


static HipTouch touches[6] = {0xFF};

/// @brief Gets touch ID used by hipreme engine
/// @param psvId 
/// @return 
static int getTouchId(SceUInt8 psvId)
{
    for(int i = 0; i < 6; i++) if(touches[i].vitaID == psvId) return i;
    return -1;
}

/// @brief Finds in the index of psvId in the data report
/// @param psvId 
/// @param data 
/// @return 
static int idInTouchReport(SceUInt8 psvId, SceTouchData* data)
{
    for(int i = 0; i < data->reportNum; i++)
        if(data->report[i].id == psvId) return i;
    return -1;
}

static void printTouchData(SceTouchData* data)
{
    sceClibPrintf("Print touch data: ");
    for(int i = 0; i < data->reportNum; i++)
        sceClibPrintf("%d ", data->report[i].id);
    sceClibPrintf("\n");
}

void psv_abort();

void hipVitaPollTouch()
{

    ///Fixme says that SCE_TOUCH_MAX_REPORT has 6 on front.
    static SceTouchData oldTouch = {0};
	SceTouchData touch;
	sceTouchPeek(SCE_TOUCH_PORT_FRONT, &touch, 1);


    //Populate touches id representation.

    for(int i = 0; i < touch.reportNum; i++)
    {
        if(getTouchId(touch.report[i].id) == -1)
            touches[i].vitaID = touch.report[i].id;

    }


    //Release check
    for(int i = 0; i < oldTouch.reportNum;i++)
    {
        if(idInTouchReport(oldTouch.report[i].id, &touch) != -1)
            continue;
            
        int id = getTouchId(oldTouch.report[i].id);
        if(id != -1)
        {
            HipInputOnTouchReleased(id, (float)oldTouch.report[i].x, (float)oldTouch.report[i].y);
            touches[i].vitaID = 0xff;
        }
    }

    //Press check
    for(int i = 0; i < touch.reportNum;i++)
    {
        int id = getTouchId(touch.report[i].id);
        int oldId = idInTouchReport(touch.report[i].id, &oldTouch);
        if(oldId != -1)  //in old
        {
            if(touch.report[i].x != oldTouch.report[i].x || touch.report[i].x != oldTouch.report[i].y)
                HipInputOnTouchMoved(id, (float)touch.report[i].x, (float)touch.report[i].y);
            continue;
        }

        if(id != -1)
            HipInputOnTouchPressed(id, (float)touch.report[i].x, (float)touch.report[i].y);
    }

    oldTouch = touch;
}
