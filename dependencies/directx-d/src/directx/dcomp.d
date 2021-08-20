module directx.dcomp;
//---------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.  All rights reserved.
//---------------------------------------------------------------------------

version(Windows):

public import directx.com, directx.dcommon;
public import directx.dcompanimation;
public import directx.d2dbasetypes, directx.d3d9;
public import directx.d2d1_1, directx.dcomptypes;

extern(Windows)
{
	extern(Windows):	
	/// Creates a new DirectComposition device object, which can be used to create
	/// other DirectComposition objects.
	HRESULT DCompositionCreateDevice(
		IDXGIDevice dxgiDevice,
		REFIID iid,
		void** dcompositionDevice
	);
	/// Creates a new DirectComposition device object, which can be used to create
	/// other DirectComposition objects.
	HRESULT DCompositionCreateDevice2(
		IUnknown renderingDevice,
		REFIID iid,
		void** dcompositionDevice
	);
	/// Creates a new DirectComposition device object, which can be used to create
	/// other DirectComposition objects.
	HRESULT DCompositionCreateDevice3(
		IUnknown renderingDevice,
		REFIID iid,
		void** dcompositionDevice
	);
	/// Creates a new composition surface object, which can be bound to a
	/// DirectX swap chain or swap buffer or to a GDI bitmap and associated
	/// with a visual.
	HRESULT DCompositionCreateSurfaceHandle(
		DWORD desiredAccess,
		SECURITY_ATTRIBUTES* securityAttributes,
		HANDLE* surfaceHandle
	);
	/// Creates an Interaction/InputSink to route mouse wheel messages to the
	/// given HWND. After calling this API, the device owning the visual must
	/// be committed.
	HRESULT DCompositionAttachMouseWheelToHwnd(
		IDCompositionVisual visual,
		HWND hwnd,
		BOOL enable
	);
	/// Creates an Interaction/InputSink to route mouse button down and any 
	/// subsequent move and up events to the given HWND. There is no move 
	/// thresholding; when enabled, all events including and following the down 
	/// are unconditionally redirected to the specified window. After calling this 
	/// API, the device owning the visual must be committed.
	HRESULT DCompositionAttachMouseDragToHwnd(
		IDCompositionVisual visual,
		HWND hwnd,
		BOOL enable
	);
}

mixin(uuid!(IDCompositionDevice, "C37EA93A-E7AA-450D-B16F-9746CB0407F3"));
/// Serves as the root factory for all other DirectComposition objects and
/// controls transactional composition.
interface IDCompositionDevice : IUnknown
{
	extern(Windows):
    /// Commits all DirectComposition commands pending on this device.
	HRESULT Commit();
    /// Waits for the last Commit to be processed by the composition engine
	HRESULT WaitForCommitCompletion();
    /// Gets timing information about the composition engine.
	HRESULT GetFrameStatistics(DCOMPOSITION_FRAME_STATISTICS* statistics);
    /// Creates a composition target bound to a window represented by an HWND.
	HRESULT CreateTargetForHwnd(
		HWND hwnd,
		BOOL topmost,
		IDCompositionTarget* target
	);
    /// Creates a new visual object.
	HRESULT CreateVisual(IDCompositionVisual* visual);
    /// Creates a DirectComposition surface object
	HRESULT CraeteSurface(
		UINT width,
		UINT height,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionSurface* surface
	);
    /// Creates a DirectComposition virtual surface object
	HRESULT CreateVirtualSurface(
		UINT initialWidth,
		UINT initialHeight,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionVirtualSurface* virtualSurface
	);
    /// Creates a surface wrapper around a pre-existing surface that can be associated with one or more visuals for composition.
	HRESULT CreateSurfaceForHandle(
		HANDLE handle,
		IUnknown* surface
	);
	/// Creates a wrapper object that represents the rasterization of a layered window and which can be associated with a visual for composition.
	HRESULT CreateSurfaceForHwnd(
		HWND hwnd,
		IUnknown* surface
	);
    /// Creates a 2D translation transform object.
	HRESULT CreateTranslateTransform(IDCompositionTranslateTransform* translateTransform);
    /// Creates a 2D scale transform object.
	HRESULT CreateScaleTransform(IDCompositionScaleTransform* scaleTransform);
    /// Creates a 2D rotation transform object.
	HRESULT CreateRotateTransform(IDCompositionRotateTransform* rotateTransform);
    /// Creates a 2D skew transform object.
	HRESULT CreateSkewTransform(IDCompositionSkewTransform* skewTransform);
    /// Creates a 2D 3x2 matrix transform object.
	HRESULT CreateMatrixTransform(IDCompositionMatrixTransform* matrixTransform);
    /// Creates a 2D transform object that holds an array of 2D transform objects.
	HRESULT CreateTransformGroup(
		IDCompositionTransform* transforms, UINT elements,
		IDCompositionTransform* transformGroup
	);
    /// Creates a 3D translation transform object.
	HRESULT CreateTranslateTransform3D(IDCompositionTranslateTransform3D* translateTransform3D);
    /// Creates a 3D scale transform object.
	HRESULT CreateScaleTransform3D(IDCompositionScaleTransform3D* scaleTransform3D);
    /// Creates a 3D rotation transform object.
	HRESULT CreateRotateTransform3D(IDCompositionRotateTransform3D* rotateTransform3D);
    /// Creates a 3D 4x4 matrix transform object.
	HRESULT CreateMatrixTransform3D(IDCompositionMatrixTransform3D* matrixTransform3D);
    /// Creates a 3D transform object that holds an array of 3D transform objects.
	HRESULT CreateTransform3DGroup(
		IDCompositionTransform3D* transform3D, UINT elements,
		IDCompositionTransform3D* transform3DGroup
	);
    /// Creates an effect group
	HRESULT CreateEffectrGroup(IDCompositionEffectGroup* effectGroup);
    /// Creates a clip object that can be used to clip the contents of a visual subtree.
	HRESULT CreateRectangleClip(IDCompositionRectangleClip* clip);
    /// Creates an animation object
	HRESULT CreateAnimation(IDCompositionAnimation animation);
    /// Returns the states of the app's DX device and DWM's dx devices
	HRESULT CheckDeviceState(BOOL* pfValid);
}

