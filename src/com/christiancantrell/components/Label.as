package com.adobe.components
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class Label extends Sprite
	{
		private var textLine:TextLine;
		private var label:TextField;
		
		public function SimpleLabel(text:String, fontWeight:String = "normal", fontColor:int = 0xffffff, fontName:String = "_sans", fontSize:uint = 18)
		{
			super();
			
			var fontDesc:FontDescription = new FontDescription(fontName, fontWeight);
			var elementFormat:ElementFormat = new ElementFormat(fontDesc, fontSize, fontColor);
			var textElement:TextElement = new TextElement(text, elementFormat);
			var textBlock:TextBlock = new TextBlock(textElement);
			this.textLine = textBlock.createTextLine();
			this.textLine.x = 0;
			this.textLine.y = 0;
			this.addChild(this.textLine);
		}
		
		public function get textWidth():Number
		{
			return this.textLine.textWidth;
		}
		
		public function get textHeight():Number
		{
			return this.textLine.textHeight;
		}
	}
}