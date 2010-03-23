package com.christiancantrell.components
{
	import flash.display.Sprite;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class MultilineLabel extends Sprite
	{
		//private var textField:TextField;
		public static const LEADING:Number = 1.25;
		public var textHeight:uint;
		
		public function MultilineLabel(text:String,
									   width:uint,
									   height:int = -1,
									   fontWeight:String = "normal",
									   fontColor:int = 0xffffff,
									   fontName:String = "_sans",
									   fontSize:uint = 18)
		{
			super();
			var fontDesc:FontDescription = new FontDescription(fontName, fontWeight);
			var elementFormat:ElementFormat = new ElementFormat(fontDesc, fontSize, fontColor);
			var textElement:TextElement = new TextElement(text, elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);
			var textLine:TextLine;
			var leading:Number = 1.25;
			var yPos:Number = 0;
			var totalHeight:uint = 0;
			
			while (textLine = textBlock.createTextLine(textLine, width, 0, true)) 
			{
				this.textHeight += textLine.textHeight;
				textLine.x = 0; 
				textLine.y = yPos;
				yPos += LEADING * textLine.height; 
				this.addChild(textLine); 
				totalHeight += yPos;
			}
			
			// Text is getting cut off by a fraction of a pixel. Round up seems to fix it. 
			//this.height = (height != -1) ? Math.ceil(height) : totalHeight; 
		}
	}
}