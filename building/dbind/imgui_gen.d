
import core.stdc.config;
import std.bitmanip : bitfields;
import std.conv : emplace;

bool isModuleAvailable(alias T)() {
    mixin("import " ~ T ~ ";");
    static if (__traits(compiles, mixin(T).stringof))
        return true;
    else
        return false;
}
    
static if (__traits(compiles, isModuleAvailable!"nsgen" )) 
    static import nsgen;

struct CppClassSizeAttr
{
    alias size this;
    size_t size;
}
CppClassSizeAttr cppclasssize(size_t a) { return CppClassSizeAttr(a); }

struct CppSizeAttr
{
    alias size this;
    size_t size;
}
CppSizeAttr cppsize(size_t a) { return CppSizeAttr(a); }

struct CppMethodAttr{}
CppMethodAttr cppmethod() { return CppMethodAttr(); }

struct PyExtract{}
auto pyExtract(string name = null) { return PyExtract(); }

mixin template RvalueRef()
{
    alias T = typeof(this);
    static assert (is(T == struct));

    @nogc @safe
    ref const(T) byRef() const pure nothrow return
    {
        return this;
    }
}


extern(C)
ImVec2* ImVec2_ImVec2Nil(){
return emplace( ImNewWrapper(), MemAlloc((ImVec2).sizeof), ImVec2());
}

extern(C)
void ImVec2_destroy(ImVec2* self){
IM_DELETE(self);
}

extern(C)
ImVec2* ImVec2_ImVec2Float(float _x, float _y){
return emplace( ImNewWrapper(), MemAlloc((ImVec2).sizeof), ImVec2(_x, _y));
}

extern(C)
ImVec4* ImVec4_ImVec4Nil(){
return emplace( ImNewWrapper(), MemAlloc((ImVec4).sizeof), ImVec4());
}

extern(C)
void ImVec4_destroy(ImVec4* self){
IM_DELETE(self);
}

extern(C)
ImVec4* ImVec4_ImVec4Float(float _x, float _y, float _z, float _w){
return emplace( ImNewWrapper(), MemAlloc((ImVec4).sizeof), ImVec4(_x, _y, _z, _w));
}

extern(C)
ImGuiContext* igCreateContext(ImFontAtlas* shared_font_atlas){
return CreateContext(shared_font_atlas);
}

extern(C)
void igDestroyContext(ImGuiContext* ctx){
return DestroyContext(ctx);
}

extern(C)
ImGuiContext* igGetCurrentContext(){
return GetCurrentContext();
}

extern(C)
void igSetCurrentContext(ImGuiContext* ctx){
return SetCurrentContext(ctx);
}

extern(C)
ImGuiIO* igGetIO(){
return &GetIO();
}

extern(C)
ImGuiStyle* igGetStyle(){
return &GetStyle();
}

extern(C)
void igNewFrame(){
return NewFrame();
}

extern(C)
void igEndFrame(){
return EndFrame();
}

extern(C)
void igRender(){
return Render();
}

extern(C)
ImDrawData* igGetDrawData(){
return GetDrawData();
}

extern(C)
void igShowDemoWindow(bool* p_open){
return ShowDemoWindow(p_open);
}

extern(C)
void igShowAboutWindow(bool* p_open){
return ShowAboutWindow(p_open);
}

extern(C)
void igShowMetricsWindow(bool* p_open){
return ShowMetricsWindow(p_open);
}

extern(C)
void igShowStyleEditor(ImGuiStyle* ref_){
return ShowStyleEditor(ref_);
}

extern(C)
bool igShowStyleSelector(const(char)* label){
return ShowStyleSelector(label);
}

extern(C)
void igShowFontSelector(const(char)* label){
return ShowFontSelector(label);
}

extern(C)
void igShowUserGuide(){
return ShowUserGuide();
}

extern(C)
const(char)* igGetVersion(){
return GetVersion();
}

extern(C)
void igStyleColorsDark(ImGuiStyle* dst){
return StyleColorsDark(dst);
}

extern(C)
void igStyleColorsClassic(ImGuiStyle* dst){
return StyleColorsClassic(dst);
}

extern(C)
void igStyleColorsLight(ImGuiStyle* dst){
return StyleColorsLight(dst);
}

extern(C)
bool igBegin(const(char)* name, bool* p_open, ImGuiWindowFlags flags){
return Begin(name, p_open, flags);
}

extern(C)
void igEnd(){
return End();
}

extern(C)
bool igBeginChildStr(const(char)* str_id, ImVec2 size, bool border, ImGuiWindowFlags flags){
return BeginChild(str_id, size, border, flags);
}

extern(C)
bool igBeginChildID(ImGuiID id, ImVec2 size, bool border, ImGuiWindowFlags flags){
return BeginChild(id, size, border, flags);
}

extern(C)
void igEndChild(){
return EndChild();
}

extern(C)
bool igIsWindowAppearing(){
return IsWindowAppearing();
}

extern(C)
bool igIsWindowCollapsed(){
return IsWindowCollapsed();
}

extern(C)
bool igIsWindowFocused(ImGuiFocusedFlags flags){
return IsWindowFocused(flags);
}

extern(C)
bool igIsWindowHovered(ImGuiHoveredFlags flags){
return IsWindowHovered(flags);
}

extern(C)
ImDrawList* igGetWindowDrawList(){
return GetWindowDrawList();
}

extern(C)
void igGetWindowPos(ImVec2* pOut){
*pOut = GetWindowPos();
}

extern(C)
void igGetWindowSize(ImVec2* pOut){
*pOut = GetWindowSize();
}

extern(C)
float igGetWindowWidth(){
return GetWindowWidth();
}

extern(C)
float igGetWindowHeight(){
return GetWindowHeight();
}

extern(C)
void igSetNextWindowPos(ImVec2 pos, ImGuiCond cond, ImVec2 pivot){
return SetNextWindowPos(pos, cond, pivot);
}

extern(C)
void igSetNextWindowSize(ImVec2 size, ImGuiCond cond){
return SetNextWindowSize(size, cond);
}

extern(C)
void igSetNextWindowSizeConstraints(ImVec2 size_min, ImVec2 size_max, void function(ImGuiSizeCallbackData*) custom_callback, void* custom_callback_data){
return SetNextWindowSizeConstraints(size_min, size_max, custom_callback, custom_callback_data);
}

extern(C)
void igSetNextWindowContentSize(ImVec2 size){
return SetNextWindowContentSize(size);
}

extern(C)
void igSetNextWindowCollapsed(bool collapsed, ImGuiCond cond){
return SetNextWindowCollapsed(collapsed, cond);
}

extern(C)
void igSetNextWindowFocus(){
return SetNextWindowFocus();
}

extern(C)
void igSetNextWindowBgAlpha(float alpha){
return SetNextWindowBgAlpha(alpha);
}

extern(C)
void igSetWindowPosVec2(ImVec2 pos, ImGuiCond cond){
return SetWindowPos(pos, cond);
}

extern(C)
void igSetWindowSizeVec2(ImVec2 size, ImGuiCond cond){
return SetWindowSize(size, cond);
}

extern(C)
void igSetWindowCollapsedBool(bool collapsed, ImGuiCond cond){
return SetWindowCollapsed(collapsed, cond);
}

extern(C)
void igSetWindowFocusNil(){
return SetWindowFocus();
}

extern(C)
void igSetWindowFontScale(float scale){
return SetWindowFontScale(scale);
}

extern(C)
void igSetWindowPosStr(const(char)* name, ImVec2 pos, ImGuiCond cond){
return SetWindowPos(name, pos, cond);
}

extern(C)
void igSetWindowSizeStr(const(char)* name, ImVec2 size, ImGuiCond cond){
return SetWindowSize(name, size, cond);
}

extern(C)
void igSetWindowCollapsedStr(const(char)* name, bool collapsed, ImGuiCond cond){
return SetWindowCollapsed(name, collapsed, cond);
}

extern(C)
void igSetWindowFocusStr(const(char)* name){
return SetWindowFocus(name);
}

extern(C)
void igGetContentRegionMax(ImVec2* pOut){
*pOut = GetContentRegionMax();
}

extern(C)
void igGetContentRegionAvail(ImVec2* pOut){
*pOut = GetContentRegionAvail();
}

extern(C)
void igGetWindowContentRegionMin(ImVec2* pOut){
*pOut = GetWindowContentRegionMin();
}

extern(C)
void igGetWindowContentRegionMax(ImVec2* pOut){
*pOut = GetWindowContentRegionMax();
}

extern(C)
float igGetWindowContentRegionWidth(){
return GetWindowContentRegionWidth();
}

extern(C)
float igGetScrollX(){
return GetScrollX();
}

extern(C)
float igGetScrollY(){
return GetScrollY();
}

extern(C)
float igGetScrollMaxX(){
return GetScrollMaxX();
}

extern(C)
float igGetScrollMaxY(){
return GetScrollMaxY();
}

extern(C)
void igSetScrollXFloat(float scroll_x){
return SetScrollX(scroll_x);
}

extern(C)
void igSetScrollYFloat(float scroll_y){
return SetScrollY(scroll_y);
}

extern(C)
void igSetScrollHereX(float center_x_ratio){
return SetScrollHereX(center_x_ratio);
}

extern(C)
void igSetScrollHereY(float center_y_ratio){
return SetScrollHereY(center_y_ratio);
}

extern(C)
void igSetScrollFromPosXFloat(float local_x, float center_x_ratio){
return SetScrollFromPosX(local_x, center_x_ratio);
}

extern(C)
void igSetScrollFromPosYFloat(float local_y, float center_y_ratio){
return SetScrollFromPosY(local_y, center_y_ratio);
}

extern(C)
void igPushFont(ImFont* font){
return PushFont(font);
}

extern(C)
void igPopFont(){
return PopFont();
}

extern(C)
void igPushStyleColorU32(ImGuiCol idx, ImU32 col){
return PushStyleColor(idx, col);
}

extern(C)
void igPushStyleColorVec4(ImGuiCol idx, ImVec4 col){
return PushStyleColor(idx, col);
}

extern(C)
void igPopStyleColor(int count){
return PopStyleColor(count);
}

extern(C)
void igPushStyleVarFloat(ImGuiStyleVar idx, float val){
return PushStyleVar(idx, val);
}

extern(C)
void igPushStyleVarVec2(ImGuiStyleVar idx, ImVec2 val){
return PushStyleVar(idx, val);
}

extern(C)
void igPopStyleVar(int count){
return PopStyleVar(count);
}

extern(C)
const(ImVec4)* igGetStyleColorVec4(ImGuiCol idx){
return &GetStyleColorVec4(idx);
}

extern(C)
ImFont* igGetFont(){
return GetFont();
}

extern(C)
float igGetFontSize(){
return GetFontSize();
}

extern(C)
void igGetFontTexUvWhitePixel(ImVec2* pOut){
*pOut = GetFontTexUvWhitePixel();
}

extern(C)
ImU32 igGetColorU32Col(ImGuiCol idx, float alpha_mul){
return GetColorU32(idx, alpha_mul);
}

extern(C)
ImU32 igGetColorU32Vec4(ImVec4 col){
return GetColorU32(col);
}

extern(C)
ImU32 igGetColorU32U32(ImU32 col){
return GetColorU32(col);
}

extern(C)
void igPushItemWidth(float item_width){
return PushItemWidth(item_width);
}

extern(C)
void igPopItemWidth(){
return PopItemWidth();
}

extern(C)
void igSetNextItemWidth(float item_width){
return SetNextItemWidth(item_width);
}

extern(C)
float igCalcItemWidth(){
return CalcItemWidth();
}

extern(C)
void igPushTextWrapPos(float wrap_local_pos_x){
return PushTextWrapPos(wrap_local_pos_x);
}

extern(C)
void igPopTextWrapPos(){
return PopTextWrapPos();
}

extern(C)
void igPushAllowKeyboardFocus(bool allow_keyboard_focus){
return PushAllowKeyboardFocus(allow_keyboard_focus);
}

extern(C)
void igPopAllowKeyboardFocus(){
return PopAllowKeyboardFocus();
}

extern(C)
void igPushButtonRepeat(bool repeat){
return PushButtonRepeat(repeat);
}

extern(C)
void igPopButtonRepeat(){
return PopButtonRepeat();
}

extern(C)
void igSeparator(){
return Separator();
}

extern(C)
void igSameLine(float offset_from_start_x, float spacing){
return SameLine(offset_from_start_x, spacing);
}

extern(C)
void igNewLine(){
return NewLine();
}

extern(C)
void igSpacing(){
return Spacing();
}

extern(C)
void igDummy(ImVec2 size){
return Dummy(size);
}

extern(C)
void igIndent(float indent_w){
return Indent(indent_w);
}

extern(C)
void igUnindent(float indent_w){
return Unindent(indent_w);
}

extern(C)
void igBeginGroup(){
return BeginGroup();
}

extern(C)
void igEndGroup(){
return EndGroup();
}

extern(C)
void igGetCursorPos(ImVec2* pOut){
*pOut = GetCursorPos();
}

extern(C)
float igGetCursorPosX(){
return GetCursorPosX();
}

extern(C)
float igGetCursorPosY(){
return GetCursorPosY();
}

extern(C)
void igSetCursorPos(ImVec2 local_pos){
return SetCursorPos(local_pos);
}

extern(C)
void igSetCursorPosX(float local_x){
return SetCursorPosX(local_x);
}

extern(C)
void igSetCursorPosY(float local_y){
return SetCursorPosY(local_y);
}

extern(C)
void igGetCursorStartPos(ImVec2* pOut){
*pOut = GetCursorStartPos();
}

extern(C)
void igGetCursorScreenPos(ImVec2* pOut){
*pOut = GetCursorScreenPos();
}

extern(C)
void igSetCursorScreenPos(ImVec2 pos){
return SetCursorScreenPos(pos);
}

extern(C)
void igAlignTextToFramePadding(){
return AlignTextToFramePadding();
}

extern(C)
float igGetTextLineHeight(){
return GetTextLineHeight();
}

extern(C)
float igGetTextLineHeightWithSpacing(){
return GetTextLineHeightWithSpacing();
}

extern(C)
float igGetFrameHeight(){
return GetFrameHeight();
}

extern(C)
float igGetFrameHeightWithSpacing(){
return GetFrameHeightWithSpacing();
}

extern(C)
void igPushIDStr(const(char)* str_id){
return PushID(str_id);
}

extern(C)
void igPushIDStrStr(const(char)* str_id_begin, const(char)* str_id_end){
return PushID(str_id_begin, str_id_end);
}

extern(C)
void igPushIDPtr(const(void)* ptr_id){
return PushID(ptr_id);
}

extern(C)
void igPushIDInt(int int_id){
return PushID(int_id);
}

extern(C)
void igPopID(){
return PopID();
}

extern(C)
ImGuiID igGetIDStr(const(char)* str_id){
return GetID(str_id);
}

extern(C)
ImGuiID igGetIDStrStr(const(char)* str_id_begin, const(char)* str_id_end){
return GetID(str_id_begin, str_id_end);
}

extern(C)
ImGuiID igGetIDPtr(const(void)* ptr_id){
return GetID(ptr_id);
}

extern(C)
void igTextUnformatted(const(char)* text, const(char)* text_end){
return TextUnformatted(text, text_end);
}

extern(C)
void igText(const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
TextV(fmt, args);
(args = cast(char*)0);
}

extern(C)
void igTextV(const(char)* fmt, char* args){
return TextV(fmt, args);
}

extern(C)
void igTextColored(ImVec4 col, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
TextColoredV(col, fmt, args);
(args = cast(char*)0);
}

extern(C)
void igTextColoredV(ImVec4 col, const(char)* fmt, char* args){
return TextColoredV(col, fmt, args);
}

extern(C)
void igTextDisabled(const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
TextDisabledV(fmt, args);
(args = cast(char*)0);
}

extern(C)
void igTextDisabledV(const(char)* fmt, char* args){
return TextDisabledV(fmt, args);
}

extern(C)
void igTextWrapped(const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
TextWrappedV(fmt, args);
(args = cast(char*)0);
}

extern(C)
void igTextWrappedV(const(char)* fmt, char* args){
return TextWrappedV(fmt, args);
}

extern(C)
void igLabelText(const(char)* label, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
LabelTextV(label, fmt, args);
(args = cast(char*)0);
}

extern(C)
void igLabelTextV(const(char)* label, const(char)* fmt, char* args){
return LabelTextV(label, fmt, args);
}

extern(C)
void igBulletText(const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
BulletTextV(fmt, args);
(args = cast(char*)0);
}

extern(C)
void igBulletTextV(const(char)* fmt, char* args){
return BulletTextV(fmt, args);
}

extern(C)
bool igButton(const(char)* label, ImVec2 size){
return Button(label, size);
}

extern(C)
bool igSmallButton(const(char)* label){
return SmallButton(label);
}

extern(C)
bool igInvisibleButton(const(char)* str_id, ImVec2 size, ImGuiButtonFlags flags){
return InvisibleButton(str_id, size, flags);
}

extern(C)
bool igArrowButton(const(char)* str_id, ImGuiDir dir){
return ArrowButton(str_id, dir);
}

extern(C)
void igImage(void* user_texture_id, ImVec2 size, ImVec2 uv0, ImVec2 uv1, ImVec4 tint_col, ImVec4 border_col){
return Image(user_texture_id, size, uv0, uv1, tint_col, border_col);
}

extern(C)
bool igImageButton(void* user_texture_id, ImVec2 size, ImVec2 uv0, ImVec2 uv1, int frame_padding, ImVec4 bg_col, ImVec4 tint_col){
return ImageButton(user_texture_id, size, uv0, uv1, frame_padding, bg_col, tint_col);
}

extern(C)
bool igCheckbox(const(char)* label, bool* v){
return Checkbox(label, v);
}

