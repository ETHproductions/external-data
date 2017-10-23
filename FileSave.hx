import com.stencyl.Engine;
import com.stencyl.behavior.Script;
import com.stencyl.behavior.TimedTask;
import com.stencyl.models.Font;
import com.stencyl.graphics.G;
import com.stencyl.utils.Utils;

import nme.display.BitmapData;
import nme.utils.ByteArray;
import lime.system.System in SystemPath;
import haxe.io.Bytes;
import openfl.geom.Rectangle;
import openfl.display.*;

#if !flash
import sys.*;
import sys.io.*;
#end

class FileSave {

	public static function getText(path:String):String {
		var content:String = "";
		var path2:String = "";
		
		// Flash or HTML5: This should not happen; error out
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		#elseif js
		trace("ERROR: File IO cannot be accessed on HTML5.");
		
		// iOS or Android: Attempt to get text from the external directory, then the internal directory
		#elseif mobile
		path2 = SystemPath.userDirectory + "/" + path;
		
		if (FileSystem.exists(path2)) {
			content = File.getContent(path2);
		} else {
			content = nme.Assets.getText(path);
			if (content == null) {
				trace("ERROR: File does not exist at: " + path);
				content = "";
			}
		}
		
		// Windows, Mac or Linux: Attempt to get text straight from the "assets/data/" folder
		#else
		path2 = FileSystem.fullPath(path);
		if (FileSystem.exists(path2)) {
			content = File.getContent(path2);
		} else {
			trace("ERROR: File does not exist at: " + path2);
		}
		
		#end
		return content;
	}
	
	public static function getImage(path:String):BitmapData {
		var image:BitmapData = new BitmapData(1,1);
		var path2:String = "";
		
		// Flash or HTML5: This should not happen; error out
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		#elseif js
		trace("ERROR: File IO cannot be accessed on HTML5.");
		
		// iOS or Android: Attempt to get image from the external directory, then the internal directory
		#elseif mobile
		path2 = SystemPath.userDirectory + "/" + path;
		if (FileSystem.exists(path2)) {
			image = BitmapData.fromBytes(File.getBytes(path2));
		} else {
			image = nme.Assets.getBitmapData(path);
		}
		if (image == null) {
			trace("ERROR: File does not exist at: " + path);
			image = new BitmapData(1,1);
		}
		
		// Windows, Mac or Linux: Attempt to get image straight from the "assets/data/" folder
		#else
		path2 = FileSystem.fullPath(path);
		if (FileSystem.exists(path2)) {
			image = BitmapData.fromBytes(File.getBytes(path2));
		} else {
			trace("ERROR: File does not exist at: " + path2);
		}
		if (image == null) {
			trace("ERROR: File does not exist at: " + path);
			image = new BitmapData(1,1);
		}
		
		#end
		return image;
	}
	
	public static function saveText(path:String, content:String, ?whenDone:Bool->Void):Void {
		var success:Bool = true;
		var path2:String = "";
		path = "/assets/data/" + path;
		var a:Array<String> = DataUtils.subfold(path);
		
		// Flash or HTML5: Not possible to save; error out
		#if (flash || js)
		success = false;
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		#else
		trace("ERROR: File IO cannot be accessed on HTML5.");
		#end
		
		// iOS and Android: Attempt to save to the storage directory
		#elseif mobile
		if (!FileSystem.exists(SystemPath.userDirectory + "/" + a[0])) {
			FileSystem.createDirectory(SystemPath.userDirectory + "/" + a[0]);
		}
		
		path2 = SystemPath.userDirectory + "/" + a[0] + "/" + a[1];
		try {
			File.saveContent(path2, Std.string(content));
		} catch (e:Dynamic) {
			success = false;
			trace("ERROR: " + e);
			errorify(e);
		}
		
		// Windows, Mac, and Linux: Save straight to the "assets/data/" folder
		#else
		if (!FileSystem.exists(FileSystem.fullPath(a[0]))) {
			FileSystem.createDirectory(FileSystem.fullPath(a[0]));
		}
		
		path2 = FileSystem.fullPath(a[0] + "/" + a[1]);
		try {
			File.saveContent(path2, Std.string(content));
		} catch (e:Dynamic) {
			success = false;
			trace("ERROR: " + e);
			errorify(e);
		}
		
		#end
		if (whenDone != null)
			whenDone(success);
	}
	
