﻿/*
 * Copyright (c) 2012 David MASSENOT - http://artcustomer.fr/
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package artcustomer.framework.loaders.resource.core {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	
	/**
	 * LoadableAnimation
	 * 
	 * @author David Massenot
	 */
	public class LoadableAnimation extends LoadableFile implements ILoadableFile {
		private var _loader:Loader;
		private var _urlrequest:URLRequest;
		
		
		/**
		 * Constructor
		 */
		public function LoadableAnimation() {
			setupLoader();
		}
		
		//---------------------------------------------------------------------
		//  Loader
		//---------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setupLoader():void {
			_loader = new Loader();
			
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, handleErrorLoader, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handleProgressLoader, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, handleCompleteLoader, false, 0, true);
		}
		
		/**
		 * @private
		 */
		private function startLoader():void {
			_loader.load(_urlrequest);
		}
		
		/**
		 * @private
		 */
		private function destroyLoader():void {
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, handleErrorLoader);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handleProgressLoader);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, handleCompleteLoader);
			
			_loader = null;
		}
		
		//---------------------------------------------------------------------
		//  URLRequest
		//---------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function setupURLRequest():void {
			_urlrequest = new URLRequest(_folder + _file);
		}
		
		/**
		 * @private
		 */
		private function destroyURLRequest():void {
			_urlrequest = null;
		}
		
		//---------------------------------------------------------------------
		//  Listeners
		//---------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private function handleErrorLoader(e:IOErrorEvent):void {
			_error = e.text;
			
			super.errorHandler();
		}
		
		/**
		 * @private
		 */
		private function handleProgressLoader(e:ProgressEvent):void {
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
			_percent = Math.floor((e.bytesLoaded / e.bytesTotal) * 100);
			
			this.dispatchEvent(e.clone());
		}
		
		/**
		 * @private
		 */
		private function handleCompleteLoader(e:Event):void {
			_bytesLoaded = _bytesTotal;
			
			_data = e.target.content;
			_bytes = e.target.bytes;
			
			super.completeHandler();
		}
		
		
		/**
		 * Start file loading.
		 */
		public function startLoading():void {
			if (this.isAlreadyLoaded) {
				super.completeHandler();
			} else {
				setupURLRequest();
				startLoader();
				
				super.startLoadingFile();
			}
		}
		
		/**
		 * Close file loading.
		 */
		public function closeLoading():void {
			if (!isLoading) {
				if (_isOpenStream) {
					try {
						_loader.close();
					} catch (er:Error) {
						
					}
				}
				
				destroyURLRequest();
				destroyLoader();
			}
		}
		
		/**
		 * Release instance.
		 */
		override public function destroy():void {
			_loader = null;
			_urlrequest = null;
			
			super.destroy();
		}
	}
}