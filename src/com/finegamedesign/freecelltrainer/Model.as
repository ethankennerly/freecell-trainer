package com.finegamedesign.freecelltrainer
{
    public class Model
    {
        internal static const EMPTY:int = 0;
        internal static var levels:Array = [
            {foundations: [[0]], 
             cells: [0], 
             tableau: [[1, 2]], 
             help: "You may drag a bottom layer to any empty pan."},
            {foundations: [[0], [100]], 
             cells: [102], 
             tableau: [[1, 103], [101, 2]], 
             help: "You may drag a bottom layer to the next smaller layer of the opposite flavor."},
            {backsteps: 5,
             foundations: [[1, 2, 3], [101, 102, 103]], 
             cells: [0], 
             tableau: [[], []], 
             help: "Build both two cakes.  You may drag a bottom layer to an empty pan or the next smaller layer of the opposite flavor."},
        ];

        internal var backsteps:int = 0;
        internal var cells:Array = [];
        internal var foundations:Array = [[]];
        internal var level:int;
        internal var tableau:Array = [[]];
        internal var onContagion:Function;
        internal var onDeselect:Function;
        internal var onDie:Function;
        internal var onDieBonus:Function;
        internal var selected:int;
        internal var highScore:int;
        internal var score:int;
        internal var restartScore:int;
        internal var round:int;
        internal var roundMax:int = levels.length;  
                                    // 1;  // debug

        public function Model()
        {
            highScore = 0;
            restart();
        }

        internal function restart():void
        {
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
            kill += length;
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
                var bonus:int = 0;
                if (length <= Model.LETTER_MIN + 1) {
                    bonus = 0;
                }
                else if (length <= Model.LETTER_MIN + 2) {
                    bonus = 1;
                }
                else if (length <= Model.LETTER_MIN + 3) {
                    bonus = 2;
                }
                else if (length < Model.LETTER_MAX) {
                    bonus = 3;
                }
                else {
                    bonus = 4;
                }
                onDie(bonus);
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
            for each(var column:Array in tableau) {
                for each(var card:int in column) {
                    if (1 <= card) {
                        return 0;
                    }
                }
            }
            return 1;
        }
    }
}
