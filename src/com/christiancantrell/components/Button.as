package com.christiancantrell.components
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	
	public class Button extends Sprite
	{
		private const ENABLED_COLOR:uint = 0xffffff;
		private const DISABLED_COLOR:uint = 0x303030;
		private const GRADIENT_COLORS:Array = [0x333333, 0x030608];

		private var _enabled:Boolean;
		private var labelText:String;
		private var buttonLabel:Label;
		
		public function Button(labelText:String, forcedWidth:int = -1, forcedHeight:int = -1)
		{
			super();
			
			this._enabled = true;
			this.labelText = labelText;

			this.drawLabel(ENABLED_COLOR);
			
			var buttonWidth:uint = (forcedWidth == -1) ? this.buttonLabel.textWidth + 6 : forcedWidth;
			var buttonHeight:uint = (forcedHeight == -1) ? this.buttonLabel.textHeight + 6 : forcedHeight;
			
			this.graphics.beginGradientFill(GradientType.LINEAR, GRADIENT_COLORS, [1,1], [0,255]);
			graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 5, 5);
			graphics.endFill();
			
			var bevel:BevelFilter = new BevelFilter(2);
			this.filters = [bevel];

			this.placeLabel();
			
			this.mouseChildren = false;
			
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function drawLabel(color:uint):void
		{
			if (this.buttonLabel != null) this.removeChild(this.buttonLabel);
			this.buttonLabel = new Label(labelText, "normal", color);
		}
		
		private function placeLabel():void
		{
			this.buttonLabel.x = (this.width / 2) - (buttonLabel.textWidth / 2);
			this.buttonLabel.y = (this.height / 2) + (buttonLabel.textHeight / 2);
			this.addChild(buttonLabel);
		}
		
		public function set enabled(enabled:Boolean):void
		{
			if (enabled != this._enabled)
			{
				this.drawLabel((enabled) ? ENABLED_COLOR : DISABLED_COLOR);
				this.placeLabel();
				this._enabled = enabled;
			}
		}
		
		private function onClick(e:MouseEvent):void
		{
			if (!this._enabled) e.stopImmediatePropagation();
		}
		
		public function get label():String
		{
			return this.labelText;
		}
	}
}