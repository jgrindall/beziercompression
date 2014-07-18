package geom{
	import flash.events.Event;
	public class SquiggleEvent extends Event{
		public static const LIST_POINTS:String="SquiggleEvent: LIST_POINTS";
		public static const SHOW_XML:String="SquiggleEvent: SHOW_XML";
		public var _data:Object;
		public function SquiggleEvent(type:String,bubbles:Boolean=false,cancelable:Boolean=true,d:Object=null){
			super(type,bubbles,cancelable);
			_data=d;
			
		}
	}
}
