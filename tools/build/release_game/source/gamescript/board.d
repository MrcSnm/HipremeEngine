module gamescript.board;
import hip.util.conv;
import hip.math.utils;
import hip.api;
import hip.util.algorithm;
import hip.tween;

import gamescript.level;
import gamescript.config;
import gamescript.piece;
import gamescript.game;

private enum spritesheetRows = 7;
private enum spritesheetColumns = 7;
private enum byte[2] nullPiece = [-1, -1];

class Board : IHipPreloadable
{
    mixin Preload;

    @Asset("sprites/assets_candy.png")
    IHipTexture boardSprites;

    @Asset("sprites/explotion.png")
    IHipTexture explosionTexture;


    //Visuals
    Cursor cursor;
    Spritesheet spritesheet;
    IHipTextureRegion[] candies;
    Piece[][] board;




    IHipAnimationTrack explosionAnimation;
    Game game;
    Level currentLevel;

    //Input

    bool canInput = true;
    byte[2] selectedPiece = nullPiece;


    protected float pieceScaleX = 0;
    protected float pieceScaleY = 0;

    protected int xOffsetPerCandy;
    protected int yOffsetPerCandy;

    protected int pieceWidth = 100;
    protected int pieceHeight = 100;


    this(Game game)
    {
        this.game = game;
        preload();

        logg((HipAssetManager.get!IHipTexture("sprites/assets_candy.png")).getWidth);
        cursor = new Cursor(this);

        explosionAnimation = newHipAnimationTrack("Explosion", 24)
            .addFrames(
                cropSpritesheetRowsAndColumns(explosionTexture, 2, 4)
            );

        import hip.util.conv;
        spritesheet = cropSpritesheetRowsAndColumns(boardSprites, spritesheetRows, spritesheetColumns);
        board = new Piece[][](BOARD_PIECES, BOARD_PIECES);
        for(int i = 0; i < 3; i++)
            for(int j = 0; j < 5; j++)
                candies~= spritesheet[i, j];

        pieceScaleX = cast(float)(BOARD_SIZE / BOARD_PIECES) / candies[0].getWidth();
        pieceScaleY = cast(float)(BOARD_SIZE / BOARD_PIECES) / candies[0].getHeight();
        pieceWidth = cast(int)(candies[0].getWidth*pieceScaleX);
        pieceHeight = cast(int)(candies[0].getHeight*pieceScaleY);

        
    }

    void setLevel (Level level, void delegate() onLevelChange)
    {
        assert(level !is null);
        currentLevel = level;

        for(ubyte y = 0; y < BOARD_PIECES; y++)
            for(ubyte x = 0; x < BOARD_PIECES; x++)
                board[y][x] = null;
        level.greetLevel(()
        {
            generateBoard();
            onLevelChange();
        });
    }

    final void generateBoard ()
    {
        xOffsetPerCandy = cast(int)(candies[0].getWidth() * pieceScaleX *  PIECE_DISTANCE_MULTIPLIER);
        yOffsetPerCandy = cast(int)(candies[0].getHeight() * pieceScaleY * PIECE_DISTANCE_MULTIPLIER);

        for(ubyte y = 0; y < BOARD_PIECES; y++)
        {   
            for(ubyte x = 0; x < BOARD_PIECES; x++)
            {
                board[y][x] = getNewPiece(x, y);
            }
        }

        board[0][0] = new Piece(0, candies[0], 0, 0, 0, 0, pieceScaleX, pieceScaleY);
        board[1][0] = new Piece(0, candies[0], 0, yOffsetPerCandy*1, 0, 1, pieceScaleX, pieceScaleY);
        board[2][0] = new Piece(0, candies[0], 0, yOffsetPerCandy*2, 0, 2, pieceScaleX, pieceScaleY);
    }

    byte[2] getPiecePosition(float[2] worldPos)
    {
        if(worldPos[0] < BOARD_OFFSET_X || worldPos[1] < BOARD_OFFSET_Y)
            return nullPiece;

        
        logVars!worldPos;
        worldPos[0]-= BOARD_OFFSET_X;
        worldPos[1]-= BOARD_OFFSET_Y;

        int x = cast(int)(worldPos[0] / pieceWidth);
        int y = cast(int)(worldPos[1] / pieceHeight);

        return [cast(byte)x, cast(byte)y];
    }

