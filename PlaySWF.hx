import haxe.Timer;

import com.stencyl.Engine;
import com.stencyl.utils.Assets;

import openfl.display.Loader;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.utils.ByteArray;

#if flash
import flash.display.AVM1Movie;
#end

class PlaySWF {
	
	private static var moviesRunning:Map<String, Dynamic>;

	public static function playSWF(filename:String, x:Float, y:Float, whenOver:Void->Void) {
		playMovie(filename, x, y, function(_) { whenOver(); });
	}

	public static function playAVM1(filename:String, ms:Float, whenOver:Void->Void) {
		playMovie(filename, 0, 0, function(_) { whenOver(); });
		Timer.delay(function() { stopMovie(filename); }, Std.int(ms));
	}
	
	#if (flash || display)
	
	public static function playMovie(filename:String, x:Float, y:Float, whenLoaded:Bool->Void) {
		var clip:MovieClip;
		var loader:Loader;
		var filepath:String;
		var bytes:ByteArray;
		
		if (filename.substr(-4) != ".swf") {
			filename += ".swf";
		}
		filepath = "assets/data/" + filename;
		
		try {
			bytes = Assets.getBytes(filepath);
		} catch (e:Dynamic) {
			trace("Could not find " + filename);
			whenLoaded(false);
			return;
		}
		
		if (bytes == null) {
			trace("Could not find " + filename);
			whenLoaded(false);
			return;
		}
		
		loader = new Loader();
		loader.loadBytes(bytes);
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(_) {
			if (Std.is(loader.content, AVM1Movie)) {
				// trace("Playing AVM1 SWF from file " + filename);
				loader.x = x;
				loader.y = y;
				startMovie(loader, filename);
			} else {
				// trace("Playing AVM2 SWF from file " + filename);
				clip = cast(loader.content, MovieClip);
				clip.x = x;
				clip.y = y;
				startMovie(clip, filename);
			}
			whenLoaded(true);
		});
	}
	
	public static function startMovie(movie:Dynamic, filename:String) {
		if (moviesRunning == null) {
			moviesRunning = new Map<String, Dynamic>();
		}
		
		moviesRunning.set(filename, movie);
		Engine.engine.root.addChild(movie);
	}
	
	public static function stopMovie(filename:String) {
		if (filename.substr(-4) != ".swf")
			filename += ".swf";
		
		var movie:Dynamic = moviesRunning.get(filename);
		if (movie == null) {
			trace(filename + " is not currently running");
			return;
		}
		
		Engine.engine.root.removeChild(movie);
		if (Std.is(movie, Loader))
			movie.unloadAndStop();
		
		moviesRunning.remove(filename);
		// trace("Closed SWF from file " + filename);
	}
	
	#else
	
	public static function playMovie(filename:String, x:Float, y:Float, whenLoaded:Bool->Void) {
		trace("Cannot play SWF files unless running on Flash.");
	}
	public static function startMovie(movie:Dynamic, filename:String) {
		trace("Cannot play SWF files unless running on Flash.");
	}
	public static function stopMovie(filename:String) {
		trace("Cannot play SWF files unless running on Flash.");
	}
	
	#end
}
