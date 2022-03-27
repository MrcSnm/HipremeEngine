module view.assettest;
import util.data_structures;
import view.scene;
import data.image;


/**
*   This class is currently a placeholder, in the future, a parser(probably HipDDF) should be able
*   to correctly return the assets defined here.
*/
class AssetTest : Scene
{
    this()
    {
        RangeMap!(int, int) playerStrengthProgression;
        playerStrengthProgression = 0;

        playerStrengthProgression[0..4] = 2;
        playerStrengthProgression[5..14] = 5;
        playerStrengthProgression[15..26] = 12;
        playerStrengthProgression[27..99] = 15;

        RangeMap!(int, string) rankingReward;
        rankingReward = "";
        rankingReward[0..0]   = "Platinum Medal";
        rankingReward[1..1]   = "Golden Medal";
        rankingReward[2..2]   = "Silver Medal";
        rankingReward[3..3]   = "Bronze Medal";
        rankingReward[4..9]   = "Motivation Medal";
        rankingReward[10..32] = "Loser Sign";

        Map!(string, int) tester;

        tester["ops"] = 500;
        tester["Hello World"] = 1500;

        debug { import std.stdio : writeln; try { writeln(tester["Hello World"]); } catch (Exception) {} }

        Map!(int, String) tester2;

        tester2[523] = String("Oops");
        tester2[522] = String("Eba");

        debug { import std.stdio : writeln; try { writeln(tester2[523]); } catch (Exception) {} }
        debug { import std.stdio : writeln; try { writeln(tester2[522]); } catch (Exception) {} }
        tester2[523] = String("Ie me");
        debug { import std.stdio : writeln; try { writeln(tester2[523]); } catch (Exception) {} }

    }
}