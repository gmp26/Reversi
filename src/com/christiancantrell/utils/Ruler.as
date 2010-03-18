package com.christiancantrell.utils
{
	public class Ruler
	{
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