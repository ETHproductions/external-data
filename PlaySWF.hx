import String;
import haxe.Timer;
import com.stencyl.Engine;
import nme.display.Loader;
import nme.display.MovieClip;
import nme.events.Event;
import flash.display.AVM1Movie;

class PlaySWF {

	private static var alreadyTried:Bool = false;

	#if (flash || display) // These functions only work on Flash
	
	public static function playSWF(filename:String, X:Float, Y:Float, whenOver:Void->Void) {
		var clip:MovieClip;
		var loader:Loader;
		var SWF:String;
		if (filename.substring(filename.length - 4, filename.length) == ".swf") {
			SWF = "assets/data/" + filename;
		} else {
			SWF = "assets/data/" + filename + ".swf";
		}
		var bytes = nme.Assets.getBytes(SWF);
		if (bytes == null) {
			trace("SWF with name: " + filename + " does not exist!");
			return;
		}
		loader = new Loader();
		loader.loadBytes(bytes);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
			if (Std.is(loader.content, AVM1Movie)) {
				trace("SWF with name: " + filename + " is an AVM1 movie.");
				if (!(alreadyTried)) {
					// Alternately play movie for 10 seconds
					alreadyTried = true;
					playAVM1(filename, 10000, function () {whenOver();});
				} else {
					trace("SWF with name: " + filename + " could not be played.");
				}
			} else {
				trace("Playing SWF with name: " + filename + " at (x: " + X + " y: " + Y + ").");
				clip = cast(loader.content, MovieClip);
				Engine.engine.root.addChild(clip);
				clip.x = X;
				clip.y = Y;
				clip.addFrameScript(clip.totalFrames - 1, function() {
					clip.stop();
					loader.unloadAndStop();
					Engine.engine.root.removeChild(clip);
					whenOver();
				});
				Engine.engine.root.addChild(clip);
			}
		});
	}

	public static function playAVM1(filename:String, ms:Float, whenOver:Void->Void) {
		var clip:MovieClip;
		var loader:Loader;
		var SWF:String;
		if (filename.substring(filename.length - 4, filename.length) == ".swf") {
			SWF = "assets/data/" + filename;
		} else {
			SWF = "assets/data/" + filename + ".swf";
		}
		var bytes = nme.Assets.getBytes(SWF);
		if (bytes == null) {
			trace("SWF with name: " + filename + " does not exist!");
			return;
		}
		loader = new Loader();
		loader.loadBytes(bytes);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
			if (Std.is(loader.content, AVM1Movie)) {
				trace("Playing AVM1 SWF with name: " + filename + " for " + (ms / 1000) + " seconds.");
				Engine.engine.root.addChild(loader);
				Timer.delay(function() {
					Engine.engine.root.removeChild(loader);
					loader.unloadAndStop();
					whenOver();
				}, Std.int(ms));
			} else {
				trace("SWF with name: " + filename + " is not an AVM1 movie.");
				if (!(alreadyTried)) {
					// Alternately play movie at (0,0)
					alreadyTried = true;
					playSWF(filename, 0, 0, function () {whenOver();});
				} else {
					trace("SWF with name: " + filename + " could not be played.");
				}
			}
		});
	}
	
	#else // Debug versions for Desktop and Mobile
	
	public static function playSWF(filename:String, X:Float, Y:Float, whenOver:Void->Void) {
		trace("Cannot play SWF files unless running on Flash.");
	}

	public static function playAVM1(filename:String, ms:Float, whenOver:Void->Void) {
		trace("Cannot play SWF files unless running on Flash.");
	}
	
	#end
}
