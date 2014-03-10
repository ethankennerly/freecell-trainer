package com.finegamedesign.freecelltrainer
{
    import flash.display.MovieClip;
    import flash.display.SimpleButton;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.media.Sound;
    import flash.media.SoundMixer;
    import flash.media.SoundTransform;
    import flash.text.TextField;
    import flash.utils.getTimer;

    import org.flixel.plugin.photonstorm.API.FlxKongregate;

    public dynamic class Main extends MovieClip
    {
        [Embed(source="../../../../sfx/complete.mp3")]
        private static var completeClass:Class;
        private var complete:Sound = new completeClass();
        [Embed(source="../../../../sfx/correct.mp3")]
        private static var correctClass:Class;
        private var correct:Sound = new correctClass();
        [Embed(source="../../../../sfx/wrong.mp3")]
        private static var wrongClass:Class;
        private var wrong:Sound = new wrongClass();
        [Embed(source="../../../../sfx/contagion.mp3")]
        private static var contagionClass:Class;
        private var contagion:Sound = new contagionClass();
        [Embed(source="../../../../sfx/die.mp3")]
        private static var dieClass:Class;
        private var die:Sound = new dieClass();
        [Embed(source="../../../../sfx/bonus.mp3")]
        private static var bonusClass:Class;
        private var bonus:Sound = new bonusClass();
        [Embed(source="../../../../sfx/bonus2.mp3")]
        private static var bonus2Class:Class;
        private var bonus2:Sound = new bonus2Class();
        [Embed(source="../../../../sfx/bonus3.mp3")]
        private static var bonus3Class:Class;
        private var bonus3:Sound = new bonus3Class();
        [Embed(source="../../../../sfx/bonus4.mp3")]
        private static var bonus4Class:Class;
        private var bonus4:Sound = new bonus4Class();
        private var bonuses:Array;

        public var feedback:MovieClip;
        public var highScore_txt:TextField;
        public var level_txt:TextField;
        public var round_txt:TextField;
        public var levelMax_txt:TextField;
        public var roundMax_txt:TextField;
        public var room:MovieClip;
        public var score_txt:TextField;
        public var restartTrial_btn:SimpleButton;

        public var selected_0:LetterSelected;
        public var selected_1:LetterSelected;
        public var selected_2:LetterSelected;
        public var selected_3:LetterSelected;
        public var selected_4:LetterSelected;
        public var selected_5:LetterSelected;
        public var selected_6:LetterSelected;
        public var selected_7:LetterSelected;
        public var submit:SimpleButton;

        private var inTrial:Boolean;
        private var model:Model;
        private var view:View;

        public function Main()
        {
            if (stage) {
                init(null);
            }
            else {
                addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
            }
        }

        public function init(event:Event=null):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            inTrial = false;
            model = new Model();
            model.onContagion = contagion.play;
            model.onDie = scoreUp;
            model.onDieBonus = bonus.play;
            model.onDeselect = die.play;
            model.level = 1;
            view = new View();
            trial(model.level);
            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            level_txt.addEventListener(MouseEvent.CLICK, cheatLevel, false, 0, true);
            restartTrial_btn.addEventListener(MouseEvent.CLICK, restartTrial, false, 0, true);
            feedback.mouseEnabled = false;
            feedback.mouseChildren = false;
            feedback.txt.mouseEnabled = false;
            bonuses = [correct, bonus, bonus2, bonus3, bonus4];
            var transform:SoundTransform = new SoundTransform(0.25);
            SoundMixer.soundTransform = transform;
        }

        private function cheatLevel(event:MouseEvent):void
        {
            model.level++;
            if (model.levelMax < model.level) {
                model.level = 1;
            }
        }

        private function restartTrial(e:MouseEvent):void
        {
            model.restartTrial();
            lose();
        }

        public function trial(level:int):void
        {
            if (!inTrial) {
                inTrial = true;
                mouseChildren = true;
                model.populate(Model.levels[level - 1]);
                view.populate(model, room, this);
            }
        }

        private function updateHudText():void
        {
            // trace("updateHudText: ", score, highScore);
            score_txt.text = model.score.toString();
            highScore_txt.text = model.highScore.toString();
            level_txt.text = model.level.toString();
            levelMax_txt.text = model.levelMax.toString();
            round_txt.text = model.round.toString();
            roundMax_txt.text = model.roundMax.toString();
        }

        private function update(event:Event):void
        {
            // After stage is setup, connect to Kongregate.
            // http://flixel.org/forums/index.php?topic=293.0
            // http://www.photonstorm.com/tags/kongregate
            if (! FlxKongregate.hasLoaded && stage != null) {
                FlxKongregate.stage = stage;
                FlxKongregate.init(FlxKongregate.connect);
            }
            if (inTrial) {
                var win:int = model.update();
                view.update();
                result(win);
            }
            else {
                view.update();
                if ("next" == feedback.currentLabel) {
                    next();
                }
            }
            updateHudText();
        }

        private function result(winning:int):void
        {
            if (!inTrial) {
                return;
            }
            if (winning <= -1) {
                lose();
            }
            else if (1 <= winning) {
                win();
            }
        }

        private function scoreUp(bonus:int):void
        {
            bonuses[bonus].play();
        }

        private function win():void
        {
            inTrial = false;
            model.level++;
            if (model.levelMax < model.level) {
                model.level = 1;
                feedback.gotoAndPlay("complete");
                complete.play();
            }
            else {
                feedback.gotoAndPlay("correct");
            }
            FlxKongregate.api.stats.submit("Score", model.score);
        }

        private function lose():void
        {
            inTrial = false;
            FlxKongregate.api.stats.submit("Score", model.score);
            mouseChildren = false;
            feedback.gotoAndPlay("wrong");
            feedback.txt.text = model.help;
            wrong.play();
        }

        public function next():void
        {
            if (!inTrial) {
                view.clear();
                feedback.gotoAndPlay("none");
                mouseChildren = true;
                if (currentFrame < totalFrames) {
                    nextFrame();
                }
                if (model.level <= 1 || model.levelMax < model.level) {
                    restart();
                }
                trial(model.level);
            }
        }

        public function restart():void
        {
            model.restart();
            mouseChildren = true;
            gotoAndPlay(1);
        }
    }
}