    final void unselectPiece() {selectedPiece = nullPiece;}

    void selectPiece (ubyte x, ubyte y)
    {
        if(!canInput)
            return;
        if(selectedPiece == [x, y])
            unselectPiece();
        else if(selectedPiece != nullPiece)
        {
            if(canMovePieces(selectedPiece[0], selectedPiece[1], x, y))
                swapPieces(selectedPiece[0], selectedPiece[1], x, y);   
            selectedPiece = nullPiece;
        }
        else
            selectedPiece = [x, y];
    }

    bool calculateMatches (out Piece[3][] matches)
    {
        for(int y = 0; y < BOARD_PIECES; y++)
        {
            int matchCount = 1;
            for(int x = 1; x < BOARD_PIECES; x++) 
            {
                if(board[y][x] is null || board[y][x-1] is null)
                {
                    matchCount = 1;
                    continue;
                }
                if(board[y][x].type == board[y][x-1].type)
                {
                    if(++matchCount == 3)
                    {
                        matches~= [board[y][x-2], board[y][x-1], board[y][x]];
                        matchCount = 1;
                    }
                }
                else
                    matchCount = 1;
            }
        }

        for(int x = 0; x < BOARD_PIECES; x++) 
        {
            int matchCount = 1;
            for(int y = 1; y < BOARD_PIECES; y++)
            {
                if(board[y][x] is null || board[y-1][x] is null)
                {
                    matchCount = 1;
                    continue;
                }
                if(board[y][x].type == board[y-1][x].type)
                {
                    if(++matchCount == 3)
                    {
                        matches~= [board[y-2][x], board[y-1][x], board[y][x]];
                        matchCount = 1;
                    }
                }
                else
                    matchCount = 1;
            }
        }
        return matches.length != 0;
    }


    bool canMovePieces (ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        if(x1 >= BOARD_PIECES || y1 >= BOARD_PIECES || x2 >= BOARD_PIECES || y2 >= BOARD_PIECES)
            return false;
        
        int xDiff = abs(x1 - x2);
        int yDiff = abs(y1 - y2);
        
        return xDiff + yDiff == 1; //0 means don't move, greater than 1 means diagonal or far swap
    }

    ///Returns if any piece has fallen
    bool makePiecesFall (IHipTimerList animation)
    {
        bool anyFall = false;
        for(int x = 0; x < BOARD_PIECES; x++)
        {
            //The target must be the board's end
            int targetY = BOARD_PIECES - 1;
            for(int y = BOARD_PIECES - 1; y >= 0; y--)
            {
                if(board[y][x] is null)
                    continue;
                else
                {
                    if(targetY != y) //If there is no in between them, no need to swap
                    {
                        anyFall = true;
                        int yDiff = targetY - y;
                        Piece p = board[y][x];
                        p.gridY = cast(ubyte)targetY;

                        animation.add(
                            HipTween.by!(["y"])(0.1, p, [yDiff * pieceHeight])
                        );
                        swap(board[targetY][x], board[y][x]);
                    }
                    targetY-= 1; //The last empty space will be the one up above
                }
            }
        }
        if(anyFall)
        {
            canInput = false;
            animation.addOnFinish(()
            {
                canInput = true;
                updateBoard(true);
            });
        }
        return anyFall;
    }

    protected Piece getNewPiece (int x, int y)
    {
        assert(x >= 0 && y >= 0, "Can't receive negative new piece");
        int type = currentLevel.getPieceType();
        Piece ret = new Piece(
            type, 
            candies[type], 
            xOffsetPerCandy*x, yOffsetPerCandy*y, 
            cast(ubyte)x, cast(ubyte)y, 
            pieceScaleX, pieceScaleY
        );
        return ret;
    }

    protected void regenerateBoard (IHipTimerList animation)
    {
        for(int x = 0; x < BOARD_PIECES; x++)
        {
            int regToY = -1;            
            for(int y = 0; y < BOARD_PIECES; y++)
            {
                if(board[y][x] !is null)
                {
                    break;
                }
                else
                {
                    regToY = y;
                }
            }
            while(regToY >= 0)
            {
                Piece p = getNewPiece(x, regToY);
                float targetY = p.y;
                p.y = PIECE_FALL_FROM_Y;
                board[regToY][x] = p;
                regToY--;
                animation.add(HipTween.to(PIECE_FALL_TIME, [&p.y], [targetY]));
            }
        }
    }


