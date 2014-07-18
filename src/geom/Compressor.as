package geom{
	import flash.geom.Point;
	public class Compressor{
		private var a:Array;
		private var _tolerance:int;
		private var _segments:Array;
		private var bez:Array;
		public function Compressor(a:Array,tolerance:int):void{
			this.a=a;
			bez=[];
			_tolerance=tolerance;
			_segments=[  [0,a.length-1]   ];
		}
		public function compress():Array{
			// returns an array of bezier segments given an array of points.
			// for the theory, see here:  /docs/cubicbezierleastsquarefit.pdf
			// source is : http://www.mathworks.co.jp/matlabcentral/fileexchange/15542-cubic-bezier-least-square-fitting
			
			var hadToSplit:Boolean=true;
			while(hadToSplit){
				hadToSplit=checkSplit();
			}
			return bez;
		}
		private function checkSplit():Boolean{
			var splitAtArray:Array=[];
			var hadToSplit:Boolean=false;
			var MAX:int=_segments.length-1;
			for(var i:int=0;i<=MAX;i++){
				var splitAt:int=-1;
				var e0:int=_segments[i][0];
				var e1:int=_segments[i][1];
				if(e1 - e0 >= 4){
					var c1:Point=getC1(e0,e1);
					var c2:Point=getC2(e0,e1);
					var a1:Number=geta1(e0,e1);
					var a2:Number=geta2(e0,e1);
					var a12:Number=geta12(e0,e1);
					var P1:Point=getP1(a1,a2,a12,c1,c2);
					var P2:Point=getP2(a1,a2,a12,c1,c2);
					var b:BezierSegment=new BezierSegment(new Point(a[e0].x,a[e0].y),P1,P2,new Point(a[e1].x,a[e1].y));
					bez[i]=b;
					splitAt = getSplitAt(e0,e1,b);
					if(splitAt!=-1){
						hadToSplit=true;
					}
				}
				else if(e1-e0 == 3){
					bez[i]=BezierSegment.getFourPoints(a[e0],a[e0+1],a[e0+2],a[e1]);
				}
				else if(e1-e0 == 2){
					bez[i]=BezierSegment.getThreePoints(a[e0],a[e0+1],a[e1]);
				}
				else if(e1-e0==1){
					bez[i]=BezierSegment.getTwoPoints(a[e0],a[e1]);	
				}
				splitAtArray[i]=splitAt;
			}
			if(hadToSplit){
				var newSegments:Array=[];
				MAX=_segments.length-1;
				for(i=0;i<=MAX;i++){
					if(splitAtArray[i]==-1){
						newSegments.push(_segments[i]);
					}
					else{
						newSegments.push(  [_segments[i][0], splitAtArray[i]  ]);
						newSegments.push(  [ splitAtArray[i] ,  _segments[i][1] ]);
					}
				}
				_segments=newSegments;
			}
			return hadToSplit;
		}
		private function getSplitAt(e0:int,e1:int,b:BezierSegment):int{
			var maxdsqr:Number=-1;
			var splitAt:int=-1;
			for(var q:int=e0;q<=e1;q++){
				var t:Number=(q-e0)/(e1-e0);
				var bPoint:Point=b.getValue(t);
				var pPoint:Point=new Point(a[q].x,a[q].y);
				var dsqr:Number=(bPoint.x-pPoint.x)*(bPoint.x-pPoint.x)+(bPoint.y-pPoint.y)*(bPoint.y-pPoint.y);
				if(dsqr>maxdsqr && dsqr>_tolerance*_tolerance){
					maxdsqr=dsqr;
					splitAt=q;
				}
			}
			return splitAt;
		}
		private function getP1(a1:Number,a2:Number,a12:Number,c1:Point,c2:Point):Point{
			var denom:Number=a1*a2-a12*a12;
			var x:Number=a2*c1.x-a12*c2.x;
			var y:Number=a2*c1.y-a12*c2.y;
			return new Point(x/denom,y/denom);
		}
		private function getP2(a1:Number,a2:Number,a12:Number,c1:Point,c2:Point):Point{
			var denom:Number=a1*a2-a12*a12;
			var x:Number=a1*c1.x-a12*c2.x;
			var y:Number=a1*c1.y-a12*c2.y;
			return new Point(x/denom,y/denom);
		}
		private function getC1(p0:int,p1:int):Point{
			var c1x:Number=0;
			var c1y:Number=0;
			for(var i:int=p0;i<=p1;i++){
				var t:Number=(i-p0)/(p1-p0);
				var oneMinus:Number=1-t;
				c1x+=3*t*oneMinus*oneMinus *  (a[i].x  -  oneMinus*oneMinus*oneMinus*a[p0].x  - t*t*t*a[p1].x   );
				c1y+=3*t*oneMinus*oneMinus *  (a[i].y  -  oneMinus*oneMinus*oneMinus*a[p0].y  - t*t*t*a[p1].y   );
			}
			return new Point(c1x,c1y);
			}
		private function getC2(p0:int,p1:int):Point{
			var c1x:Number=0;
			var c1y:Number=0;
			for(var i:int=p0;i<=p1;i++){
				var t:Number=(i-p0)/(p1-p0);
				var oneMinus:Number=1-t;
				c1x+=3*t*t*oneMinus *  (a[i].x  -  oneMinus*oneMinus*oneMinus*a[p0].x  - t*t*t*a[p1].x  );
				c1y+=3*t*t*oneMinus *  (a[i].y  -  oneMinus*oneMinus*oneMinus*a[p0].y  - t*t*t*a[p1].y  );
			}
			return new Point(c1x,c1y);
		}
		private function geta1(p0:int,p1:int):Number{
			var i:int
			var a1:Number=0;
			for(i=p0;i<=p1;i++){
				var t:Number=(i-p0)/(p1-p0);
				var oneMinus:Number=1-t;
				a1+=t*t*oneMinus*oneMinus*oneMinus*oneMinus;	
			}
			a1*=9;
			return a1;
		}
		private function geta2(p0:int,p1:int):Number{
			var i:int
			var a2:Number=0;
			for(i=p0;i<=p1;i++){
				var t:Number=(i-p0)/(p1-p0);
				var oneMinus:Number=1-t;
				a2+=t*t*t*t*oneMinus*oneMinus;
			}
			a2*=9;
			return a2;
		}
		private function geta12(p0:int,p1:int):Number{
			var i:int;
			var a12:Number=0;
			for(i=p0;i<=p1;i++){
				var t:Number=(i-p0)/(p1-p0);
				var oneMinus:Number=1-t;
				a12+=t*t*t*oneMinus*oneMinus*oneMinus;
			}
			a12*=9;
			return a12;
		}
	}
}

