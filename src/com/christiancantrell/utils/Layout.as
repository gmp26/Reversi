package com.christiancantrell.utils
{
	import flash.display.DisplayObject;

	public class Layout
	{
		/**
		 * Center horizontally one DisplayObject relative to another.
		 */
		public static function centerHorizontally(foreground:DisplayObject, background:DisplayObject):void
		{
			foreground.x = (background.width / 2) - (foreground.width / 2);
		}

		/**
		 * Center vertically one DisplayObject relative to another.
		 */
		public static function centerVertically(foreground:DisplayObject, background:DisplayObject):void
		{
			foreground.y = (background.height / 2) + (foreground.height / 2);
		}

		/**
		 * Center both horizontally and vertically one DisplayObject relative to another.
		 */
		public static function center(foreground:DisplayObject, background:DisplayObject):void
		{
			centerHorizontally(foreground, background);
			centerVertically(foreground, background);
		}
	}
}