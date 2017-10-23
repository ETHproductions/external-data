import com.stencyl.graphics.G;
import com.stencyl.Engine;
import com.stencyl.models.Sound;
import nme.display.BitmapData;

class DataUtils {

	public static function getTextData(file:String):String {
		file = "assets/data/" + file;
		#if (flash || js)
		var text:String = nme.Assets.getText(file);
		#else
		var text:String = FileSave.getText(file);
		#end
		if (text == null) text = "";						// if something goes wrong, return blank text
		text = StringTools.replace(text, "\r\n", "\n\r");	// swap double line breaks (Windows-style line breaks)
		text = StringTools.replace(text, "\n\r", "\r");		// replace all double breaks with single breaks
		text = StringTools.replace(text, "\n", "\r");		// make all line breaks the same type
		return text;
	}
	
	public static function getImageData(file:String):BitmapData {
		file = "assets/data/" + file;
		#if (flash || js)
		var image:BitmapData = nme.Assets.getBitmapData(file);
		#else
		var image:BitmapData = FileSave.getImage(file);
		#end
		if (image == null) image = new BitmapData(1,1);		// if something goes wrong, return blank image
		return image;
	}
	
	/* Takes a file path, gets rid of all illegal characters, and splits into a path and a filename. */
	public static function subfold(file:String):Array<String> {
		for (a in [':','*','?','"','<','>','|'])
			file = StringTools.replace(file, a, "");	// remove all illegal characters from path/filename
		file = StringTools.replace(file, "\\", "/");	// swap backslashes for forward slashes
		file = StringTools.replace(file, "//", "/");	// change double slashes to single ones
		while (file.charAt(0) == "/")
			file = file.substr(1);						// remove leading slashes
		var n:Int = file.lastIndexOf("/");
		if (n == -1)
			return ["", file];
		else
			return [file.substr(0,n), file.substr(n+1)];
	}
	
	public static function appendLine(path:String, content:String):Void {
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		#elseif js
		trace("ERROR: File IO cannot be accessed on HTML5.");
		#else
		var file = getTextData(path) + "\r" + content;
		FileSave.saveText(path, file, null);
		#end
	}

	public static function drawList(g:G, list:Array<Dynamic>, x:Float, y:Float):Void {
		for (i in 0...list.length) {
			g.drawString("" + list[Std.int(i)], x, (y + (i * g.font.getHeight()/Engine.SCALE)));
		}
	}
	
	public static function printList(list:Array<Dynamic>):Void {
		for (item in list) {
			trace(item);
		}
	}

	// EXPERIMENTAL
	public static function removeSpecial(text:String, char:Int):String {
		var special:String = "";
		if (char == 0) {
			special = "\n";
		} else if (char == 1) {
			special = "\u0009";
		}
		return "abc" + special + "def";
	}

	public static function getSoundData(filename:String):com.stencyl.models.Sound {
		var ext:String;
		#if(mobile || desktop || js)
		ext = ".ogg";
		#else
		ext = ".mp3";
		#end
		var file:String = "assets/data/" + filename + ext;
		var nmeSound:flash.media.Sound = nme.Assets.getSound(file);
		return soundToStencyl(nmeSound, filename, ext);
	} 

	public static function soundToStencyl(sound:flash.media.Sound, filename:String, ext:String):com.stencyl.models.Sound {
		var stencylSound = new com.stencyl.models.Sound(-1, filename, true, false, 0.0, 1.0, ext);
		stencylSound.streaming = false;
		stencylSound.src = sound;
		return stencylSound;
	} 
}