/*
	Web:Extend webcam integration WIP
	Copyright (c) 2006-2009 Dev:Extend

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

import flash.display.MovieClip;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class WebcamChat extends MovieClip {
	private var camera:Camera;
	private var mic:Microphone;
	private var nc:NetConnection;
	private var pns:NetStream;
	private var sns:NetStream;

	public function new() {
		super();

		// init cam/mic
		camera = Camera.getCamera();
		mic = Microphone.getMicrophone();

		// connect
		try {
			nc = new NetConnection();
			nc.connect("rtmp://localhost/oflaDemo");
			nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		} catch (error:Dynamic) {
			trace("Error connecting to the application.");
		}
	}

	private function display() {
		// Stream video

		var vid:Video = new Video(320, 240);
		vid.attachNetStream(sns);
		addChild(vid);

		// Small camera preview

		var wpreview:Int = Std.int(camera.width / 4);
		var hpreview:Int = Std.int(camera.height / 4);
		var pvid:Video = new Video(camera.width, camera.height);
		pvid.x = 5;
		pvid.y = camera.height - hpreview - 5;
		pvid.width = wpreview;
		pvid.height = hpreview;
		pvid.attachCamera(camera);
		addChild(pvid);
	}

	private function netStatusHandler(e:NetStatusEvent) {
		if (e.info.code == "NetConnection.Connect.Success") {
			publish();
			subscribe();
			display();
		} else {
			// TODO:handle bad stuff
			trace("Error NSH: " + e.info.code);
		}
	}

	private function publish() {
		try {
			camera.setMode(320, 240, 15);
			camera.setQuality(0, 80);

			pns = new NetStream(nc);
			pns.attachCamera(camera);

			mic.rate = 44;
			pns.attachAudio(mic);

			pns.publish("red5" + flash.Lib.current.loaderInfo.parameters.pid, "live");
		} catch (error:Dynamic) {
			trace("Error publishing the camera and/or mic.");
		}
	}

	private function subscribe() {
		try {
			sns = new NetStream(nc);
			sns.play("red5" + flash.Lib.current.loaderInfo.parameters.sid);
		} catch (error:Dynamic) {
			trace("Error subscribing to stream.");
		}
	}
}

class Test {
	static function main() {
		var wc:WebcamChat = new WebcamChat();
		flash.Lib.current.addChild(wc);
	}
}
