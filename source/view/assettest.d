module view.assettest;
import util.data_structures;
import view.scene;


/**
*   This class is currently a placeholder, in the future, a parser(probably HipDDF) should be able
*   to correctly return the assets defined here.
*/
class AssetTest : Scene
{
    this()
    {
        RangeMap!(int, int) playerStrengthProgression;
        playerStrengthProgression.setDefault(0);

        playerStrengthProgression[0..4] = 2;
        playerStrengthProgression[5..14] = 5;
        playerStrengthProgression[15..26] = 12;
        playerStrengthProgression[27..99] = 15;

        RangeMap!(int, string) rankingReward;
        rankingReward.setDefault("");
        rankingReward[0..0]   = "Platinum Medal";
        rankingReward[1..1]   = "Golden Medal";
        rankingReward[2..2]   = "Silver Medal";
        rankingReward[3..3]   = "Bronze Medal";
        rankingReward[4..9]   = "Motivation Medal";
        rankingReward[10..32] = "Loser Sign";
        
    }
}