mixin(uuid!(IDCompositionTarget, "eacdd04c-117e-4e17-88f4-d1b12b0e3d89"));
/// An IDCompositionTarget interface represents a binding between a
/// DirectComposition visual tree and a destination on top of which the
/// visual tree should be composed.
interface IDCompositionTarget : IUnknown
{
	extern(Windows):
    /// Sets the root visual
	HRESULT SetRoot(IDCompositionVisual visual);
}

mixin(uuid!(IDCompositionVisual, "4d93059d-097b-4651-9a60-f0f25116e2f3"));
/// An IDCompositionVisual interface represents a visual that participates in
/// a visual tree.
interface IDCompositionVisual : IUnknown
{
	extern(Windows):
    /// Changes the value of OffsetX property
	HRESULT SetOffsetX(float offsetX);
    /// Animates the value of the OffsetX property.
	HRESULT SetOffsetX(IDCompositionAnimation animation);
    /// Changes the value of OffsetY property
	HRESULT SetOffsetY(float offsetY);
    /// Animates the value of the OffsetY property.
	HRESULT SetOffsetY(IDCompositionAnimation animation);
    /// Sets the matrix that modifies the coordinate system of this visual.
	HRESULT SetTransform(const(D2D_MATRIX_3X2_F)* matrix);
    /// Sets the transformation object that modifies the coordinate system of this visual.
	HRESULT SetTransform(IDCompositionTransform transform);
    /// Sets the visual that should act as this visual's parent for the
    /// purpose of establishing a base coordinate system.
	HRESULT SetTransformParent(IDCompositionVisual visual);
    /// Sets the effect object that is applied during the rendering of this visual
	HRESULT SetEffect(IDCompositionEffect effect);
    /// Sets the mode to use when interpolating pixels from bitmaps drawn not
    /// exactly at scale and axis-aligned.
	HRESULT SetBitmapInterpolationMode(DCOMPOSITION_BITMAP_INTERPOLATION_MODE interpolationMode);
    /// Sets the mode to use when drawing the edge of bitmaps that are not
    /// exactly axis-aligned and at precise pixel boundaries.
	HRESULT SetBorderMode(DCOMPOSITION_BORDER_MODE borderMode);
    /// Sets the clip object that restricts the rendering of this visual to a D2D rectangle.
	HRESULT SetClip(const(D2D_RECT_F)* rect);
    /// Sets the clip object that restricts the rendering of this visual to a rectangle.
	HRESULT SetClip(IDCompositionClip clip);
    /// Associates a bitmap with a visual
	HRESULT SetContent(IUnknown content);
    /// Adds a visual to the children list of another visual.
	HRESULT AddVisual(
		IDCompositionVisual visual,
		BOOL insertAbove,
		IDCompositionVisual referenceVisual
	);
    /// Removes a visual from the children list of another visual.
	HRESULT RemoveVisual(IDCompositionVisual visual);
    /// Removes all visuals from the children list of another visual.
	HRESULT RemoveAllVisuals();
    /// Sets the mode to use when composing the bitmap against the render target.
	HRESULT SetCompositeMode(DCOMPOSITION_COMPOSITE_MODE compositeMode);
}

mixin(uuid!(IDCompositionEffect, "EC81B08F-BFCB-4e8d-B193-A915587999E8"));
/// An IDCompositionEffect interface represents an effect
interface IDCompositionEffect : IUnknown {}
mixin(uuid!(IDCompositionTransform3D, "71185722-246B-41f2-AAD1-0443F7F4BFC2"));
/// An IDCompositionTransform3D interface represents a 3D transformation.
interface IDCompositionTransform3D : IDCompositionEffect {}
mixin(uuid!(IDCompositionTransform, "FD55FAA7-37E0-4c20-95D2-9BE45BC33F55"));
/// An IDCompositionTransform interface represents a 2D transformation that
/// can be used to modify the coordinate space of a visual subtree.
interface IDCompositionTransform : IDCompositionTransform3D {}
mixin(uuid!(IDCompositionTranslateTransform, "06791122-C6F0-417d-8323-269E987F5954"));
/// An IDCompositionTranslateTransform interface represents a 2D transformation
/// that affects only the offset of a visual along the x and y axes.
interface IDCompositionTranslateTransform : IDCompositionTransform
{
	extern(Windows):
    /// Changes the value of the OffsetX property.
	HRESULT SetOffsetX(float offsetX);
    /// Animates the value of the OffsetX property.
	HRESULT SetOffsetX(IDCompositionAnimation animation);
	/// Changes the value of the OffsetY property.
	HRESULT SetOffsetY(float offsetY);
	/// Animates the value of the OffsetY property.
	HRESULT SetOffsetY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionScaleTransform, "71FDE914-40EF-45ef-BD51-68B037C339F9"));
/// An IDCompositionScaleTransform interface represents a 2D transformation that
/// affects the scale of a visual along the x and y axes. The coordinate system
/// is scaled from the specified center point.
interface IDCompositionScaleTransform : IDCompositionTransform
{
	extern(Windows):
    /// Changes the value of the ScaleX property.
	HRESULT SetScaleX(float scaleX);
    /// Animates the value of the ScaleX property.
	HRESULT SetScaleX(IDCompositionAnimation animation);
    /// Changes the value of the ScaleY property.
	HRESULT SetScaleY(float scaleY);
    /// Animates the value of the ScaleY property.
	HRESULT SetScaleY(IDCompositionAnimation animation);
    /// Changes the value of the CenterX property.
	HRESULT SetCenterX(float centerX);
    /// Animates the value of the CenterX property.
	HRESULT SetCenterX(IDCompositionAnimation animation);
    /// Changes the value of the CenterY property.
	HRESULT SetCenterY(float centerY);
    /// Animates the value of the CenterY property.
	HRESULT SetCenterY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionRotateTransform, "641ED83C-AE96-46c5-90DC-32774CC5C6D5"));
