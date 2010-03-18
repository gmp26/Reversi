package
{
	import com.christiancantrell.pieces.Board;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class Reversi extends Sprite
	{
		
		private const WHITE:Boolean = true;
		private const BLACK:Boolean = false;
		
		private var board:Sprite;
		private var stones:Array;
		private var turn:Boolean;
		
		public function Reversi()
		{
			super();
			this.initStones();
			this.turn = BLACK;
			this.addEventListener(Event.ADDED, onAddedToDisplayList);
		}
		
		private function onAddedToDisplayList(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAddedToDisplayList);
			this.stage.addEventListener(Event.RESIZE, doLayout);
		}
		
		public function doLayout(e:Event):void
		{
			// Remove any children that have already been added
			while (this.numChildren > 0) this.removeChildAt(0);

			var stageWidth:uint = this.stage.stageWidth;
			var stageHeight:uint = this.stage.stageHeight;
			
			// Figure out the size of the board
			var boardSize:uint = Math.min(stageWidth, stageHeight);
			
			// Figure out the placement of the board
			var boardX:uint, boardY:uint;
			if (boardSize == stageWidth)
			{
				boardX = 0;
				boardY = (stageHeight - stageWidth) / 2;
			}
			else
			{
				boardY = 0;
				boardX = (stageWidth - stageHeight) / 2;
			}

			// Create the board and place it
			this.board = new Sprite();
			this.board.x = boardX;
			this.board.y = boardY;
			
			// Draw the board's background
			this.board.graphics.beginFill(0x00ff00);
			this.board.graphics.drawRect(0, 0, boardSize, boardSize);
			this.board.graphics.endFill();
			
			// Draw cells on board
			var lineSpace:Number = boardSize / 8;
			this.board.graphics.lineStyle(1, 0x000000);
			var linePosition:uint = 0;
			for (var i:uint = 0; i <= 8; ++i)
			{
				linePosition = i * lineSpace;
				if (linePosition == boardSize) linePosition -= 1;
				// Veritcal
				this.board.graphics.moveTo(linePosition, 0);
				this.board.graphics.lineTo(linePosition, boardSize);
				// Horizontal
				this.board.graphics.moveTo(0, linePosition);
				this.board.graphics.lineTo(boardSize, linePosition);
			}

			this.addChild(this.board);
			this.placeStones();
			this.board.addEventListener(MouseEvent.CLICK, onBoardClicked);
		}
		
		private function initStones():void
		{
			this.stones = new Array(8);
			for (var i:uint = 0; i < 8; ++i)
			{
				this.stones[i] = new Array(8);
			}
			this.stones[3][3] = WHITE;
			this.stones[4][4] = WHITE;
			this.stones[4][3] = BLACK;
			this.stones[3][4] = BLACK;
		}
		
		private function placeStones():void
		{
			var cellSize:Number = (this.board.width / 8); 
			var stoneSize:Number = cellSize - 2;
			for (var x:uint = 0; x < 8; ++x)
			{
				for (var y:uint = 0; y < 8; ++y)
				{
					if (this.stones[x][y] == null) continue;
					this.placeStone(this.stones[x][y], x, y);
				}
			}
		}
		
		private function placeStone(color:Boolean, x:uint, y:uint):void
		{
			var cellSize:Number = (this.board.width / 8); 
			var stoneSize:Number = cellSize - 2;
			var stone:Sprite = new Sprite();
			stone.mouseEnabled = false;
			stone.graphics.beginFill((color == WHITE) ? 0xffffff : 0x000000);
			stone.graphics.drawCircle(stoneSize/2, stoneSize/2, stoneSize/2);
			stone.graphics.endFill();
			stone.x = (x * cellSize) + 1;
			stone.y = (y * cellSize) + 1;
			this.board.addChild(stone);
		}
		
		private function onBoardClicked(e:MouseEvent):void
		{
			var scaleFactor:uint = this.board.width / 8;
			var x:uint = e.localX / scaleFactor;
			var y:uint = e.localY / scaleFactor;
			if (this.stones[x][y] != null) return;
			if (!this.findCaptures(this.turn, x, y)) return;
			this.placeStone(this.turn, x, y);
			this.stones[x][y] = this.turn;
			this.turn = !this.turn;
		}
		
		private function findCaptures(turn:Boolean, x:uint, y:uint):Boolean
		{
			var topLeft:Boolean     = this.walkPath(turn, x, y, -1, -1); // top left
			var top:Boolean         = this.walkPath(turn, x, y,  0, -1); // top
			var topRight:Boolean    = this.walkPath(turn, x, y,  1, -1); // top right
			var right:Boolean       = this.walkPath(turn, x, y,  1,  0); // right
			var bottomRight:Boolean = this.walkPath(turn, x, y,  1,  1); // bottom right
			var bottom:Boolean      = this.walkPath(turn, x, y,  0,  1); // bottom
			var bottomLeft:Boolean  = this.walkPath(turn, x, y, -1, +1); // bottom left
			var left:Boolean        = this.walkPath(turn, x, y, -1,  0); // left
			return (topLeft || top || topRight || right || bottomRight || bottom || bottomLeft || left) ? true : false;
		}
		
		private function walkPath(turn:Boolean, x:uint, y:uint, xFactor:int, yFactor:int):Boolean
		{
			// Are we in bounds?
			if (x + xFactor > 7 || x + xFactor < 0 || y + yFactor > 7 || y + yFactor < 0)
			{
				return false;
			}

			// Is the next squre empty?
			if (this.stones[x + xFactor][y + yFactor] == null)
			{
				return false;
			}
			
			var nextStone:Boolean = this.stones[x + xFactor][y + yFactor];

			// Is the next stone the wrong color?
			if (nextStone != !turn)
			{
				return false;
			}
			
			// Find the next piece of the same color
			var tmpX:uint = x, tmpY:uint = y;
			while (true)
			{
				tmpX = tmpX + xFactor;
				tmpY = tmpY + yFactor;
				if (this.stones[tmpX][tmpY] == null) // Not enclosed
				{
					return false;
				}
				nextStone = this.stones[tmpX][tmpY];
				if (nextStone == turn) // Capture!
				{
					this.turnStones(turn, x, y, tmpX, tmpY, xFactor, yFactor);
					return true;
				}
			}
			return false;
		}
		
		private function turnStones(turn:Boolean, fromX:uint, fromY:uint, toX:uint, toY:uint, xFactor:uint, yFactor:uint):void
		{
			var nextX:uint = fromX, nextY:uint = fromY;
			while (true)
			{
				nextX = nextX + xFactor;
				nextY = nextY + yFactor;
				this.stones[nextX][nextY] = turn;
				this.placeStone(turn, nextX, nextY);
				if (nextX == toX && nextY == toY) return;
			}
		}
	}
}