    protected void updateBoard(bool isContinous = false)
    {
        Piece[3][] matches;
        if(calculateMatches(matches))
        {
            foreach(match; matches)
            {
                foreach(piece; match)
                {
                    HipGameUtils.playAnimationAtPosition(cast(int)piece.x+BOARD_OFFSET_X, cast(int)piece.y+BOARD_OFFSET_Y, explosionAnimation, 0.1, 0);
                    board[piece.gridY][piece.gridX] = null;
                }
            }
            game.onMatch(isContinous);
            HipSpawn animation = new HipSpawn("Fall old pieces and spawn new pieces");
            makePiecesFall(animation);
            regenerateBoard(animation);
            HipTimerManager.addTimer(animation);
        }
    }
    protected void onSwapFinish()
    {
        canInput = true;
        updateBoard();
    }

    void swapPieces(ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        if(!canInput)
            return;
        canInput = false;
        Piece a = board[y1][x1];
        Piece b = board[y2][x2];
        swap(board[y1][x1], board[y2][x2]);
        a.swapGridPosition(b);
        

        HipTimerManager.addTimer(
            new HipSpawn("Swap Pieces",
                HipTween.to!(["x", "y"])(PIECE_SWAP_TIME, a, [b.x, b.y]),
                HipTween.to!(["x", "y"])(PIECE_SWAP_TIME, b, [a.x, a.y])
            ).addOnFinish((){onSwapFinish();})
        );
    }

    void update(float deltaTime)
    {
        cursor.update();
    }


    void draw()
    {
        for(int i = 0; i < BOARD_PIECES; i++)
        {
            for(int j = 0; j < BOARD_PIECES; j++)
            {
                if(board[i][j] !is null)
                    board[i][j].draw(BOARD_OFFSET_X, BOARD_OFFSET_Y);
            }
        }
        renderSprites();

        if(selectedPiece != nullPiece)
        {
            setGeometryColor(CURSOR_SELECTED_COLOR);
            fillRectangle(BOARD_OFFSET_X + selectedPiece[0]*pieceWidth, BOARD_OFFSET_Y + selectedPiece[1]*pieceHeight, pieceWidth, pieceHeight);
        }

        cursor.draw(BOARD_OFFSET_X,BOARD_OFFSET_Y, pieceWidth, pieceHeight);
        renderGeometries();
    }
}

class Cursor
{
    ubyte x = 0;
    ubyte y = 0;
    Board board;
    this(Board b)
    {
        board = b;
    }

    void moveTo(ubyte x, ubyte y)
    {
        this.x = cast(ubyte)clamp(x, 0, BOARD_PIECES-1);
        this.y = cast(ubyte)clamp(y, 0, BOARD_PIECES-1);
    }

    void moveX(byte direction)
    {
        x+= direction;

        if(x == ubyte.max)
            x = BOARD_PIECES - 1;
        else if(x >= BOARD_PIECES)
            x = 0;
    }
    void moveY(byte direction)
    {
        y+= direction;
        if(y == ubyte.max)
            y = BOARD_PIECES-1;
        else if(y >= BOARD_PIECES)
            y = 0;
    }

    void select()
    {
        board.selectPiece(x, y);
    }

    void update()
    {
        if(HipInput.isMouseButtonJustPressed())
        {
            byte[2] pos = board.getPiecePosition(HipInput.getWorldMousePosition());
            if(pos != nullPiece)
                moveTo(pos[0], pos[1]);
        }
        else if(HipInput.isKeyJustPressed('w'))
            moveY(-1);
        else if(HipInput.isKeyJustPressed('s'))
            moveY(1);
        else if(HipInput.isKeyJustPressed('a'))
            moveX(-1);
        else if(HipInput.isKeyJustPressed('d'))
            moveX(1);
        else if(HipInput.isKeyJustPressed(HipKey.ENTER))
            select();
    }

    void draw(int boardX, int boardY, int pieceWidth = 100, int pieceHeight = 100)
    {
        setGeometryColor(CURSOR_HOVER_COLOR);
        fillRectangle(boardX + pieceWidth*x, boardY + pieceHeight*y, pieceWidth, pieceHeight);
    }
}