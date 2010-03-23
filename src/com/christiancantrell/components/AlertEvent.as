package com.christiancantrell.components
{
	import flash.events.Event;
	
	public class AlertEvent extends Event
	{
		public static var ALERT_CLICKED:String = "alertClicked";
		
		public var label:String;
		
		public function AlertEvent()
		{
			super(ALERT_CLICKED);
		}
	}
}