extern(C)
bool igCheckboxFlags(const(char)* label, uint* flags, uint flags_value){
return CheckboxFlags(label, flags, flags_value);
}

extern(C)
bool igRadioButtonBool(const(char)* label, bool active){
return RadioButton(label, active);
}

extern(C)
bool igRadioButtonIntPtr(const(char)* label, int* v, int v_button){
return RadioButton(label, v, v_button);
}

extern(C)
void igProgressBar(float fraction, ImVec2 size_arg, const(char)* overlay){
return ProgressBar(fraction, size_arg, overlay);
}

extern(C)
void igBullet(){
return Bullet();
}

extern(C)
bool igBeginCombo(const(char)* label, const(char)* preview_value, ImGuiComboFlags flags){
return BeginCombo(label, preview_value, flags);
}

extern(C)
void igEndCombo(){
return EndCombo();
}

extern(C)
bool igComboStr_arr(const(char)* label, int* current_item, const(const(char))** items, int items_count, int popup_max_height_in_items){
return Combo(label, current_item, items, items_count, popup_max_height_in_items);
}

extern(C)
bool igComboStr(const(char)* label, int* current_item, const(char)* items_separated_by_zeros, int popup_max_height_in_items){
return Combo(label, current_item, items_separated_by_zeros, popup_max_height_in_items);
}

extern(C)
bool igComboFnBoolPtr(const(char)* label, int* current_item, bool function(void*, int, const(char)**) items_getter, void* data, int items_count, int popup_max_height_in_items){
return Combo(label, current_item, items_getter, data, items_count, popup_max_height_in_items);
}

extern(C)
bool igDragFloat(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return DragFloat(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragFloat2(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return DragFloat2(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragFloat3(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return DragFloat3(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragFloat4(const(char)* label, float* v, float v_speed, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return DragFloat4(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragFloatRange2(const(char)* label, float* v_current_min, float* v_current_max, float v_speed, float v_min, float v_max, const(char)* format, const(char)* format_max, ImGuiSliderFlags flags){
return DragFloatRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags);
}

extern(C)
bool igDragInt(const(char)* label, int* v, float v_speed, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return DragInt(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragInt2(const(char)* label, int* v, float v_speed, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return DragInt2(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragInt3(const(char)* label, int* v, float v_speed, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return DragInt3(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragInt4(const(char)* label, int* v, float v_speed, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return DragInt4(label, v, v_speed, v_min, v_max, format, flags);
}

extern(C)
bool igDragIntRange2(const(char)* label, int* v_current_min, int* v_current_max, float v_speed, int v_min, int v_max, const(char)* format, const(char)* format_max, ImGuiSliderFlags flags){
return DragIntRange2(label, v_current_min, v_current_max, v_speed, v_min, v_max, format, format_max, flags);
}

extern(C)
bool igDragScalar(const(char)* label, ImGuiDataType data_type, void* p_data, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return DragScalar(label, data_type, p_data, v_speed, p_min, p_max, format, flags);
}

extern(C)
bool igDragScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return DragScalarN(label, data_type, p_data, components, v_speed, p_min, p_max, format, flags);
}

extern(C)
bool igSliderFloat(const(char)* label, float* v, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderFloat(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderFloat2(const(char)* label, float* v, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderFloat2(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderFloat3(const(char)* label, float* v, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderFloat3(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderFloat4(const(char)* label, float* v, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderFloat4(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderAngle(const(char)* label, float* v_rad, float v_degrees_min, float v_degrees_max, const(char)* format, ImGuiSliderFlags flags){
return SliderAngle(label, v_rad, v_degrees_min, v_degrees_max, format, flags);
}

extern(C)
bool igSliderInt(const(char)* label, int* v, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderInt(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderInt2(const(char)* label, int* v, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderInt2(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderInt3(const(char)* label, int* v, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderInt3(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderInt4(const(char)* label, int* v, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return SliderInt4(label, v, v_min, v_max, format, flags);
}

extern(C)
bool igSliderScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return SliderScalar(label, data_type, p_data, p_min, p_max, format, flags);
}

extern(C)
bool igSliderScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return SliderScalarN(label, data_type, p_data, components, p_min, p_max, format, flags);
}

extern(C)
bool igVSliderFloat(const(char)* label, ImVec2 size, float* v, float v_min, float v_max, const(char)* format, ImGuiSliderFlags flags){
return VSliderFloat(label, size, v, v_min, v_max, format, flags);
}

extern(C)
bool igVSliderInt(const(char)* label, ImVec2 size, int* v, int v_min, int v_max, const(char)* format, ImGuiSliderFlags flags){
return VSliderInt(label, size, v, v_min, v_max, format, flags);
}

extern(C)
bool igVSliderScalar(const(char)* label, ImVec2 size, ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return VSliderScalar(label, size, data_type, p_data, p_min, p_max, format, flags);
}

extern(C)
bool igInputText(const(char)* label, char* buf, size_t buf_size, ImGuiInputTextFlags flags, int function(ImGuiInputTextCallbackData*) callback, void* user_data){
return InputText(label, buf, buf_size, flags, callback, user_data);
}

extern(C)
bool igInputTextMultiline(const(char)* label, char* buf, size_t buf_size, ImVec2 size, ImGuiInputTextFlags flags, int function(ImGuiInputTextCallbackData*) callback, void* user_data){
return InputTextMultiline(label, buf, buf_size, size, flags, callback, user_data);
}

extern(C)
bool igInputTextWithHint(const(char)* label, const(char)* hint, char* buf, size_t buf_size, ImGuiInputTextFlags flags, int function(ImGuiInputTextCallbackData*) callback, void* user_data){
return InputTextWithHint(label, hint, buf, buf_size, flags, callback, user_data);
}

extern(C)
bool igInputFloat(const(char)* label, float* v, float step, float step_fast, const(char)* format, ImGuiInputTextFlags flags){
return InputFloat(label, v, step, step_fast, format, flags);
}

extern(C)
bool igInputFloat2(const(char)* label, float* v, const(char)* format, ImGuiInputTextFlags flags){
return InputFloat2(label, v, format, flags);
}

extern(C)
bool igInputFloat3(const(char)* label, float* v, const(char)* format, ImGuiInputTextFlags flags){
return InputFloat3(label, v, format, flags);
}

extern(C)
bool igInputFloat4(const(char)* label, float* v, const(char)* format, ImGuiInputTextFlags flags){
return InputFloat4(label, v, format, flags);
}

extern(C)
bool igInputInt(const(char)* label, int* v, int step, int step_fast, ImGuiInputTextFlags flags){
return InputInt(label, v, step, step_fast, flags);
}

extern(C)
bool igInputInt2(const(char)* label, int* v, ImGuiInputTextFlags flags){
return InputInt2(label, v, flags);
}

extern(C)
bool igInputInt3(const(char)* label, int* v, ImGuiInputTextFlags flags){
return InputInt3(label, v, flags);
}

extern(C)
bool igInputInt4(const(char)* label, int* v, ImGuiInputTextFlags flags){
return InputInt4(label, v, flags);
}

extern(C)
bool igInputDouble(const(char)* label, double* v, double step, double step_fast, const(char)* format, ImGuiInputTextFlags flags){
return InputDouble(label, v, step, step_fast, format, flags);
}

extern(C)
bool igInputScalar(const(char)* label, ImGuiDataType data_type, void* p_data, const(void)* p_step, const(void)* p_step_fast, const(char)* format, ImGuiInputTextFlags flags){
return InputScalar(label, data_type, p_data, p_step, p_step_fast, format, flags);
}

extern(C)
bool igInputScalarN(const(char)* label, ImGuiDataType data_type, void* p_data, int components, const(void)* p_step, const(void)* p_step_fast, const(char)* format, ImGuiInputTextFlags flags){
return InputScalarN(label, data_type, p_data, components, p_step, p_step_fast, format, flags);
}

extern(C)
bool igColorEdit3(const(char)* label, float* col, ImGuiColorEditFlags flags){
return ColorEdit3(label, col, flags);
}

extern(C)
bool igColorEdit4(const(char)* label, float* col, ImGuiColorEditFlags flags){
return ColorEdit4(label, col, flags);
}

extern(C)
bool igColorPicker3(const(char)* label, float* col, ImGuiColorEditFlags flags){
return ColorPicker3(label, col, flags);
}

extern(C)
bool igColorPicker4(const(char)* label, float* col, ImGuiColorEditFlags flags, const(float)* ref_col){
return ColorPicker4(label, col, flags, ref_col);
}

extern(C)
bool igColorButton(const(char)* desc_id, ImVec4 col, ImGuiColorEditFlags flags, ImVec2 size){
return ColorButton(desc_id, col, flags, size);
}

extern(C)
void igSetColorEditOptions(ImGuiColorEditFlags flags){
return SetColorEditOptions(flags);
}

extern(C)
bool igTreeNodeStr(const(char)* label){
return TreeNode(label);
}

extern(C)
bool igTreeNodeStrStr(const(char)* str_id, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
bool ret = TreeNodeV(str_id, fmt, args);
(args = cast(char*)0);
return ret;
}

extern(C)
bool igTreeNodePtr(const(void)* ptr_id, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
bool ret = TreeNodeV(ptr_id, fmt, args);
(args = cast(char*)0);
return ret;
}

extern(C)
bool igTreeNodeVStr(const(char)* str_id, const(char)* fmt, char* args){
return TreeNodeV(str_id, fmt, args);
}

extern(C)
bool igTreeNodeVPtr(const(void)* ptr_id, const(char)* fmt, char* args){
return TreeNodeV(ptr_id, fmt, args);
}

extern(C)
bool igTreeNodeExStr(const(char)* label, ImGuiTreeNodeFlags flags){
return TreeNodeEx(label, flags);
}

extern(C)
bool igTreeNodeExStrStr(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
bool ret = TreeNodeExV(str_id, flags, fmt, args);
(args = cast(char*)0);
return ret;
}

extern(C)
bool igTreeNodeExPtr(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
bool ret = TreeNodeExV(ptr_id, flags, fmt, args);
(args = cast(char*)0);
return ret;
}

extern(C)
bool igTreeNodeExVStr(const(char)* str_id, ImGuiTreeNodeFlags flags, const(char)* fmt, char* args){
return TreeNodeExV(str_id, flags, fmt, args);
}

extern(C)
bool igTreeNodeExVPtr(const(void)* ptr_id, ImGuiTreeNodeFlags flags, const(char)* fmt, char* args){
return TreeNodeExV(ptr_id, flags, fmt, args);
}

extern(C)
void igTreePushStr(const(char)* str_id){
return TreePush(str_id);
}

extern(C)
void igTreePushPtr(const(void)* ptr_id){
return TreePush(ptr_id);
}

extern(C)
void igTreePop(){
return TreePop();
}

extern(C)
float igGetTreeNodeToLabelSpacing(){
return GetTreeNodeToLabelSpacing();
}

extern(C)
bool igCollapsingHeaderTreeNodeFlags(const(char)* label, ImGuiTreeNodeFlags flags){
return CollapsingHeader(label, flags);
}

extern(C)
bool igCollapsingHeaderBoolPtr(const(char)* label, bool* p_open, ImGuiTreeNodeFlags flags){
return CollapsingHeader(label, p_open, flags);
}

extern(C)
void igSetNextItemOpen(bool is_open, ImGuiCond cond){
return SetNextItemOpen(is_open, cond);
}

extern(C)
bool igSelectableBool(const(char)* label, bool selected, ImGuiSelectableFlags flags, ImVec2 size){
return Selectable(label, selected, flags, size);
}

extern(C)
bool igSelectableBoolPtr(const(char)* label, bool* p_selected, ImGuiSelectableFlags flags, ImVec2 size){
return Selectable(label, p_selected, flags, size);
}

extern(C)
bool igListBoxStr_arr(const(char)* label, int* current_item, const(const(char))** items, int items_count, int height_in_items){
return ListBox(label, current_item, items, items_count, height_in_items);
}

extern(C)
bool igListBoxFnBoolPtr(const(char)* label, int* current_item, bool function(void*, int, const(char)**) items_getter, void* data, int items_count, int height_in_items){
return ListBox(label, current_item, items_getter, data, items_count, height_in_items);
}

extern(C)
bool igListBoxHeaderVec2(const(char)* label, ImVec2 size){
return ListBoxHeader(label, size);
}

extern(C)
bool igListBoxHeaderInt(const(char)* label, int items_count, int height_in_items){
return ListBoxHeader(label, items_count, height_in_items);
}

extern(C)
void igListBoxFooter(){
return ListBoxFooter();
}

extern(C)
void igPlotLinesFloatPtr(const(char)* label, const(float)* values, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size, int stride){
return PlotLines(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride);
}

extern(C)
void igPlotLinesFnFloatPtr(const(char)* label, float function(void*, int) values_getter, void* data, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size){
return PlotLines(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

extern(C)
void igPlotHistogramFloatPtr(const(char)* label, const(float)* values, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size, int stride){
return PlotHistogram(label, values, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size, stride);
}

extern(C)
void igPlotHistogramFnFloatPtr(const(char)* label, float function(void*, int) values_getter, void* data, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, ImVec2 graph_size){
return PlotHistogram(label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, graph_size);
}

extern(C)
void igValueBool(const(char)* prefix, bool b){
return Value(prefix, b);
}

extern(C)
void igValueInt(const(char)* prefix, int v){
return Value(prefix, v);
}

extern(C)
void igValueUint(const(char)* prefix, uint v){
return Value(prefix, v);
}

extern(C)
void igValueFloat(const(char)* prefix, float v, const(char)* float_format){
return Value(prefix, v, float_format);
}

extern(C)
bool igBeginMenuBar(){
return BeginMenuBar();
}

extern(C)
void igEndMenuBar(){
return EndMenuBar();
}

extern(C)
bool igBeginMainMenuBar(){
return BeginMainMenuBar();
}

extern(C)
void igEndMainMenuBar(){
return EndMainMenuBar();
}

extern(C)
bool igBeginMenu(const(char)* label, bool enabled){
return BeginMenu(label, enabled);
}

extern(C)
void igEndMenu(){
return EndMenu();
}

extern(C)
bool igMenuItemBool(const(char)* label, const(char)* shortcut, bool selected, bool enabled){
return MenuItem(label, shortcut, selected, enabled);
}

extern(C)
bool igMenuItemBoolPtr(const(char)* label, const(char)* shortcut, bool* p_selected, bool enabled){
return MenuItem(label, shortcut, p_selected, enabled);
}

extern(C)
void igBeginTooltip(){
return BeginTooltip();
}

extern(C)
void igEndTooltip(){
return EndTooltip();
}

extern(C)
void igSetTooltip(const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
SetTooltipV(fmt, args);
(args = cast(char*)0);
}

extern(C)
void igSetTooltipV(const(char)* fmt, char* args){
return SetTooltipV(fmt, args);
}

extern(C)
bool igBeginPopup(const(char)* str_id, ImGuiWindowFlags flags){
return BeginPopup(str_id, flags);
}

extern(C)
bool igBeginPopupModal(const(char)* name, bool* p_open, ImGuiWindowFlags flags){
return BeginPopupModal(name, p_open, flags);
}

extern(C)
void igEndPopup(){
return EndPopup();
}

extern(C)
void igOpenPopup(const(char)* str_id, ImGuiPopupFlags popup_flags){
return OpenPopup(str_id, popup_flags);
}

extern(C)
bool igOpenPopupContextItem(const(char)* str_id, ImGuiPopupFlags popup_flags){
return OpenPopupContextItem(str_id, popup_flags);
}

extern(C)
void igCloseCurrentPopup(){
return CloseCurrentPopup();
}

extern(C)
bool igBeginPopupContextItem(const(char)* str_id, ImGuiPopupFlags popup_flags){
return BeginPopupContextItem(str_id, popup_flags);
}

extern(C)
bool igBeginPopupContextWindow(const(char)* str_id, ImGuiPopupFlags popup_flags){
return BeginPopupContextWindow(str_id, popup_flags);
}

extern(C)
bool igBeginPopupContextVoid(const(char)* str_id, ImGuiPopupFlags popup_flags){
return BeginPopupContextVoid(str_id, popup_flags);
}

extern(C)
bool igIsPopupOpenStr(const(char)* str_id, ImGuiPopupFlags flags){
return IsPopupOpen(str_id, flags);
}

extern(C)
void igColumns(int count, const(char)* id, bool border){
return Columns(count, id, border);
}

extern(C)
void igNextColumn(){
return NextColumn();
}

extern(C)
int igGetColumnIndex(){
return GetColumnIndex();
}

extern(C)
float igGetColumnWidth(int column_index){
return GetColumnWidth(column_index);
}

extern(C)
void igSetColumnWidth(int column_index, float width){
return SetColumnWidth(column_index, width);
}

extern(C)
float igGetColumnOffset(int column_index){
return GetColumnOffset(column_index);
}

extern(C)
void igSetColumnOffset(int column_index, float offset_x){
return SetColumnOffset(column_index, offset_x);
}

extern(C)
int igGetColumnsCount(){
return GetColumnsCount();
}

extern(C)
bool igBeginTabBar(const(char)* str_id, ImGuiTabBarFlags flags){
return BeginTabBar(str_id, flags);
}

extern(C)
void igEndTabBar(){
return EndTabBar();
}

extern(C)
bool igBeginTabItem(const(char)* label, bool* p_open, ImGuiTabItemFlags flags){
return BeginTabItem(label, p_open, flags);
}

extern(C)
void igEndTabItem(){
return EndTabItem();
}

extern(C)
void igSetTabItemClosed(const(char)* tab_or_docked_window_label){
return SetTabItemClosed(tab_or_docked_window_label);
}

extern(C)
void igLogToTTY(int auto_open_depth){
return LogToTTY(auto_open_depth);
}

extern(C)
void igLogToFile(int auto_open_depth, const(char)* filename){
return LogToFile(auto_open_depth, filename);
}

extern(C)
void igLogToClipboard(int auto_open_depth){
return LogToClipboard(auto_open_depth);
}

extern(C)
void igLogFinish(){
return LogFinish();
}

extern(C)
void igLogButtons(){
return LogButtons();
}

extern(C)
bool igBeginDragDropSource(ImGuiDragDropFlags flags){
return BeginDragDropSource(flags);
}

extern(C)
bool igSetDragDropPayload(const(char)* type, const(void)* data, size_t sz, ImGuiCond cond){
return SetDragDropPayload(type, data, sz, cond);
}

extern(C)
void igEndDragDropSource(){
return EndDragDropSource();
}

extern(C)
bool igBeginDragDropTarget(){
return BeginDragDropTarget();
}

extern(C)
const(ImGuiPayload)* igAcceptDragDropPayload(const(char)* type, ImGuiDragDropFlags flags){
return AcceptDragDropPayload(type, flags);
}

extern(C)
void igEndDragDropTarget(){
return EndDragDropTarget();
}

extern(C)
const(ImGuiPayload)* igGetDragDropPayload(){
return GetDragDropPayload();
}

extern(C)
void igPushClipRect(ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect){
return PushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect);
}

extern(C)
void igPopClipRect(){
return PopClipRect();
}

extern(C)
void igSetItemDefaultFocus(){
return SetItemDefaultFocus();
}

extern(C)
void igSetKeyboardFocusHere(int offset){
return SetKeyboardFocusHere(offset);
}

extern(C)
bool igIsItemHovered(ImGuiHoveredFlags flags){
return IsItemHovered(flags);
}

extern(C)
bool igIsItemActive(){
return IsItemActive();
}

extern(C)
bool igIsItemFocused(){
return IsItemFocused();
}

extern(C)
bool igIsItemClicked(ImGuiMouseButton mouse_button){
return IsItemClicked(mouse_button);
}

extern(C)
bool igIsItemVisible(){
return IsItemVisible();
}

extern(C)
bool igIsItemEdited(){
return IsItemEdited();
}

extern(C)
bool igIsItemActivated(){
return IsItemActivated();
}

extern(C)
bool igIsItemDeactivated(){
return IsItemDeactivated();
}

extern(C)
bool igIsItemDeactivatedAfterEdit(){
return IsItemDeactivatedAfterEdit();
}

extern(C)
bool igIsItemToggledOpen(){
return IsItemToggledOpen();
}

extern(C)
bool igIsAnyItemHovered(){
return IsAnyItemHovered();
}

extern(C)
bool igIsAnyItemActive(){
return IsAnyItemActive();
}

extern(C)
bool igIsAnyItemFocused(){
return IsAnyItemFocused();
}

extern(C)
void igGetItemRectMin(ImVec2* pOut){
*pOut = GetItemRectMin();
}

extern(C)
void igGetItemRectMax(ImVec2* pOut){
*pOut = GetItemRectMax();
}

extern(C)
void igGetItemRectSize(ImVec2* pOut){
*pOut = GetItemRectSize();
}

extern(C)
void igSetItemAllowOverlap(){
return SetItemAllowOverlap();
}

extern(C)
bool igIsRectVisibleNil(ImVec2 size){
return IsRectVisible(size);
}

extern(C)
bool igIsRectVisibleVec2(ImVec2 rect_min, ImVec2 rect_max){
return IsRectVisible(rect_min, rect_max);
}

extern(C)
double igGetTime(){
return GetTime();
}

extern(C)
int igGetFrameCount(){
return GetFrameCount();
}

extern(C)
ImDrawList* igGetBackgroundDrawList(){
return GetBackgroundDrawList();
}

extern(C)
ImDrawList* igGetForegroundDrawListNil(){
return GetForegroundDrawList();
}

extern(C)
ImDrawListSharedData* igGetDrawListSharedData(){
return GetDrawListSharedData();
}

extern(C)
const(char)* igGetStyleColorName(ImGuiCol idx){
return GetStyleColorName(idx);
}

extern(C)
void igSetStateStorage(ImGuiStorage* storage){
return SetStateStorage(storage);
}

extern(C)
ImGuiStorage* igGetStateStorage(){
return GetStateStorage();
}

extern(C)
void igCalcListClipping(int items_count, float items_height, int* out_items_display_start, int* out_items_display_end){
return CalcListClipping(items_count, items_height, out_items_display_start, out_items_display_end);
}

extern(C)
bool igBeginChildFrame(ImGuiID id, ImVec2 size, ImGuiWindowFlags flags){
return BeginChildFrame(id, size, flags);
}

extern(C)
void igEndChildFrame(){
return EndChildFrame();
}

extern(C)
void igCalcTextSize(ImVec2* pOut, const(char)* text, const(char)* text_end, bool hide_text_after_double_hash, float wrap_width){
*pOut = CalcTextSize(text, text_end, hide_text_after_double_hash, wrap_width);
}

extern(C)
void igColorConvertU32ToFloat4(ImVec4* pOut, ImU32 in_){
*pOut = ColorConvertU32ToFloat4(in_);
}

extern(C)
ImU32 igColorConvertFloat4ToU32(ImVec4 in_){
return ColorConvertFloat4ToU32(in_);
}

extern(C)
void igColorConvertRGBtoHSV(float r, float g, float b, float* out_h, float* out_s, float* out_v){
return ColorConvertRGBtoHSV(r, g, b, *out_h, *out_s, *out_v);
}

extern(C)
void igColorConvertHSVtoRGB(float h, float s, float v, float* out_r, float* out_g, float* out_b){
return ColorConvertHSVtoRGB(h, s, v, *out_r, *out_g, *out_b);
}

extern(C)
int igGetKeyIndex(ImGuiKey imgui_key){
return GetKeyIndex(imgui_key);
}

extern(C)
bool igIsKeyDown(int user_key_index){
return IsKeyDown(user_key_index);
}

extern(C)
bool igIsKeyPressed(int user_key_index, bool repeat){
return IsKeyPressed(user_key_index, repeat);
}

extern(C)
bool igIsKeyReleased(int user_key_index){
return IsKeyReleased(user_key_index);
}

extern(C)
int igGetKeyPressedAmount(int key_index, float repeat_delay, float rate){
return GetKeyPressedAmount(key_index, repeat_delay, rate);
}

extern(C)
void igCaptureKeyboardFromApp(bool want_capture_keyboard_value){
return CaptureKeyboardFromApp(want_capture_keyboard_value);
}

extern(C)
bool igIsMouseDown(ImGuiMouseButton button){
return IsMouseDown(button);
}

extern(C)
bool igIsMouseClicked(ImGuiMouseButton button, bool repeat){
return IsMouseClicked(button, repeat);
}

extern(C)
bool igIsMouseReleased(ImGuiMouseButton button){
return IsMouseReleased(button);
}

extern(C)
bool igIsMouseDoubleClicked(ImGuiMouseButton button){
return IsMouseDoubleClicked(button);
}

extern(C)
bool igIsMouseHoveringRect(ImVec2 r_min, ImVec2 r_max, bool clip){
return IsMouseHoveringRect(r_min, r_max, clip);
}

extern(C)
bool igIsMousePosValid(const(ImVec2)* mouse_pos){
return IsMousePosValid(mouse_pos);
}

extern(C)
bool igIsAnyMouseDown(){
return IsAnyMouseDown();
}

extern(C)
void igGetMousePos(ImVec2* pOut){
*pOut = GetMousePos();
}

extern(C)
void igGetMousePosOnOpeningCurrentPopup(ImVec2* pOut){
*pOut = GetMousePosOnOpeningCurrentPopup();
}

extern(C)
bool igIsMouseDragging(ImGuiMouseButton button, float lock_threshold){
return IsMouseDragging(button, lock_threshold);
}

extern(C)
void igGetMouseDragDelta(ImVec2* pOut, ImGuiMouseButton button, float lock_threshold){
*pOut = GetMouseDragDelta(button, lock_threshold);
}

extern(C)
void igResetMouseDragDelta(ImGuiMouseButton button){
return ResetMouseDragDelta(button);
}

extern(C)
ImGuiMouseCursor igGetMouseCursor(){
return GetMouseCursor();
}

extern(C)
void igSetMouseCursor(ImGuiMouseCursor cursor_type){
return SetMouseCursor(cursor_type);
}

extern(C)
void igCaptureMouseFromApp(bool want_capture_mouse_value){
return CaptureMouseFromApp(want_capture_mouse_value);
}

extern(C)
const(char)* igGetClipboardText(){
return GetClipboardText();
}

extern(C)
void igSetClipboardText(const(char)* text){
return SetClipboardText(text);
}

extern(C)
void igLoadIniSettingsFromDisk(const(char)* ini_filename){
return LoadIniSettingsFromDisk(ini_filename);
}

extern(C)
void igLoadIniSettingsFromMemory(const(char)* ini_data, size_t ini_size){
return LoadIniSettingsFromMemory(ini_data, ini_size);
}

extern(C)
void igSaveIniSettingsToDisk(const(char)* ini_filename){
return SaveIniSettingsToDisk(ini_filename);
}

extern(C)
const(char)* igSaveIniSettingsToMemory(size_t* out_ini_size){
return SaveIniSettingsToMemory(out_ini_size);
}

extern(C)
bool igDebugCheckVersionAndDataLayout(const(char)* version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx){
return DebugCheckVersionAndDataLayout(version_str, sz_io, sz_style, sz_vec2, sz_vec4, sz_drawvert, sz_drawidx);
}

extern(C)
void igSetAllocatorFunctions(void* function(size_t, void*) alloc_func, void function(void*, void*) free_func, void* user_data){
return SetAllocatorFunctions(alloc_func, free_func, user_data);
}

extern(C)
void* igMemAlloc(size_t size){
return MemAlloc(size);
}

extern(C)
void igMemFree(void* ptr){
return MemFree(ptr);
}

extern(C)
ImGuiStyle* ImGuiStyle_ImGuiStyle(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStyle).sizeof), ImGuiStyle());
}

extern(C)
void ImGuiStyle_destroy(ImGuiStyle* self){
IM_DELETE(self);
}

extern(C)
void ImGuiStyle_ScaleAllSizes(ImGuiStyle* self, float scale_factor){
return self.ScaleAllSizes(scale_factor);
}

extern(C)
void ImGuiIO_AddInputCharacter(ImGuiIO* self, uint c){
return self.AddInputCharacter(c);
}

extern(C)
void ImGuiIO_AddInputCharacterUTF16(ImGuiIO* self, ImWchar16 c){
return self.AddInputCharacterUTF16(c);
}

extern(C)
void ImGuiIO_AddInputCharactersUTF8(ImGuiIO* self, const(char)* str){
return self.AddInputCharactersUTF8(str);
}

extern(C)
void ImGuiIO_ClearInputCharacters(ImGuiIO* self){
return self.ClearInputCharacters();
}

extern(C)
ImGuiIO* ImGuiIO_ImGuiIO(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiIO).sizeof), ImGuiIO());
}

extern(C)
void ImGuiIO_destroy(ImGuiIO* self){
IM_DELETE(self);
}

extern(C)
ImGuiInputTextCallbackData* ImGuiInputTextCallbackData_ImGuiInputTextCallbackData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiInputTextCallbackData).sizeof), ImGuiInputTextCallbackData());
}

extern(C)
void ImGuiInputTextCallbackData_destroy(ImGuiInputTextCallbackData* self){
IM_DELETE(self);
}

extern(C)
void ImGuiInputTextCallbackData_DeleteChars(ImGuiInputTextCallbackData* self, int pos, int bytes_count){
return self.DeleteChars(pos, bytes_count);
}

extern(C)
void ImGuiInputTextCallbackData_InsertChars(ImGuiInputTextCallbackData* self, int pos, const(char)* text, const(char)* text_end){
return self.InsertChars(pos, text, text_end);
}

extern(C)
bool ImGuiInputTextCallbackData_HasSelection(ImGuiInputTextCallbackData* self){
return self.HasSelection();
}

extern(C)
ImGuiPayload* ImGuiPayload_ImGuiPayload(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiPayload).sizeof), ImGuiPayload());
}

extern(C)
void ImGuiPayload_destroy(ImGuiPayload* self){
IM_DELETE(self);
}

extern(C)
void ImGuiPayload_Clear(ImGuiPayload* self){
return self.Clear();
}

extern(C)
bool ImGuiPayload_IsDataType(ImGuiPayload* self, const(char)* type){
return self.IsDataType(type);
}

extern(C)
bool ImGuiPayload_IsPreview(ImGuiPayload* self){
return self.IsPreview();
}

extern(C)
bool ImGuiPayload_IsDelivery(ImGuiPayload* self){
return self.IsDelivery();
}

extern(C)
ImGuiOnceUponAFrame* ImGuiOnceUponAFrame_ImGuiOnceUponAFrame(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiOnceUponAFrame).sizeof), ImGuiOnceUponAFrame());
}

extern(C)
void ImGuiOnceUponAFrame_destroy(ImGuiOnceUponAFrame* self){
IM_DELETE(self);
}

extern(C)
ImGuiTextFilter* ImGuiTextFilter_ImGuiTextFilter(const(char)* default_filter){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTextFilter).sizeof), ImGuiTextFilter(default_filter));
}

extern(C)
void ImGuiTextFilter_destroy(ImGuiTextFilter* self){
IM_DELETE(self);
}

extern(C)
bool ImGuiTextFilter_Draw(ImGuiTextFilter* self, const(char)* label, float width){
return self.Draw(label, width);
}

extern(C)
bool ImGuiTextFilter_PassFilter(ImGuiTextFilter* self, const(char)* text, const(char)* text_end){
return self.PassFilter(text, text_end);
}

extern(C)
void ImGuiTextFilter_Build(ImGuiTextFilter* self){
return self.Build();
}

extern(C)
void ImGuiTextFilter_Clear(ImGuiTextFilter* self){
return self.Clear();
}

extern(C)
bool ImGuiTextFilter_IsActive(ImGuiTextFilter* self){
return self.IsActive();
}

extern(C)
ImGuiTextRange* ImGuiTextRange_ImGuiTextRangeNil(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTextRange).sizeof), ImGuiTextRange());
}

extern(C)
void ImGuiTextRange_destroy(ImGuiTextRange* self){
IM_DELETE(self);
}

extern(C)
ImGuiTextRange* ImGuiTextRange_ImGuiTextRangeStr(const(char)* _b, const(char)* _e){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTextRange).sizeof), ImGuiTextRange(_b, _e));
}

