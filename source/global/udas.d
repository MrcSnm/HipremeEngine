/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module global.udas;

/**
* UDA used together with runtime debugger, it won't print if it has this attribute
*/
struct Hidden;

/**
* UDA used together with runtime debugger, mark your class member for being able to change
* the target property on the runtime console
*/
struct RuntimeConsole;
