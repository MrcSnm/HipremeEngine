module math.rect;
import bindbc.sdl;

struct Size
{
    uint w, h;

    alias width = w;
    alias height = h;
}

/**
*   Simple struct for running from SDL_Rect
*/
alias Rect = SDL_Rect;