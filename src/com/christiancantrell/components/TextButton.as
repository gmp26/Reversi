package com.christiancantrell.components
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BevelFilter;
	
	public class TextButton extends Sprite
	{
		private const ENABLED_COLOR:uint = 0x333333;
		private const DISABLED_COLOR:uint = 0x707070;
		
		private var _enabled:Boolean;
		private var labelText:String;
		private var buttonLabel:Label;
		
		public function TextButton(labelText:String, background:Boolean = false, forcedWidth:int = -1, forcedHeight:int = -1)
		{
			super();
			
			this._enabled = true;
			this.labelText = labelText;
			
			this.drawLabel(ENABLED_COLOR);
			
			var buttonWidth:uint = (forcedWidth == -1) ? this.buttonLabel.textWidth + 6 : forcedWidth;
			var buttonHeight:uint = (forcedHeight == -1) ? this.buttonLabel.textHeight + 6 : forcedHeight;
			
			this.graphics.beginFill(0xcccccc, (background) ? .15 : 0);
			graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 5, 5);
			graphics.endFill();
			
			this.placeLabel();
			
			this.mouseChildren = false;
			
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function drawLabel(color:uint):void
		{
			if (this.buttonLabel != null) this.removeChild(this.buttonLabel);
			this.buttonLabel = new Label(labelText, "bold", color, "_sans", 32);
		}
		
		private function placeLabel():void
		{
			this.buttonLabel.x = (this.width / 2) - (buttonLabel.textWidth / 2);
			this.buttonLabel.y = ((this.height / 2) + (buttonLabel.textHeight / 2)) + 2;
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