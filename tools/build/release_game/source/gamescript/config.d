module gamescript.config;
import hip.api.graphics.color;

///16/9 will be the main game scale
enum GAME_WIDTH = 1280;
enum GAME_HEIGHT = 720;

enum CURSOR_SELECTED_COLOR = HipColor(1.0, 0.0, 0.0, 0.6);
enum CURSOR_HOVER_COLOR = HipColor(1.0, 0.0, 0.0, 0.4);


enum int BOARD_OFFSET_X = 600;
enum int BOARD_OFFSET_Y = (GAME_HEIGHT - BOARD_SIZE) / 2;
enum BOARD_SIZE = 600;
enum BOARD_PIECES = 8;
enum PRESS_ENTER_TWEEN_TIME = 1.5;

enum PIECE_FALL_FROM_Y = -300f;
enum PIECE_FALL_TIME = 0.5f;
enum PIECE_DISTANCE_MULTIPLIER = 1;
enum PIECE_SWAP_TIME = 0.25;