/// An IDCompositionRotateTransform interface represents a 2D transformation
/// that affects the rotation of a visual along the z axis. The coordinate system
/// is rotated around the specified center point.
interface IDCompositionRotateTransform : IDCompositionTransform
{
	extern(Windows):
    /// Changes the value of the Angle property.
	HRESULT SetAngle(float angle);
    /// Animates the value of the Angle property.
	HRESULT SetAngle(IDCompositionAnimation animation);
    /// Changes the value of the CenterX property.
	HRESULT SetCenterX(float centerX);
    /// Animates the value of the CenterX property.
	HRESULT SetCenterX(IDCompositionAnimation animation);
    /// Changes the value of the CenterY property.
	HRESULT SetCenterY(float centerY);
    /// Animates the value of the CenterY property.
	HRESULT SetCenterY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionSkewTransform, "E57AA735-DCDB-4c72-9C61-0591F58889EE"));
/// An IDCompositionSkewTransform interface represents a 2D transformation that
/// affects the skew of a visual along the x and y axes. The coordinate system
/// is skewed around the specified center point.
interface IDCompositionSkewTransform : IDCompositionTransform
{
	extern(Windows):
    /// Changes the value of the AngleX property.
	HRESULT SetAngleX(float angleX);
    /// Animates the value of the AngleX property.
	HRESULT SetAngleX(IDCompositionAnimation animation);
    /// Changes the value of the AngleY property.
	HRESULT SetAngleY(float angleY);
    /// Animates the value of the AngleY property.
	HRESULT SetAngleY(IDCompositionAnimation animation);
    /// Changes the value of the CenterX property.
	HRESULT SetCenterX(float centerX);
    /// Animates the value of the CenterX property.
	HRESULT SetCenterX(IDCompositionAnimation animation);
    /// Changes the value of the CenterY property.
	HRESULT SetCenterY(float centerY);
    /// Animates the value of the CenterY property.
	HRESULT SetCenterY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionMatrixTransform, "16CDFF07-C503-419c-83F2-0965C7AF1FA6"));
/// An IDCompositionMatrixTransform interface represents an arbitrary affine
/// 2D transformation defined by a 3x2 matrix.
interface IDCompositionMatrixTransform : IDCompositionTransform
{
	extern(Windows):
    /// Changes all values of the matrix of this transform.
	HRESULT SetMatrix(const(D2D_MATRIX_3X2_F)* matrix);
    /// Changes a single element of the matrix of this transform.
	HRESULT SetMatrixElement(int row, int column, float value);
    /// Animates a single element of the matrix of this transform.
	HRESULT SetMatrixElement(int row, int column, IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionEffectGroup, "A7929A74-E6B2-4bd6-8B95-4040119CA34D"));
/// An IDCompositionEffectGroup holds effects, inluding 3D transforms that can
/// be applied to a visual.
interface IDCompositionEffectGroup : IDCompositionEffect
{
	extern(Windows):
    /// Changes the opacity property.
	HRESULT SetOpacity(float opacity);
    /// Animates the opacity property
	HRESULT SetOpacity(IDCompositionAnimation animation);
    /// Sets the 3D transform
	HRESULT SetTransform3D(IDCompositionTransform3D transform3D);
}

mixin(uuid!(IDCompositionTranslateTransform3D, "91636D4B-9BA1-4532-AAF7-E3344994D788"));
/// An IDCompositionTranslateTransform3D interface represents a 3D transformation
/// that affects the offset of a visual along the x,y and z axes.
interface IDCompositionTranslateTransform3D : IDCompositionTransform3D
{
	extern(Windows):
    /// Changes the value of the OffsetX property.
	HRESULT SetOffsetX(float offsetX);
    /// Animates the value of the OffsetX property.
	HRESULT SetOffsetX(IDCompositionAnimation animation);
	/// Changes the value of the OffsetY property.
	HRESULT SetOffsetY(float offsetY);
    /// Animates the value of the OffsetY property.
	HRESULT SetOffsetY(IDCompositionAnimation animation);
	/// Changes the value of the OffsetZ property.
	HRESULT SetOffsetZ(float offsetZ);
    /// Animates the value of the OffsetZ property.
	HRESULT SetOffsetZ(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionScaleTransform3D, "2A9E9EAD-364B-4b15-A7C4-A1997F78B389"));
/// An IDCompositionScaleTransform3D interface represents a 3D transformation that
/// affects the scale of a visual along the x, y and z axes. The coordinate system
/// is scaled from the specified center point.
interface IDCompositionScaleTransform3D : IDCompositionTransform3D
{
	extern(Windows):
    /// Changes the value of the ScaleX property.
	HRESULT SetScaleX(float scaleX);
    /// Animates the value of the ScaleX property.
	HRESULT SetScaleX(IDCompositionAnimation animation);
    /// Changes the value of the ScaleY property.
	HRESULT SetScaleY(float scaleY);
    /// Animates the value of the ScaleY property.
	HRESULT SetScaleY(IDCompositionAnimation animation);
    /// Changes the value of the ScaleZ property.
	HRESULT SetScaleZ(float scaleZ);
    /// Animates the value of the ScaleZ property.
	HRESULT SetScaleZ(IDCompositionAnimation animation);
    /// Changes the value of the CenterX property.
	HRESULT SetCenterX(float centerX);
    /// Animates the value of the CenterX property.
	HRESULT SetCenterX(IDCompositionAnimation animation);
    /// Changes the value of the CenterY property.
	HRESULT SetCenterY(float centerY);
    /// Animates the value of the CenterY property.
	HRESULT SetCenterY(IDCompositionAnimation animation);
    /// Changes the value of the CenterZ property.
	HRESULT SetCenterZ(float centerZ);
    /// Animates the value of the CenterZ property.
	HRESULT SetCenterZ(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionRotateTransform3D, "D8F5B23F-D429-4a91-B55A-D2F45FD75B18"));
