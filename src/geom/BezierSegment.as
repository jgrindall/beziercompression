package geom {
	import flash.display.Graphics;
	import flash.geom.Point;
	public class BezierSegment{
    	public var a:Point;
	    public var b:Point;
	    public var c:Point;
	    public var d:Point;
		function BezierSegment(a:Point, b:Point, c:Point, d:Point) {
			// a bezier segment is made up of two anchor points and two control points.
			this.a = a;
			this.b = b;
			this.c = c;
			this.d = d;
		}
		public function getValue(t:Number):Point {
			
			// standard bezier stuff, see for example http://en.wikipedia.org/wiki/B%C3%A9zier_curve
			
			
			var ax:Number = this.a.x;
			var bx:Number = this.b.x;
			var cx:Number = this.c.x;
			var dx:Number = this.d.x;
			
			var ay:Number = this.a.y;
			var by:Number = this.b.y;
			var cy:Number = this.c.y;
			var dy:Number = this.d.y;
			
			
			
			
			var x:Number = (t*t*(dx-ax) + 3*(1-t)*(t*(cx-ax) + (1-t)*(bx-ax)))*t + ax;
			var y:Number = (t * t * (dy - ay) + 3 * (1 - t) * (t * (cy - ay) + (1 - t) * (by - ay))) * t + ay;
			
			return new Point(x, y);	
		}	
		public function draw(g:Graphics, num:int):void {
			
			// render it using 'g', in 'num' steps.
			
			for(var i:int=0;i<=num;i++){
				var t:Number=i/num;
				var p:Point=getValue(t);
				if(i==0){
					g.moveTo(p.x,p.y);
				}
				else{
					g.lineTo(p.x,p.y);
				}
			}
		}
		public static function getThreePoints(p0:Point, p1:Point, p2:Point):BezierSegment {
			
			// convert a segment going through 3 points into a Bezier Segment with 2 anchor and 2 control points.
			
			var a:Point=p0.clone();
			var d:Point=p2.clone();
			var aplusd:Point=new Point(a.x+d.x,a.y+d.y);
			var b:Point=new Point((4/3)*(p1.x-aplusd.x/8), (4/3)*(p1.y-aplusd.y/8) );
			var c:Point=b.clone();
			return new BezierSegment(a,b,c,d);
		}
		public static function getFourPoints(p0:Point, p1:Point, p2:Point, p3:Point):BezierSegment {
			
			// convert a segment going through 4 points into a Bezier Segment with 2 anchor and 2 control points.
			
			var dminusa:Point;
			var bminusa:Point;
			var cminusa:Point;
			var a:Point=p0.clone();
			var d:Point=p3.clone();
			dminusa=new Point(d.x-a.x,d.y-a.y);
			var _23bminusa:Point=new Point(2*p1.x-p2.x+(2/9)*dminusa.x-a.x,  2*p1.y-p2.y+(2/9)*dminusa.y-a.y);
			bminusa=new Point(  1.5*_23bminusa.x,1.5*_23bminusa.y);
			var b:Point=new Point(bminusa.x+a.x,bminusa.y+a.y);
			var _29cminusa:Point=new Point(p1.x-(4/9)*bminusa.x-(1/27)*dminusa.x-a.x,p1.y-(4/9)*bminusa.y-(1/27)*dminusa.y-a.y);
			cminusa=new Point(4.5*_29cminusa.x,4.5*_29cminusa.y);
			var c:Point=new Point(cminusa.x+a.x,cminusa.y+a.y);
			return new BezierSegment(a,b,c,d);
		}
		public static function getTwoPoints(p0:Point, p1:Point):BezierSegment {
			
			// convert a segment going through 2 points into a Bezier Segment with 2 anchor and 2 control points.
			
			return new BezierSegment(p0.clone(),new Point(p0.x+(p1.x-p0.x)/3,p0.y+(p1.y-p0.y)/3 ),new Point(p0.x+2*(p1.x-p0.x)/3,p0.y+2*(p1.y-p0.y)/3 ),p1.clone());
		}
	}
}