extern(C)
bool ImGuiTextRange_empty(ImGuiTextRange* self){
return self.empty();
}

extern(C)
void ImGuiTextRange_split(ImGuiTextRange* self, char separator, ImVector_ImGuiTextRange* out_){
return self.split(separator, out_);
}

extern(C)
ImGuiTextBuffer* ImGuiTextBuffer_ImGuiTextBuffer(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTextBuffer).sizeof), ImGuiTextBuffer());
}

extern(C)
void ImGuiTextBuffer_destroy(ImGuiTextBuffer* self){
IM_DELETE(self);
}

extern(C)
const(char)* ImGuiTextBuffer_begin(ImGuiTextBuffer* self){
return self.begin();
}

extern(C)
const(char)* ImGuiTextBuffer_end(ImGuiTextBuffer* self){
return self.end();
}

extern(C)
int ImGuiTextBuffer_size(ImGuiTextBuffer* self){
return self.size();
}

extern(C)
bool ImGuiTextBuffer_empty(ImGuiTextBuffer* self){
return self.empty();
}

extern(C)
void ImGuiTextBuffer_clear(ImGuiTextBuffer* self){
return self.clear();
}

extern(C)
void ImGuiTextBuffer_reserve(ImGuiTextBuffer* self, int capacity){
return self.reserve(capacity);
}

extern(C)
const(char)* ImGuiTextBuffer_c_str(ImGuiTextBuffer* self){
return self.c_str();
}

extern(C)
void ImGuiTextBuffer_append(ImGuiTextBuffer* self, const(char)* str, const(char)* str_end){
return self.append(str, str_end);
}

extern(C)
void ImGuiTextBuffer_appendfv(ImGuiTextBuffer* self, const(char)* fmt, char* args){
return self.appendfv(fmt, args);
}

extern(C)
ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePairInt(ImGuiID _key, int _val_i){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStoragePair).sizeof), ImGuiStoragePair(_key, _val_i));
}

extern(C)
void ImGuiStoragePair_destroy(ImGuiStoragePair* self){
IM_DELETE(self);
}

extern(C)
ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePairFloat(ImGuiID _key, float _val_f){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStoragePair).sizeof), ImGuiStoragePair(_key, _val_f));
}

extern(C)
ImGuiStoragePair* ImGuiStoragePair_ImGuiStoragePairPtr(ImGuiID _key, void* _val_p){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStoragePair).sizeof), ImGuiStoragePair(_key, _val_p));
}

extern(C)
void ImGuiStorage_Clear(ImGuiStorage* self){
return self.Clear();
}

extern(C)
int ImGuiStorage_GetInt(ImGuiStorage* self, ImGuiID key, int default_val){
return self.GetInt(key, default_val);
}

extern(C)
void ImGuiStorage_SetInt(ImGuiStorage* self, ImGuiID key, int val){
return self.SetInt(key, val);
}

extern(C)
bool ImGuiStorage_GetBool(ImGuiStorage* self, ImGuiID key, bool default_val){
return self.GetBool(key, default_val);
}

extern(C)
void ImGuiStorage_SetBool(ImGuiStorage* self, ImGuiID key, bool val){
return self.SetBool(key, val);
}

extern(C)
float ImGuiStorage_GetFloat(ImGuiStorage* self, ImGuiID key, float default_val){
return self.GetFloat(key, default_val);
}

extern(C)
void ImGuiStorage_SetFloat(ImGuiStorage* self, ImGuiID key, float val){
return self.SetFloat(key, val);
}

