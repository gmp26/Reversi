package com.christiancantrell.utils
{
	public class Ruler
	{
		public static const MIN_BUTTON_SIZE_MM:uint       = 7;
		public static const MIN_BUTTON_SIZE_INCHES:Number = 0.27559055;
		
		/**
		 * Convert inches to pixels.
		 */
		public static function inchesToPixels(inches:Number, dpi:uint):uint
		{
			return Math.round(dpi * inches);
		}
		
		/**
		 * Convert millimeters to pixels.
		 */
		public static function mmToPixels(mm:Number, dpi:uint):uint
		{
			return Math.round(dpi * (mm / 25.4));
		}

	}
}