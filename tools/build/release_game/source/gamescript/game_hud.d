module gamescript.game_hud;
import gamescript.gameover;
import gamescript.text;
import gamescript.game;
import gamescript.config;
import hip.tween;
import hip.api;
import hip.timer;

class GameHud
{
    Game game;

    Text pressEnter;
    Text scoreText;
    Text timeText;
    Text levelText;
    Text goalText;



    IHipFont font;
    IHipFont pressEnterFont;
    HipTimer timer;
    GameOver gameOver;
    private int time = 60;
    private enum rectX = 100;
    private enum rectWidth = 400;

    this(Game game)
    {
        this.game = game;
        font = HipDefaultAssets.getDefaultFontWithSize(62);
        pressEnterFont = HipDefaultAssets.getDefaultFontWithSize(124);
        timer = new HipTimer("Time Subtraction", 1, HipTimerType.oneShot, true)
        .addHandler(&subtractTime);
        uint height  = font.lineBreakHeight;


        version(Android)
            pressEnter = new Text("Touch to Start the Game", GAME_WIDTH/2, 0);
        else
            pressEnter = new Text("Press Enter to Start the Game", GAME_WIDTH/2, 0);
        pressEnter.color = HipColor.black;

        int textX = rectX;

        scoreText = new Text("Score: 0", textX, 100, font, rectWidth);
        timeText = new Text("Time: 60", textX, scoreText.y+height, font, rectWidth);
        levelText = new Text("Level 1", textX, timeText.y+height, font, rectWidth);
        goalText = new Text("Goal: 1000", textX, levelText.y+height, font, rectWidth);
        game.setGameHud(this);
    }

public:
    void showEnterToStartGame()
    {
		HipTimerManager.addTimer(
			HipTween.to(PRESS_ENTER_TWEEN_TIME, [&pressEnter.y], [GAME_HEIGHT/2 - pressEnterFont.lineBreakHeight/2]).setEasing(HipEasing.easeOutBounce).addOnFinish(()
			{

                version(Android)
                {
                    HipInput.addTouchListener(HipMouseButton.any, (meta)
                    {
                        game.onGameStart();
                    }, HipButtonType.down, AutoRemove.yes);
                }
                else
                {
                    HipInput.addKeyboardListener(HipKey.ENTER, (meta)
                    {
                        game.onGameStart();
                    }, HipButtonType.down, AutoRemove.yes);
                }
			})
		);
    }

    void onNextLevel (int duration)
    {
        time = duration;
        timer.setProperties(timer.name, 1, HipTimerType.oneShot, true);
        timer.reset();
    }

    void setScore(int score)
    {
        scoreText.setText("Score: ", score);
    }

    void setLevel(int level)
    {
        levelText.setText("Level ", level);
    }
    void setGoal(int goal){goalText.setText("Goal: ", goal);}
    
    void setDuration(int duration)
    {
        time = duration;
        timeText.setText("Time: ", duration);
    }

    void update(float deltaTime)
    {
        timer.tick(deltaTime);
    }

    void draw()
    {
        if(!game.hasStarted)
        {
            setFont(pressEnterFont);
            pressEnter.draw();
        }
        else if(game.isPlayingLevel)
        {
            setFont(font);
            ///Rect
            setGeometryColor(HipColor(0.3, 0.3, 0.3, 0.8));
            fillRectangle(50, rectX, rectWidth, 250);

            //Info
            scoreText.draw();
            timeText.draw();
            levelText.draw();
            goalText.draw();
        }
        else if(gameOver !is null)
            gameOver.draw();
        renderTexts();
    }

protected:
    void showGameFinish()
    {
        gameOver = new GameOver(true);
        gameOver.show();
    }

    void playGameOver()
    {
        gameOver = new GameOver(true);
        gameOver.show();
    }

    void subtractTime()
    {
        time-= 1;
        timeText.setText("Time: ", time);
        if(time <= 0)
        {
            timer.stop();
            playGameOver();
        }
    } 
}