extern(C)
void* ImGuiStorage_GetVoidPtr(ImGuiStorage* self, ImGuiID key){
return self.GetVoidPtr(key);
}

extern(C)
void ImGuiStorage_SetVoidPtr(ImGuiStorage* self, ImGuiID key, void* val){
return self.SetVoidPtr(key, val);
}

extern(C)
int* ImGuiStorage_GetIntRef(ImGuiStorage* self, ImGuiID key, int default_val){
return self.GetIntRef(key, default_val);
}

extern(C)
bool* ImGuiStorage_GetBoolRef(ImGuiStorage* self, ImGuiID key, bool default_val){
return self.GetBoolRef(key, default_val);
}

extern(C)
float* ImGuiStorage_GetFloatRef(ImGuiStorage* self, ImGuiID key, float default_val){
return self.GetFloatRef(key, default_val);
}

extern(C)
void** ImGuiStorage_GetVoidPtrRef(ImGuiStorage* self, ImGuiID key, void* default_val){
return self.GetVoidPtrRef(key, default_val);
}

extern(C)
void ImGuiStorage_SetAllInt(ImGuiStorage* self, int val){
return self.SetAllInt(val);
}

extern(C)
void ImGuiStorage_BuildSortByKey(ImGuiStorage* self){
return self.BuildSortByKey();
}

extern(C)
ImGuiListClipper* ImGuiListClipper_ImGuiListClipper(int items_count, float items_height){
return emplace( ImNewWrapper(), MemAlloc((ImGuiListClipper).sizeof), ImGuiListClipper(items_count, items_height));
}

extern(C)
void ImGuiListClipper_destroy(ImGuiListClipper* self){
IM_DELETE(self);
}

extern(C)
bool ImGuiListClipper_Step(ImGuiListClipper* self){
return self.Step();
}

extern(C)
void ImGuiListClipper_Begin(ImGuiListClipper* self, int items_count, float items_height){
return self.Begin(items_count, items_height);
}

extern(C)
void ImGuiListClipper_End(ImGuiListClipper* self){
return self.End();
}

extern(C)
ImColor* ImColor_ImColorNil(){
return emplace( ImNewWrapper(), MemAlloc((ImColor).sizeof), ImColor());
}

extern(C)
void ImColor_destroy(ImColor* self){
IM_DELETE(self);
}

extern(C)
ImColor* ImColor_ImColorInt(int r, int g, int b, int a){
return emplace( ImNewWrapper(), MemAlloc((ImColor).sizeof), ImColor(r, g, b, a));
}

extern(C)
ImColor* ImColor_ImColorU32(ImU32 rgba){
return emplace( ImNewWrapper(), MemAlloc((ImColor).sizeof), ImColor(rgba));
}

extern(C)
ImColor* ImColor_ImColorFloat(float r, float g, float b, float a){
return emplace( ImNewWrapper(), MemAlloc((ImColor).sizeof), ImColor(r, g, b, a));
}

extern(C)
ImColor* ImColor_ImColorVec4(ImVec4 col){
return emplace( ImNewWrapper(), MemAlloc((ImColor).sizeof), ImColor(col));
}

extern(C)
void ImColor_SetHSV(ImColor* self, float h, float s, float v, float a){
return self.SetHSV(h, s, v, a);
}

extern(C)
void ImColor_HSV(ImColor* pOut, float h, float s, float v, float a){
*pOut = ImColor.HSV(h, s, v, a);
}

extern(C)
ImDrawCmd* ImDrawCmd_ImDrawCmd(){
return emplace( ImNewWrapper(), MemAlloc((ImDrawCmd).sizeof), ImDrawCmd());
}

extern(C)
void ImDrawCmd_destroy(ImDrawCmd* self){
IM_DELETE(self);
}

extern(C)
ImDrawListSplitter* ImDrawListSplitter_ImDrawListSplitter(){
return emplace( ImNewWrapper(), MemAlloc((ImDrawListSplitter).sizeof), ImDrawListSplitter());
}

extern(C)
void ImDrawListSplitter_destroy(ImDrawListSplitter* self){
IM_DELETE(self);
}

extern(C)
void ImDrawListSplitter_Clear(ImDrawListSplitter* self){
return self.Clear();
}

extern(C)
void ImDrawListSplitter_ClearFreeMemory(ImDrawListSplitter* self){
return self.ClearFreeMemory();
}

extern(C)
void ImDrawListSplitter_Split(ImDrawListSplitter* self, ImDrawList* draw_list, int count){
return self.Split(draw_list, count);
}

extern(C)
void ImDrawListSplitter_Merge(ImDrawListSplitter* self, ImDrawList* draw_list){
return self.Merge(draw_list);
}

extern(C)
void ImDrawListSplitter_SetCurrentChannel(ImDrawListSplitter* self, ImDrawList* draw_list, int channel_idx){
return self.SetCurrentChannel(draw_list, channel_idx);
}

extern(C)
ImDrawList* ImDrawList_ImDrawList(const(ImDrawListSharedData)* shared_data){
return emplace( ImNewWrapper(), MemAlloc((ImDrawList).sizeof), ImDrawList(shared_data));
}

extern(C)
void ImDrawList_destroy(ImDrawList* self){
IM_DELETE(self);
}

extern(C)
void ImDrawList_PushClipRect(ImDrawList* self, ImVec2 clip_rect_min, ImVec2 clip_rect_max, bool intersect_with_current_clip_rect){
return self.PushClipRect(clip_rect_min, clip_rect_max, intersect_with_current_clip_rect);
}

extern(C)
void ImDrawList_PushClipRectFullScreen(ImDrawList* self){
return self.PushClipRectFullScreen();
}

extern(C)
void ImDrawList_PopClipRect(ImDrawList* self){
return self.PopClipRect();
}

extern(C)
void ImDrawList_PushTextureID(ImDrawList* self, void* texture_id){
return self.PushTextureID(texture_id);
}

extern(C)
void ImDrawList_PopTextureID(ImDrawList* self){
return self.PopTextureID();
}

extern(C)
void ImDrawList_GetClipRectMin(ImVec2* pOut, ImDrawList* self){
*pOut = self.GetClipRectMin();
}

extern(C)
void ImDrawList_GetClipRectMax(ImVec2* pOut, ImDrawList* self){
*pOut = self.GetClipRectMax();
}

extern(C)
void ImDrawList_AddLine(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImU32 col, float thickness){
return self.AddLine(p1, p2, col, thickness);
}

extern(C)
void ImDrawList_AddRect(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col, float rounding, ImDrawCornerFlags rounding_corners, float thickness){
return self.AddRect(p_min, p_max, col, rounding, rounding_corners, thickness);
}

extern(C)
void ImDrawList_AddRectFilled(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col, float rounding, ImDrawCornerFlags rounding_corners){
return self.AddRectFilled(p_min, p_max, col, rounding, rounding_corners);
}

extern(C)
void ImDrawList_AddRectFilledMultiColor(ImDrawList* self, ImVec2 p_min, ImVec2 p_max, ImU32 col_upr_left, ImU32 col_upr_right, ImU32 col_bot_right, ImU32 col_bot_left){
return self.AddRectFilledMultiColor(p_min, p_max, col_upr_left, col_upr_right, col_bot_right, col_bot_left);
}

extern(C)
void ImDrawList_AddQuad(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col, float thickness){
return self.AddQuad(p1, p2, p3, p4, col, thickness);
}

extern(C)
void ImDrawList_AddQuadFilled(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col){
return self.AddQuadFilled(p1, p2, p3, p4, col);
}

extern(C)
void ImDrawList_AddTriangle(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImU32 col, float thickness){
return self.AddTriangle(p1, p2, p3, col, thickness);
}

extern(C)
void ImDrawList_AddTriangleFilled(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImU32 col){
return self.AddTriangleFilled(p1, p2, p3, col);
}

extern(C)
void ImDrawList_AddCircle(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments, float thickness){
return self.AddCircle(center, radius, col, num_segments, thickness);
}

extern(C)
void ImDrawList_AddCircleFilled(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments){
return self.AddCircleFilled(center, radius, col, num_segments);
}

extern(C)
void ImDrawList_AddNgon(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments, float thickness){
return self.AddNgon(center, radius, col, num_segments, thickness);
}

extern(C)
void ImDrawList_AddNgonFilled(ImDrawList* self, ImVec2 center, float radius, ImU32 col, int num_segments){
return self.AddNgonFilled(center, radius, col, num_segments);
}

extern(C)
void ImDrawList_AddTextVec2(ImDrawList* self, ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end){
return self.AddText(pos, col, text_begin, text_end);
}

extern(C)
void ImDrawList_AddTextFontPtr(ImDrawList* self, const(ImFont)* font, float font_size, ImVec2 pos, ImU32 col, const(char)* text_begin, const(char)* text_end, float wrap_width, const(ImVec4)* cpu_fine_clip_rect){
return self.AddText(font, font_size, pos, col, text_begin, text_end, wrap_width, cpu_fine_clip_rect);
}

extern(C)
void ImDrawList_AddPolyline(ImDrawList* self, const(ImVec2)* points, int num_points, ImU32 col, bool closed, float thickness){
return self.AddPolyline(points, num_points, col, closed, thickness);
}

extern(C)
void ImDrawList_AddConvexPolyFilled(ImDrawList* self, const(ImVec2)* points, int num_points, ImU32 col){
return self.AddConvexPolyFilled(points, num_points, col);
}

extern(C)
void ImDrawList_AddBezierCurve(ImDrawList* self, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImU32 col, float thickness, int num_segments){
return self.AddBezierCurve(p1, p2, p3, p4, col, thickness, num_segments);
}

extern(C)
void ImDrawList_AddImage(ImDrawList* self, void* user_texture_id, ImVec2 p_min, ImVec2 p_max, ImVec2 uv_min, ImVec2 uv_max, ImU32 col){
return self.AddImage(user_texture_id, p_min, p_max, uv_min, uv_max, col);
}

extern(C)
void ImDrawList_AddImageQuad(ImDrawList* self, void* user_texture_id, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 uv1, ImVec2 uv2, ImVec2 uv3, ImVec2 uv4, ImU32 col){
return self.AddImageQuad(user_texture_id, p1, p2, p3, p4, uv1, uv2, uv3, uv4, col);
}

extern(C)
void ImDrawList_AddImageRounded(ImDrawList* self, void* user_texture_id, ImVec2 p_min, ImVec2 p_max, ImVec2 uv_min, ImVec2 uv_max, ImU32 col, float rounding, ImDrawCornerFlags rounding_corners){
return self.AddImageRounded(user_texture_id, p_min, p_max, uv_min, uv_max, col, rounding, rounding_corners);
}

extern(C)
void ImDrawList_PathClear(ImDrawList* self){
return self.PathClear();
}

extern(C)
void ImDrawList_PathLineTo(ImDrawList* self, ImVec2 pos){
return self.PathLineTo(pos);
}

extern(C)
void ImDrawList_PathLineToMergeDuplicate(ImDrawList* self, ImVec2 pos){
return self.PathLineToMergeDuplicate(pos);
}

extern(C)
void ImDrawList_PathFillConvex(ImDrawList* self, ImU32 col){
return self.PathFillConvex(col);
}

extern(C)
void ImDrawList_PathStroke(ImDrawList* self, ImU32 col, bool closed, float thickness){
return self.PathStroke(col, closed, thickness);
}

extern(C)
void ImDrawList_PathArcTo(ImDrawList* self, ImVec2 center, float radius, float a_min, float a_max, int num_segments){
return self.PathArcTo(center, radius, a_min, a_max, num_segments);
}

extern(C)
void ImDrawList_PathArcToFast(ImDrawList* self, ImVec2 center, float radius, int a_min_of_12, int a_max_of_12){
return self.PathArcToFast(center, radius, a_min_of_12, a_max_of_12);
}

extern(C)
void ImDrawList_PathBezierCurveTo(ImDrawList* self, ImVec2 p2, ImVec2 p3, ImVec2 p4, int num_segments){
return self.PathBezierCurveTo(p2, p3, p4, num_segments);
}

extern(C)
void ImDrawList_PathRect(ImDrawList* self, ImVec2 rect_min, ImVec2 rect_max, float rounding, ImDrawCornerFlags rounding_corners){
return self.PathRect(rect_min, rect_max, rounding, rounding_corners);
}

extern(C)
void ImDrawList_AddCallback(ImDrawList* self, void function(const(ImDrawList)*, const(ImDrawCmd)*) callback, void* callback_data){
return self.AddCallback(callback, callback_data);
}

extern(C)
void ImDrawList_AddDrawCmd(ImDrawList* self){
return self.AddDrawCmd();
}

extern(C)
ImDrawList* ImDrawList_CloneOutput(ImDrawList* self){
return self.CloneOutput();
}

extern(C)
void ImDrawList_ChannelsSplit(ImDrawList* self, int count){
return self.ChannelsSplit(count);
}

extern(C)
void ImDrawList_ChannelsMerge(ImDrawList* self){
return self.ChannelsMerge();
}

extern(C)
void ImDrawList_ChannelsSetCurrent(ImDrawList* self, int n){
return self.ChannelsSetCurrent(n);
}

extern(C)
void ImDrawList_PrimReserve(ImDrawList* self, int idx_count, int vtx_count){
return self.PrimReserve(idx_count, vtx_count);
}

extern(C)
void ImDrawList_PrimUnreserve(ImDrawList* self, int idx_count, int vtx_count){
return self.PrimUnreserve(idx_count, vtx_count);
}

extern(C)
void ImDrawList_PrimRect(ImDrawList* self, ImVec2 a, ImVec2 b, ImU32 col){
return self.PrimRect(a, b, col);
}

extern(C)
void ImDrawList_PrimRectUV(ImDrawList* self, ImVec2 a, ImVec2 b, ImVec2 uv_a, ImVec2 uv_b, ImU32 col){
return self.PrimRectUV(a, b, uv_a, uv_b, col);
}

extern(C)
void ImDrawList_PrimQuadUV(ImDrawList* self, ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 d, ImVec2 uv_a, ImVec2 uv_b, ImVec2 uv_c, ImVec2 uv_d, ImU32 col){
return self.PrimQuadUV(a, b, c, d, uv_a, uv_b, uv_c, uv_d, col);
}

extern(C)
void ImDrawList_PrimWriteVtx(ImDrawList* self, ImVec2 pos, ImVec2 uv, ImU32 col){
return self.PrimWriteVtx(pos, uv, col);
}

extern(C)
void ImDrawList_PrimWriteIdx(ImDrawList* self, ImDrawIdx idx){
return self.PrimWriteIdx(idx);
}

extern(C)
void ImDrawList_PrimVtx(ImDrawList* self, ImVec2 pos, ImVec2 uv, ImU32 col){
return self.PrimVtx(pos, uv, col);
}

extern(C)
void ImDrawList__ResetForNewFrame(ImDrawList* self){
return self._ResetForNewFrame();
}

extern(C)
void ImDrawList__ClearFreeMemory(ImDrawList* self){
return self._ClearFreeMemory();
}

extern(C)
void ImDrawList__PopUnusedDrawCmd(ImDrawList* self){
return self._PopUnusedDrawCmd();
}

extern(C)
void ImDrawList__OnChangedClipRect(ImDrawList* self){
return self._OnChangedClipRect();
}

extern(C)
void ImDrawList__OnChangedTextureID(ImDrawList* self){
return self._OnChangedTextureID();
}

extern(C)
void ImDrawList__OnChangedVtxOffset(ImDrawList* self){
return self._OnChangedVtxOffset();
}

extern(C)
ImDrawData* ImDrawData_ImDrawData(){
return emplace( ImNewWrapper(), MemAlloc((ImDrawData).sizeof), ImDrawData());
}

extern(C)
void ImDrawData_destroy(ImDrawData* self){
IM_DELETE(self);
}

extern(C)
void ImDrawData_Clear(ImDrawData* self){
return self.Clear();
}

extern(C)
void ImDrawData_DeIndexAllBuffers(ImDrawData* self){
return self.DeIndexAllBuffers();
}

extern(C)
void ImDrawData_ScaleClipRects(ImDrawData* self, ImVec2 fb_scale){
return self.ScaleClipRects(fb_scale);
}

extern(C)
ImFontConfig* ImFontConfig_ImFontConfig(){
return emplace( ImNewWrapper(), MemAlloc((ImFontConfig).sizeof), ImFontConfig());
}

extern(C)
void ImFontConfig_destroy(ImFontConfig* self){
IM_DELETE(self);
}

extern(C)
ImFontGlyphRangesBuilder* ImFontGlyphRangesBuilder_ImFontGlyphRangesBuilder(){
return emplace( ImNewWrapper(), MemAlloc((ImFontGlyphRangesBuilder).sizeof), ImFontGlyphRangesBuilder());
}

extern(C)
void ImFontGlyphRangesBuilder_destroy(ImFontGlyphRangesBuilder* self){
IM_DELETE(self);
}

extern(C)
void ImFontGlyphRangesBuilder_Clear(ImFontGlyphRangesBuilder* self){
return self.Clear();
}

extern(C)
bool ImFontGlyphRangesBuilder_GetBit(ImFontGlyphRangesBuilder* self, size_t n){
return self.GetBit(n);
}

extern(C)
void ImFontGlyphRangesBuilder_SetBit(ImFontGlyphRangesBuilder* self, size_t n){
return self.SetBit(n);
}

extern(C)
void ImFontGlyphRangesBuilder_AddChar(ImFontGlyphRangesBuilder* self, ImWchar c){
return self.AddChar(c);
}

extern(C)
void ImFontGlyphRangesBuilder_AddText(ImFontGlyphRangesBuilder* self, const(char)* text, const(char)* text_end){
return self.AddText(text, text_end);
}

extern(C)
void ImFontGlyphRangesBuilder_AddRanges(ImFontGlyphRangesBuilder* self, const(ImWchar)* ranges){
return self.AddRanges(ranges);
}

