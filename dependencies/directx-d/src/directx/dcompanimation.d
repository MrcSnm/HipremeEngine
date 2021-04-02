module directx.dcompanimation;
//---------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation.  All rights reserved.
//
//---------------------------------------------------------------------------

version(Windows):

public import directx.com, directx.dcommon;

mixin(uuid!(IDCompositionAnimation, "CBFD91D9-51B2-45e4-B3DE-D19CCFB863C5"));
interface IDCompositionAnimation : IUnknown
{
	extern(Windows):
	HRESULT Reset();
	HRESULT SetAbsoluteBeginTime(LARGE_INTEGER beginTime);
	HRESULT AddCubic(
		double beginOffset,
		float constantCoefficient,
		float linearCoefficient,
		float quadraticCoefficient,
		float cubicCoefficient);
	HRESULT AddSinusoidal(
		double beginOffset,
		float bias,
		float amplitude,
		float frequency,
		float phase);
	HRESULT AddRepeat(
		double beginOffset,
		double durationToRepeat);
	HRESULT End(
		double endOffset,
		float endValue);
}
