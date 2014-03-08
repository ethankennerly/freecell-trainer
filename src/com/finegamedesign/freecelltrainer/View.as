package com.finegamedesign.freecelltrainer
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class View
    {
        internal var model:Model;
        internal var originalRoomHeight:int = -1;
        internal var originalRoomWidth:int = -1;
        internal var originalTileWidth:int = 80;
        internal var room:DisplayObjectContainer;
        internal var scale:Number;
        internal var tileWidth:int;
        internal var table:Array;
        private var isMouseDown:Boolean;
        private var mouseJustPressed:Boolean;
        private var ui:Main;

        public function View()
        {
            table = [];
        }

        /**
         * Position each object in the model's grid into the center-aligned room and scale to fit in room.
         * Adds property "model" to each cell in table.
         */
        internal function populate(model:Model, room:DisplayObjectContainer, ui:Main):void
        {
            this.model = model;
            this.room = room;
            this.ui = ui;
            populateCards(model.foundations, room, "foundation");
            populateCards(model.cells, room, "cell");
            populateCards(model.columns, room, "column");
            ui.feedback.txt.text = model.help;
            room.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
        }

        private function populateCards(foundations:Array,
                room:DisplayObjectContainer, prefix:String):void
        {
            var cardPrefix:String = "card";
            for (var f:int = 0; f < foundations.length; f++) {
                var foundation:DisplayObjectContainer = room[prefix + "_" + f];
                for (var c:int = 0; c < foundations[f].length; c++) {
                    var card:Card = foundation[cardPrefix + "_" + c];
                    card.txt.text = foundations[f][c].toString();
                    card.gotoAndStop("enable");
                }
                show(foundation, cardPrefix, c);
            }
            show(room, prefix, f);
        }

        private function show(room:DisplayObjectContainer, prefix:String, index:int):void
        {
            for (var c:int = 0; c < room.numChildren; c++) {
                var child:DisplayObject = room.getChildAt(c);
                if (0 == child.name.indexOf(prefix)) {
                    var n:int = parseInt(child.name.split("_")[1]);
                    child.visible = n < index;
                }
            }
        }

        private function mouseDown(event:MouseEvent):void
        {
            mouseJustPressed = !isMouseDown;
            isMouseDown = true;
        }

        private function mouseUp(event:MouseEvent):void
        {
            mouseJustPressed = false;
            isMouseDown = false;
        }

        private function selectDown(e:MouseEvent):void
        {
            mouseDown(e);
            select(e);
        }

        private function select(e:MouseEvent):void
        {
            if (!isMouseDown) {
                return;
            }
            var mc:MovieClip = MovieClip(e.currentTarget);
            var index:int = parseInt(mc.name.split("_")[1]);
            // trace("View.select: index " + index);
            update();
        }

        internal function update():void
        {
        }

        internal function clear():void
        {
        }
    }
}