extern(C)
void ImFontGlyphRangesBuilder_BuildRanges(ImFontGlyphRangesBuilder* self, ImVector_ImWchar* out_ranges){
return self.BuildRanges(out_ranges);
}

extern(C)
ImFontAtlasCustomRect* ImFontAtlasCustomRect_ImFontAtlasCustomRect(){
return emplace( ImNewWrapper(), MemAlloc((ImFontAtlasCustomRect).sizeof), ImFontAtlasCustomRect());
}

extern(C)
void ImFontAtlasCustomRect_destroy(ImFontAtlasCustomRect* self){
IM_DELETE(self);
}

extern(C)
bool ImFontAtlasCustomRect_IsPacked(ImFontAtlasCustomRect* self){
return self.IsPacked();
}

extern(C)
ImFontAtlas* ImFontAtlas_ImFontAtlas(){
return emplace( ImNewWrapper(), MemAlloc((ImFontAtlas).sizeof), ImFontAtlas());
}

extern(C)
void ImFontAtlas_destroy(ImFontAtlas* self){
IM_DELETE(self);
}

extern(C)
ImFont* ImFontAtlas_AddFont(ImFontAtlas* self, const(ImFontConfig)* font_cfg){
return self.AddFont(font_cfg);
}

extern(C)
ImFont* ImFontAtlas_AddFontDefault(ImFontAtlas* self, const(ImFontConfig)* font_cfg){
return self.AddFontDefault(font_cfg);
}

extern(C)
ImFont* ImFontAtlas_AddFontFromFileTTF(ImFontAtlas* self, const(char)* filename, float size_pixels, const(ImFontConfig)* font_cfg, const(ImWchar)* glyph_ranges){
return self.AddFontFromFileTTF(filename, size_pixels, font_cfg, glyph_ranges);
}

extern(C)
ImFont* ImFontAtlas_AddFontFromMemoryTTF(ImFontAtlas* self, void* font_data, int font_size, float size_pixels, const(ImFontConfig)* font_cfg, const(ImWchar)* glyph_ranges){
return self.AddFontFromMemoryTTF(font_data, font_size, size_pixels, font_cfg, glyph_ranges);
}

extern(C)
ImFont* ImFontAtlas_AddFontFromMemoryCompressedTTF(ImFontAtlas* self, const(void)* compressed_font_data, int compressed_font_size, float size_pixels, const(ImFontConfig)* font_cfg, const(ImWchar)* glyph_ranges){
return self.AddFontFromMemoryCompressedTTF(compressed_font_data, compressed_font_size, size_pixels, font_cfg, glyph_ranges);
}

extern(C)
ImFont* ImFontAtlas_AddFontFromMemoryCompressedBase85TTF(ImFontAtlas* self, const(char)* compressed_font_data_base85, float size_pixels, const(ImFontConfig)* font_cfg, const(ImWchar)* glyph_ranges){
return self.AddFontFromMemoryCompressedBase85TTF(compressed_font_data_base85, size_pixels, font_cfg, glyph_ranges);
}

extern(C)
void ImFontAtlas_ClearInputData(ImFontAtlas* self){
return self.ClearInputData();
}

extern(C)
void ImFontAtlas_ClearTexData(ImFontAtlas* self){
return self.ClearTexData();
}

extern(C)
void ImFontAtlas_ClearFonts(ImFontAtlas* self){
return self.ClearFonts();
}

extern(C)
void ImFontAtlas_Clear(ImFontAtlas* self){
return self.Clear();
}

extern(C)
bool ImFontAtlas_Build(ImFontAtlas* self){
return self.Build();
}

extern(C)
void ImFontAtlas_GetTexDataAsAlpha8(ImFontAtlas* self, ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel){
return self.GetTexDataAsAlpha8(out_pixels, out_width, out_height, out_bytes_per_pixel);
}

extern(C)
void ImFontAtlas_GetTexDataAsRGBA32(ImFontAtlas* self, ubyte** out_pixels, int* out_width, int* out_height, int* out_bytes_per_pixel){
return self.GetTexDataAsRGBA32(out_pixels, out_width, out_height, out_bytes_per_pixel);
}

extern(C)
bool ImFontAtlas_IsBuilt(ImFontAtlas* self){
return self.IsBuilt();
}

extern(C)
void ImFontAtlas_SetTexID(ImFontAtlas* self, void* id){
return self.SetTexID(id);
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesDefault(ImFontAtlas* self){
return self.GetGlyphRangesDefault();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesKorean(ImFontAtlas* self){
return self.GetGlyphRangesKorean();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesJapanese(ImFontAtlas* self){
return self.GetGlyphRangesJapanese();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesChineseFull(ImFontAtlas* self){
return self.GetGlyphRangesChineseFull();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesChineseSimplifiedCommon(ImFontAtlas* self){
return self.GetGlyphRangesChineseSimplifiedCommon();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesCyrillic(ImFontAtlas* self){
return self.GetGlyphRangesCyrillic();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesThai(ImFontAtlas* self){
return self.GetGlyphRangesThai();
}

extern(C)
const(ImWchar)* ImFontAtlas_GetGlyphRangesVietnamese(ImFontAtlas* self){
return self.GetGlyphRangesVietnamese();
}

extern(C)
int ImFontAtlas_AddCustomRectRegular(ImFontAtlas* self, int width, int height){
return self.AddCustomRectRegular(width, height);
}

extern(C)
int ImFontAtlas_AddCustomRectFontGlyph(ImFontAtlas* self, ImFont* font, ImWchar id, int width, int height, float advance_x, ImVec2 offset){
return self.AddCustomRectFontGlyph(font, id, width, height, advance_x, offset);
}

extern(C)
ImFontAtlasCustomRect* ImFontAtlas_GetCustomRectByIndex(ImFontAtlas* self, int index){
return self.GetCustomRectByIndex(index);
}

extern(C)
void ImFontAtlas_CalcCustomRectUV(ImFontAtlas* self, const(ImFontAtlasCustomRect)* rect, ImVec2* out_uv_min, ImVec2* out_uv_max){
return self.CalcCustomRectUV(rect, out_uv_min, out_uv_max);
}

extern(C)
bool ImFontAtlas_GetMouseCursorTexData(ImFontAtlas* self, ImGuiMouseCursor cursor, ImVec2* out_offset, ImVec2* out_size, ImVec2* out_uv_border, ImVec2* out_uv_fill){
return self.GetMouseCursorTexData(cursor, out_offset, out_size, out_uv_border, out_uv_fill);
}

extern(C)
ImFont* ImFont_ImFont(){
return emplace( ImNewWrapper(), MemAlloc((ImFont).sizeof), ImFont());
}

extern(C)
void ImFont_destroy(ImFont* self){
IM_DELETE(self);
}

extern(C)
const(ImFontGlyph)* ImFont_FindGlyph(ImFont* self, ImWchar c){
return self.FindGlyph(c);
}

extern(C)
const(ImFontGlyph)* ImFont_FindGlyphNoFallback(ImFont* self, ImWchar c){
return self.FindGlyphNoFallback(c);
}

extern(C)
float ImFont_GetCharAdvance(ImFont* self, ImWchar c){
return self.GetCharAdvance(c);
}

extern(C)
bool ImFont_IsLoaded(ImFont* self){
return self.IsLoaded();
}

extern(C)
const(char)* ImFont_GetDebugName(ImFont* self){
return self.GetDebugName();
}

extern(C)
void ImFont_CalcTextSizeA(ImVec2* pOut, ImFont* self, float size, float max_width, float wrap_width, const(char)* text_begin, const(char)* text_end, const(char)** remaining){
*pOut = self.CalcTextSizeA(size, max_width, wrap_width, text_begin, text_end, remaining);
}

extern(C)
const(char)* ImFont_CalcWordWrapPositionA(ImFont* self, float scale, const(char)* text, const(char)* text_end, float wrap_width){
return self.CalcWordWrapPositionA(scale, text, text_end, wrap_width);
}

extern(C)
void ImFont_RenderChar(ImFont* self, ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ImWchar c){
return self.RenderChar(draw_list, size, pos, col, c);
}

extern(C)
void ImFont_RenderText(ImFont* self, ImDrawList* draw_list, float size, ImVec2 pos, ImU32 col, ImVec4 clip_rect, const(char)* text_begin, const(char)* text_end, float wrap_width, bool cpu_fine_clip){
return self.RenderText(draw_list, size, pos, col, clip_rect, text_begin, text_end, wrap_width, cpu_fine_clip);
}

extern(C)
void ImFont_BuildLookupTable(ImFont* self){
return self.BuildLookupTable();
}

extern(C)
void ImFont_ClearOutputData(ImFont* self){
return self.ClearOutputData();
}

extern(C)
void ImFont_GrowIndex(ImFont* self, int new_size){
return self.GrowIndex(new_size);
}

extern(C)
void ImFont_AddGlyph(ImFont* self, ImFontConfig* src_cfg, ImWchar c, float x0, float y0, float x1, float y1, float u0, float v0, float u1, float v1, float advance_x){
return self.AddGlyph(src_cfg, c, x0, y0, x1, y1, u0, v0, u1, v1, advance_x);
}

extern(C)
void ImFont_AddRemapChar(ImFont* self, ImWchar dst, ImWchar src, bool overwrite_dst){
return self.AddRemapChar(dst, src, overwrite_dst);
}

extern(C)
void ImFont_SetGlyphVisible(ImFont* self, ImWchar c, bool visible){
return self.SetGlyphVisible(c, visible);
}

extern(C)
void ImFont_SetFallbackChar(ImFont* self, ImWchar c){
return self.SetFallbackChar(c);
}

extern(C)
bool ImFont_IsGlyphRangeUnused(ImFont* self, uint c_begin, uint c_last){
return self.IsGlyphRangeUnused(c_begin, c_last);
}

extern(C)
ImU32 igImHashData(const(void)* data, size_t data_size, ImU32 seed){
return ImHashData(data, data_size, seed);
}

extern(C)
ImU32 igImHashStr(const(char)* data, size_t data_size, ImU32 seed){
return ImHashStr(data, data_size, seed);
}

extern(C)
ImU32 igImAlphaBlendColors(ImU32 col_a, ImU32 col_b){
return ImAlphaBlendColors(col_a, col_b);
}

extern(C)
bool igImIsPowerOfTwo(int v){
return ImIsPowerOfTwo(v);
}

extern(C)
int igImUpperPowerOfTwo(int v){
return ImUpperPowerOfTwo(v);
}

extern(C)
int igImStricmp(const(char)* str1, const(char)* str2){
return ImStricmp(str1, str2);
}

extern(C)
int igImStrnicmp(const(char)* str1, const(char)* str2, size_t count){
return ImStrnicmp(str1, str2, count);
}

extern(C)
void igImStrncpy(char* dst, const(char)* src, size_t count){
return ImStrncpy(dst, src, count);
}

extern(C)
char* igImStrdup(const(char)* str){
return ImStrdup(str);
}

extern(C)
char* igImStrdupcpy(char* dst, size_t* p_dst_size, const(char)* str){
return ImStrdupcpy(dst, p_dst_size, str);
}

extern(C)
const(char)* igImStrchrRange(const(char)* str_begin, const(char)* str_end, char c){
return ImStrchrRange(str_begin, str_end, c);
}

extern(C)
int igImStrlenW(const(ImWchar)* str){
return ImStrlenW(str);
}

extern(C)
const(char)* igImStreolRange(const(char)* str, const(char)* str_end){
return ImStreolRange(str, str_end);
}

extern(C)
const(ImWchar)* igImStrbolW(const(ImWchar)* buf_mid_line, const(ImWchar)* buf_begin){
return ImStrbolW(buf_mid_line, buf_begin);
}

extern(C)
const(char)* igImStristr(const(char)* haystack, const(char)* haystack_end, const(char)* needle, const(char)* needle_end){
return ImStristr(haystack, haystack_end, needle, needle_end);
}

extern(C)
void igImStrTrimBlanks(char* str){
return ImStrTrimBlanks(str);
}

extern(C)
const(char)* igImStrSkipBlank(const(char)* str){
return ImStrSkipBlank(str);
}

extern(C)
int igImFormatString(char* buf, size_t buf_size, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
int ret = ImFormatStringV(buf, buf_size, fmt, args);
(args = cast(char*)0);
return ret;
}

extern(C)
int igImFormatStringV(char* buf, size_t buf_size, const(char)* fmt, char* args){
return ImFormatStringV(buf, buf_size, fmt, args);
}

extern(C)
const(char)* igImParseFormatFindStart(const(char)* format){
return ImParseFormatFindStart(format);
}

extern(C)
const(char)* igImParseFormatFindEnd(const(char)* format){
return ImParseFormatFindEnd(format);
}

extern(C)
const(char)* igImParseFormatTrimDecorations(const(char)* format, char* buf, size_t buf_size){
return ImParseFormatTrimDecorations(format, buf, buf_size);
}

extern(C)
int igImParseFormatPrecision(const(char)* format, int default_value){
return ImParseFormatPrecision(format, default_value);
}

extern(C)
bool igImCharIsBlankA(char c){
return ImCharIsBlankA(c);
}

extern(C)
bool igImCharIsBlankW(uint c){
return ImCharIsBlankW(c);
}

extern(C)
int igImTextStrToUtf8(char* buf, int buf_size, const(ImWchar)* in_text, const(ImWchar)* in_text_end){
return ImTextStrToUtf8(buf, buf_size, in_text, in_text_end);
}

extern(C)
int igImTextCharFromUtf8(uint* out_char, const(char)* in_text, const(char)* in_text_end){
return ImTextCharFromUtf8(out_char, in_text, in_text_end);
}

extern(C)
int igImTextStrFromUtf8(ImWchar* buf, int buf_size, const(char)* in_text, const(char)* in_text_end, const(char)** in_remaining){
return ImTextStrFromUtf8(buf, buf_size, in_text, in_text_end, in_remaining);
}

extern(C)
int igImTextCountCharsFromUtf8(const(char)* in_text, const(char)* in_text_end){
return ImTextCountCharsFromUtf8(in_text, in_text_end);
}

extern(C)
int igImTextCountUtf8BytesFromChar(const(char)* in_text, const(char)* in_text_end){
return ImTextCountUtf8BytesFromChar(in_text, in_text_end);
}

extern(C)
int igImTextCountUtf8BytesFromStr(const(ImWchar)* in_text, const(ImWchar)* in_text_end){
return ImTextCountUtf8BytesFromStr(in_text, in_text_end);
}

extern(C)
FILE* igImFileOpen(const(char)* filename, const(char)* mode){
return ImFileOpen(filename, mode);
}

extern(C)
bool igImFileClose(FILE* file){
return ImFileClose(file);
}

extern(C)
ImU64 igImFileGetSize(FILE* file){
return ImFileGetSize(file);
}

extern(C)
ImU64 igImFileRead(void* data, ImU64 size, ImU64 count, FILE* file){
return ImFileRead(data, size, count, file);
}

extern(C)
ImU64 igImFileWrite(const(void)* data, ImU64 size, ImU64 count, FILE* file){
return ImFileWrite(data, size, count, file);
}

extern(C)
void* igImFileLoadToMemory(const(char)* filename, const(char)* mode, size_t* out_file_size, int padding_bytes){
return ImFileLoadToMemory(filename, mode, out_file_size, padding_bytes);
}

extern(C)
float igImPowFloat(float x, float y){
return ImPow(x, y);
}

extern(C)
double igImPowdouble(double x, double y){
return ImPow(x, y);
}

extern(C)
float igImLogFloat(float x){
return ImLog(x);
}

extern(C)
double igImLogdouble(double x){
return ImLog(x);
}

extern(C)
float igImAbsFloat(float x){
return ImAbs(x);
}

extern(C)
double igImAbsdouble(double x){
return ImAbs(x);
}

extern(C)
float igImSignFloat(float x){
return ImSign(x);
}

extern(C)
double igImSigndouble(double x){
return ImSign(x);
}

extern(C)
void igImMin(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs){
*pOut = ImMin(lhs, rhs);
}

extern(C)
void igImMax(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs){
*pOut = ImMax(lhs, rhs);
}

extern(C)
void igImClamp(ImVec2* pOut, ImVec2 v, ImVec2 mn, ImVec2 mx){
*pOut = ImClamp(v, mn, mx);
}

extern(C)
void igImLerpVec2Float(ImVec2* pOut, ImVec2 a, ImVec2 b, float t){
*pOut = ImLerp(a, b, t);
}

extern(C)
void igImLerpVec2Vec2(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 t){
*pOut = ImLerp(a, b, t);
}

extern(C)
void igImLerpVec4(ImVec4* pOut, ImVec4 a, ImVec4 b, float t){
*pOut = ImLerp(a, b, t);
}

extern(C)
float igImSaturate(float f){
return ImSaturate(f);
}

extern(C)
float igImLengthSqrVec2(ImVec2 lhs){
return ImLengthSqr(lhs);
}

extern(C)
float igImLengthSqrVec4(ImVec4 lhs){
return ImLengthSqr(lhs);
}

extern(C)
float igImInvLength(ImVec2 lhs, float fail_value){
return ImInvLength(lhs, fail_value);
}

extern(C)
float igImFloorFloat(float f){
return ImFloor(f);
}

extern(C)
void igImFloorVec2(ImVec2* pOut, ImVec2 v){
*pOut = ImFloor(v);
}

extern(C)
int igImModPositive(int a, int b){
return ImModPositive(a, b);
}

extern(C)
float igImDot(ImVec2 a, ImVec2 b){
return ImDot(a, b);
}

extern(C)
void igImRotate(ImVec2* pOut, ImVec2 v, float cos_a, float sin_a){
*pOut = ImRotate(v, cos_a, sin_a);
}

extern(C)
float igImLinearSweep(float current, float target, float speed){
return ImLinearSweep(current, target, speed);
}

extern(C)
void igImMul(ImVec2* pOut, ImVec2 lhs, ImVec2 rhs){
*pOut = ImMul(lhs, rhs);
}

extern(C)
void igImBezierCalc(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, float t){
*pOut = ImBezierCalc(p1, p2, p3, p4, t);
}

extern(C)
void igImBezierClosestPoint(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 p, int num_segments){
*pOut = ImBezierClosestPoint(p1, p2, p3, p4, p, num_segments);
}

extern(C)
void igImBezierClosestPointCasteljau(ImVec2* pOut, ImVec2 p1, ImVec2 p2, ImVec2 p3, ImVec2 p4, ImVec2 p, float tess_tol){
*pOut = ImBezierClosestPointCasteljau(p1, p2, p3, p4, p, tess_tol);
}

extern(C)
void igImLineClosestPoint(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 p){
*pOut = ImLineClosestPoint(a, b, p);
}

extern(C)
bool igImTriangleContainsPoint(ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p){
return ImTriangleContainsPoint(a, b, c, p);
}

extern(C)
void igImTriangleClosestPoint(ImVec2* pOut, ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p){
*pOut = ImTriangleClosestPoint(a, b, c, p);
}

extern(C)
void igImTriangleBarycentricCoords(ImVec2 a, ImVec2 b, ImVec2 c, ImVec2 p, float* out_u, float* out_v, float* out_w){
return ImTriangleBarycentricCoords(a, b, c, p, *out_u, *out_v, *out_w);
}

extern(C)
float igImTriangleArea(ImVec2 a, ImVec2 b, ImVec2 c){
return ImTriangleArea(a, b, c);
}

extern(C)
ImGuiDir igImGetDirQuadrantFromDelta(float dx, float dy){
return ImGetDirQuadrantFromDelta(dx, dy);
}

extern(C)
ImVec1* ImVec1_ImVec1Nil(){
return emplace( ImNewWrapper(), MemAlloc((ImVec1).sizeof), ImVec1());
}

extern(C)
void ImVec1_destroy(ImVec1* self){
IM_DELETE(self);
}

extern(C)
ImVec1* ImVec1_ImVec1Float(float _x){
return emplace( ImNewWrapper(), MemAlloc((ImVec1).sizeof), ImVec1(_x));
}

extern(C)
ImVec2ih* ImVec2ih_ImVec2ihNil(){
return emplace( ImNewWrapper(), MemAlloc((ImVec2ih).sizeof), ImVec2ih());
}

extern(C)
void ImVec2ih_destroy(ImVec2ih* self){
IM_DELETE(self);
}

extern(C)
ImVec2ih* ImVec2ih_ImVec2ihshort(short _x, short _y){
return emplace( ImNewWrapper(), MemAlloc((ImVec2ih).sizeof), ImVec2ih(_x, _y));
}

extern(C)
ImVec2ih* ImVec2ih_ImVec2ihVec2(ImVec2 rhs){
return emplace( ImNewWrapper(), MemAlloc((ImVec2ih).sizeof), ImVec2ih(rhs));
}

extern(C)
ImRect* ImRect_ImRectNil(){
return emplace( ImNewWrapper(), MemAlloc((ImRect).sizeof), ImRect());
}

extern(C)
void ImRect_destroy(ImRect* self){
IM_DELETE(self);
}

extern(C)
ImRect* ImRect_ImRectVec2(ImVec2 min, ImVec2 max){
return emplace( ImNewWrapper(), MemAlloc((ImRect).sizeof), ImRect(min, max));
}

extern(C)
ImRect* ImRect_ImRectVec4(ImVec4 v){
return emplace( ImNewWrapper(), MemAlloc((ImRect).sizeof), ImRect(v));
}

extern(C)
ImRect* ImRect_ImRectFloat(float x1, float y1, float x2, float y2){
return emplace( ImNewWrapper(), MemAlloc((ImRect).sizeof), ImRect(x1, y1, x2, y2));
}

extern(C)
void ImRect_GetCenter(ImVec2* pOut, ImRect* self){
*pOut = self.GetCenter();
}

extern(C)
void ImRect_GetSize(ImVec2* pOut, ImRect* self){
*pOut = self.GetSize();
}

extern(C)
float ImRect_GetWidth(ImRect* self){
return self.GetWidth();
}

extern(C)
float ImRect_GetHeight(ImRect* self){
return self.GetHeight();
}

extern(C)
void ImRect_GetTL(ImVec2* pOut, ImRect* self){
*pOut = self.GetTL();
}

extern(C)
void ImRect_GetTR(ImVec2* pOut, ImRect* self){
*pOut = self.GetTR();
}

extern(C)
void ImRect_GetBL(ImVec2* pOut, ImRect* self){
*pOut = self.GetBL();
}

extern(C)
void ImRect_GetBR(ImVec2* pOut, ImRect* self){
*pOut = self.GetBR();
}

extern(C)
bool ImRect_ContainsVec2(ImRect* self, ImVec2 p){
return self.Contains(p);
}

extern(C)
bool ImRect_ContainsRect(ImRect* self, ImRect r){
return self.Contains(r);
}

extern(C)
bool ImRect_Overlaps(ImRect* self, ImRect r){
return self.Overlaps(r);
}

extern(C)
void ImRect_AddVec2(ImRect* self, ImVec2 p){
return self.Add(p);
}

extern(C)
void ImRect_AddRect(ImRect* self, ImRect r){
return self.Add(r);
}

extern(C)
void ImRect_ExpandFloat(ImRect* self, const float amount){
return self.Expand(amount);
}

extern(C)
void ImRect_ExpandVec2(ImRect* self, ImVec2 amount){
return self.Expand(amount);
}

extern(C)
void ImRect_Translate(ImRect* self, ImVec2 d){
return self.Translate(d);
}

extern(C)
void ImRect_TranslateX(ImRect* self, float dx){
return self.TranslateX(dx);
}

extern(C)
void ImRect_TranslateY(ImRect* self, float dy){
return self.TranslateY(dy);
}

extern(C)
void ImRect_ClipWith(ImRect* self, ImRect r){
return self.ClipWith(r);
}

extern(C)
void ImRect_ClipWithFull(ImRect* self, ImRect r){
return self.ClipWithFull(r);
}

extern(C)
void ImRect_Floor(ImRect* self){
return self.Floor();
}

extern(C)
bool ImRect_IsInverted(ImRect* self){
return self.IsInverted();
}

extern(C)
void ImRect_ToVec4(ImVec4* pOut, ImRect* self){
*pOut = self.ToVec4();
}

extern(C)
bool igImBitArrayTestBit(const(ImU32)* arr, int n){
return ImBitArrayTestBit(arr, n);
}

extern(C)
void igImBitArrayClearBit(ImU32* arr, int n){
return ImBitArrayClearBit(arr, n);
}

extern(C)
void igImBitArraySetBit(ImU32* arr, int n){
return ImBitArraySetBit(arr, n);
}

extern(C)
void igImBitArraySetBitRange(ImU32* arr, int n, int n2){
return ImBitArraySetBitRange(arr, n, n2);
}

extern(C)
void ImBitVector_Create(ImBitVector* self, int sz){
return self.Create(sz);
}

extern(C)
void ImBitVector_Clear(ImBitVector* self){
return self.Clear();
}

extern(C)
bool ImBitVector_TestBit(ImBitVector* self, int n){
return self.TestBit(n);
}

extern(C)
void ImBitVector_SetBit(ImBitVector* self, int n){
return self.SetBit(n);
}

extern(C)
void ImBitVector_ClearBit(ImBitVector* self, int n){
return self.ClearBit(n);
}

extern(C)
ImDrawListSharedData* ImDrawListSharedData_ImDrawListSharedData(){
return emplace( ImNewWrapper(), MemAlloc((ImDrawListSharedData).sizeof), ImDrawListSharedData());
}

extern(C)
void ImDrawListSharedData_destroy(ImDrawListSharedData* self){
IM_DELETE(self);
}

extern(C)
void ImDrawListSharedData_SetCircleSegmentMaxError(ImDrawListSharedData* self, float max_error){
return self.SetCircleSegmentMaxError(max_error);
}

extern(C)
void ImDrawDataBuilder_Clear(ImDrawDataBuilder* self){
return self.Clear();
}

extern(C)
void ImDrawDataBuilder_ClearFreeMemory(ImDrawDataBuilder* self){
return self.ClearFreeMemory();
}

extern(C)
void ImDrawDataBuilder_FlattenIntoSingleLayer(ImDrawDataBuilder* self){
return self.FlattenIntoSingleLayer();
}

extern(C)
ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleModInt(ImGuiStyleVar idx, int v){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStyleMod).sizeof), ImGuiStyleMod(idx, v));
}

extern(C)
void ImGuiStyleMod_destroy(ImGuiStyleMod* self){
IM_DELETE(self);
}

extern(C)
ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleModFloat(ImGuiStyleVar idx, float v){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStyleMod).sizeof), ImGuiStyleMod(idx, v));
}

extern(C)
ImGuiStyleMod* ImGuiStyleMod_ImGuiStyleModVec2(ImGuiStyleVar idx, ImVec2 v){
return emplace( ImNewWrapper(), MemAlloc((ImGuiStyleMod).sizeof), ImGuiStyleMod(idx, v));
}

extern(C)
ImGuiMenuColumns* ImGuiMenuColumns_ImGuiMenuColumns(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiMenuColumns).sizeof), ImGuiMenuColumns());
}

