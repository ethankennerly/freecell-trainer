package com.finegamedesign.freecelltrainer
{
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
             columns: [[1, 103], [101, 2]], 
             help: "To build two cakes, you may drag a bottom layer to below the next higher layer of the opposite flavor."},
            {backsteps: 5,
             foundations: [[1, 2, 3], [101, 102, 103]], 
             cells: [[]], 
             columns: [[], []], 
             help: "Build both two cakes.  You may drag a bottom layer to an empty pan or to below next higher layer of the opposite flavor."},
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

        internal var backsteps:int = 0;
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
        internal var selected:int = -1;
        internal var score:int = 0;
        internal var restartScore:int = 0;
        internal var round:int = 1;
        internal var roundMax:int = levels.length;  
                                    // 1;  // debug

        public function Model()
        {
            restart();
        }

        internal function restart():void
        {
            level = 1;
            round = 1;
            score = 0;
            restartScore = 0;
        }

        internal function populate(levelParams:Object):void
        {
            for (var param:String in levelParams) {
                this[param] = levelParams[param];
            }
            round++;
            selected = -1;
            restartScore = score;
        }

        /**
         * 0, 0, 10, 20, 40,  80, 160, 320, 640, 1280, 2560, 5120, ...
         */
        private function scoreUp(length:int):void
        {
            var points:int = Math.pow(2, length - 3);
            points *= 10;
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
            return index == this[name + "s"][columnIndex].length - 1 &&
                from(name, columnIndex, false);
        }

        /**
         * @param   push    Hold place at each column this may go to.
         * @return  last card can move.
         */
        internal function from(name:String, columnIndex:int, push:Boolean=true):Boolean
        {
            var column:Array = this[name + "s"][columnIndex];
            var card:int = column[column.length - 1];
            var canMove:Boolean = false;
            for (var c:int = 0; c < cells.length; c++) {
                if (cells[c].length == 0) {
                    canMove = true;
                    if (push) {
                        cells[c].push(EMPTY);
                    }
                }
            }
            for (c = 0; c < columns.length; c++) {
                var above:int = columns[c][columns[c].length - 1];
                if (compatible(card, above)) {
                    canMove = true;
                    if (push) {
                        columns[c].push(EMPTY);
                    }
                }
            }
            return canMove;
        }

        internal function cancel():void
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
