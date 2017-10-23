// EXPERIMENTAL

import openfl.display.Loader;
import openfl.events.ProgressEvent;
import openfl.events.Event;
import openfl.net.URLRequest;

class DataFromURL {
	public var myLoader:Loader;

	public function new() {
		myLoader = new Loader();
		myLoader.load(new URLRequest("https://www.dropbox.com/s/xufhvbtsqk3knlf/StencylTest.txt?dl=1"));
		myLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
		myLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
	}
	
	public function onComplete(e:Event):Void {
		trace("Load complete.");
	}

	public function onProgress(e:ProgressEvent):Void {
		var percentLoaded:Float = myLoader.contentLoaderInfo.bytesLoaded / myLoader.contentLoaderInfo.bytesTotal;
		trace("Percent loaded: " + percentLoaded * 100);
	}
}