	/**
	 * Save bytes as a file
	 * @param	path	
	 * @param	content	
	 * @return true if succeed, false overwise
	 */
	static function saveBytes(path:String, content:Bytes):Bool {
		var success = true;
		
		// Flash or HTML5: This should not happen; error out
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		success = false;
		#elseif js
		trace("ERROR: File IO cannot be accessed on HTML5.");
		success = false;
		
		#else
		var fo:FileOutput = null;
		try {
			//open binary file and write bytes
			fo = File.write(path, true);
			fo.writeBytes(content, 0, content.length);
		} catch (e:Dynamic) {
		    success = false;
			trace("ERROR: " + e);
			errorify(e);
		}
		
		//file output should be closed in any case
		try {
			if (fo != null) 
				fo.close();
		} catch (e:Dynamic) {
			success = false;
			trace("ERROR: " + e);
			errorify(e);
		}
		#end
		
		return success;
	}
	
	public static function saveImage(path:String, type:String, image:BitmapData, ?whenDone:Bool->Void):Void {
		if (type == "png") {
			if (path.substr(path.length - 4).toLowerCase() != ".png")
				path += ".png";
		}
		else if (type == "jpg") {
			if (path.substr(path.length - 4).toLowerCase() != ".jpg"
			 && path.substr(path.length - 5).toLowerCase() != ".jpeg")
				path += ".jpg";
		}
		else {
			trace("ERROR: Could not determine how to save image as a ." + type + " file.");
			whenDone(false);
			return;
		}
		
		path = "/assets/data/" + path;
		var path2:String = "";
		var a:Array<String> = DataUtils.subfold(path);
		var success = false;
		
		// Flash or HTML5: Not possible to save; error out
		#if flash
		trace("ERROR: File IO cannot be accessed on Flash.");
		#elseif js
		trace("ERROR: File IO cannot be accessed on HTML5.");
		#else
		
		// Windows, Mac, Linux, iOS, and Android: Use the "saveBytes" function with the converted file
		#if mobile
		if (!FileSystem.exists(SystemPath.userDirectory + "/" + a[0])) {
			FileSystem.createDirectory(SystemPath.userDirectory + "/" + a[0]);
		}
		path2 = SystemPath.userDirectory + "/" + a[0] + "/" + a[1];

		#else
		if (!FileSystem.exists(FileSystem.fullPath(a[0]))) {
			FileSystem.createDirectory(FileSystem.fullPath(a[0]));
		}
		path2 = FileSystem.fullPath(a[0] + "/" + a[1]);

		#end

		var b:ByteArray = image.encode(image.rect, type == "jpg" ? new JPEGEncoderOptions() : new PNGEncoderOptions());
		success = saveBytes(path2, b);
		
		#end
		
		if (whenDone != null)
			whenDone(success);
	}
	
	public static function savePNG(path:String, image:BitmapData, ?whenDone:Bool->Void):Void {
		saveImage(path, "png", image, whenDone);
	}
	
	public static function saveJPG(path:String, image:BitmapData, ?whenDone:Bool->Void):Void {
		saveImage(path, "jpg", image, whenDone);
	}
	
	public static function errorify(e:Dynamic):Void {
		var email:String = "mailto:eth3792@nycap.rr.com?subject=External Data Error"
			+ "&body=Hi ETHproductions,%0a%0a"
			+ "I came across this error when I was testing my game:%0a%0a"
			+ e + "%0a%0a";

		// When the screen is pressed, opens an link to PM ETHproductions.
		Engine.engine.whenMousePressedListeners.push(function(list:Array<Dynamic>) {
			Script.openURLInBrowser("http://community.stencyl.com/index.php?action=pm;sa=send;u=185723");
			// Script.openURLInBrowser(email); // Would open the email instead
		});
		
		// Draws information on the screen to alert the user to the error.
		// Runs after 20 milliseconds to make sure all Drawing events fire first.
		Script.runLater(20, function(timeTask:TimedTask){
			Engine.engine.whenDrawingListeners.push(function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void {
				var font:Font = new Font(-1, -1, "Default Font", true);
				g.setFont(font);
				g.fillColor = Utils.getColorRGB(255,255,255);
				g.translateToScreen();
				g.moveTo(0, 0);
				g.strokeSize = 0;
				g.alpha = 1;
				g.fillRect(0,0,Script.getScreenWidth(),106);
				g.drawString("Uh-oh! Something went really wrong", 8, 8);
				g.drawString("with the External Data extension!", 8, 28);
				g.drawString("Click anywhere on the screen to con-", 8, 48);
				g.drawString("tact the author, ETHproductions.", 8, 68);
				g.drawString("See Log Viewer for error details.", 8, 88);
			});
		});
	}
	
}