/// An IDCompositionRotateTransform3D interface represents a 3D transformation
/// that affects the rotation of a visual along the specified axis at the
/// specified center point.
interface IDCompositionRotateTransform3D : IDCompositionTransform3D
{
	extern(Windows):
    /// Changes the value of the Angle property.
	HRESULT SetAngle(float angle);
    /// Animates the value of the Angle property.
	HRESULT SetAngle(IDCompositionAnimation animation);
    /// Changes the value of the AxisX property.
	HRESULT SetAxisX(float axisX);
    /// Animates the value of the AxisX property.
	HRESULT SetAxisX(IDCompositionAnimation animation);
    /// Changes the value of the AxisY property.
	HRESULT SetAxisY(float axisY);
    /// Animates the value of the AxisY property.
    HRESULT SetAxisY(IDCompositionAnimation animation);
    /// Changes the value of the AxisZ property.
    HRESULT SetAxisZ(float axisZ);
    /// Animates the value of the AxisZ property.
    HRESULT SetAxisZ(IDCompositionAnimation animation);
    /// Changes the value of the CenterX property.
    HRESULT SetCenterX(float centerX);
    /// Animates the value of the CenterX property.
    HRESULT SetCenterX(IDCompositionAnimation animation);
    /// Changes the value of the CenterY property.
    HRESULT SetCenterY(float centerY);
    /// Animates the value of the CenterY property.
    HRESULT SetCenterY(IDCompositionAnimation animation);
    /// Changes the value of the CenterZ property.
    HRESULT SetCenterZ(float centerZ);
    /// Animates the value of the CenterZ property.
	HRESULT SetCenterZ(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionMatrixTransform3D, "4B3363F0-643B-41b7-B6E0-CCF22D34467C"));
/// An IDCompositionMatrixTransform3D interface represents an arbitrary
/// 3D transformation defined by a 4x4 matrix.
interface IDCompositionMatrixTransform3D : IDCompositionTransform3D
{
	extern(Windows):
    /// Changes all values of the matrix of this transform.
    HRESULT SetMatrix(const(D3DMATRIX)* matrix);
    /// Changes a single element of the matrix of this transform.
    HRESULT SetMatrixElement(int row, int column, float value);
    /// Animates a single element of the matrix of this transform.
    HRESULT SetMatrixElement(int row, int column, IDCompositionAnimation animation);
}
mixin(uuid!(IDCompositionClip, "64AC3703-9D3F-45ec-A109-7CAC0E7A13A7"));
/// An IDCompositionClip interface represents a rectangle that restricts the
/// rasterization of a visual subtree.
interface IDCompositionClip : IUnknown {}
mixin(uuid!(IDCompositionRectangleClip, "9842AD7D-D9CF-4908-AED7-48B51DA5E7C2"));
/// An IDCompositionRectangleClip interface represents a rectangle that restricts
/// the rasterization of a visual subtree.
interface IDCompositionRectangleClip : IDCompositionClip
{
	extern(Windows):
    /// Changes the value of the Left property.
    HRESULT SetLeft(float left);
    /// Animates the value of the Left property.
    HRESULT SetLeft(IDCompositionAnimation animation);
    /// Changes the value of the Top property.
    HRESULT SetTop(float top);
    /// Animates the value of the Top property.
    HRESULT SetTop(IDCompositionAnimation animation);
    /// Changes the value of the Right property.
    HRESULT SetRight(float right);
    /// Animates the value of the Right property.
    HRESULT SetRight(IDCompositionAnimation animation);
    /// Changes the value of the Bottom property.
    HRESULT SetBottom(float bottom);
    /// Animates the value of the Bottom property.
    HRESULT SetBottom(IDCompositionAnimation animation);
    /// Changes the value of the x radius of the ellipse that rounds the
    /// top-left corner of the clip.
    HRESULT SetTopLeftRadiusX(float radius);
    /// Animates the value of the x radius of the ellipse that rounds the
    /// top-left corner of the clip.
    HRESULT SetTopLeftRadiusX(IDCompositionAnimation animation);
    /// Changes the value of the y radius of the ellipse that rounds the
    /// top-left corner of the clip.
    HRESULT SetTopLeftRadiusY(float radius);
    /// Animates the value of the y radius of the ellipse that rounds the
    /// top-left corner of the clip.
    HRESULT SetTopLeftRadiusY(IDCompositionAnimation animation);
    /// Changes the value of the x radius of the ellipse that rounds the
    /// top-right corner of the clip.
    HRESULT SetTopRightRadiusX(float radius);
    /// Animates the value of the x radius of the ellipse that rounds the
    /// top-right corner of the clip.
    HRESULT SetTopRightRadiusX(IDCompositionAnimation animation);
    /// Changes the value of the y radius of the ellipse that rounds the
    /// top-right corner of the clip.
    HRESULT SetTopRightRadiusY(float radius);
    /// Animates the value of the y radius of the ellipse that rounds the
    /// top-right corner of the clip.
    HRESULT SettopRightRadiusY(IDCompositionAnimation animation);
    /// Changes the value of the x radius of the ellipse that rounds the
    /// bottom-left corner of the clip.
    HRESULT SetBottomLeftRadiusX(float radius);
    /// Animates the value of the x radius of the ellipse that rounds the
    /// bottom-left corner of the clip.
    HRESULT SetBottomLeftRadiusX(IDCompositionAnimation animation);
    /// Changes the value of the y radius of the ellipse that rounds the
    /// bottom-left corner of the clip.
    HRESULT SetBottomLeftRadiusY(float radius);
    /// Animates the value of the y radius of the ellipse that rounds the
    /// bottom-left corner of the clip.
    HRESULT SetBottomLeftRadiusY(IDCompositionAnimation animation);
    /// Changes the value of the x radius of the ellipse that rounds the
    /// bottom-right corner of the clip.
    HRESULT SetBottomRightRadiusX(float radius);
    /// Animates the value of the x radius of the ellipse that rounds the
    /// bottom-right corner of the clip.
    HRESULT SetBottomRightRadiusX(IDCompositionAnimation animation);
    /// Changes the value of the y radius of the ellipse that rounds the
    /// bottom-right corner of the clip.
    HRESULT SetBottomRightRadiusY(float radius);
    /// Animates the value of the y radius of the ellipse that rounds the
    /// bottom-right corner of the clip.
    HRESULT SetBottomRightRadiusY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionSurface, "BB8A4953-2C99-4F5A-96F5-4819027FA3AC"));
