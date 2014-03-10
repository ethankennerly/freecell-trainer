package com.finegamedesign.freecelltrainer
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.MovieClip;
    import flash.geom.Point;
    import flash.events.MouseEvent;

    import com.greensock.easing.Linear;
    import com.greensock.TweenLite;

    public class View
    {
        private static var cardPrefix:String = "card";
        internal var model:Model;
        internal var room:DisplayObjectContainer;
        private var cursor:Card;
        private var brooms:Array = [];
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
            ui.addEventListener(MouseEvent.MOUSE_UP, cancelDrag, false, 0, true);
            cursor = Card(room.getChildByName("cursor"));
            room.addEventListener(MouseEvent.MOUSE_MOVE, follow, false, 0, true);
            ui.addEventListener(MouseEvent.ROLL_OUT, cancelDrag, false, 0, true);
            update();
        }

        internal function clear():void
        {
            model.clear();
            for each(var broom:DisplayObject in brooms) {
                if (null != broom.parent) {
                    broom.parent.removeChild(broom);
                }
            }
            brooms = [];
        }

        /**
         * Show cards that may be selected.
         */
        internal function update():void
        {
            sweep();
            populateCards(model.foundations, room, "foundation");
            populateCards(model.cells, room, "cell");
            populateCards(model.columns, room, "column");
            ui.feedback.txt.text = model.help;
            cursor.visible = model.dragging && ! model.sweeping;
            if (model.dragging) {
                cursor.x = room.mouseX;
                cursor.y = room.mouseY;
            }
        }

        private function populateCards(foundations:Array,
                room:DisplayObjectContainer, prefix:String):void
        {
            for (var f:int = 0; f < foundations.length; f++) {
                var foundation:DisplayObjectContainer = room[prefix + "_" + f];
                for (var c:int = 0; c < foundations[f].length; c++) {
                    var card:Card = foundation[cardPrefix + "_" + c];
                    var value:int = Model.value(foundations[f][c]);
                    card.txt.text = Model.EMPTY == value ? "" : value.toString();
                    card.txt.mouseEnabled = false;
                    card.drag_btn.visible = model.canMove(prefix, f, c);
                    populateDragButton(card.drag_btn);
                    card.drop_btn.visible = Model.EMPTY == value;
                    populateDropButton(card.drop_btn);
                    var label:String = Model.EMPTY == value ? "enable" : "disable";
                    if (label != card.currentLabel) {
                        card.gotoAndStop(label);
                    }
                    var suitFrame:int = Model.suit(foundations[f][c]) + 1;
                    card.suit.gotoAndStop(suitFrame);
                    card.suit.scaleX = model.scale(value);
                    card.suit.visible = Model.EMPTY < value;
                }
                show(foundation, cardPrefix, c);
            }
            show(room, prefix, f);
        }

        private function populateDragButton(drag_btn:DisplayObject):void
        {
            if (!drag_btn.hasEventListener(MouseEvent.MOUSE_DOWN)) {
                drag_btn.addEventListener(MouseEvent.MOUSE_DOWN, drag, false, 0, true);
            }
        }

        private function populateDropButton(drop_btn:DisplayObject):void
        {
            if (!drop_btn.hasEventListener(MouseEvent.MOUSE_UP)) {
                drop_btn.addEventListener(MouseEvent.MOUSE_UP, drop, false, 0, true);
            }
        }

        private function doAt(f:Function, e:MouseEvent):Card
        {
            var selected:Card = Card(e.currentTarget.parent);
            var names:Array = selected.parent.name.split("_");
            f(names[0], parseInt(names[1]));
            return selected;
        }

        private function drag(e:MouseEvent):void
        {
            if (!model.dragging) {
                var selected:Card = doAt(model.drag, e);
                cursor.txt.text = selected.txt.text;
                cursor.suit.gotoAndStop(selected.suit.currentFrame);
                cursor.suit.scaleX = selected.suit.scaleX;
                cursor.gotoAndStop(selected.currentLabel);
                cursor.drag_btn.visible = true;
                cursor.drop_btn.visible = false;
                cursor.mouseChildren = false;
                cursor.mouseEnabled = false;
            }
        }

        private function drop(e:MouseEvent):void
        {
            if (model.dragging) {
                doAt(model.drop, e);
            }
        }

        private function cancelDrag(e:MouseEvent):void
        {
            model.cancelDrag();
        }

        private function follow(e:MouseEvent):void
        {
            if (model.dragging && !model.sweeping) {
                cursor.x = e.currentTarget.mouseX;
                cursor.y = e.currentTarget.mouseY;
                e.updateAfterEvent();
            }
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

        private function mouseUp(event:MouseEvent):void
        {
            model.dragging = false;
        }

        private function sweep():void
        {
            var nameFromTo:Object = model.sweep();
            if (null != nameFromTo) {
                var length:int = model.foundations[nameFromTo.to].length
                var foundation:DisplayObjectContainer = room["foundation" + "_" + nameFromTo.to];
                var card:Card = foundation[cardPrefix + "_" + length];
                var target:Point = card.localToGlobal(new Point());
                target = room.globalToLocal(target);
                var column:DisplayObjectContainer = room[nameFromTo.name + "_" + nameFromTo.from];
                var fromIndex:int = model[nameFromTo.name + "s"][nameFromTo.from].length;
                var fromCard:Card = column[cardPrefix + "_" + fromIndex];
                var from:Point = fromCard.localToGlobal(new Point());
                from = room.globalToLocal(from);
                var sweepCard:Card = new Card();
                sweepCard.txt.text = Model.value(model.selected).toString();
                sweepCard.suit.gotoAndStop(Model.suit(model.selected) + 1);
                sweepCard.suit.scaleX = model.scale(model.selected);
                sweepCard.gotoAndStop("disable");
                sweepCard.drag_btn.visible = false;
                sweepCard.drop_btn.visible = false;
                sweepCard.mouseChildren = false;
                sweepCard.mouseEnabled = false;
                var broom:Broom = new Broom();
                broom.addChild(sweepCard);
                broom.txt.text = "+" + model.points.toString();
                broom.mouseEnabled = false;
                brooms.push(broom);
                broom.x = from.x;
                broom.y = from.y;
                room.addChild(broom);
                TweenLite.to(broom, 0.5, {x: target.x, y: target.y, 
                    ease:Linear.easeNone, onComplete: model.sweepEnd});
            }
        }
    }
}
