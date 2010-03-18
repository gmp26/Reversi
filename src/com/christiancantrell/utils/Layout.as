package com.christiancantrell.utils
{
	public class Layout
	{
		/**
		 * Center one DisplayObject relative to another.
		 */
		public static function center(foreground:DisplayObject, background:DisplayObject):void
		{
			foreground.x = (background.width / 2) - (foreground.width / 2);
			foreground.y = (background.height / 2) + (foreground.height / 2);
		}
	}
}