/// An IDCompositionSurface interface represents a wrapper around a DirectX
/// object, or a sub-rectangle of one of those objects.
interface IDCompositionSurface : IUnknown
{
	extern(Windows):
	HRESULT BeginDraw(const(RECT)* updateRect, REFIID iid, void** updateObject, POINT* updateOffset);
	HRESULT EndDraw();
	HRESULT SuspendDraw();
	HRESULT ResumeDraw();
	HRESULT Scroll(
		const(RECT)* scrollRect,
		const(RECT)* clipRect,
		int offsetX,
		int offsetY);
}
mixin(uuid!(IDCompositionVirtualSurface, "AE471C51-5F53-4A24-8D3E-D0C39C30B3F0"));
/// An IDCompositionVirtualSurface interface represents a sparsely
/// allocated surface.
interface IDCompositionVirtualSurface : IDCompositionSurface
{
	extern(Windows):
	HRESULT Resize(UINT width, UINT height);
	HRESULT Trim(const(RECT)* rectangles, UINT count);
}

mixin(uuid!(IDCompositionDevice2, "75F6468D-1B8E-447C-9BC6-75FEA80B5B25"));
/// Serves as the root factory for all other DirectComposition2 objects and
/// controls transactional composition.
interface IDCompositionDevice2 : IUnknown
{
	extern(Windows):
    /// Commits all DirectComposition commands pending on this device.
    HRESULT Commit();
    /// Waits for the last Commit to be processed by the composition engine
    HRESULT WaitForCommitCompletion();
    /// Gets timing information about the composition engine.
    HRESULT GetFrameStatistics(DCOMPOSITION_FRAME_STATISTICS* statistics);
    /// Creates a new visual object.
    HRESULT CreateVisual(IDCompositionVisual2* visual);
    /// Creates a factory for surface objects
    HRESULT CreateSurfaceFactory(IUnknown renderingDevice, IDCompositionSurfaceFactory* surfaceFactory);
    /// Creates a DirectComposition surface object
    HRESULT CreateSurface(
		UINT width,
		UINT height,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionSurface* surface);
    /// Creates a DirectComposition virtual surface object
    HRESULT CreateVirtualSurface(
		UINT initialWidth,
		UINT initialHeight,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionVirtualSurface* virtualSurface);
    /// Creates a 2D translation transform object.
    HRESULT CreateTranslateTransform(IDCompositionTranslateTransform* translateTransform);
    /// Creates a 2D scale transform object.
    HRESULT CreateScaleTransform(IDCompositionScaleTransform* scaleTransform);
    /// Creates a 2D rotation transform object.
    HRESULT CreateRotateTransform(IDCompositionRotateTransform* rotateTransform);
    /// Creates a 2D skew transform object.
    HRESULT CreateSkewTransform(IDCompositionSkewTransform* skewTransform);
    /// Creates a 2D 3x2 matrix transform object.
    HRESULT CreateMatrixTransform(IDCompositionMatrixTransform* matrixTransform);
    /// Creates a 2D transform object that holds an array of 2D transform objects.
    HRESULT CreateTransformGroup(
		IDCompositionTransform* transforms, UINT elements,
		IDCompositionTransform* transformGroup);
    /// Creates a 3D translation transform object.
    HRESULT CreateTranslateTransform3D(IDCompositionTranslateTransform3D* translateTransform3D);
    /// Creates a 3D scale transform object.
    HRESULT CreateScaleTransform3D(IDCompositionScaleTransform3D* scaleTransform3D);
    /// Creates a 3D rotation transform object.
	HRESULT CreateRotateTransform3D(IDCompositionRotateTransform3D* rotateTransfrom3D);
    /// Creates a 3D 4x4 matrix transform object.
	HRESULT CreateMatrixTransform3D(IDCompositionMatrixTransform3D* matrixTransform3D);
    /// Creates a 3D transform object that holds an array of 3D transform objects.
	HRESULT CreateTransform3DGroup(
		IDCompositionTransform3D* transforms3D, UINT elements,
		IDCompositionTransform3D* transform3DGroup);
    /// Creates an effect group
	HRESULT CreateEffectGroup(IDCompositionEffectGroup* effectGroup);
    /// Creates a clip object that can be used to clip the contents of a visual subtree.
    HRESULT CreateRectangleClip(IDCompositionRectangleClip* clip);
    /// Creates an animation object
	HRESULT CreateAnimation(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionDesktopDevice, "5F4633FE-1E08-4CB8-8C75-CE24333F5602"));
