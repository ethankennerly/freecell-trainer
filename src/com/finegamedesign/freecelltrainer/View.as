package com.finegamedesign.freecelltrainer
{
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
            room.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
        }

        private function position(mc:MovieClip, i:int, columnCount:int, rowCount:int):void
        {
            mc.x = positionX(i, columnCount);
            mc.y = positionY(i, columnCount, rowCount);
        }

        private function positionX(i:int, columnCount:int):Number
        {
            var column:int = i % columnCount;
            return tileWidth * (0.5 + column - columnCount * 0.5);
        }

        private function positionY(i:int, columnCount:int, rowCount:int):Number
        {
            var row:int = i / columnCount;
            return tileWidth * (0.5 + row - rowCount * 0.5);
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
