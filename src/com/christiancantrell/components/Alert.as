package com.christiancantrell.components
{
	import com.christiancantrell.utils.Layout;
	import com.christiancantrell.utils.Ruler;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	[Event(name=AlertEvent.ALERT_CLICKED, type="com.christiancantrell.components.AlertEvent")]
	public class Alert extends Sprite
	{
		private const BACKGROUND_COLOR:uint   = 0x0000ff;
		private const BACKGROUND_ALPHA:Number = .85;
		private const BORDER_COLOR:uint       = 0xffffff;
		private const FONT_COLOR:uint         = 0xffffff;
		private const CORNER:uint             = 20;
		private const MARGIN:uint             = 15;
		
		private var _stage:Stage;
		private var _ppi:uint;

		public function Alert(stage:Stage, ppi:uint)
		{
			this._stage = stage;
			this._ppi = ppi;
		}
		
		public function show(title:String, message:String, buttonLabels:Array = null):void
		{
			var bgWidth:uint = (this._stage.stageWidth < 300) ? this._stage.stageWidth - 20 : 300;
			
			var titleLabel:Label = new Label(title, "bold", FONT_COLOR);
			titleLabel.x = (bgWidth / 2) - (titleLabel.width / 2);
			titleLabel.y = 15 + MARGIN;
			this.addChild(titleLabel);

			var messageLabel:MultilineLabel = new MultilineLabel(message, bgWidth - (MARGIN * 2), -1, "normal", FONT_COLOR);
			messageLabel.x = MARGIN;
			messageLabel.y = titleLabel.y + (MARGIN * 1.5);
			this.addChild(messageLabel);
						
			var buttonCount:uint = (buttonLabels == null) ? 0 : buttonLabels.length;
			var buttonHeight:uint = Ruler.mmToPixels(Ruler.MIN_BUTTON_SIZE_MM, this._ppi) + 10;
			
			if (buttonCount == 1)
			{
				var button_1:Sprite = this.getButton(buttonLabels[0], bgWidth - (MARGIN * 2), buttonHeight);
				button_1.x = (bgWidth / 2) - (button_1.width / 2);
				button_1.y = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				this.addChild(button_1);
			}
			else if (buttonCount == 2)
			{
				var button_2:Sprite = this.getButton(buttonLabels[0], (bgWidth - (MARGIN * 3)) / 2, buttonHeight);
				var button_3:Sprite = this.getButton(buttonLabels[1], (bgWidth - (MARGIN * 3)) / 2, buttonHeight);
				button_2.x = MARGIN;
				button_2.y = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				button_3.x = button_2.x + button_2.width + MARGIN;
				button_3.y = button_2.y;
				this.addChild(button_2);
				this.addChild(button_3);
			}
			else if (buttonCount > 2)
			{
				var buttonY:uint = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				for (var i:uint = 0; i < buttonLabels.length; ++i)
				{
					var button:Sprite = this.getButton(buttonLabels[i], bgWidth - (MARGIN * 2), buttonHeight);
					button.x = (bgWidth / 2) - (button.width / 2);
					button.y = buttonY;
					this.addChild(button);
					buttonY += buttonHeight + MARGIN;
				}
			}
			
			if (buttonCount == 2) buttonCount = 1;
			var bgHeight:uint = (messageLabel.height + titleLabel.textHeight + (buttonCount * buttonHeight) + (MARGIN * (buttonCount + 2)));
			
			this.graphics.beginFill(BACKGROUND_COLOR, BACKGROUND_ALPHA);
			this.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			this.graphics.endFill();

			this.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			this.graphics.lineStyle(2, BORDER_COLOR, 1, true, "normal", CapsStyle.NONE);
			this.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			
			this.x = (this._stage.stageWidth / 2) - (this.width / 2);
			this.y = (this._stage.stageHeight / 2) - (this.height / 2);
			this._stage.addChild(this);
			
			if (buttonCount == 0) this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function getButton(buttonLabel:String, width:uint, height:uint):Sprite
		{
			var button:Sprite = new Sprite();
			button.graphics.beginFill(BACKGROUND_COLOR, BACKGROUND_ALPHA - .25);
			button.graphics.drawRoundRect(0, 0, width, height, CORNER, CORNER);
			button.graphics.endFill();
			button.graphics.lineStyle(2, BORDER_COLOR, 1, true, "normal", CapsStyle.NONE);
			button.graphics.drawRoundRect(0, 0, width, height, CORNER, CORNER);
			var label:Label = new Label(buttonLabel, "normal", FONT_COLOR);
			Layout.center(label, button);
			button.addChild(label);
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
			return button;
		}
		
		private function onClick(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.CLICK, onClick);
			this._stage.removeChild(this);
			this.dispatchEvent(new AlertEvent());
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			e.stopPropagation();
			var button:Sprite = e.target as Sprite;
			this._stage.removeChild(this);
			var label:Label = button.getChildAt(0) as Label;
			var ae:AlertEvent = new AlertEvent();
			ae.label = label.text;
			this.dispatchEvent(ae);
		}
	}
}