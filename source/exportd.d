module exportd;
import hip.util.reflection; //ExportD
import hip.graphics.g2d.animation;
import hip.game.utils;
import hip.hipaudio.audio;
import hip.hiprenderer.renderer;
import hip.assetmanager;
import hip.systems.timer_manager;
import hip.filesystem.hipfs;
import hip.network;

import std.traits:ReturnType;

mixin HipExportDFunctions!(hip.graphics.g2d.animation);
mixin HipExportDFunctions!(hip.game.utils);
mixin HipExportDFunctions!(hip.hipaudio.audio);
mixin HipExportDFunctions!(hip.hiprenderer.renderer);
mixin HipExportDFunctions!(hip.assetmanager);
mixin HipExportDFunctions!(hip.systems.timer_manager);


///ExportD doesn't work on function/delegate
alias AssetDelegate = void delegate(HipAsset);
export extern(System) static void HipAssetManager_addOnCompleteHandler(IHipAssetLoadTask task, AssetDelegate onComplete)
{
    HipAssetManager.addOnCompleteHandler(task, onComplete);
}


void referenceExported()
{
    auto a = &getNetworkInterface;
    auto b = &HipFileSystemAPI;
}