import haxe.Timer;
import com.stencyl.Engine;
import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.events.Event;
import flash.display.AVM1Movie;

class PlaySWF {

	public static function playSWF(filename:String, x:Float, y:Float, whenOver:Void->Void) {
		playMovie(filename, x, y, 0, whenOver);
	}

	public static function playAVM1(filename:String, ms:Float, whenOver:Void->Void) {
		playMovie(filename, 0, 0, ms, whenOver);
	}
	
	#if (flash || display)
	
	public static function playMovie(filename:String, x:Float, y:Float, ms:Float, whenOver:Void->Void) {
		var clip:MovieClip;
		var loader:Loader;
		var filepath:String;
		if (filename.substring(filename.length - 4, filename.length) == ".swf") {
			filepath = "assets/data/" + filename;
		} else {
			filepath = "assets/data/" + filename + ".swf";
		}
		var bytes = openfl.Assets.getBytes(filepath);
		if (bytes == null) {
			trace("SWF with name: " + filename + " does not exist");
			return;
		}
		loader = new Loader();
		loader.loadBytes(bytes);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
			if (Std.is(loader.content, AVM1Movie)) {
				trace("Playing AVM1 SWF with name: " + filename);
				loader.x = x;
				loader.y = y;
				Engine.engine.root.addChild(loader);
				
				if (ms > 0)
					Timer.delay(function() {
						Engine.engine.root.removeChild(loader);
						loader.unloadAndStop();
						whenOver();
					}, Std.int(ms));
			} else {
				trace("Playing AVM2 SWF with name: " + filename);
				clip = cast(loader.content, MovieClip);
				clip.x = x;
				clip.y = y;
				Engine.engine.root.addChild(clip);
				
				if (ms > 0)
					Timer.delay(function() {
						Engine.engine.root.removeChild(clip);
						whenOver();
					}, Std.int(ms));
			}
		});
	}
	
	#else
	
	public static function playMovie(filename:String, x:Float, y:Float, ms:Float, whenOver:Void->Void) {
		trace("Cannot play SWF files unless running on Flash.");
	}
	
	#end
}