/// Serves as the root factory for all other desktop DirectComposition
/// objects.
interface IDCompositionDesktopDevice : IDCompositionDevice2
{
	extern(Windows):
	HRESULT CreateTargetForHwnd(HWND hwnd, BOOL topmost, IDCompositionTarget* target);
    /// Creates a surface wrapper around a pre-existing surface that can be associated with one or more visuals for composition.
    HRESULT CreateSurfaceFromHandle(HANDLE handle, IUnknown* surface);
    /// Creates a wrapper object that represents the rasterization of a layered window and which can be associated with a visual for composition.
    HRESULT CreateSurfaceFromHwnd(HWND hwnd, IUnknown* surface);
}

mixin(uuid!(IDCompositionDeviceDebug, "A1A3C64A-224F-4A81-9773-4F03A89D3C6C"));
/// IDCompositionDeviceDebug serves as a debug interface
interface IDCompositionDeviceDebug : IUnknown
{
	extern(Windows):
    /// Enables debug counters
	HRESULT EnableDebugCounters();
    /// Enables debug counters
	HRESULT DisableDebugCounters();
}

mixin(uuid!(IDCompositionSurfaceFactory, "E334BC12-3937-4E02-85EB-FCF4EB30D2C8"));
/// An IDCompositionSurfaceFactory interface represents an object that can
/// create surfaces suitable for composition.
interface IDCompositionSurfaceFactory : IUnknown
{
	extern(Windows):
    /// Creates a DirectComposition surface object
    HRESULT CreateSurface(
		UINT width,
		UINT height,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionSurface* surface);
    /// Creates a DirectComposition virtual surface object
    HRESULT CreateVirtualSurface(
		UINT initialWidth,
		UINT initialHeight,
		DXGI_FORMAT pixelFormat,
		DXGI_ALPHA_MODE alphaMode,
		IDCompositionVirtualSurface* virtualSurface);
}

mixin(uuid!(IDCompositionVisual2, "E8DE1639-4331-4B26-BC5F-6A321D347A85"));
/// An IDCompositionVisual2 interface represents a visual that participates in
/// a visual tree.
interface IDCompositionVisual2 : IDCompositionVisual
{
	extern(Windows):
    /// Changes the interpretation of the opacity property of an effect group
    /// associated with this visual
    HRESULT SetOpacityMode(DCOMPOSITION_OPACITY_MODE mode);
    /// Sets back face visibility
    HRESULT SetBackFaceVisibility(DCOMPOSITION_BACKFACE_VISIBILITY visibility);
}

mixin(uuid!(IDCompositionVisualDebug, "FED2B808-5EB4-43A0-AEA3-35F65280F91B"));
/// An IDCompositionVisualDebug interface represents a debug visual
interface IDCompositionVisualDebug : IDCompositionVisual2
{
	extern(Windows):
    /// Enable heat map
    HRESULT EnableHeatMap(const(D2D1_COLOR_F)* color);
    /// Disable heat map
    HRESULT DisableHeatMap();
    /// Enable redraw regions
	HRESULT EnableRedrawRegions();
    /// Disable redraw regions
	HRESULT DisableRedrawRegions();
}

mixin(uuid!(IDCompositionVisual3, "2775F462-B6C1-4015-B0BE-B3E7D6A4976D"));
/// An IDCompositionVisual3 interface represents a visual that participates in
/// a visual tree.
interface IDCompositionVisual3 : IDCompositionVisualDebug
{
	extern(Windows):
    /// Sets depth mode property associated with this visual
    HRESULT SetDepthMode(DCOMPOSITION_DEPTH_MODE mode);
    /// Changes the value of OffsetZ property.
    HRESULT SetOffsetZ(float offsetZ);
    /// Animates the value of the OffsetZ property.
    HRESULT SetOffsetZ(IDCompositionAnimation animation);
    /// Changes the value of the Opacity property.
    HRESULT SetOpacity(float opacity);
    /// Animates the value of the Opacity property.
    HRESULT SetOpacity(IDCompositionAnimation animation);
    /// Sets the matrix that modifies the coordinate system of this visual.
    HRESULT SetTransform(const(D2D_MATRIX_4X4_F)* matrix);
    /// Sets the transformation object that modifies the coordinate system of this visual.
    HRESULT SetTransform(IDCompositionTransform3D transform);
    /// Changes the value of the Visible property
    HRESULT SetVisible(BOOL visible);
}

mixin(uuid!(IDCompositionDevice3, "0987CB06-F916-48BF-8D35-CE7641781BD9"));
/// Serves as the root factory for all other DirectComposition3 objects and
/// controls transactional composition.
interface IDCompositionDevice3 : IDCompositionDevice2
{
	extern(Windows):
    /// Effect creation calls, each creates an interface around a D2D1Effect
    HRESULT CreateGaussianBlurEffect(IDCompositionGaussianBlurEffect* gaussianBlurEffect);
	HRESULT CreateBrightnessEffect(IDCompositionBrightnessEffect* brightnessEffect);
    HRESULT CreateColorMatrixEffect(IDCompositionColorMatrixEffect* colorMatrixEffect);
	HRESULT CreateShadowEffect(IDCompositionShadowEffect* shadowEffect);
    HRESULT CreateHueRotationEffect(IDCompositionHueRotationEffect* hueRotationEffect);
    HRESULT CreateSaturationEffect(IDCompositionSaturationEffect* saturationEffect);
    HRESULT CreateTurbulenceEffect(IDCompositionTurbulenceEffect* turbulenceEffect);
    HRESULT CreateLinearTransferEffect(IDCompositionLinearTransferEffect* linearTransferEffect);
    HRESULT CreateTableTransferEffect(IDCompositionTableTransferEffect* tableTransferEffect);
    HRESULT CreateCompositeEffect(IDCompositionCompositeEffect* compositeEffect);
    HRESULT CreateBlendEffect(IDCompositionBlendEffect* blendEffect);
	HRESULT CreateArithmeticCompositeEffect(IDCompositionArithmeticCompositeEffect* arithmeticCompositeEffect);
    HRESULT CreateAffineTransform2DEffect(IDCompositionAffineTransform2DEffect* affineTransform2dEffect);
}