extern(C)
void ImGuiMenuColumns_destroy(ImGuiMenuColumns* self){
IM_DELETE(self);
}

extern(C)
void ImGuiMenuColumns_Update(ImGuiMenuColumns* self, int count, float spacing, bool clear){
return self.Update(count, spacing, clear);
}

extern(C)
float ImGuiMenuColumns_DeclColumns(ImGuiMenuColumns* self, float w0, float w1, float w2){
return self.DeclColumns(w0, w1, w2);
}

extern(C)
float ImGuiMenuColumns_CalcExtraSpace(ImGuiMenuColumns* self, float avail_w){
return self.CalcExtraSpace(avail_w);
}

extern(C)
ImGuiInputTextState* ImGuiInputTextState_ImGuiInputTextState(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiInputTextState).sizeof), ImGuiInputTextState());
}

extern(C)
void ImGuiInputTextState_destroy(ImGuiInputTextState* self){
IM_DELETE(self);
}

extern(C)
void ImGuiInputTextState_ClearText(ImGuiInputTextState* self){
return self.ClearText();
}

extern(C)
void ImGuiInputTextState_ClearFreeMemory(ImGuiInputTextState* self){
return self.ClearFreeMemory();
}

extern(C)
int ImGuiInputTextState_GetUndoAvailCount(ImGuiInputTextState* self){
return self.GetUndoAvailCount();
}

extern(C)
int ImGuiInputTextState_GetRedoAvailCount(ImGuiInputTextState* self){
return self.GetRedoAvailCount();
}

extern(C)
void ImGuiInputTextState_OnKeyPressed(ImGuiInputTextState* self, int key){
return self.OnKeyPressed(key);
}

extern(C)
void ImGuiInputTextState_CursorAnimReset(ImGuiInputTextState* self){
return self.CursorAnimReset();
}

extern(C)
void ImGuiInputTextState_CursorClamp(ImGuiInputTextState* self){
return self.CursorClamp();
}

extern(C)
bool ImGuiInputTextState_HasSelection(ImGuiInputTextState* self){
return self.HasSelection();
}

extern(C)
void ImGuiInputTextState_ClearSelection(ImGuiInputTextState* self){
return self.ClearSelection();
}

extern(C)
void ImGuiInputTextState_SelectAll(ImGuiInputTextState* self){
return self.SelectAll();
}

extern(C)
ImGuiPopupData* ImGuiPopupData_ImGuiPopupData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiPopupData).sizeof), ImGuiPopupData());
}

extern(C)
void ImGuiPopupData_destroy(ImGuiPopupData* self){
IM_DELETE(self);
}

extern(C)
ImGuiNavMoveResult* ImGuiNavMoveResult_ImGuiNavMoveResult(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiNavMoveResult).sizeof), ImGuiNavMoveResult());
}

extern(C)
void ImGuiNavMoveResult_destroy(ImGuiNavMoveResult* self){
IM_DELETE(self);
}

extern(C)
void ImGuiNavMoveResult_Clear(ImGuiNavMoveResult* self){
return self.Clear();
}

extern(C)
ImGuiNextWindowData* ImGuiNextWindowData_ImGuiNextWindowData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiNextWindowData).sizeof), ImGuiNextWindowData());
}

extern(C)
void ImGuiNextWindowData_destroy(ImGuiNextWindowData* self){
IM_DELETE(self);
}

extern(C)
void ImGuiNextWindowData_ClearFlags(ImGuiNextWindowData* self){
return self.ClearFlags();
}

extern(C)
ImGuiNextItemData* ImGuiNextItemData_ImGuiNextItemData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiNextItemData).sizeof), ImGuiNextItemData());
}

extern(C)
void ImGuiNextItemData_destroy(ImGuiNextItemData* self){
IM_DELETE(self);
}

extern(C)
void ImGuiNextItemData_ClearFlags(ImGuiNextItemData* self){
return self.ClearFlags();
}

extern(C)
ImGuiPtrOrIndex* ImGuiPtrOrIndex_ImGuiPtrOrIndexPtr(void* ptr){
return emplace( ImNewWrapper(), MemAlloc((ImGuiPtrOrIndex).sizeof), ImGuiPtrOrIndex(ptr));
}

extern(C)
void ImGuiPtrOrIndex_destroy(ImGuiPtrOrIndex* self){
IM_DELETE(self);
}

extern(C)
ImGuiPtrOrIndex* ImGuiPtrOrIndex_ImGuiPtrOrIndexInt(int index){
return emplace( ImNewWrapper(), MemAlloc((ImGuiPtrOrIndex).sizeof), ImGuiPtrOrIndex(index));
}

extern(C)
ImGuiColumnData* ImGuiColumnData_ImGuiColumnData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiColumnData).sizeof), ImGuiColumnData());
}

extern(C)
void ImGuiColumnData_destroy(ImGuiColumnData* self){
IM_DELETE(self);
}

extern(C)
ImGuiColumns* ImGuiColumns_ImGuiColumns(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiColumns).sizeof), ImGuiColumns());
}

extern(C)
void ImGuiColumns_destroy(ImGuiColumns* self){
IM_DELETE(self);
}

extern(C)
void ImGuiColumns_Clear(ImGuiColumns* self){
return self.Clear();
}

extern(C)
ImGuiWindowSettings* ImGuiWindowSettings_ImGuiWindowSettings(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiWindowSettings).sizeof), ImGuiWindowSettings());
}

extern(C)
void ImGuiWindowSettings_destroy(ImGuiWindowSettings* self){
IM_DELETE(self);
}

extern(C)
char* ImGuiWindowSettings_GetName(ImGuiWindowSettings* self){
return self.GetName();
}

extern(C)
ImGuiSettingsHandler* ImGuiSettingsHandler_ImGuiSettingsHandler(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiSettingsHandler).sizeof), ImGuiSettingsHandler());
}

extern(C)
void ImGuiSettingsHandler_destroy(ImGuiSettingsHandler* self){
IM_DELETE(self);
}

extern(C)
ImGuiContext* ImGuiContext_ImGuiContext(ImFontAtlas* shared_font_atlas){
return emplace( ImNewWrapper(), MemAlloc((ImGuiContext).sizeof), ImGuiContext(shared_font_atlas));
}

extern(C)
void ImGuiContext_destroy(ImGuiContext* self){
IM_DELETE(self);
}

extern(C)
ImGuiWindowTempData* ImGuiWindowTempData_ImGuiWindowTempData(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiWindowTempData).sizeof), ImGuiWindowTempData());
}

extern(C)
void ImGuiWindowTempData_destroy(ImGuiWindowTempData* self){
IM_DELETE(self);
}

extern(C)
ImGuiWindow* ImGuiWindow_ImGuiWindow(ImGuiContext* context, const(char)* name){
return emplace( ImNewWrapper(), MemAlloc((ImGuiWindow).sizeof), ImGuiWindow(context, name));
}

extern(C)
void ImGuiWindow_destroy(ImGuiWindow* self){
IM_DELETE(self);
}

extern(C)
ImGuiID ImGuiWindow_GetIDStr(ImGuiWindow* self, const(char)* str, const(char)* str_end){
return self.GetID(str, str_end);
}

extern(C)
ImGuiID ImGuiWindow_GetIDPtr(ImGuiWindow* self, const(void)* ptr){
return self.GetID(ptr);
}

extern(C)
ImGuiID ImGuiWindow_GetIDInt(ImGuiWindow* self, int n){
return self.GetID(n);
}

extern(C)
ImGuiID ImGuiWindow_GetIDNoKeepAliveStr(ImGuiWindow* self, const(char)* str, const(char)* str_end){
return self.GetIDNoKeepAlive(str, str_end);
}

extern(C)
ImGuiID ImGuiWindow_GetIDNoKeepAlivePtr(ImGuiWindow* self, const(void)* ptr){
return self.GetIDNoKeepAlive(ptr);
}

extern(C)
ImGuiID ImGuiWindow_GetIDNoKeepAliveInt(ImGuiWindow* self, int n){
return self.GetIDNoKeepAlive(n);
}

extern(C)
ImGuiID ImGuiWindow_GetIDFromRectangle(ImGuiWindow* self, ImRect r_abs){
return self.GetIDFromRectangle(r_abs);
}

extern(C)
void ImGuiWindow_Rect(ImRect* pOut, ImGuiWindow* self){
*pOut = self.Rect();
}

extern(C)
float ImGuiWindow_CalcFontSize(ImGuiWindow* self){
return self.CalcFontSize();
}

