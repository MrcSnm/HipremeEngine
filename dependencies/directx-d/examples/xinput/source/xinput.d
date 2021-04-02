/*
Simple XInput tutorial
*/

import core.thread;
import core.stdc.string; // for memset
import core.stdc.stdlib : system;
import std.math;
import std.process;
import std.stdio;
import std.string;

import directx.xinput;
import directx.win32;

int xinput_tutorial()
{
	DWORD dwResult;
	bool found = false;
	
	// get first controller and do some IO, 
	// you can modify the loop to iterate over all users(gamepads) instead to perform 'parallel' test
	for (DWORD i=0; i< XUSER_MAX_COUNT; i++ )
	{
		XINPUT_STATE state;
		memset( &state, 0, XINPUT_STATE.sizeof );

        // Simply get the state of the controller from XInput.
        dwResult = XInputGetState( i, &state );

        if( dwResult == ERROR_SUCCESS )
		{
			found = true;
			bool vibro = false;
			bool start_held = false;
			
			while(true)
			{
				XInputGetState(i, &state);
			
				// =============== LEFT STICK
				float LX = state.Gamepad.sThumbLX;
				float LY = state.Gamepad.sThumbLY;

				//determine how far the controller is pushed
				float magnitudeL = sqrt(LX*LX + LY*LY);

				//determine the direction the controller is pushed
				float normalizedLX = LX / magnitudeL;
				float normalizedLY = LY / magnitudeL;

				float normalizedMagnitudeL = 0;

				//check if the controller is outside a circular dead zone
				if (magnitudeL > XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)
				{
					//clip the magnitude at its expected maximum value
					if (magnitudeL > 32767) magnitudeL = 32767;

					//adjust magnitude relative to the end of the dead zone
					magnitudeL -= XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;

					//optionally normalize the magnitude with respect to its expected range
					//giving a magnitude value of 0.0 to 1.0
					normalizedMagnitudeL = magnitudeL / (32767 - XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE);
				}
				else //if the controller is in the deadzone zero out the magnitude
				{
					magnitudeL = 0.0;
					normalizedMagnitudeL = 0.0;
				}
				
				// =============== RIGHT STICK
				float RX = state.Gamepad.sThumbRX;
				float RY = state.Gamepad.sThumbRY;

				//determine how far the controller is pushed
				float magnitudeR = sqrt(RX*RX + RY*RY);

				//determine the direction the controller is pushed
				float normalizedRX = RX / magnitudeR;
				float normalizedRY = RY / magnitudeR;

				float normalizedMagnitudeR = 0;

				//check if the controller is outside a circular dead zone
				if (magnitudeR > XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE)
				{
					//clip the magnitude at its expected maximum value
					if (magnitudeR > 32767) magnitudeR = 32767;

					//adjust magnitude relative to the end of the dead zone
					magnitudeR -= XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE;

					//optionally normalize the magnitude with respect to its expected range
					//giving a magnitude value of 0.0 to 1.0
					normalizedMagnitudeR = magnitudeR / (32767 - XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE);
				}
				else //if the controller is in the deadzone zero out the magnitude
				{
					magnitudeR = 0.0;
					normalizedMagnitudeR = 0.0;
				}
				// ================================

				// system call to clear console
				system("cls");
			
				writeln("prees [B] to stop\npress [start] to toggle vibration on/off\n\n");
				writefln( "\t\t[LS]\t\t[RS]\n[NormalizedX]\t%f\t%f\n[NormalizedY]\t%f\t%f\n[Magnitude]\t%f\t%f\n\n",   normalizedLX, normalizedRX, 
										normalizedLY, normalizedRY, normalizedMagnitudeL, normalizedMagnitudeR );
				writefln( "buttons(masks) [%x]\n" , state.Gamepad.wButtons );

				// check if [B] button pressed to quit
				if  ( (state.Gamepad.wButtons & XINPUT_GAMEPAD_B) != 0)
					return 0;
				
				// toggle check for [start]
				if  ( (state.Gamepad.wButtons & XINPUT_GAMEPAD_START) != 0) {
					if ( !start_held ) {
						vibro = !vibro;
						start_held = true;
					}
					
					XINPUT_VIBRATION vibration; // this should be memset'ed in C++ but it works in D as is
					vibration.wLeftMotorSpeed = vibro ? 8000 : 0; // use any value between 0-65535 here
					vibration.wRightMotorSpeed = vibro ? 12000 : 0; // use any value between 0-65535 here
					XInputSetState( i, &vibration );
				}
				else
				{
					if ( start_held )
						start_held = false;
				}

				Thread.sleep(dur!"msecs"(30));
			}
		}
        
	}
	
	if ( !found )
	{
		writeln("no xbox360 controllers connected");
	}

	return 0;
}

void main()
{
	xinput_tutorial();
}