mixin(uuid!(IDCompositionFilterEffect, "30C421D5-8CB2-4E9F-B133-37BE270D4AC2"));
/// An IDCompositionFilterEffect interface represents a filter effect
interface IDCompositionFilterEffect : IDCompositionEffect
{
	extern(Windows):
    /// Sets the input at the given index to the filterEffect (NULL will use source visual, unless flagged otherwise)
    HRESULT SetInput(UINT index, IUnknown input, UINT flags);
}

mixin(uuid!(IDCompositionGaussianBlurEffect, "45D4D0B7-1BD4-454E-8894-2BFA68443033"));
/// An IDCompositionGaussianBlurEffect interface represents a gaussian blur filter effect
interface IDCompositionGaussianBlurEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the amount of blur to be applied.
    HRESULT SetStandardDeviation(float amount);
    HRESULT SetStandardDeviation(IDCompositionAnimation animation);
    /// Changes border mode (see D2D1_GAUSSIANBLUR)
    HRESULT SetBorderMode(D2D1_BORDER_MODE mode);
}

mixin(uuid!(IDCompositionBrightnessEffect, "6027496E-CB3A-49AB-934F-D798DA4F7DA6"));
/// An IDCompositionBrightnessEffect interface represents a brightness filter effect
interface IDCompositionBrightnessEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the value of white point property.
    HRESULT SetWhitePoint(const(D2D1_VECTOR_2F)* whitePoint);
    /// Changes the value of black point property
    HRESULT SetBlackPoint(const(D2D1_VECTOR_2F)* blackPoint);
    /// Changes the X value of the white point property.
    HRESULT SetWhitePointX(float whitePointX);
    HRESULT SetWhitePointX(IDCompositionAnimation animation);
    /// Changes the Y value of the white point property.
    HRESULT SetWhitePointY(float whitePointY);
    HRESULT SetWhitePointY(IDCompositionAnimation animation);
    /// Changes the X value of the black point property.
    HRESULT SetBlackPointX(float blackPointX);
    HRESULT SetBlackPointX(IDCompositionAnimation animation);
    /// Changes the Y value of the black point property.
    HRESULT SetBlackPointY(float blackPointY);
    HRESULT SetBlackPointY(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionColorMatrixEffect, "C1170A22-3CE2-4966-90D4-55408BFC84C4"));
/// An IDCompositionColorMatrixEffect interface represents a color matrix filter effect
interface IDCompositionColorMatrixEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes all values of the matrix for a color transform
    HRESULT SetMatrix(const(D2D1_MATRIX_5X4_F)* matrix);
    /// Changes a single element of the matrix of this color transform.
    HRESULT SetMatrixElement(int row, int column, float value);
    /// Animates a single element of the matrix of this color transform.
    HRESULT SetMatrixElement(int row, int column, IDCompositionAnimation animation);
    /// Changes the alpha mode
    HRESULT SetAlphaMode(D2D1_COLORMATRIX_ALPHA_MODE mode);
    /// Sets the clamp output property
    HRESULT SetClampOutput(BOOL clamp);
}

mixin(uuid!(IDCompositionShadowEffect, "4AD18AC0-CFD2-4C2F-BB62-96E54FDB6879"));
/// An IDCompositionShadowEffect interface represents a shadow filter effect
interface IDCompositionShadowEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the amount of blur to be applied.
    HRESULT SetStandardDeviation(float amount);
    HRESULT SetStandardDeviation(IDCompositionAnimation animation);
    /// Changes shadow color
    HRESULT SetColor(const(D2D1_VECTOR_4F)* color);
    HRESULT SetRed(float amount);
    HRESULT SetRed(IDCompositionAnimation animation);
    HRESULT SetGreen(float amount);
    HRESULT SetGreen(IDCompositionAnimation animation);
    HRESULT SetBlue(float amount);
    HRESULT SetBlue(IDCompositionAnimation animation);
    HRESULT SetAlpha(float amount);
    HRESULT SetAlpha(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionHueRotationEffect, "6DB9F920-0770-4781-B0C6-381912F9D167"));
/// An IDCompositionHueRotationEffect interface represents a hue rotation filter effect
interface IDCompositionHueRotationEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the angle of rotation
    HRESULT SetAngle(float amountDegrees);
    HRESULT SetAngle(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionSaturationEffect, "A08DEBDA-3258-4FA4-9F16-9174D3FE93B1"));
/// An IDCompositionSaturationEffect interface represents a saturation filter effect
interface IDCompositionSaturationEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the amount of saturation to be applied.
    HRESULT SetSaturation(float ratio);
    HRESULT SetSaturation(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionTurbulenceEffect, "A6A55BDA-C09C-49F3-9193-A41922C89715"));
/// An IDCompositionTurbulenceEffect interface represents a turbulence filter effect
interface IDCompositionTurbulenceEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the starting offset of the turbulence
    HRESULT SetOffset(const(D2D1_VECTOR_2F)* offset);
    /// Changes the base frequency of the turbulence
    HRESULT SetBaseFrequency(const(D2D1_VECTOR_2F)* frequency);
    /// Changes the output size of the turbulence
    HRESULT SetSize(const(D2D1_VECTOR_2F)* size);
    /// Sets the number of octaves
    HRESULT SetNumOctaves(UINT numOctaves);
    /// Set the random number seed
    HRESULT SetSeed(UINT seed);
    /// Set the noise mode
    HRESULT SetNoise(D2D1_TURBULENCE_NOISE noise);
    /// Set stitchable
    HRESULT SetStitchable(BOOL stitchable);
}

