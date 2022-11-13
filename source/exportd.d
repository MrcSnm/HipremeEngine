module exportd;
import hip.util.reflection; //ExportD
import hip.math.api;
import hip.graphics.g2d.animation;
import hip.game.utils;
import hip.hipaudio.audio;
import hip.assetmanager;
import hip.systems.timer_manager;
import hip.filesystem.hipfs;



mixin ExportMathAPI;
mixin HipExportDFunctions!(hip.graphics.g2d.animation);
mixin HipExportDFunctions!(hip.game.utils);
mixin HipExportDFunctions!(hip.filesystem.hipfs);
mixin HipExportDFunctions!(hip.hipaudio.audio);
mixin HipExportDFunctions!(hip.assetmanager);
mixin HipExportDFunctions!(hip.systems.timer_manager);
