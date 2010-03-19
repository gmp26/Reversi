package com.christiancantrell.components
{
	import flash.display.Sprite;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class DynamicLabel extends Sprite
	{
		public var textField:TextField;
		
		public function DynamicLabel(initialText:String,
									 fontWeight:String = "normal",
									 color:int = 0xffffff,
									 font:String = "_sans",
									 size:uint = 18)
		{
			super();
			
			var textFormat:TextFormat = new TextFormat();
			textFormat.color = color;
			textFormat.font = font;
			textFormat.size = size;
			textFormat.bold = (fontWeight == "normal") ? false : true;
			
			this.textField = new TextField();
			this.textField.defaultTextFormat = textFormat;
			this.textField.selectable = false;
			this.textField.antiAliasType = AntiAliasType.ADVANCED;
			this.textField.text = initialText;
			this.addChild(this.textField);
		}
		
		public function get value():String
		{
			return this.textField.text;
		}
		
		public function update(newText:String):void
		{
			this.textField.text = newText;
		}
	}
}