mixin(uuid!(IDCompositionLinearTransferEffect, "4305EE5B-C4A0-4C88-9385-67124E017683"));
/// An IDCompositionLinearTransferEffect interface represents a linear transfer filter effect
interface IDCompositionLinearTransferEffect : IDCompositionFilterEffect
{
	extern(Windows):
    HRESULT SetRedYIntercept(float redYIntercept);
    HRESULT SetRedYIntercept(IDCompositionAnimation animation);
    HRESULT SetRedSlope(float redSlope);
    HRESULT SetRedSlope(IDCompositionAnimation animation);
    HRESULT SetRedDisable(BOOL redDisable);
    HRESULT SetGreenYIntercept(float greenYIntercept);
    HRESULT SetGreenYIntercept(IDCompositionAnimation animation);
    HRESULT SetGreenSlope(float greenSlope);
    HRESULT SetGreenSlope(IDCompositionAnimation animation);
    HRESULT SetGreenDisable(BOOL greenDisable);
    HRESULT SetBlueYIntercept(float blueYIntercept);
    HRESULT SetBlueYIntercept(IDCompositionAnimation animation);
    HRESULT SetBlueSlope(float blueSlope);
    HRESULT SetBlueSlope(IDCompositionAnimation animation);
    HRESULT SetBlueDisable(BOOL blueDisable);
    HRESULT SetAlphaYIntercept(float alphaYIntercept);
    HRESULT SetAlphaYIntercept(IDCompositionAnimation animation);
    HRESULT SetAlphaSlope(float alphaSlope);
    HRESULT SetAlphaSlope(IDCompositionAnimation animation);
    HRESULT SetAlphaDisable(BOOL alphaDisable);
    HRESULT SetClampOutput(BOOL clampOutput);
}

mixin(uuid!(IDCompositionTableTransferEffect, "9B7E82E2-69C5-4EB4-A5F5-A7033F5132CD"));
/// An IDCompositionTableTransferEffect interface represents a Table transfer filter effect
interface IDCompositionTableTransferEffect : IDCompositionFilterEffect
{
	extern(Windows):
    HRESULT SetRedTable(const(float)* tableValues, UINT count);
    HRESULT SetGreenTable(const(float)* tableValues, UINT count);
    HRESULT SetBlueTable(const(float)* tableValues, UINT count);
    HRESULT SetAlphaTable(const(float)* tableValues, UINT count);
    HRESULT SetRedDisable(BOOL redDisable);
    HRESULT SetGreenDisable(BOOL greenDisable);
    HRESULT SetBlueDisable(BOOL blueDisable);
    HRESULT SetAlphaDisable(BOOL alphaDisable);
    HRESULT SetClampOutput(BOOL clampOutput);
    /// Note:  To set individual values, the table must have already been initialized
    ////   with a buffer of values of the appropriate size, or these calls will fail
    HRESULT SetRedTableValue(UINT index, float value);
    HRESULT SetRedTableValue(UINT index, IDCompositionAnimation animation);
    HRESULT SetGreenTableValue(UINT index, float value);
    HRESULT SetGreenTableValue(UINT index, IDCompositionAnimation animation);
    HRESULT SetBlueTableValue(UINT index, float value);
    HRESULT SetBlueTableValue(UINT index, IDCompositionAnimation animation);
    HRESULT SetAlphaTableValue(UINT index, float value);
    HRESULT SetAlphaTableValue(UINT index, IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionCompositeEffect, "576616C0-A231-494D-A38D-00FD5EC4DB46"));
/// An IDCompositionCompositeEffect interface represents a composite filter effect
interface IDCompositionCompositeEffect : IDCompositionFilterEffect
{
	extern(Windows):
    /// Changes the composite mode.
    HRESULT SetMode(D2D1_COMPOSITE_MODE mode);
}

mixin(uuid!(IDCompositionBlendEffect, "33ECDC0A-578A-4A11-9C14-0CB90517F9C5"));
/// An IDCompositionBlendEffect interface represents a blend filter effect
interface IDCompositionBlendEffect : IDCompositionFilterEffect
{
	extern(Windows):
    HRESULT SetMode(D2D1_BLEND_MODE mode);
}

mixin(uuid!(IDCompositionArithmeticCompositeEffect, "3B67DFA8-E3DD-4E61-B640-46C2F3D739DC"));
/// An IDCompositionArithmeticCompositeEffect interface represents an arithmetic composite filter effect
interface IDCompositionArithmeticCompositeEffect : IDCompositionFilterEffect
{
	extern(Windows):
    HRESULT SetCoefficients(const(D2D1_VECTOR_4F)* coefficients);
    HRESULT SetClampOutput(BOOL clampoutput);
    HRESULT SetCoefficient1(float Coeffcient1);
    HRESULT SetCoefficient1(IDCompositionAnimation animation);
    HRESULT SetCoefficient2(float Coefficient2);
    HRESULT SetCoefficient2(IDCompositionAnimation animation);
    HRESULT SetCoefficient3(float Coefficient3);
    HRESULT SetCoefficient3(IDCompositionAnimation animation);
    HRESULT SetCoefficient4(float Coefficient4);
    HRESULT SetCoefficient4(IDCompositionAnimation animation);
}

mixin(uuid!(IDCompositionAffineTransform2DEffect, "0B74B9E8-CDD6-492F-BBBC-5ED32157026D"));
/// An IDCompositionAffineTransform2DEffect interface represents a affine transform 2D filter effect
interface IDCompositionAffineTransform2DEffect : IDCompositionFilterEffect
{
	extern(Windows):
    HRESULT SetInterpolationMode(D2D1_2DAFFINETRANSFORM_INTERPOLATION_MODE interpolationMode);
    HRESULT SetBorderMode(D2D1_BORDER_MODE borderMode);
    HRESULT SetTransformMatrix(const(D2D1_MATRIX_3X2_F)* transformMatrix);
    HRESULT SetTransformMatrixElement(int row, int column, float value);
    HRESULT SetTransformMatrixElement(int row, int column, IDCompositionAnimation animation);
    HRESULT SetSharpness(float sharpness);
    HRESULT SetSharpness(IDCompositionAnimation animation);
}