extern(C)
float ImGuiWindow_TitleBarHeight(ImGuiWindow* self){
return self.TitleBarHeight();
}

extern(C)
void ImGuiWindow_TitleBarRect(ImRect* pOut, ImGuiWindow* self){
*pOut = self.TitleBarRect();
}

extern(C)
float ImGuiWindow_MenuBarHeight(ImGuiWindow* self){
return self.MenuBarHeight();
}

extern(C)
void ImGuiWindow_MenuBarRect(ImRect* pOut, ImGuiWindow* self){
*pOut = self.MenuBarRect();
}

extern(C)
ImGuiLastItemDataBackup* ImGuiLastItemDataBackup_ImGuiLastItemDataBackup(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiLastItemDataBackup).sizeof), ImGuiLastItemDataBackup());
}

extern(C)
void ImGuiLastItemDataBackup_destroy(ImGuiLastItemDataBackup* self){
IM_DELETE(self);
}

extern(C)
void ImGuiLastItemDataBackup_Backup(ImGuiLastItemDataBackup* self){
return self.Backup();
}

extern(C)
void ImGuiLastItemDataBackup_Restore(ImGuiLastItemDataBackup* self){
return self.Restore();
}

extern(C)
ImGuiTabItem* ImGuiTabItem_ImGuiTabItem(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTabItem).sizeof), ImGuiTabItem());
}

extern(C)
void ImGuiTabItem_destroy(ImGuiTabItem* self){
IM_DELETE(self);
}

extern(C)
ImGuiTabBar* ImGuiTabBar_ImGuiTabBar(){
return emplace( ImNewWrapper(), MemAlloc((ImGuiTabBar).sizeof), ImGuiTabBar());
}

extern(C)
void ImGuiTabBar_destroy(ImGuiTabBar* self){
IM_DELETE(self);
}

extern(C)
int ImGuiTabBar_GetTabOrder(ImGuiTabBar* self, const(ImGuiTabItem)* tab){
return self.GetTabOrder(tab);
}

extern(C)
const(char)* ImGuiTabBar_GetTabName(ImGuiTabBar* self, const(ImGuiTabItem)* tab){
return self.GetTabName(tab);
}

extern(C)
ImGuiWindow* igGetCurrentWindowRead(){
return GetCurrentWindowRead();
}

extern(C)
ImGuiWindow* igGetCurrentWindow(){
return GetCurrentWindow();
}

extern(C)
ImGuiWindow* igFindWindowByID(ImGuiID id){
return FindWindowByID(id);
}

extern(C)
ImGuiWindow* igFindWindowByName(const(char)* name){
return FindWindowByName(name);
}

extern(C)
void igUpdateWindowParentAndRootLinks(ImGuiWindow* window, ImGuiWindowFlags flags, ImGuiWindow* parent_window){
return UpdateWindowParentAndRootLinks(window, flags, parent_window);
}

extern(C)
void igCalcWindowExpectedSize(ImVec2* pOut, ImGuiWindow* window){
*pOut = CalcWindowExpectedSize(window);
}

extern(C)
bool igIsWindowChildOf(ImGuiWindow* window, ImGuiWindow* potential_parent){
return IsWindowChildOf(window, potential_parent);
}

extern(C)
bool igIsWindowNavFocusable(ImGuiWindow* window){
return IsWindowNavFocusable(window);
}

extern(C)
void igGetWindowAllowedExtentRect(ImRect* pOut, ImGuiWindow* window){
*pOut = GetWindowAllowedExtentRect(window);
}

extern(C)
void igSetWindowPosWindowPtr(ImGuiWindow* window, ImVec2 pos, ImGuiCond cond){
return SetWindowPos(window, pos, cond);
}

extern(C)
void igSetWindowSizeWindowPtr(ImGuiWindow* window, ImVec2 size, ImGuiCond cond){
return SetWindowSize(window, size, cond);
}

extern(C)
void igSetWindowCollapsedWindowPtr(ImGuiWindow* window, bool collapsed, ImGuiCond cond){
return SetWindowCollapsed(window, collapsed, cond);
}

extern(C)
void igSetWindowHitTestHole(ImGuiWindow* window, ImVec2 pos, ImVec2 size){
return SetWindowHitTestHole(window, pos, size);
}

extern(C)
void igFocusWindow(ImGuiWindow* window){
return FocusWindow(window);
}

extern(C)
void igFocusTopMostWindowUnderOne(ImGuiWindow* under_this_window, ImGuiWindow* ignore_window){
return FocusTopMostWindowUnderOne(under_this_window, ignore_window);
}

extern(C)
void igBringWindowToFocusFront(ImGuiWindow* window){
return BringWindowToFocusFront(window);
}

extern(C)
void igBringWindowToDisplayFront(ImGuiWindow* window){
return BringWindowToDisplayFront(window);
}

extern(C)
void igBringWindowToDisplayBack(ImGuiWindow* window){
return BringWindowToDisplayBack(window);
}

extern(C)
void igSetCurrentFont(ImFont* font){
return SetCurrentFont(font);
}

extern(C)
ImFont* igGetDefaultFont(){
return GetDefaultFont();
}

extern(C)
ImDrawList* igGetForegroundDrawListWindowPtr(ImGuiWindow* window){
return GetForegroundDrawList(window);
}

extern(C)
void igInitialize(ImGuiContext* context){
return Initialize(context);
}

extern(C)
void igShutdown(ImGuiContext* context){
return Shutdown(context);
}

extern(C)
void igUpdateHoveredWindowAndCaptureFlags(){
return UpdateHoveredWindowAndCaptureFlags();
}

extern(C)
void igStartMouseMovingWindow(ImGuiWindow* window){
return StartMouseMovingWindow(window);
}

extern(C)
void igUpdateMouseMovingWindowNewFrame(){
return UpdateMouseMovingWindowNewFrame();
}

extern(C)
void igUpdateMouseMovingWindowEndFrame(){
return UpdateMouseMovingWindowEndFrame();
}

extern(C)
void igMarkIniSettingsDirtyNil(){
return MarkIniSettingsDirty();
}

extern(C)
void igMarkIniSettingsDirtyWindowPtr(ImGuiWindow* window){
return MarkIniSettingsDirty(window);
}

extern(C)
void igClearIniSettings(){
return ClearIniSettings();
}

extern(C)
ImGuiWindowSettings* igCreateNewWindowSettings(const(char)* name){
return CreateNewWindowSettings(name);
}

extern(C)
ImGuiWindowSettings* igFindWindowSettings(ImGuiID id){
return FindWindowSettings(id);
}

extern(C)
ImGuiWindowSettings* igFindOrCreateWindowSettings(const(char)* name){
return FindOrCreateWindowSettings(name);
}

extern(C)
ImGuiSettingsHandler* igFindSettingsHandler(const(char)* type_name){
return FindSettingsHandler(type_name);
}

extern(C)
void igSetNextWindowScroll(ImVec2 scroll){
return SetNextWindowScroll(scroll);
}

extern(C)
void igSetScrollXWindowPtr(ImGuiWindow* window, float new_scroll_x){
return SetScrollX(window, new_scroll_x);
}

extern(C)
void igSetScrollYWindowPtr(ImGuiWindow* window, float new_scroll_y){
return SetScrollY(window, new_scroll_y);
}

extern(C)
void igSetScrollFromPosXWindowPtr(ImGuiWindow* window, float local_x, float center_x_ratio){
return SetScrollFromPosX(window, local_x, center_x_ratio);
}

extern(C)
void igSetScrollFromPosYWindowPtr(ImGuiWindow* window, float local_y, float center_y_ratio){
return SetScrollFromPosY(window, local_y, center_y_ratio);
}

extern(C)
void igScrollToBringRectIntoView(ImVec2* pOut, ImGuiWindow* window, ImRect item_rect){
*pOut = ScrollToBringRectIntoView(window, item_rect);
}

extern(C)
ImGuiID igGetItemID(){
return GetItemID();
}

extern(C)
ImGuiItemStatusFlags igGetItemStatusFlags(){
return GetItemStatusFlags();
}

extern(C)
ImGuiID igGetActiveID(){
return GetActiveID();
}

extern(C)
ImGuiID igGetFocusID(){
return GetFocusID();
}

extern(C)
void igSetActiveID(ImGuiID id, ImGuiWindow* window){
return SetActiveID(id, window);
}

extern(C)
void igSetFocusID(ImGuiID id, ImGuiWindow* window){
return SetFocusID(id, window);
}

extern(C)
void igClearActiveID(){
return ClearActiveID();
}

extern(C)
ImGuiID igGetHoveredID(){
return GetHoveredID();
}

extern(C)
void igSetHoveredID(ImGuiID id){
return SetHoveredID(id);
}

extern(C)
void igKeepAliveID(ImGuiID id){
return KeepAliveID(id);
}

extern(C)
void igMarkItemEdited(ImGuiID id){
return MarkItemEdited(id);
}

extern(C)
void igPushOverrideID(ImGuiID id){
return PushOverrideID(id);
}

extern(C)
void igItemSizeVec2(ImVec2 size, float text_baseline_y){
return ItemSize(size, text_baseline_y);
}

extern(C)
void igItemSizeRect(ImRect bb, float text_baseline_y){
return ItemSize(bb, text_baseline_y);
}

extern(C)
bool igItemAdd(ImRect bb, ImGuiID id, const(ImRect)* nav_bb){
return ItemAdd(bb, id, nav_bb);
}

extern(C)
bool igItemHoverable(ImRect bb, ImGuiID id){
return ItemHoverable(bb, id);
}

extern(C)
bool igIsClippedEx(ImRect bb, ImGuiID id, bool clip_even_when_logged){
return IsClippedEx(bb, id, clip_even_when_logged);
}

extern(C)
void igSetLastItemData(ImGuiWindow* window, ImGuiID item_id, ImGuiItemStatusFlags status_flags, ImRect item_rect){
return SetLastItemData(window, item_id, status_flags, item_rect);
}

extern(C)
bool igFocusableItemRegister(ImGuiWindow* window, ImGuiID id){
return FocusableItemRegister(window, id);
}

extern(C)
void igFocusableItemUnregister(ImGuiWindow* window){
return FocusableItemUnregister(window);
}

extern(C)
void igCalcItemSize(ImVec2* pOut, ImVec2 size, float default_w, float default_h){
*pOut = CalcItemSize(size, default_w, default_h);
}

extern(C)
float igCalcWrapWidthForPos(ImVec2 pos, float wrap_pos_x){
return CalcWrapWidthForPos(pos, wrap_pos_x);
}

extern(C)
void igPushMultiItemsWidths(int components, float width_full){
return PushMultiItemsWidths(components, width_full);
}

extern(C)
void igPushItemFlag(ImGuiItemFlags option, bool enabled){
return PushItemFlag(option, enabled);
}

extern(C)
void igPopItemFlag(){
return PopItemFlag();
}

extern(C)
bool igIsItemToggledSelection(){
return IsItemToggledSelection();
}

extern(C)
void igGetContentRegionMaxAbs(ImVec2* pOut){
*pOut = GetContentRegionMaxAbs();
}

extern(C)
void igShrinkWidths(ImGuiShrinkWidthItem* items, int count, float width_excess){
return ShrinkWidths(items, count, width_excess);
}

extern(C)
void igLogBegin(ImGuiLogType type, int auto_open_depth){
return LogBegin(type, auto_open_depth);
}

extern(C)
void igLogToBuffer(int auto_open_depth){
return LogToBuffer(auto_open_depth);
}

extern(C)
bool igBeginChildEx(const(char)* name, ImGuiID id, ImVec2 size_arg, bool border, ImGuiWindowFlags flags){
return BeginChildEx(name, id, size_arg, border, flags);
}

extern(C)
void igOpenPopupEx(ImGuiID id, ImGuiPopupFlags popup_flags){
return OpenPopupEx(id, popup_flags);
}

extern(C)
void igClosePopupToLevel(int remaining, bool restore_focus_to_window_under_popup){
return ClosePopupToLevel(remaining, restore_focus_to_window_under_popup);
}

extern(C)
void igClosePopupsOverWindow(ImGuiWindow* ref_window, bool restore_focus_to_window_under_popup){
return ClosePopupsOverWindow(ref_window, restore_focus_to_window_under_popup);
}

extern(C)
bool igIsPopupOpenID(ImGuiID id, ImGuiPopupFlags popup_flags){
return IsPopupOpen(id, popup_flags);
}

extern(C)
bool igBeginPopupEx(ImGuiID id, ImGuiWindowFlags extra_flags){
return BeginPopupEx(id, extra_flags);
}

extern(C)
void igBeginTooltipEx(ImGuiWindowFlags extra_flags, ImGuiTooltipFlags tooltip_flags){
return BeginTooltipEx(extra_flags, tooltip_flags);
}

extern(C)
ImGuiWindow* igGetTopMostPopupModal(){
return GetTopMostPopupModal();
}

extern(C)
void igFindBestWindowPosForPopup(ImVec2* pOut, ImGuiWindow* window){
*pOut = FindBestWindowPosForPopup(window);
}

extern(C)
void igFindBestWindowPosForPopupEx(ImVec2* pOut, ImVec2 ref_pos, ImVec2 size, ImGuiDir* last_dir, ImRect r_outer, ImRect r_avoid, ImGuiPopupPositionPolicy policy){
*pOut = FindBestWindowPosForPopupEx(ref_pos, size, last_dir, r_outer, r_avoid, policy);
}

extern(C)
void igNavInitWindow(ImGuiWindow* window, bool force_reinit){
return NavInitWindow(window, force_reinit);
}

extern(C)
bool igNavMoveRequestButNoResultYet(){
return NavMoveRequestButNoResultYet();
}

extern(C)
void igNavMoveRequestCancel(){
return NavMoveRequestCancel();
}

extern(C)
void igNavMoveRequestForward(ImGuiDir move_dir, ImGuiDir clip_dir, ImRect bb_rel, ImGuiNavMoveFlags move_flags){
return NavMoveRequestForward(move_dir, clip_dir, bb_rel, move_flags);
}

extern(C)
void igNavMoveRequestTryWrapping(ImGuiWindow* window, ImGuiNavMoveFlags move_flags){
return NavMoveRequestTryWrapping(window, move_flags);
}

extern(C)
float igGetNavInputAmount(ImGuiNavInput n, ImGuiInputReadMode mode){
return GetNavInputAmount(n, mode);
}

extern(C)
void igGetNavInputAmount2d(ImVec2* pOut, ImGuiNavDirSourceFlags dir_sources, ImGuiInputReadMode mode, float slow_factor, float fast_factor){
*pOut = GetNavInputAmount2d(dir_sources, mode, slow_factor, fast_factor);
}

extern(C)
int igCalcTypematicRepeatAmount(float t0, float t1, float repeat_delay, float repeat_rate){
return CalcTypematicRepeatAmount(t0, t1, repeat_delay, repeat_rate);
}

extern(C)
void igActivateItem(ImGuiID id){
return ActivateItem(id);
}

extern(C)
void igSetNavID(ImGuiID id, int nav_layer, ImGuiID focus_scope_id){
return SetNavID(id, nav_layer, focus_scope_id);
}

extern(C)
void igSetNavIDWithRectRel(ImGuiID id, int nav_layer, ImGuiID focus_scope_id, ImRect rect_rel){
return SetNavIDWithRectRel(id, nav_layer, focus_scope_id, rect_rel);
}

extern(C)
void igPushFocusScope(ImGuiID id){
return PushFocusScope(id);
}

extern(C)
void igPopFocusScope(){
return PopFocusScope();
}

extern(C)
ImGuiID igGetFocusScopeID(){
return GetFocusScopeID();
}

extern(C)
bool igIsActiveIdUsingNavDir(ImGuiDir dir){
return IsActiveIdUsingNavDir(dir);
}

extern(C)
bool igIsActiveIdUsingNavInput(ImGuiNavInput input){
return IsActiveIdUsingNavInput(input);
}

extern(C)
bool igIsActiveIdUsingKey(ImGuiKey key){
return IsActiveIdUsingKey(key);
}

extern(C)
bool igIsMouseDragPastThreshold(ImGuiMouseButton button, float lock_threshold){
return IsMouseDragPastThreshold(button, lock_threshold);
}

extern(C)
bool igIsKeyPressedMap(ImGuiKey key, bool repeat){
return IsKeyPressedMap(key, repeat);
}

extern(C)
bool igIsNavInputDown(ImGuiNavInput n){
return IsNavInputDown(n);
}

extern(C)
bool igIsNavInputTest(ImGuiNavInput n, ImGuiInputReadMode rm){
return IsNavInputTest(n, rm);
}

extern(C)
ImGuiKeyModFlags igGetMergedKeyModFlags(){
return GetMergedKeyModFlags();
}

extern(C)
bool igBeginDragDropTargetCustom(ImRect bb, ImGuiID id){
return BeginDragDropTargetCustom(bb, id);
}

extern(C)
void igClearDragDrop(){
return ClearDragDrop();
}

extern(C)
bool igIsDragDropPayloadBeingAccepted(){
return IsDragDropPayloadBeingAccepted();
}

extern(C)
void igSetWindowClipRectBeforeSetChannel(ImGuiWindow* window, ImRect clip_rect){
return SetWindowClipRectBeforeSetChannel(window, clip_rect);
}

extern(C)
void igBeginColumns(const(char)* str_id, int count, ImGuiColumnsFlags flags){
return BeginColumns(str_id, count, flags);
}

extern(C)
void igEndColumns(){
return EndColumns();
}

extern(C)
void igPushColumnClipRect(int column_index){
return PushColumnClipRect(column_index);
}

extern(C)
void igPushColumnsBackground(){
return PushColumnsBackground();
}

extern(C)
void igPopColumnsBackground(){
return PopColumnsBackground();
}

extern(C)
ImGuiID igGetColumnsID(const(char)* str_id, int count){
return GetColumnsID(str_id, count);
}

