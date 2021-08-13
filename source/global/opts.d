/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

/**
* This module is used for mantaining global options related to the engine
*/ 
module global.opts;

/**
*   Use that for mainly mantaining engine related debug things
*/
enum HE_DEBUG = true;

/**
*   Used for disabling every engine log function
*/
enum HE_NO_LOG = false;

/**
*   Mantain only error related logging
*/
enum HE_ERR_ONLY = false; 