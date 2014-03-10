package com.finegamedesign.freecelltrainer
{
    import flash.utils.ByteArray; 
        
    public class Model
    {
        internal static const EMPTY:int = 0;
        internal static const RADIX:int = 100;
        internal static const COLORS:int = 2;
        internal static var levels:Array = [
            {foundations: [[]], 
             cells: [[]], 
             columns: [[1, 2]], 
             help: "To build a cake, you may drag a bottom layer to any empty pan."},
            {foundations: [[], []], 
             cells: [[102]], 
             columns: [[3, 103], [1, 101, 2]], 
             help: "To build two cakes, you may drag a bottom layer to below the next higher layer of the opposite flavor."},
            {suitCount: 2, valueCount: 5, cellCount: 3, columnCount: 2,
             help: "Think ahead to build both cakes.  You may drag a bottom layer to an empty pan or to below next higher layer of the opposite flavor."},
            {suitCount: 2, valueCount: 6, cellCount: 3, columnCount: 3,
             help: "Think ahead to build both cakes.  You may drag a bottom layer to an empty pan or to below next higher layer of the opposite flavor."},
            {suitCount: 2, valueCount: 7, cellCount: 3, columnCount: 3,
             help: "Think ahead to build both cakes.  Plan to uncover layer 1."},
            {suitCount: 2, valueCount: 8, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to uncover layer 1."},
            {suitCount: 2, valueCount: 9, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to uncover layer 1."},
            {suitCount: 2, valueCount: 10, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to use all columns."},
            {suitCount: 2, valueCount: 11, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to use all columns."},
            {suitCount: 2, valueCount: 12, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to use all columns."},
            {suitCount: 2, valueCount: 13, cellCount: 4, columnCount: 4,
             help: "Think ahead to build both cakes.  Plan to use all columns."}
        ];

        internal static function suit(card:int):int
        {
            return card / RADIX;
        }

        internal static function color(card:int):int
        {
            return suit(card) % COLORS;
        }

        internal static function value(card:int):int
        {
            return card % RADIX;
        }

        private static function equal(card:int, next:int):Boolean
        {
            return value(card) == value(next) && suit(card) == suit(next);
        }

        // http://help.adobe.com/en_US/ActionScript/3.0_ProgrammingAS3/WS5b3ccc516d4fbf351e63e3d118a9b90204-7ee7.html
        private static function clone(source:Object):* 
        { 
            var myBA:ByteArray = new ByteArray(); 
            myBA.writeObject(source); 
            myBA.position = 0; 
            return(myBA.readObject()); 
        }

        private static function shuffle(array:Array):void
        {
            for (var i:int = array.length - 1; 1 <= i; i--) {
                var j:int = (i + 1) * Math.random();
                var tmp:* = array[i];
                array[i] = array[j];
                array[j] = tmp;
            }
        }

        internal var dragging:Boolean = false;
        internal var cells:Array = [];
        internal var foundations:Array = [[]];
        internal var highScore:int = 0;
        internal var help:String = "";
        internal var level:int = 1;
        internal var levelMax:int = levels.length;
        internal var columns:Array = [[]];
        internal var onContagion:Function;
        internal var onDeselect:Function;
        internal var onDie:Function;
        internal var onDieBonus:Function;
        internal var points:int = 0;
        internal var restartScore:int = 0;
        internal var round:int = 1;
        internal var roundMax:int = levels.length;  
                                    // 1;  // debug
        internal var selected:int = EMPTY;
        internal var selectedColumn:Array;
        internal var selectedName:String;
        internal var score:int = 0;
        internal var sweeping:Boolean = false;
        internal var sweepLength:int = 0;
        internal var targetColumnIndex:int = -1;
        private var deck:Array;
        private var cellCount:int = -1;
        private var columnCount:int = -1;
        private var suitCount:int = -1;
        private var valueCount:int = -1;
        private var valueMin:int = 1;
        private var valueMax:int = 3;

        public function Model()
        {
            restart();
        }

        internal function restart():void
        {
            clear();
            level = 1;
            round = 0;
            score = 0;
            restartScore = 0;
        }

        internal function clear():void
        {
            dragging = false;
            cells = [];
            foundations = [];
            help = "";
            columns = [];
            selected = EMPTY;
            selectedColumn = null;
            selectedName = null;
            targetColumnIndex = -1;
            sweeping = false;
            deck = null;
            cellCount = -1;
            columnCount = -1;
            suitCount = -1;
            valueCount = -1;
            valueMin = 1;
            valueMax = 3;
            sweepLength = 0;
            points = 0;
        }

        internal function populate(levelParams:Object):void
        {
            deck = null;
            for (var param:String in levelParams) {
                this[param] = clone(levelParams[param]);
            }
            generate();
            deal();
            round++;
            selected = EMPTY;
            restartScore = score;
            trace("Model.populate: "
                + "\n    cells " + cells
                + "\n    foundations " + foundations
                + "\n    columns " + columns);
        }

        private function generate():void
        {
            if (1 <= suitCount && 1 <= valueCount) {
                if (null == deck) {
                    deck = [];
                }
                for (var s:int = 0; s < suitCount; s++) {
                    for (var v:int = 1; v <= valueCount; v++) {
                        deck.push(s * RADIX + v);
                    }
                }
                valueMax = valueCount;
            }
            if (1 <= suitCount) {
                if (null == foundations) {
                    foundations = [];
                }
                for (s = 0; s < suitCount; s++) {
                    foundations.push([]);
                }
            }
            if (1 <= cellCount) {
                if (null == cells) {
                    cells = [];
                }
                for (s = 0; s < cellCount; s++) {
                    cells.push([]);
                }
            }
            if (1 <= columnCount) {
                if (null == columns) {
                    columns = [];
                }
                for (s = 0; s < columnCount; s++) {
                    columns.push([]);
                }
            }
        }

        private function deal():void
        {
            if (null != deck) {
                shuffle(deck);
                for (var d:int = 0; d < deck.length; ) {
                    for (var c:int = 0; 
                            c < columns.length && d < deck.length; c++, d++) {
                        columns[c].push(deck[d]);
                    }
                }
            }
        }

        internal function scale(card:int):Number
        {
            return 1.0 - 0.75 * (value(card) - valueMin) / (valueMax - valueMin);
        }

        /**
         * 0, 0, 10, 20, 40,  80, 160, 320, 640, 1280, 2560, 5120, ...
         */
        private function scoreUp(length:int):void
        {
            score += points;
            if (highScore < score) {
                highScore = score;
            }
            bonus(length);
        }

        private function bonus(length:int):void
        {
            if (null != onDie) {
                var amount:int = Math.max(0, Math.min(4, length - 2));
                onDie(amount);
            }
        }

        internal function restartTrial():void
        {
            score = restartScore;
        }

        internal function update():int
        {
            return win();
        }

        internal function canMove(name:String, columnIndex:int, index:int):Boolean
        {
            return (!sweeping && !dragging &&
                "foundation" != name &&
                index == this[name + "s"][columnIndex].length - 1 &&
                from(name, columnIndex, false));
        }

        /**
         * Auto drag next card on a foundation.
         * Disable interaction while sweeping.
         * @return  {name, from, to}
         */
        internal function sweep():Object
        {
            if (dragging || sweeping) {
                return null;
            }
            selectedName = null;
            targetColumnIndex = -1;
            selectedColumn = null;
            for (var f:int = 0; f < foundations.length; f++) {
                var next:int;
                if (0 == foundations[f].length) {
                    next = f * RADIX;
                }
                else {
                    next = foundations[f][foundations[f].length - 1];
                }
                next++;
                sweepTop("cell", next, f);
                sweepTop("column", next, f);
            }
            if (null == selectedColumn) {
                sweepLength = 0;
                points = 0;
                return null;
            }
            else {
                sweepLength++;
                points = Math.pow(2, sweepLength - 1);
                points *= 10;
                return {name: selectedName, 
                    from: this[selectedName + "s"].indexOf(selectedColumn), 
                    to: targetColumnIndex};
            }
        }

        internal function sweepEnd():void
        {
            scoreUp(sweepLength);
            drop("foundation", targetColumnIndex);
        }

        private function sweepTop(name:String, next:int, f:int):void
        {
            var cells:Array = this[name + "s"];
            for (var c:int = 0; c < cells.length; c++) {
                if (!dragging && !sweeping) {
                    if (1 <= cells[c].length) {
                        var card:int = cells[c][cells[c].length - 1];
                        if (equal(next, card)) {
                            hideEmpty();
                            drag(name, c, foundations[f]);
                            selectedColumn = cells[c];
                            selectedName = name;
                            targetColumnIndex = f;
                        }
                    }
                }
            }
        }

        internal function drag(name:String, columnIndex:int, foundation:Array=null):void
        {
            if (!dragging) {
                dragging = true;
                var column:Array = this[name + "s"][columnIndex];
                var card:int = column[column.length - 1];
                selected = card;
                selectedColumn = column;
                if (null == foundation) {
                    from(name, columnIndex);
                }
                else {
                    sweeping = true;
                }
                column.pop();
            }
        }

        internal function cancelDrag():void
        {
            if (dragging) {
                dropSelected();
            }
        }

        private function dropSelected():void
        {
            if (dragging) {
                dragging = false;
                hideEmpty();
                selectedColumn.push(selected);
                selectedColumn = null;
                selected = EMPTY;
                sweeping = false;
                selectedName = null;
                targetColumnIndex = -1;
            }
        }

        internal function drop(name:String, columnIndex:int):void
        {
            if (dragging) {
                selectedColumn = this[name + "s"][columnIndex];
                dropSelected();
            }
        }

        /**
         * @param   push    Hold place at each column this may go to.
         * @return  top card can move.
         */
        internal function from(name:String, columnIndex:int, push:Boolean=true):Boolean
        {
            var column:Array = this[name + "s"][columnIndex];
            var card:int = column[column.length - 1];
            var canMove:Boolean = false;
            if (EMPTY == card) {
                return canMove;
            }
            if ("cell" != name) {
                for (var c:int = 0; c < cells.length; c++) {
                    if (cells[c].length == 0) {
                        canMove = true;
                        if (push) {
                            cells[c].push(EMPTY);
                        }
                    }
                }
            }
            for (c = 0; c < columns.length; c++) {
                var canMoveHere:Boolean = false;
                if (columns[c].length == 0) {
                    canMoveHere = true;
                }
                else {
                    var above:int = columns[c][columns[c].length - 1];
                    if (compatible(card, above)) {
                        canMoveHere = true;
                    }
                }
                if (canMoveHere) {
                    canMove = true;
                    if (push) {
                        columns[c].push(EMPTY);
                    }
                }
            }
            return canMove;
        }

        internal function hideEmpty():void
        {
            popEmpty(cells);
            popEmpty(columns);
        }

        private function popEmpty(cells:Array):void
        {
            for (var c:int = 0; c < cells.length; c++) {
                if (1 <= cells[c].length) {
                    if (EMPTY == cells[c][cells[c].length - 1]) {
                        cells[c].pop();
                    }
                }
            }
        }

        /**
         * TODO: Lose if no moves remaining.
         * @return  0 continue, 1: win, -1: lose.
         */
        private function win():int
        {
            for each(var cell:int in cells) {
                if (1 <= cell) {
                    return 0;
                }
            }
            for each(var column:Array in columns) {
                for each(var card:int in column) {
                    if (1 <= card) {
                        return 0;
                    }
                }
            }
            return 1;
        }

        private function compatible(card:int, above:int):Boolean
        {
            return color(card) != color(above) && value(card) == value(above) - 1;
        }
    }
}
