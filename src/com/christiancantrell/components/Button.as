package com.adobe.components
{
	import flash.display.GradientType;
	import flash.display.Sprite;
	
	public class Button extends Sprite
	{
		public function SimpleButton(label:String, forcedWidth:int = -1, forcedHeight:int = -1)
		{
			super();
						
			var buttonLabel:Label = new Label(label);
			
			var buttonWidth:uint = (forcedWidth == -1) ? buttonLabel.textWidth + 6 : forcedWidth;
			var buttonHeight:uint = (forcedHeight == -1) ? buttonLabel.textHeight + 6 : forcedHeight;
			
			this.graphics.beginGradientFill(GradientType.LINEAR, [0x333333, 0x030608], [1,1], [0,255]);
			graphics.drawRoundRect(0, 0, buttonWidth, buttonHeight, 5, 5);
			graphics.endFill();
			
			buttonLabel.x = (buttonWidth / 2) - (buttonLabel.textWidth / 2);
			buttonLabel.y = ((buttonHeight / 2) + (buttonLabel.textHeight / 2)) - 3;
			this.addChild(buttonLabel);
		}
	}
}