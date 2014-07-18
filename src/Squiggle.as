package {
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import geom.*;
	public class Squiggle extends MovieClip{
		/**
		 * This class allows the user to scribble an annotation
		 * It was required to save these to the user's harddisk.
		 * This is achieved by waiting until the user finishes scribbling (mouseup)
		 * and then using Bezier compression to change the thousands of little line segments
		 * into a compressed form of piecewise Bezier curves that approximates the curve pretty well.
		 * 
		 * Decrease tolerance to make it better (but XML length will increase). 
		 */
		
		private var _points:Array = [];
		private var _xml:XML = <Data />;   // XML stores the compressed data
		private var _bg:Sprite = new Sprite();
		private var _lines:Sprite = new Sprite();
		/**
		 * Points contains an array of (potentially thousands of) points that make up the scribbles that the user draws.
		 */
		private var _tolerance:int=50;
		public static const BEZIER_SEPARATOR:String=";";
		
		public function Squiggle() {
			super();
			this.addChild(_bg);
			this.addChild(_lines);
			var g:Graphics = _bg.graphics;
			g.lineStyle(0, 0x000000, 0);
			g.beginFill(0x000000, 0.1);
			g.drawRect(0, 0, 800, 600);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
		}
		private function drawCurves():void {
			var g:Graphics=_lines.graphics;
			g.clear();
			var clr:uint = 0x0000FF;
			drawLayer(g,3,clr,1);
		}
		private function drawLayer(g:Graphics,thick:int,clr:uint,alpha:Number):void{
			g.lineStyle(thick,clr,alpha);
			var b:String = _xml.@Bezier;
			var p:Array = b.split(Squiggle.BEZIER_SEPARATOR);
			var prev:Point;
			var pa:Point;
			var pb:Point;
			var pc:Point;
			var pd:Point;
			var eightPoints:Array;
			var bez:BezierSegment;
			var MAX:int=p.length-1;
			for(var i:int=0;i<=MAX;i++){
				eightPoints=(p[i] as String).split(",");
				if(i==0){
					pa=new Point(eightPoints[0],eightPoints[1]);
					pb=new Point(eightPoints[2],eightPoints[3]);
					pc=new Point(eightPoints[4],eightPoints[5]);
					pd=new Point(eightPoints[6],eightPoints[7]);	
				}
				else{
					pa=new Point(prev.x,prev.y);
					pb=new Point(eightPoints[0],eightPoints[1]);
					pc=new Point(eightPoints[2],eightPoints[3]);
					pd=new Point(eightPoints[4],eightPoints[5]);
				}
				prev=pd.clone();
				bez=new BezierSegment(pa,pb,pc,pd);
				bez.draw(g, 10);
				
				
				
			}
		}
		private function addPoint():void{
			var g:Graphics=_lines.graphics;
			var p:Point=_points[_points.length-1] as Point;
			g.lineTo(p.x,p.y);
		}
		private function drawLines():void {
			// this is the uncompressed scribble made up of the points array
			var g:Graphics=_lines.graphics;
			g.clear();
			g.lineStyle(2,0xFF0000,1);
			var p:Point;
			var MAX:int=_points.length-1;
			for(var i:int=0;i<=MAX;i++){
				p=_points[i] as Point;
				if(i==0){
					g.moveTo(p.x,p.y);
				}	
				else{
					g.lineTo(p.x,p.y);
				}
			}
		}
		private function removeLines():void {
			
			var g:Graphics=_lines.graphics;
			g.clear();
			_points=[];
		}
		private function onMouseDown(e:MouseEvent):void {
			
			// when the user presses on the canvas start drawing.  
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			_points=[new Point(mouseX,mouseY)];
			drawLines();
		}
		private function onMouseMove(e:MouseEvent):void {
			_points.push(  new Point(mouseX,mouseY)  );
			var se:SquiggleEvent = new SquiggleEvent(SquiggleEvent.LIST_POINTS,true,true,_points);
			dispatchEvent(se);
			addPoint();
		}
		private function setXML(bezArray:Array):void{
			var allStrings:Array=[];
			var eightPoints:Array;
			var i:int;
			var MAX:int=bezArray.length-1;
			for(i=0;i<=MAX;i++){
				var bez:BezierSegment=bezArray[i] as BezierSegment;
				var pa:Point=bez.a;
				var pb:Point=bez.b;
				var pc:Point=bez.c;
				var pd:Point=bez.d;
				if(i==0){
					eightPoints=[int(pa.x),int(pa.y),int(pb.x),int(pb.y),int(pc.x),int(pc.y),int(pd.x),int(pd.y)];
				}
				else{
					eightPoints=[int(pb.x),int(pb.y),int(pc.x),int(pc.y),int(pd.x),int(pd.y)];
				}
				allStrings.push(eightPoints.join(","));
			}
			_xml.@Bezier=allStrings.join(Squiggle.BEZIER_SEPARATOR);
		}
		private function onMouseUp(e:MouseEvent):void {
			this.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		
			if(_points.length==1){
				var clone:Point=(_points[0] as Point).clone();
				clone.x+=2;
				_points.push(clone);
			}
			var bezArray:Array = compress();
			setXML(bezArray);
			var se:SquiggleEvent = new SquiggleEvent(SquiggleEvent.SHOW_XML,true,true,_xml.toXMLString());
			dispatchEvent(se);
			// the bezArray is an Array of BezierSegments
			removeLines();
			drawCurves();
	
			// remove the uncompressed scribbles and replace with the compressed ones!
		}
		private function compress():Array{
			var bezCompressor:Compressor=new Compressor(_points,_tolerance);
			return bezCompressor.compress();
		}
	}
}