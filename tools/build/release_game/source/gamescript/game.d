module gamescript.game;
import hip.api;
import gamescript.game_hud;
import gamescript.background;
import gamescript.board;
import gamescript.level;


enum MATCH_SCORE = 50;

class Game : IHipPreloadable
{
    mixin Preload;
    int score = 0;
    int level = 0;
    int continuousMultiplier = 1;
    GameHud hud;
	Background background;
    Board board;
    bool hasStarted;
    bool isPlayingLevel;

    AHipAudioSource musicSrc;
    AHipAudioSource source;


    @Asset("sounds/pop.wav")
    IHipAudioClip pop;

    @Asset("sounds/song17mono.mp3")
    IHipAudioClip music;

    @Asset("data/levels.txt", &Level.parseLevels)
    Level[] levels;




    this()
    {
        preload();
		board = new Board(this);
        background = new Background();
        source = HipAudio.getSource();
        source.clip = pop;

        musicSrc = HipAudio.getSource();
        musicSrc.clip = music;
        musicSrc.loop = true;
        musicSrc.play();
    }

    void advanceLevel(void delegate(Level) onNextLevel)
    {
        isPlayingLevel = false;
        Level nextLevel;
        if(level < levels.length)
            nextLevel = levels[level];
        if(nextLevel !is null)
        {
            hud.setLevel(level+1);
            hud.setGoal(nextLevel.targetGoal);
            hud.setDuration(nextLevel.duration);
            board.setLevel(nextLevel, ()
            {
                isPlayingLevel = true;
                onNextLevel(nextLevel);
            });
            level++;
        }
        else
        {
            isPlayingLevel = false;
            hud.showGameFinish();
        }
    }

    Level getCurrentLevel()
    {
        return level-1 < levels.length ? levels[level-1] : null;
    }

    void setGameHud(GameHud hud)
    {
        this.hud = hud;
    }
    void onGameStart()
    {
        hasStarted = true;
        background.fade();
        advanceLevel((Level level)
        {
            isPlayingLevel = true;
            hud.onNextLevel(level.duration);
        });
    }

    void onMatch(bool continuousMatch)
    {
        source.play();
        if(!continuousMatch)
            continuousMultiplier = 1;
        else
            continuousMultiplier<<= 1; //Multiply by 2
        setScore(score + MATCH_SCORE * continuousMultiplier * level);
    }

    private void resetScore()
    {
        score = 0;
        hud.setScore(0);
        continuousMultiplier = 1;
    }

    void setScore(int score)
    {
        this.score = score;
        hud.setScore(score);
        Level currLevel = getCurrentLevel();
        if(currLevel && score >= currLevel.targetGoal)
        {
            resetScore();
            advanceLevel((Level lvl){});
        }
    }

    void update(float deltaTime)
    {
        if(isPlayingLevel)
		{
			board.update(deltaTime);
			hud.update(deltaTime);
		}
    }

    void render()
    {
        background.draw();
        renderSprites();
		if(isPlayingLevel)
			board.draw();
        if(hud !is null)
		    hud.draw();
    }
}