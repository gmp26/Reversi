package com.christiancantrell.pieces
{
	import flash.display.Sprite;
	
	public class Stone extends Sprite
	{
		public const WHITE:Boolean = true;
		public const BLACK:Boolean = false;
		
		private var color:Boolean;
		private var column:uint;
		private var row:uint;
		
		public function Stone(color:Boolean, column:uint, row:uint)
		{
			super();
			this.color = color;
			this.column = column;
			this.row = row;
		}
	}
}