extern(C)
ImGuiColumns* igFindOrCreateColumns(ImGuiWindow* window, ImGuiID id){
return FindOrCreateColumns(window, id);
}

extern(C)
float igGetColumnOffsetFromNorm(const(ImGuiColumns)* columns, float offset_norm){
return GetColumnOffsetFromNorm(columns, offset_norm);
}

extern(C)
float igGetColumnNormFromOffset(const(ImGuiColumns)* columns, float offset){
return GetColumnNormFromOffset(columns, offset);
}

extern(C)
bool igBeginTabBarEx(ImGuiTabBar* tab_bar, ImRect bb, ImGuiTabBarFlags flags){
return BeginTabBarEx(tab_bar, bb, flags);
}

extern(C)
ImGuiTabItem* igTabBarFindTabByID(ImGuiTabBar* tab_bar, ImGuiID tab_id){
return TabBarFindTabByID(tab_bar, tab_id);
}

extern(C)
void igTabBarRemoveTab(ImGuiTabBar* tab_bar, ImGuiID tab_id){
return TabBarRemoveTab(tab_bar, tab_id);
}

extern(C)
void igTabBarCloseTab(ImGuiTabBar* tab_bar, ImGuiTabItem* tab){
return TabBarCloseTab(tab_bar, tab);
}

extern(C)
void igTabBarQueueChangeTabOrder(ImGuiTabBar* tab_bar, const(ImGuiTabItem)* tab, int dir){
return TabBarQueueChangeTabOrder(tab_bar, tab, dir);
}

extern(C)
bool igTabItemEx(ImGuiTabBar* tab_bar, const(char)* label, bool* p_open, ImGuiTabItemFlags flags){
return TabItemEx(tab_bar, label, p_open, flags);
}

extern(C)
void igTabItemCalcSize(ImVec2* pOut, const(char)* label, bool has_close_button){
*pOut = TabItemCalcSize(label, has_close_button);
}

extern(C)
void igTabItemBackground(ImDrawList* draw_list, ImRect bb, ImGuiTabItemFlags flags, ImU32 col){
return TabItemBackground(draw_list, bb, flags, col);
}

extern(C)
bool igTabItemLabelAndCloseButton(ImDrawList* draw_list, ImRect bb, ImGuiTabItemFlags flags, ImVec2 frame_padding, const(char)* label, ImGuiID tab_id, ImGuiID close_button_id, bool is_contents_visible){
return TabItemLabelAndCloseButton(draw_list, bb, flags, frame_padding, label, tab_id, close_button_id, is_contents_visible);
}

extern(C)
void igRenderText(ImVec2 pos, const(char)* text, const(char)* text_end, bool hide_text_after_hash){
return RenderText(pos, text, text_end, hide_text_after_hash);
}

extern(C)
void igRenderTextWrapped(ImVec2 pos, const(char)* text, const(char)* text_end, float wrap_width){
return RenderTextWrapped(pos, text, text_end, wrap_width);
}

extern(C)
void igRenderTextClipped(ImVec2 pos_min, ImVec2 pos_max, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known, ImVec2 align, const(ImRect)* clip_rect){
return RenderTextClipped(pos_min, pos_max, text, text_end, text_size_if_known, align, clip_rect);
}

extern(C)
void igRenderTextClippedEx(ImDrawList* draw_list, ImVec2 pos_min, ImVec2 pos_max, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known, ImVec2 align, const(ImRect)* clip_rect){
return RenderTextClippedEx(draw_list, pos_min, pos_max, text, text_end, text_size_if_known, align, clip_rect);
}

extern(C)
void igRenderTextEllipsis(ImDrawList* draw_list, ImVec2 pos_min, ImVec2 pos_max, float clip_max_x, float ellipsis_max_x, const(char)* text, const(char)* text_end, const(ImVec2)* text_size_if_known){
return RenderTextEllipsis(draw_list, pos_min, pos_max, clip_max_x, ellipsis_max_x, text, text_end, text_size_if_known);
}

extern(C)
void igRenderFrame(ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, bool border, float rounding){
return RenderFrame(p_min, p_max, fill_col, border, rounding);
}

extern(C)
void igRenderFrameBorder(ImVec2 p_min, ImVec2 p_max, float rounding){
return RenderFrameBorder(p_min, p_max, rounding);
}

extern(C)
void igRenderColorRectWithAlphaCheckerboard(ImDrawList* draw_list, ImVec2 p_min, ImVec2 p_max, ImU32 fill_col, float grid_step, ImVec2 grid_off, float rounding, int rounding_corners_flags){
return RenderColorRectWithAlphaCheckerboard(draw_list, p_min, p_max, fill_col, grid_step, grid_off, rounding, rounding_corners_flags);
}

extern(C)
void igRenderNavHighlight(ImRect bb, ImGuiID id, ImGuiNavHighlightFlags flags){
return RenderNavHighlight(bb, id, flags);
}

extern(C)
const(char)* igFindRenderedTextEnd(const(char)* text, const(char)* text_end){
return FindRenderedTextEnd(text, text_end);
}

extern(C)
void igLogRenderedText(const(ImVec2)* ref_pos, const(char)* text, const(char)* text_end){
return LogRenderedText(ref_pos, text, text_end);
}

extern(C)
void igRenderArrow(ImDrawList* draw_list, ImVec2 pos, ImU32 col, ImGuiDir dir, float scale){
return RenderArrow(draw_list, pos, col, dir, scale);
}

extern(C)
void igRenderBullet(ImDrawList* draw_list, ImVec2 pos, ImU32 col){
return RenderBullet(draw_list, pos, col);
}

extern(C)
void igRenderCheckMark(ImDrawList* draw_list, ImVec2 pos, ImU32 col, float sz){
return RenderCheckMark(draw_list, pos, col, sz);
}

extern(C)
void igRenderMouseCursor(ImDrawList* draw_list, ImVec2 pos, float scale, ImGuiMouseCursor mouse_cursor, ImU32 col_fill, ImU32 col_border, ImU32 col_shadow){
return RenderMouseCursor(draw_list, pos, scale, mouse_cursor, col_fill, col_border, col_shadow);
}

extern(C)
void igRenderArrowPointingAt(ImDrawList* draw_list, ImVec2 pos, ImVec2 half_sz, ImGuiDir direction, ImU32 col){
return RenderArrowPointingAt(draw_list, pos, half_sz, direction, col);
}

extern(C)
void igRenderRectFilledRangeH(ImDrawList* draw_list, ImRect rect, ImU32 col, float x_start_norm, float x_end_norm, float rounding){
return RenderRectFilledRangeH(draw_list, rect, col, x_start_norm, x_end_norm, rounding);
}

extern(C)
void igRenderRectFilledWithHole(ImDrawList* draw_list, ImRect outer, ImRect inner, ImU32 col, float rounding){
return RenderRectFilledWithHole(draw_list, outer, inner, col, rounding);
}

extern(C)
void igTextEx(const(char)* text, const(char)* text_end, ImGuiTextFlags flags){
return TextEx(text, text_end, flags);
}

extern(C)
bool igButtonEx(const(char)* label, ImVec2 size_arg, ImGuiButtonFlags flags){
return ButtonEx(label, size_arg, flags);
}

extern(C)
bool igCloseButton(ImGuiID id, ImVec2 pos){
return CloseButton(id, pos);
}

extern(C)
bool igCollapseButton(ImGuiID id, ImVec2 pos){
return CollapseButton(id, pos);
}

extern(C)
bool igArrowButtonEx(const(char)* str_id, ImGuiDir dir, ImVec2 size_arg, ImGuiButtonFlags flags){
return ArrowButtonEx(str_id, dir, size_arg, flags);
}

extern(C)
void igScrollbar(ImGuiAxis axis){
return Scrollbar(axis);
}

extern(C)
bool igScrollbarEx(ImRect bb, ImGuiID id, ImGuiAxis axis, float* p_scroll_v, float avail_v, float contents_v, ImDrawCornerFlags rounding_corners){
return ScrollbarEx(bb, id, axis, p_scroll_v, avail_v, contents_v, rounding_corners);
}

extern(C)
bool igImageButtonEx(ImGuiID id, void* texture_id, ImVec2 size, ImVec2 uv0, ImVec2 uv1, ImVec2 padding, ImVec4 bg_col, ImVec4 tint_col){
return ImageButtonEx(id, texture_id, size, uv0, uv1, padding, bg_col, tint_col);
}

extern(C)
void igGetWindowScrollbarRect(ImRect* pOut, ImGuiWindow* window, ImGuiAxis axis){
*pOut = GetWindowScrollbarRect(window, axis);
}

extern(C)
ImGuiID igGetWindowScrollbarID(ImGuiWindow* window, ImGuiAxis axis){
return GetWindowScrollbarID(window, axis);
}

extern(C)
ImGuiID igGetWindowResizeID(ImGuiWindow* window, int n){
return GetWindowResizeID(window, n);
}

extern(C)
void igSeparatorEx(ImGuiSeparatorFlags flags){
return SeparatorEx(flags);
}

extern(C)
bool igButtonBehavior(ImRect bb, ImGuiID id, bool* out_hovered, bool* out_held, ImGuiButtonFlags flags){
return ButtonBehavior(bb, id, out_hovered, out_held, flags);
}

extern(C)
bool igDragBehavior(ImGuiID id, ImGuiDataType data_type, void* p_v, float v_speed, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags){
return DragBehavior(id, data_type, p_v, v_speed, p_min, p_max, format, flags);
}

extern(C)
bool igSliderBehavior(ImRect bb, ImGuiID id, ImGuiDataType data_type, void* p_v, const(void)* p_min, const(void)* p_max, const(char)* format, ImGuiSliderFlags flags, ImRect* out_grab_bb){
return SliderBehavior(bb, id, data_type, p_v, p_min, p_max, format, flags, out_grab_bb);
}

extern(C)
bool igSplitterBehavior(ImRect bb, ImGuiID id, ImGuiAxis axis, float* size1, float* size2, float min_size1, float min_size2, float hover_extend, float hover_visibility_delay){
return SplitterBehavior(bb, id, axis, size1, size2, min_size1, min_size2, hover_extend, hover_visibility_delay);
}

extern(C)
bool igTreeNodeBehavior(ImGuiID id, ImGuiTreeNodeFlags flags, const(char)* label, const(char)* label_end){
return TreeNodeBehavior(id, flags, label, label_end);
}

extern(C)
bool igTreeNodeBehaviorIsOpen(ImGuiID id, ImGuiTreeNodeFlags flags){
return TreeNodeBehaviorIsOpen(id, flags);
}

extern(C)
void igTreePushOverrideID(ImGuiID id){
return TreePushOverrideID(id);
}

extern(C)
const(ImGuiDataTypeInfo)* igDataTypeGetInfo(ImGuiDataType data_type){
return DataTypeGetInfo(data_type);
}

extern(C)
int igDataTypeFormatString(char* buf, int buf_size, ImGuiDataType data_type, const(void)* p_data, const(char)* format){
return DataTypeFormatString(buf, buf_size, data_type, p_data, format);
}

extern(C)
void igDataTypeApplyOp(ImGuiDataType data_type, int op, void* output, void* arg_1, const(void)* arg_2){
return DataTypeApplyOp(data_type, op, output, arg_1, arg_2);
}

extern(C)
bool igDataTypeApplyOpFromText(const(char)* buf, const(char)* initial_value_buf, ImGuiDataType data_type, void* p_data, const(char)* format){
return DataTypeApplyOpFromText(buf, initial_value_buf, data_type, p_data, format);
}

extern(C)
bool igDataTypeClamp(ImGuiDataType data_type, void* p_data, const(void)* p_min, const(void)* p_max){
return DataTypeClamp(data_type, p_data, p_min, p_max);
}

extern(C)
bool igInputTextEx(const(char)* label, const(char)* hint, char* buf, int buf_size, ImVec2 size_arg, ImGuiInputTextFlags flags, int function(ImGuiInputTextCallbackData*) callback, void* user_data){
return InputTextEx(label, hint, buf, buf_size, size_arg, flags, callback, user_data);
}

extern(C)
bool igTempInputText(ImRect bb, ImGuiID id, const(char)* label, char* buf, int buf_size, ImGuiInputTextFlags flags){
return TempInputText(bb, id, label, buf, buf_size, flags);
}

extern(C)
bool igTempInputScalar(ImRect bb, ImGuiID id, const(char)* label, ImGuiDataType data_type, void* p_data, const(char)* format, const(void)* p_clamp_min, const(void)* p_clamp_max){
return TempInputScalar(bb, id, label, data_type, p_data, format, p_clamp_min, p_clamp_max);
}

extern(C)
bool igTempInputIsActive(ImGuiID id){
return TempInputIsActive(id);
}

extern(C)
ImGuiInputTextState* igGetInputTextState(ImGuiID id){
return GetInputTextState(id);
}

extern(C)
void igColorTooltip(const(char)* text, const(float)* col, ImGuiColorEditFlags flags){
return ColorTooltip(text, col, flags);
}

extern(C)
void igColorEditOptionsPopup(const(float)* col, ImGuiColorEditFlags flags){
return ColorEditOptionsPopup(col, flags);
}

extern(C)
void igColorPickerOptionsPopup(const(float)* ref_col, ImGuiColorEditFlags flags){
return ColorPickerOptionsPopup(ref_col, flags);
}

extern(C)
int igPlotEx(ImGuiPlotType plot_type, const(char)* label, float function(void*, int) values_getter, void* data, int values_count, int values_offset, const(char)* overlay_text, float scale_min, float scale_max, ImVec2 frame_size){
return PlotEx(plot_type, label, values_getter, data, values_count, values_offset, overlay_text, scale_min, scale_max, frame_size);
}

extern(C)
void igShadeVertsLinearColorGradientKeepAlpha(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 gradient_p0, ImVec2 gradient_p1, ImU32 col0, ImU32 col1){
return ShadeVertsLinearColorGradientKeepAlpha(draw_list, vert_start_idx, vert_end_idx, gradient_p0, gradient_p1, col0, col1);
}

extern(C)
void igShadeVertsLinearUV(ImDrawList* draw_list, int vert_start_idx, int vert_end_idx, ImVec2 a, ImVec2 b, ImVec2 uv_a, ImVec2 uv_b, bool clamp){
return ShadeVertsLinearUV(draw_list, vert_start_idx, vert_end_idx, a, b, uv_a, uv_b, clamp);
}

extern(C)
void igGcCompactTransientWindowBuffers(ImGuiWindow* window){
return GcCompactTransientWindowBuffers(window);
}

extern(C)
void igGcAwakeTransientWindowBuffers(ImGuiWindow* window){
return GcAwakeTransientWindowBuffers(window);
}

extern(C)
void igDebugDrawItemRect(ImU32 col){
return DebugDrawItemRect(col);
}

extern(C)
void igDebugStartItemPicker(){
return DebugStartItemPicker();
}

extern(C)
bool igImFontAtlasBuildWithStbTruetype(ImFontAtlas* atlas){
return ImFontAtlasBuildWithStbTruetype(atlas);
}

extern(C)
void igImFontAtlasBuildInit(ImFontAtlas* atlas){
return ImFontAtlasBuildInit(atlas);
}

extern(C)
void igImFontAtlasBuildSetupFont(ImFontAtlas* atlas, ImFont* font, ImFontConfig* font_config, float ascent, float descent){
return ImFontAtlasBuildSetupFont(atlas, font, font_config, ascent, descent);
}

extern(C)
void igImFontAtlasBuildPackCustomRects(ImFontAtlas* atlas, void* stbrp_context_opaque){
return ImFontAtlasBuildPackCustomRects(atlas, stbrp_context_opaque);
}

extern(C)
void igImFontAtlasBuildFinish(ImFontAtlas* atlas){
return ImFontAtlasBuildFinish(atlas);
}

extern(C)
void igImFontAtlasBuildRender1bppRectFromString(ImFontAtlas* atlas, int atlas_x, int atlas_y, int w, int h, const(char)* in_str, char in_marker_char, ubyte in_marker_pixel_value){
return ImFontAtlasBuildRender1bppRectFromString(atlas, atlas_x, atlas_y, w, h, in_str, in_marker_char, in_marker_pixel_value);
}

extern(C)
void igImFontAtlasBuildMultiplyCalcLookupTable(ubyte* out_table, float in_multiply_factor){
return ImFontAtlasBuildMultiplyCalcLookupTable(out_table, in_multiply_factor);
}

extern(C)
void igImFontAtlasBuildMultiplyRectAlpha8(const(ubyte)* table, ubyte* pixels, int x, int y, int w, int h, int stride){
return ImFontAtlasBuildMultiplyRectAlpha8(table, pixels, x, y, w, h, stride);
}

extern(C)
void igLogText(const(char)* fmt, ...){
char[256] buffer;
char* args;
(__va_start(&args, fmt));
vsnprintf(buffer, 256, fmt, args);
(args = cast(char*)0);
LogText("%s", buffer);
}

extern(C)
void ImGuiTextBuffer_appendf(ImGuiTextBuffer* buffer, const(char)* fmt, ...){
char* args;
(__va_start(&args, fmt));
buffer.appendfv(fmt, args);
(args = cast(char*)0);
}

extern(C)
float igGET_FLT_MAX(){
return 3.40282347E+38f;
}

extern(C)
ImVector_ImWchar* ImVector_ImWchar_create(){
return emplace( ImNewWrapper(), MemAlloc((ImVector!(ImWchar)).sizeof), ImVector!(ImWchar)());
}

extern(C)
void ImVector_ImWchar_destroy(ImVector_ImWchar* self){
IM_DELETE(self);
}

extern(C)
void ImVector_ImWchar_Init(ImVector_ImWchar* p){
emplace( ImNewWrapper(), p, ImVector!(ImWchar)());
}

extern(C)
void ImVector_ImWchar_UnInit(ImVector_ImWchar* p){
p.~ImVector();
}

