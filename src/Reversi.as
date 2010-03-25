package
{
	import com.christiancantrell.components.Alert;
	import com.christiancantrell.components.AlertEvent;
	import com.christiancantrell.components.Button;
	import com.christiancantrell.components.Label;
	import com.christiancantrell.models.Turn;
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
		private const WHITE_COLOR:uint        = 0xffffff;
		private const WHITE_COLOR_NAME:String = "White";
		private const BLACK_COLOR:uint        = 0xff0000;
		private const BLACK_COLOR_NAME:String = "Red";
		private const BOARD_COLOR:uint        = 0x000000;
		private const BOARD_LINES:uint        = 0xffffff;
		private const BACKGROUND_COLOR:uint   = 0x666666;
		private const TITLE_COLOR:uint        = 0xffffff;
		private const TURN_GLOW:uint          = 0x0000ff;
		
		private const TITLE:String = "Reversi";
		
		private const WHITE:Boolean = true;
		private const BLACK:Boolean = false;
		
		private const PORTRAIT:String = "portrait";
		private const LANDSCAPE:String = "landscape";
		
		private var board:Sprite;
		private var stones:Array;
		private var turn:Boolean;
		private var pieces:Vector.<Sprite>;
		private var history:Array;
		private var title:Label;
		private var blackScoreLabel:Label, whiteScoreLabel:Label;
		private var backButton:Button, nextButton:Button;
		private var blackScore:uint;
		private var whiteScore:uint;
		private var turnGlow:GlowFilter;
		private var ppi:uint;
		
		public function Reversi()
		{
			super();
			this.ppi = Capabilities.screenDPI;
			this.prepareGame();
			this.initUIComponents();
			this.addEventListener(Event.ADDED, onAddedToDisplayList);
		}
		
		private function prepareGame():void
		{
			this.pieces = new Vector.<Sprite>(64);
			this.history = new Array();
			this.initStones();
			this.turn = BLACK;  // Black always starts
			this.blackScore = 2;
			this.whiteScore = 2;
		}
		
		private function onAddedToDisplayList(e:Event):void
		{
			this.removeEventListener(Event.ADDED, onAddedToDisplayList);
			this.stage.addEventListener(Event.RESIZE, doLayout);
		}
		
		private function initUIComponents():void
		{
			var titleSize:uint = Ruler.mmToPixels(7, this.ppi);
			this.title = new Label(TITLE, "bold", TITLE_COLOR, "_sans", titleSize);
			this.turnGlow = new GlowFilter(TURN_GLOW, 1, 10, 10);
		}
		
		public function doLayout(e:Event):void
		{
			// Remove any children that have already been added.
			while (this.numChildren > 0) this.removeChildAt(0);
			this.pieces = new Vector.<Sprite>(64);
			
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
			
			// Scores
			var scoreSize:uint = (this.getOrientation() == PORTRAIT) ? Ruler.mmToPixels(this.ppi, 25) : Ruler.mmToPixels(this.ppi, 35);
			this.blackScoreLabel = new Label(String(this.blackScore), "normal", BLACK_COLOR, "_sans", scoreSize);
			this.whiteScoreLabel = new Label(String(this.whiteScore), "normal", WHITE_COLOR, "_sans", scoreSize);

			this.title.y = 22;
			var gutterWidth:uint, gutterHeight:uint;
			var newGameButton:Button, buttonWidth:Number, buttonHeight:Number;
			if (this.getOrientation() == PORTRAIT) // Portrait
			{
				Layout.centerHorizontally(this.title, this.stage);
				this.alignScores();

				buttonWidth = stageWidth / 3;
				buttonHeight = Ruler.mmToPixels(10, this.ppi);
				
				this.backButton = new Button("Back", buttonWidth, buttonHeight);
				this.backButton.addEventListener(MouseEvent.CLICK, this.onBack);
				this.backButton.x = 0;
				this.backButton.y = (stageHeight - this.backButton.height);
				this.addChild(this.backButton);
				
				newGameButton = new Button("New Game", buttonWidth, buttonHeight);
				newGameButton.x = this.backButton.width;
				newGameButton.y = (stageHeight - newGameButton.height);
				newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClicked);
				this.addChild(newGameButton);
				
				this.nextButton = new Button("Next", buttonWidth, buttonHeight);
				this.nextButton.addEventListener(MouseEvent.CLICK, this.onNext);
				this.nextButton.x = newGameButton.x + newGameButton.width;
				this.nextButton.y = (stageHeight - this.nextButton.height);
				this.addChild(this.nextButton);
			}
			else // Landscape
			{
				gutterWidth = (stageWidth - boardSize) / 2;
				this.title.x = (boardX / 2) - (this.title.width / 2);

				buttonWidth = gutterWidth - 10;
				buttonHeight = Ruler.mmToPixels(10, this.ppi);

				newGameButton = new Button("New Game", buttonWidth, buttonHeight);
				newGameButton.x = (stageWidth - gutterWidth) + ((gutterWidth - newGameButton.width) / 2);
				newGameButton.y = 5;
				newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClicked);
				this.addChild(newGameButton);

				this.backButton = new Button("Back", buttonWidth, buttonHeight);
				this.backButton.addEventListener(MouseEvent.CLICK, this.onBack);
				this.backButton.x = (gutterWidth - this.backButton.width) / 2;
				this.backButton.y = (stageHeight - this.backButton.height) - 5;
				this.addChild(this.backButton);
				
				this.nextButton = new Button("Next", buttonWidth, buttonHeight);
				this.nextButton.addEventListener(MouseEvent.CLICK, this.onNext);
				this.nextButton.x = newGameButton.x;
				this.nextButton.y = (stageHeight - this.nextButton.height) - 5;
				this.addChild(this.nextButton);
			}
			this.addChild(title);
			this.alignScores();
			this.addChild(this.blackScoreLabel);
			this.addChild(this.whiteScoreLabel);
			this.changeTurnIndicator();
		}
		
		private function alignScores():void
		{
			var gutterDimensions:Object = this.getGutterDimensions();
			if (this.getOrientation() == LANDSCAPE)
			{
				Layout.centerVertically(this.blackScoreLabel, this.stage);
				this.blackScoreLabel.x = (gutterDimensions.width / 2) - (this.blackScoreLabel.textWidth / 2);
				Layout.centerVertically(this.whiteScoreLabel, this.stage);
				this.whiteScoreLabel.x = this.stage.stageWidth - ((gutterDimensions.width / 2) + (this.whiteScoreLabel.textWidth / 2));
			}
			else
			{
				this.blackScoreLabel.y = (gutterDimensions.height / 2) + (this.blackScoreLabel.textHeight / 2);
				this.blackScoreLabel.x = (gutterDimensions.width / 4) - (this.blackScoreLabel.textWidth / 2);
				
				this.whiteScoreLabel.y = (gutterDimensions.height / 2) + (this.whiteScoreLabel.textHeight / 2);
				this.whiteScoreLabel.x = (gutterDimensions.width) - ((gutterDimensions.width / 4) + (this.blackScoreLabel.textWidth / 2));
			}
		}
		
		private function getOrientation():String
		{
			return (this.stage.stageHeight > this.stage.stageWidth) ? PORTRAIT : LANDSCAPE;
		}

		private function getGutterDimensions():Object
		{
			var gutter:Object = new Object();
			var gutterWidth:uint, gutterHeight:uint;
			if (this.getOrientation() == PORTRAIT)
			{
				gutterWidth = this.stage.stageWidth;
				gutterHeight = (this.stage.stageHeight - this.board.width) / 2;
			}
			else
			{
				gutterWidth = (this.stage.stageWidth - this.board.width) / 2;
				gutterHeight = this.stage.stageHeight;
			}
			gutter.width = gutterWidth;
			gutter.height = gutterHeight;
			return gutter;
		}
		
		private function onBack(e:MouseEvent):void
		{
			if (this.history.length == 0) return;
			var turn:Turn = this.history.pop();
			this.stones[turn.x][turn.y] = null;
			this.findCaptures(!turn.player, turn.x, turn.y, true);
		}
		
		private function onNext(e:MouseEvent):void
		{
			
		}
		
		private function onNewGameButtonClicked(e:MouseEvent):void
		{
			var alert:Alert = new Alert(this.stage, this.ppi);
			alert.addEventListener(AlertEvent.ALERT_CLICKED, onNewGameConfirm);
			alert.show("Confirm", "Are you sure you want to start a new game?", ["Yes", "No"]);
		}
		
		private function onNewGameConfirm(e:AlertEvent):void
		{
			var alert:Alert = e.target as Alert;
			alert.removeEventListener(AlertEvent.ALERT_CLICKED, onNewGameConfirm);
			if (e.label == "Yes")
			{
				while (this.board.numChildren > 0) this.board.removeChildAt(0);
				this.prepareGame();
				this.placeStones();
				this.changeTurnIndicator();
				this.calculateScore();
			}
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
			var index:uint = (y * 8) + x;
			var cellSize:Number = (this.board.width / 8); 
			var stoneSize:Number = cellSize - 2;
			if (this.pieces[index] != null)
			{
				this.board.removeChild(Sprite(this.pieces[index]));
			}
			var stone:Sprite = new Sprite();
			this.pieces[index] = stone;
			stone.mouseEnabled = false;
			stone.graphics.beginFill((color == WHITE) ? WHITE_COLOR : BLACK_COLOR);
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
			if (!this.findCaptures(this.turn, x, y, true)) return;
			this.placeStone(this.turn, x, y);
			this.stones[x][y] = this.turn;
			var turn:Turn = new Turn(x, y, this.turn);
			this.history.push(turn);
			this.onTurnFinished();
		}
		
		private function findCaptures(turn:Boolean, x:uint, y:uint, turnStones:Boolean):Boolean
		{
			var topLeft:Boolean     = this.walkPath(turn, x, y, -1, -1, turnStones); // top left
			var top:Boolean         = this.walkPath(turn, x, y,  0, -1, turnStones); // top
			var topRight:Boolean    = this.walkPath(turn, x, y,  1, -1, turnStones); // top right
			var right:Boolean       = this.walkPath(turn, x, y,  1,  0, turnStones); // right
			var bottomRight:Boolean = this.walkPath(turn, x, y,  1,  1, turnStones); // bottom right
			var bottom:Boolean      = this.walkPath(turn, x, y,  0,  1, turnStones); // bottom
			var bottomLeft:Boolean  = this.walkPath(turn, x, y, -1, +1, turnStones); // bottom left
			var left:Boolean        = this.walkPath(turn, x, y, -1,  0, turnStones); // left
			return (topLeft || top || topRight || right || bottomRight || bottom || bottomLeft || left) ? true : false;
		}
		
		private function walkPath(turn:Boolean, x:uint, y:uint, xFactor:int, yFactor:int, turnStones:Boolean):Boolean
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
					if (turnStones) this.turnStones(turn, x, y, tmpX, tmpY, xFactor, yFactor);
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
			this.calculateScore();
			if ((this.blackScore + this.whiteScore) == 64) // All stomes played. Game is over.
			{
				var allStonesPlayedAlert:Alert = new Alert(this.stage, this.ppi);
				var winner:String = (this.blackScore > this.whiteScore) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				allStonesPlayedAlert.show(winner + " Wins!", "All stones have been played, so the game is over. Well done, " + winner + "!");
				return;
			}
			
			if (this.isNextMovePossible())
			{
				this.changeTurn();
				return;
			}
			
			if (this.blackScore == 0 || this.whiteScore == 0) // All stones captured. Game over.
			{
				var allStonesCapturedAlert:Alert = new Alert(this.stage, this.ppi);
				var zeroPlayer:String = (this.blackScore == 0) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				var nonZeroPlayer:String = (this.blackScore != 0) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				allStonesCapturedAlert.show(nonZeroPlayer + " Wins!", nonZeroPlayer + " has captured all of " + zeroPlayer + "'s stones. Well done, " + nonZeroPlayer + "!");
				return;
			}
			else // Game isn't over, but opponent can't place stone.
			{
				var noNextMoveAlert:Alert = new Alert(this.stage, this.ppi);
				var side:String = (this.turn == WHITE) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				var otherSide:String = (this.turn != WHITE) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				noNextMoveAlert.show("No Move Available", side + " has no possible moves, and therefore must pass. It's still " + otherSide + "'s turn.");
			}
		}
		
		private function isNextMovePossible():Boolean
		{
			var capturesFound:Boolean = false;
			for (var x:uint = 0; x < 8; ++x)
			{
				for (var y:uint = 0; y < 8; ++y)
				{
					if (this.stones[x][y] != null) continue;
					if (this.findCaptures(!this.turn, x, y, false)) return true;
				}
			}
			return capturesFound;
		}
		
		private function changeTurn():void
		{
			this.turn = !this.turn;
			this.changeTurnIndicator();
		}
		
		private function changeTurnIndicator():void
		{
			if (this.turn == WHITE)
			{
				this.whiteScoreLabel.filters = [this.turnGlow];
				this.blackScoreLabel.filters = null;
			}
			else
			{
				this.blackScoreLabel.filters = [this.turnGlow];
				this.whiteScoreLabel.filters = null;
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
			this.alignScores();
		}
	}
}