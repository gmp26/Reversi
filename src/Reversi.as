package
{
	import com.christiancantrell.components.Label;
	import com.christiancantrell.pieces.Board;
	import com.christiancantrell.utils.Layout;
	import com.christiancantrell.utils.Ruler;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	public class Reversi extends Sprite
	{
		private const WHITE_COLOR:uint      = 0xffffff;
		private const BLACK_COLOR:uint      = 0x000000;
		private const BOARD_COLOR:uint      = 0x00ff00;
		private const BOARD_LINES:uint      = 0x000000;
		private const BACKGROUND_COLOR:uint = 0xcc9900;
		private const TITLE_COLOR:uint      = 0x000000;
		private const TURN_GLOW:uint        = 0x0000ff;
		
		private const TITLE:String = "Reversi";
		
		private const WHITE:Boolean = true;
		private const BLACK:Boolean = false;
		
		private var board:Sprite;
		private var stones:Array;
		private var turn:Boolean;
		
		private var title:Label;
		private var blackScoreLabel:Label;
		private var whiteScoreLabel:Label;
		private var blackScoreCircle:Sprite;
		private var whiteScoreCircle:Sprite;
		private var blackScore:uint;
		private var whiteScore:uint;
		private var turnGlow:GlowFilter;
		private var dpi:uint;
		
		public function Reversi()
		{
			super();
			this.dpi = Capabilities.screenDPI;
			this.initStones();
			this.turn = BLACK;
			this.blackScore = 0;
			this.whiteScore = 0;
			this.initUIComponents();
			this.addEventListener(Event.ADDED, onAddedToDisplayList);
		}
		
		private function onAddedToDisplayList(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAddedToDisplayList);
			this.stage.addEventListener(Event.RESIZE, doLayout);
		}
		
		private function initUIComponents():void
		{
			var titleSize:uint = Ruler.mmToPixels(5, this.dpi);
			this.title = new Label(TITLE, "bold", TITLE_COLOR, "_sans", titleSize);
			this.turnGlow = new GlowFilter(TURN_GLOW, 1, 10, 10);
		}
		
		public function doLayout(e:Event):void
		{
			// Remove any children that have already been added.
			while (this.numChildren > 0) this.removeChildAt(0);

			var stageWidth:uint = this.stage.stageWidth;
			var stageHeight:uint = this.stage.stageHeight;
			
			// Draw the background
			var bg:Sprite = new Sprite();
			bg.graphics.beginFill(BACKGROUND_COLOR);
			bg.graphics.drawRect(0, 0, stageWidth, stageHeight);
			bg.graphics.endFill();
			this.addChild(bg);
			
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
			this.board.graphics.beginFill(BOARD_COLOR);
			this.board.graphics.drawRect(0, 0, boardSize, boardSize);
			this.board.graphics.endFill();
			
			// Draw cells on board
			var lineSpace:Number = boardSize / 8;
			this.board.graphics.lineStyle(1, BOARD_LINES);
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
			
			this.title.y = 14;
			this.blackScoreCircle = new Sprite();
			this.whiteScoreCircle = new Sprite();
			var gutterWidth:uint, gutterHeight:uint, scoreCircleSize:uint;
			if (stageHeight > stageWidth) // Portrait
			{
				gutterWidth = stageWidth;
				gutterHeight = (stageHeight - boardSize) / 2;

				// Title
				Layout.centerHorizontally(this.title, this.stage);

				// Score circles
				scoreCircleSize = gutterHeight - 20;

				// Black score circle
				this.blackScoreCircle.graphics.beginFill(BLACK_COLOR);
				this.blackScoreCircle.graphics.drawCircle(0, 0, scoreCircleSize / 2);
				this.blackScoreCircle.x = (gutterWidth / 4);
				this.blackScoreCircle.y = (gutterHeight / 2);
				this.addChild(this.blackScoreCircle);

				// White score circle
				this.whiteScoreCircle.graphics.beginFill(WHITE_COLOR);
				this.whiteScoreCircle.graphics.drawCircle(0, 0, scoreCircleSize / 2);
				this.whiteScoreCircle.x = gutterWidth - (gutterWidth / 4);
				this.whiteScoreCircle.y = (gutterHeight / 2);
				this.addChild(this.whiteScoreCircle);
			}
			else // Landscape
			{
				gutterWidth = (stageWidth - boardSize) / 2;
				gutterHeight = stageHeight;
				
				// Title
				this.title.x = (boardX / 2) - (this.title.width / 2);

				// Score circles
				scoreCircleSize = gutterWidth - 50;
				
				// Black score circle
				this.blackScoreCircle.graphics.beginFill(BLACK_COLOR);
				this.blackScoreCircle.graphics.drawCircle(0, 0, scoreCircleSize / 2);
				this.blackScoreCircle.x = (gutterWidth / 2);
				this.blackScoreCircle.y = (gutterHeight / 3);
				this.addChild(this.blackScoreCircle);
				
				// White score circle
				this.whiteScoreCircle.graphics.beginFill(WHITE_COLOR);
				this.whiteScoreCircle.graphics.drawCircle(0, 0, scoreCircleSize / 2);
				this.whiteScoreCircle.x = stageWidth - (gutterWidth / 2);
				this.whiteScoreCircle.y = gutterHeight / 3;
				this.addChild(this.whiteScoreCircle);
			}
			this.addChild(title);
			
			// Black score
			this.blackScoreLabel = new Label(String(this.blackScore), "normal", WHITE_COLOR, "_sans", scoreCircleSize - 4);
			this.alignScores(this.blackScoreLabel, this.blackScoreCircle);
			this.blackScoreCircle.addChild(this.blackScoreLabel);
			
			// White score
			this.whiteScoreLabel = new Label(String(this.whiteScore), "normal", BLACK_COLOR, "_sans", scoreCircleSize - 4);
			this.alignScores(this.whiteScoreLabel, this.whiteScoreCircle);
			this.whiteScoreCircle.addChild(this.whiteScoreLabel);
			
			this.changeTurnIndicator();
		}
		
		private function alignScores(label:Label, circle:Sprite):void
		{
			label.x = 0;
			label.y = 0;
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
			stone.graphics.beginFill((color == WHITE) ? WHITE_COLOR : BLACK_COLOR);
			stone.graphics.drawCircle(stoneSize/2, stoneSize/2, stoneSize/2);
			stone.graphics.endFill();
			stone.x = (x * cellSize) + 1;
			stone.y = (y * cellSize) + 1;
			// TBD: Is this the best way to remove turned stones? Could be a performance problem.
			for (var i:uint = 0; i < this.board.numChildren; ++i)
			{
				var testStone:Sprite = this.board.getChildAt(i) as Sprite;
				if (testStone.x == stone.x && testStone.y == stone.y)
				{
					this.board.removeChild(testStone);
				}
			}
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
			this.onTurnFinished();
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
			var tmpX:int = x, tmpY:int = y;
			while (true)
			{
				tmpX = tmpX + xFactor;
				tmpY = tmpY + yFactor;
				if (tmpX < 0 || tmpY < 0 || tmpX > 7 || tmpY > 7 || this.stones[tmpX][tmpY] == null) // Not enclosed
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
		
		private function onTurnFinished():void
		{
			this.changeTurnIndicator();
			this.calculateScore();
		}
		
		private function changeTurnIndicator():void
		{
			if (this.turn == WHITE)
			{
				this.whiteScoreCircle.filters = [this.turnGlow];
				this.blackScoreCircle.filters = null;
			}
			else
			{
				this.blackScoreCircle.filters = [this.turnGlow];
				this.whiteScoreCircle.filters = null;
			}
		}
		
		private function calculateScore():void
		{
			var black:uint = 0;
			var white:uint = 0;
			for (var x:uint = 0; x < this.stones.length; ++x)
			{
				for (var y:uint = 0; y < this.stones[x].length; ++y)
				{
					if (this.stones[x][y] == null)
					{
						continue;
					}
					else if (this.stones[x][y] == WHITE)
					{
						++white;
					}
					else
					{
						++black;
					}
				}
			}
			this.blackScore = black;
			this.whiteScore = white;
			this.whiteScoreLabel.update(String(this.whiteScore));
			this.blackScoreLabel.update(String(this.blackScore));
		}
	}
}