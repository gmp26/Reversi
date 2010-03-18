package com.christiancantrell.pieces
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class Board extends Sprite
	{
		private var boardSize:uint;
		
		public function Board(boardSize:uint)
		{
			super();
			this.boardSize = boardSize;
			this.addEventListener(Event.ADDED, onAddedToDisplayList);
		}
		
		private function onAddedToDisplayList(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAddedToDisplayList);
			this.doLayout();
		}
		
		private function doLayout():void
		{
			// Draw the background
			this.graphics.beginFill(0x00ff00);
			this.graphics.drawRect(0, 0, this.boardSize, this.boardSize);
			this.graphics.endFill();
			
			// Draw cells
			var lineSpace:Number = this.boardSize / 8;
			this.graphics.lineStyle(1, 0x000000);
			var linePosition:uint = 0;
			for (var i:uint = 0; i <= 8; ++i)
			{
				linePosition = i * lineSpace;
				if (linePosition == boardSize) linePosition -= 1;
				// Veritcal
				this.graphics.moveTo(linePosition, 0);
				this.graphics.lineTo(linePosition, this.boardSize);
				// Horizontal
				this.graphics.moveTo(0, linePosition);
				this.graphics.lineTo(this.boardSize, linePosition);
			}
		}
	}
}