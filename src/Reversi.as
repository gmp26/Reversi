package
{
	import com.christiancantrell.components.Alert;
	import com.christiancantrell.components.AlertEvent;
	import com.christiancantrell.components.Label;
	import com.christiancantrell.components.TextButton;
	import com.christiancantrell.utils.Layout;
	import com.christiancantrell.utils.Ruler;
	
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
	
	public class Reversi extends Sprite
	{
		private const WHITE_COLOR:uint        = 0xffffff;
		private const WHITE_COLOR_NAME:String = "White";
		private const BLACK_COLOR:uint        = 0x000000;
		private const BLACK_COLOR_NAME:String = "Black";
		private const BOARD_COLORS:Array      = [0x666666, 0x333333];
		private const BOARD_LINES:uint        = 0x666666;
		private const BACKGROUND_COLOR:uint   = 0x666666;
		private const TITLE_COLOR:uint        = 0xffffff;
		private const TURN_GLOW_COLORS:Array  = [0xffffff, 0x000000];
		private const TITLE:String = "Reversi";
		private const WHITE:Boolean = true;
		private const BLACK:Boolean = false;
		private const PORTRAIT:String = "portrait";
		private const LANDSCAPE:String = "landscape";
		private const CACHE_AS_BITMAP:Boolean = true;
		
		private var board:Sprite;
		private var stones:Array;
		private var turn:Boolean;
		private var pieces:Vector.<Sprite>;
		private var history:Array;
		private var historyIndex:int;
		private var title:Label;
		private var blackScoreLabel:Label, whiteScoreLabel:Label;
		private var backButton:TextButton, nextButton:TextButton;
		private var blackScore:uint;
		private var whiteScore:uint;
		private var turnFilter:BlurFilter;
		private var ppi:uint;
		private var stoneBevel:BevelFilter;
		private var boardShadow:DropShadowFilter;
		private var titleShadow:DropShadowFilter;
		
		public function Reversi(ppi:int = -1)
		{
			super();
			this.ppi = (ppi == -1) ? Capabilities.screenDPI : ppi;
			this.prepareGame();
			this.initUIComponents();
			this.addEventListener(Event.ADDED, onAddedToDisplayList);
		}
		
		private function prepareGame():void
		{
			this.history = new Array(64);
			this.historyIndex = -1;
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
			this.titleShadow = new DropShadowFilter(0, 90, 0, 1, 10, 10, 1, 1, false, true);
			this.title.filters = [this.titleShadow];
			this.turnFilter = new BlurFilter(8, 8, 1);
			this.stoneBevel = new BevelFilter(1, 45);
			this.boardShadow = new DropShadowFilter(0, 90, 0, 1, 10, 10, 1, 1);
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
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(boardSize, boardSize, 0, 0, 0);
			this.board.graphics.beginGradientFill(GradientType.RADIAL, BOARD_COLORS, [1, 1], [0, 255], matrix, SpreadMethod.PAD, InterpolationMethod.LINEAR_RGB, 0);
			this.board.graphics.drawRect(0, 0, boardSize, boardSize);
			this.board.graphics.endFill();
			this.board.filters = [this.boardShadow];
			
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

			this.title.y = 24;
			var gutterWidth:uint, gutterHeight:uint, scoreSize:uint;
			var newGameButton:TextButton, buttonWidth:Number, buttonHeight:Number;
			if (this.getOrientation() == PORTRAIT) // Portrait
			{
				gutterHeight = (stageHeight - boardSize) / 2;
				gutterWidth = stageWidth;

				// Scores
				scoreSize = gutterHeight * .6;;
				this.blackScoreLabel = new Label(String(this.blackScore), "bold", BLACK_COLOR, "_sans", scoreSize);
				this.whiteScoreLabel = new Label(String(this.whiteScore), "bold", WHITE_COLOR, "_sans", scoreSize);

				Layout.centerHorizontally(this.title, this.stage);
				this.alignScores();

				buttonWidth = stageWidth / 3;
				buttonHeight = Ruler.mmToPixels(10, this.ppi);
				
				this.backButton = new TextButton("BACK", true, buttonWidth, buttonHeight);
				this.backButton.addEventListener(MouseEvent.CLICK, this.onBack);
				this.backButton.x = 2;
				this.backButton.y = (stageHeight - this.backButton.height) - 1;
				this.addChild(this.backButton);
				
				newGameButton = new TextButton("NEW", true, buttonWidth - 6, buttonHeight);
				newGameButton.x = (gutterWidth / 2) - (this.backButton.width / 2) + 3;
				newGameButton.y = this.backButton.y;
				newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClicked);
				this.addChild(newGameButton);
				
				this.nextButton = new TextButton("NEXT", true, buttonWidth, buttonHeight);
				this.nextButton.addEventListener(MouseEvent.CLICK, this.onNext);
				this.nextButton.x = gutterWidth - this.nextButton.width - 2;
				this.nextButton.y = newGameButton.y;
				this.addChild(this.nextButton);
			}
			else // Landscape
			{
				gutterWidth = (stageWidth - boardSize) / 2;
				gutterHeight = stageHeight;

				// Scores
				scoreSize = gutterHeight * .3;
				this.blackScoreLabel = new Label(String(this.blackScore), "bold", BLACK_COLOR, "_sans", scoreSize);
				this.whiteScoreLabel = new Label(String(this.whiteScore), "bold", WHITE_COLOR, "_sans", scoreSize);
				
				this.title.x = ((boardX / 2) - (this.title.width / 2) - 4);

				buttonWidth = gutterWidth - 10;
				buttonHeight = Ruler.mmToPixels(10, this.ppi);

				newGameButton = new TextButton("NEW", false, buttonWidth, buttonHeight);
				newGameButton.x = (stageWidth - gutterWidth) + ((gutterWidth - newGameButton.width) / 2);
				newGameButton.y = 5;
				newGameButton.addEventListener(MouseEvent.CLICK, onNewGameButtonClicked);
				this.addChild(newGameButton);

				this.backButton = new TextButton("BACK", false, buttonWidth, buttonHeight);
				this.backButton.addEventListener(MouseEvent.CLICK, this.onBack);
				this.backButton.x = (gutterWidth - this.backButton.width) / 2;
				this.backButton.y = (stageHeight - this.backButton.height) - 5;
				this.addChild(this.backButton);
				
				this.nextButton = new TextButton("NEXT", false, buttonWidth, buttonHeight);
				this.nextButton.addEventListener(MouseEvent.CLICK, this.onNext);
				this.nextButton.x = newGameButton.x;
				this.nextButton.y = (stageHeight - this.nextButton.height) - 5;
				this.addChild(this.nextButton);
			}
			this.evaluateButtons();
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
				this.blackScoreLabel.y = ((gutterDimensions.height / 2) + (this.blackScoreLabel.textHeight / 2) + 4);
				this.blackScoreLabel.x = ((gutterDimensions.width / 4) - (this.blackScoreLabel.textWidth / 2) - 4);
				
				this.whiteScoreLabel.y = ((gutterDimensions.height / 2) + (this.whiteScoreLabel.textHeight / 2) + 4);
				this.whiteScoreLabel.x = ((gutterDimensions.width) - ((gutterDimensions.width / 4) + (this.blackScoreLabel.textWidth / 2)) + 4);
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
			if (this.historyIndex == 0) return;
			--this.historyIndex;
			this.stones = this.deepCopyStoneArray(this.history[this.historyIndex]);
			this.placeStones();
			this.changeTurn();
			this.onTurnFinished(false);
		}
		
		private function onNext(e:MouseEvent):void
		{
			if (this.history[this.historyIndex+1] == null) return;
			++this.historyIndex;
			this.stones = this.deepCopyStoneArray(this.history[this.historyIndex]);
			this.placeStones();
			this.changeTurn();
			this.onTurnFinished(false);
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
				this.prepareGame();
				this.placeStones();
				this.changeTurnIndicator();
				this.calculateScore();
				this.evaluateButtons();
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
			this.saveHistory();
		}
		
		private function saveHistory():void
		{
			++this.historyIndex;
			this.history[this.historyIndex] = this.deepCopyStoneArray(this.stones);
			for (var i:uint = this.historyIndex + 1; i < 64; ++i)
			{
				this.history[i] = null;
			}
		}
		
		private function placeStones():void
		{
			this.pieces = new Vector.<Sprite>(64);
			while (this.board.numChildren > 0) this.board.removeChildAt(0);
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
			this.board.cacheAsBitmap = CACHE_AS_BITMAP;
		}
		
		private function placeStone(color:Boolean, x:uint, y:uint):void
		{
			var cellSize:Number = (this.board.width / 8); 
			var stoneSize:Number = cellSize - 2;
			this.removePieceFromBoard(x, y);
			var stone:Sprite = new Sprite();
			this.pieces[this.coordinatesToIndex(x, y)] = stone;
			stone.mouseEnabled = false;
			stone.graphics.beginFill((color == WHITE) ? WHITE_COLOR : BLACK_COLOR);
			stone.graphics.drawCircle(stoneSize/2, stoneSize/2, stoneSize/2);
			stone.graphics.endFill();
			stone.filters = [this.stoneBevel];
			stone.x = (x * cellSize) + 1;
			stone.y = (y * cellSize) + 1;
			this.board.addChild(stone);
		}
		
		private function removePieceFromBoard(x:uint, y:uint):void
		{
			var index:uint = this.coordinatesToIndex(x, y);
			if (this.pieces[index] != null)
			{
				this.board.removeChild(Sprite(this.pieces[index]));
			}
		}
		
		private function coordinatesToIndex(x:uint, y:uint):uint
		{
			return (y * 8) + x;
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
			this.saveHistory();
			this.onTurnFinished(true);
		}
		
		private function deepCopyStoneArray(stoneArray:Array):Array
		{
			var newStones:Array = new Array(8);
			for (var x:uint = 0; x < 8; ++x)
			{
				newStones[x] = new Array(8);
				for (var y:uint = 0; y < 8; ++y)
				{
					if (stoneArray[x][y] != null) newStones[x][y] = stoneArray[x][y];
				}
			}
			return newStones;
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
		
		private function onTurnFinished(changeTurns:Boolean):void
		{
			this.calculateScore();
			this.evaluateButtons();

			if (this.isNextMovePossible(!this.turn))
			{
				if (changeTurns) this.changeTurn();
				return;
			}

			if ((this.blackScore + this.whiteScore) == 64) // All stomes played. Game is over.
			{
				var allStonesPlayedAlert:Alert = new Alert(this.stage, this.ppi);
				var winner:String = (this.blackScore > this.whiteScore) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				allStonesPlayedAlert.show(winner + " Wins!", "All stones have been played, so the game is over. Well done, " + winner + "!");
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
			
			if (!this.isNextMovePossible(this.turn)) // Neither player can make a move. Unusual, but possible.
			{
				var noMoreMovesAlert:Alert = new Alert(this.stage, this.ppi);
				var defaultWinner:String = (this.blackScore > this.whiteScore) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
				noMoreMovesAlert.show(defaultWinner + " Wins!", "Neither player can make a move, therefore the game is over and " + defaultWinner + " wins!");
				return;
			}

			// Game isn't over, but opponent can't place a stone.
			var noNextMoveAlert:Alert = new Alert(this.stage, this.ppi);
			var side:String = (this.turn == WHITE) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
			var otherSide:String = (this.turn != WHITE) ? BLACK_COLOR_NAME : WHITE_COLOR_NAME;
			noNextMoveAlert.show("No Move Available", side + " has no possible moves, and therefore must pass. It's still " + otherSide + "'s turn.");
		}
		
		private function isNextMovePossible(player:Boolean):Boolean
		{
			for (var x:uint = 0; x < 8; ++x)
			{
				for (var y:uint = 0; y < 8; ++y)
				{
					if (this.stones[x][y] != null) continue;
					if (this.findCaptures(player, x, y, false)) return true;
				}
			}
			return false;
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
				this.whiteScoreLabel.filters = null;
				this.blackScoreLabel.filters = [this.turnFilter];
			}
			else
			{
				this.blackScoreLabel.filters = null;
				this.whiteScoreLabel.filters = [this.turnFilter];
			}
		}
		
		private function evaluateButtons():void
		{
			this.backButton.enabled = (this.historyIndex == 0) ? false : true;
			this.nextButton.enabled = (this.history[this.historyIndex+1] == null) ? false : true;
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