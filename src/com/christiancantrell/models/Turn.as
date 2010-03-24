package com.christiancantrell.models
{
	public class Turn
	{
		private var _x:uint, _y:uint, _player:Boolean;
		
		public function Turn(x:uint, y:uint, player:Boolean)
		{
			this._x = x;
			this._y = y;
			this._player = player;
		}
		
		public function get x():uint
		{
			return this._x;
		}
		
		public function get y():uint
		{
			return this._y;
		}
		
		public function get player():uint
		{
			return this._player;
		}
	}
}