package com.christiancantrell.components
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class Label extends Sprite
	{
		private var textLine:TextLine;
		private var textElement:TextElement;
		private var textBlock:TextBlock;
		
		public function Label(text:String, fontWeight:String = "normal", fontColor:int = 0xffffff, fontName:String = "_sans", fontSize:uint = 18)
		{
			super();
			var fontDesc:FontDescription = new FontDescription(fontName, fontWeight);
			var elementFormat:ElementFormat = new ElementFormat(fontDesc, fontSize, fontColor);
			this.textElement = new TextElement(text, elementFormat);
			this.textBlock = new TextBlock(textElement);
			this.textBlock.baselineZero = TextBaseline.DESCENT;
			this.drawText();
		}
		
		public function get textWidth():Number
		{
			return this.textLine.width;
		}
		
		public function get textHeight():Number
		{
			return this.textLine.textHeight;
		}
		
		private function drawText():void
		{
			if (this.textLine != null && this.contains(this.textLine))
			{
				this.removeChild(this.textLine);
			}
			this.textLine = textBlock.createTextLine();
			this.textLine.x = 0;
			this.textLine.y = 0;
			this.addChild(this.textLine);
		}
		
		public function update(newText:String):void
		{
			this.textElement.text = newText;
			this.drawText();
		}

		public function get text():String
		{
			return this.textElement.text;
		}
	}
}