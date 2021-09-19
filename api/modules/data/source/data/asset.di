// D import file generated from 'source\data\asset.d'
module data.asset;
import util.time;
private __gshared uint currentAssetID = 0;
abstract class HipAsset
{
	string name;
	uint assetID;
	float startLoadingTimestamp;
	float loadTime;
	this(string assetName)
	{
		this.name = assetName;
		assetID = ++currentAssetID;
	}
	abstract bool load();
	abstract bool isReady();
	abstract void onFinishLoading();
	void startLoading();
	void finishLoading();
	final void dispose();
	abstract void onDispose();
}
