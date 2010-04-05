//  Adobe(R) Systems Incorporated Source Code License Agreement
//  Copyright(c) 2006-2010 Adobe Systems Incorporated. All rights reserved.
//	
//  Please read this Source Code License Agreement carefully before using
//  the source code.
//	
//  Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
//  no-charge, royalty-free, irrevocable copyright license, to reproduce,
//  prepare derivative works of, publicly display, publicly perform, and
//  distribute this source code and such derivative works in source or 
//  object code form without any attribution requirements.    
//	
//  The name "Adobe Systems Incorporated" must not be used to endorse or promote products
//  derived from the source code without prior written permission.
//	
//  You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
//  against any loss, damage, claims or lawsuits, including attorney's 
//  fees that arise or result from your use or distribution of the source 
//  code.
//  
//  THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
//  ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
//  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
//  NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL ADOBE 
//  OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
//  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
//  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

package com.christiancantrell.components
{
	import com.christiancantrell.utils.Layout;
	import com.christiancantrell.utils.Ruler;
	
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	
	[Event(name=AlertEvent.ALERT_CLICKED, type="com.christiancantrell.components.AlertEvent")]
	public class Alert extends Sprite
	{
		private const BACKGROUND_COLOR:uint        = 0x0198e1;
		private const BACKGROUND_ALPHA:Number      = .85;
		private const BORDER_COLOR:uint            = 0xffffff;
		private const BUTTON_BORDER_COLOR:uint     = 0xffffff;
		private const BUTTON_BACKGROUND_COLOR:uint = 0x0198e1;
		private const MODAL_COLOR:uint             = 0x000000;
		private const FONT_COLOR:uint              = 0xffffff;
		private const CORNER:uint                  = 0;
		private const MARGIN:uint                  = 15;
		
		private var _stage:Stage;
		private var _ppi:uint;
		private var _title:String;
		private var _message:String;
		private var _buttonLabels:Array;

		public function Alert(stage:Stage, ppi:uint)
		{
			this._stage = stage;
			this._ppi = ppi;
		}
		
		public function show(title:String, message:String, buttonLabels:Array = null):void
		{
			this._title = title;
			this._message = message;
			this._buttonLabels = buttonLabels;
			this._stage.addEventListener(Event.RESIZE, doLayout);
			this.doLayout();
		}
			
		public function doLayout(e:Event = null):void
		{
			while (this.numChildren > 0) this.removeChildAt(0);
			this.graphics.clear();
			if (this._stage.contains(this)) this._stage.removeChild(this);

			var bgWidth:uint = (this._stage.stageHeight > this._stage.stageWidth) ? (this._stage.stageWidth * .75) : (this._stage.stageHeight * .8);
			
			var box:Sprite = new Sprite();
			
			var titleLabel:Label = new Label(this._title, "bold", FONT_COLOR);
			titleLabel.x = (bgWidth / 2) - (titleLabel.width / 2);
			titleLabel.y = 15 + MARGIN;
			box.addChild(titleLabel);

			var messageLabel:MultilineLabel = new MultilineLabel(_message, bgWidth - (MARGIN * 2), -1, "normal", FONT_COLOR);
			messageLabel.x = MARGIN;
			messageLabel.y = titleLabel.y + (MARGIN * 1.5);
			box.addChild(messageLabel);
						
			var buttonCount:uint = (this._buttonLabels == null) ? 0 : this._buttonLabels.length;
			var buttonHeight:uint = Ruler.mmToPixels(Ruler.MIN_BUTTON_SIZE_MM, this._ppi) + 10;
			
			if (buttonCount == 1)
			{
				var button_1:Sprite = this.getButton(this._buttonLabels[0], bgWidth - (MARGIN * 2), buttonHeight);
				button_1.x = (bgWidth / 2) - (button_1.width / 2);
				button_1.y = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				box.addChild(button_1);
			}
			else if (buttonCount == 2)
			{
				var button_2:Sprite = this.getButton(this._buttonLabels[0], (bgWidth - (MARGIN * 3)) / 2, buttonHeight);
				var button_3:Sprite = this.getButton(this._buttonLabels[1], (bgWidth - (MARGIN * 3)) / 2, buttonHeight);
				button_2.x = MARGIN;
				button_2.y = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				button_3.x = button_2.x + button_2.width + MARGIN;
				button_3.y = button_2.y;
				box.addChild(button_2);
				box.addChild(button_3);
			}
			else if (buttonCount > 2)
			{
				var buttonY:uint = (messageLabel.y + messageLabel.textHeight) + MARGIN;
				for (var i:uint = 0; i < this._buttonLabels.length; ++i)
				{
					var button:Sprite = this.getButton(this._buttonLabels[i], bgWidth - (MARGIN * 2), buttonHeight);
					button.x = (bgWidth / 2) - (button.width / 2);
					button.y = buttonY;
					box.addChild(button);
					buttonY += buttonHeight + MARGIN;
				}
			}
			
			if (buttonCount == 2) buttonCount = 1;
			var bgHeight:uint = (messageLabel.height + titleLabel.textHeight + (buttonCount * buttonHeight) + (MARGIN * (buttonCount + 2))) + 15;
			
			box.graphics.beginFill(BACKGROUND_COLOR, BACKGROUND_ALPHA);
			box.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			box.graphics.endFill();

			box.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			box.graphics.lineStyle(2, BORDER_COLOR, 1, true, "normal", CapsStyle.NONE);
			box.graphics.drawRoundRect(0, 0, bgWidth, bgHeight, CORNER, CORNER);
			
			box.x = (this._stage.stageWidth / 2) - (box.width / 2);
			box.y = (this._stage.stageHeight / 2) - (box.height / 2);
			
			// Modal
			this.x = 0;
			this.y = 0;
			this.graphics.beginFill(MODAL_COLOR, .5);
			this.graphics.drawRect(0, 0, _stage.stageWidth, _stage.stageHeight);
			this.graphics.endFill();
			
			this.addChild(box);
				
			this._stage.addChild(this);
			
			if (buttonCount == 0) this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function getButton(buttonLabel:String, width:uint, height:uint):Sprite
		{
			var button:Sprite = new Sprite();
			button.graphics.beginFill(BUTTON_BACKGROUND_COLOR, BACKGROUND_ALPHA - .25);
			button.graphics.drawRoundRect(0, 0, width, height, CORNER, CORNER);
			button.graphics.endFill();
			button.graphics.lineStyle(2, BUTTON_BORDER_COLOR, 1, true, "normal", CapsStyle.NONE);
			button.graphics.drawRoundRect(0, 0, width, height, CORNER, CORNER);
			var label:Label = new Label(buttonLabel, "normal", FONT_COLOR);
			Layout.center(label, button);
			button.addChild(label);
			button.addEventListener(MouseEvent.CLICK, onButtonClick);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onButtonMouseDown);
			button.addEventListener(MouseEvent.MOUSE_OUT, onButtonMouseOut);
			button.mouseChildren = false;
			return button;
		}
		
		private function onClick(e:MouseEvent):void
		{
			this.removeEventListener(MouseEvent.CLICK, onClick);
			this._stage.removeChild(this);
			this._stage.removeEventListener(Event.RESIZE, doLayout);
			this.dispatchEvent(new AlertEvent());
		}
		
		private function onButtonClick(e:MouseEvent):void
		{
			e.stopPropagation();
			this._stage.removeChild(this);
			this._stage.removeEventListener(Event.RESIZE, doLayout);
			var button:Sprite = e.target as Sprite;
			var label:Label = button.getChildAt(0) as Label;
			var ae:AlertEvent = new AlertEvent();
			ae.label = label.text;
			this.dispatchEvent(ae);
		}

		private function onButtonMouseDown(e:MouseEvent):void
		{
			e.stopPropagation();
			var button:Sprite = e.target as Sprite;
			var overlay:Sprite = new Sprite();
			overlay.x = 0;
			overlay.y = 0;
			overlay.graphics.beginFill(0xffffff, .75);
			overlay.graphics.drawRect(0, 0, button.width, button.height);
			overlay.graphics.endFill();
			button.addChild(overlay);
			button.graphics.beginFill(BUTTON_BORDER_COLOR);
		}

		private function onButtonMouseOut(e:MouseEvent):void
		{
			e.stopPropagation();
			var button:Sprite = e.target as Sprite;
			if (button.numChildren == 2)
			{
				button.removeChildAt(1);
			}
		}
	}
}