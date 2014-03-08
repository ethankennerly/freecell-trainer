package com.finegamedesign.freecelltrainer
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;

    public class View
    {
        internal var model:Model;
        internal var room:DisplayObjectContainer;
        private var cursor:Card;
        private var selected:Card;
        private var ui:Main;

        public function View()
        {
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
            ui.addEventListener(MouseEvent.MOUSE_UP, drop, false, 0, true);
            cursor = Card(room.getChildByName("cursor"));
            room.addEventListener(MouseEvent.MOUSE_MOVE, follow, false, 0, true);
            ui.addEventListener(MouseEvent.ROLL_OUT, drop, false, 0, true);
            update();
        }

        private function populateCards(foundations:Array,
                room:DisplayObjectContainer, prefix:String):void
        {
            var cardPrefix:String = "card";
            for (var f:int = 0; f < foundations.length; f++) {
                var foundation:DisplayObjectContainer = room[prefix + "_" + f];
                for (var c:int = 0; c < foundations[f].length; c++) {
                    var card:Card = foundation[cardPrefix + "_" + c];
                    card.txt.text = Model.value(foundations[f][c]).toString();
                    card.btn.visible = c == foundations[f].length - 1 ? true : false;
                    populateCardButton(card.btn);
                    if ("disable" != card.currentLabel) {
                        card.gotoAndStop("disable");
                    }
                    var suitFrame:int = Model.suit(foundations[f][c]) + 1;
                    card.suit.gotoAndStop(suitFrame);
                }
                show(foundation, cardPrefix, c);
            }
            show(room, prefix, f);
        }

        private function populateCardButton(btn:DisplayObject):void
        {
            if (!btn.hasEventListener(MouseEvent.MOUSE_DOWN)) {
                btn.addEventListener(MouseEvent.MOUSE_DOWN, drag, false, 0, true);
            }
        }

        private function drag(e:MouseEvent):void
        {
            if (!model.dragging) {
                model.dragging = true;
                selected = Card(e.currentTarget.parent);
                selected.visible = false;
                cursor.txt.text = selected.txt.text;
                cursor.suit.gotoAndStop(selected.suit.currentFrame);
                cursor.gotoAndStop(selected.currentLabel);
                cursor.btn.visible = false;
            }
        }

        private function drop(e:MouseEvent):void
        {
            model.dragging = false;
            if (null != selected) {
                selected.visible = true;
                selected = null;
            }
        }

        private function follow(e:MouseEvent):void
        {
            if (model.dragging) {
                cursor.x = e.currentTarget.mouseX;
                cursor.y = e.currentTarget.mouseY;
            }
            e.updateAfterEvent();
        }


        private function show(room:DisplayObjectContainer, prefix:String, index:int):void
        {
            for (var c:int = 0; c < room.numChildren; c++) {
                var child:DisplayObject = room.getChildAt(c);
                if (0 == child.name.indexOf(prefix)) {
                    var n:int = parseInt(child.name.split("_")[1]);
                    child.visible = n < index && selected != child;
                }
            }
        }

        private function mouseUp(event:MouseEvent):void
        {
            model.dragging = false;
        }

        /**
         * Show cards that may be selected.
         */
        internal function update():void
        {
            populateCards(model.foundations, room, "foundation");
            populateCards(model.cells, room, "cell");
            populateCards(model.columns, room, "column");
            ui.feedback.txt.text = model.help;
            cursor.visible = model.dragging;
            if (model.dragging) {
                cursor.x = room.mouseX;
                cursor.y = room.mouseY;
            }
        }

        internal function clear():void
        {
        }
    }
}
