package states;   包;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;
	
	var blackBarsLeft:FlxSprite;
	var blackBarsRight:FlxSprite;
	var zoomCamera:Bool = false;
	var zoomAmount:Float = 1;

	override function create()
	{
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, 0, songs[i].songName, true);
			songText.targetY = i;
			songText.screenCenter(X);
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			icon.y = songText.y + 60;
			
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			iconArray.push(icon);
			add(icon);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(0, 10, FlxG.width, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.y = 10;

		scoreBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 50, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		add(scoreText);

		diffText = new FlxText(0, 0, 0, "", 24);
		diffText.visible = false;

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		lerpSelected = curSelected;

		curDifficulty = 0;

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = "Press SPACE to listen / Press RESET to reset score";
		
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		player = new MusicPlayer(this);
		add(player);
		
		blackBarsLeft = new FlxSprite(-FlxG.width, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBarsRight = new FlxSprite(FlxG.width, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBarsLeft.alpha = 0;
		blackBarsRight.alpha = 0;
		add(blackBarsLeft);
		add(blackBarsRight);
		
		changeSelection();
		updateTexts();

		#if mobile
		addTouchPad("LEFT_FULL", "A_B_C_X_Y_Z");
		#end
		
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();

		#if mobile
		removeTouchPad();
		addTouchPad("LEFT_FULL", "A_B_C_X_Y_Z");
		#end
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;
	
	override function update(elapsed:Float)
	{
		if (zoomCamera)
		{
			zoomAmount += elapsed * 2;
			FlxG.camera.zoom = zoomAmount;
			if (zoomAmount >= 2) zoomAmount = 2;
		}
		
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) {
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) {
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;

		#if mobile
		if((FlxG.keys.pressed.SHIFT || touchPad.buttonZ.pressed) && !player.playingMusic) shiftMult = 3;
		#else
		if(FlxG.keys.pressed.SHIFT && !player.playingMusic) shiftMult = 3;
		#end

		if (!player.playingMusic && !zoomCamera)
		{
			scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				
				if (controls.UI_UP_P)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (controls.UI_DOWN_P)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
				}

				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeSelection(-shiftMult * FlxG.mouse.wheel, false);
				}
			}
		}

		if (controls.BACK && !zoomCamera)
		{
			if (player.playingMusic)
			{
				FlxG.sound.music.stop();
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;
				instPlaying = -1;

				player.playingMusic = false;
				player.switchPlayMusic();

				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			}
			else 
			{
				persistentUpdate = false;
				if(colorTween != null) {
					colorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		#if mobile
		if((FlxG.keys.justPressed.CONTROL || touchPad.buttonC.justPressed) && !player.playingMusic && !zoomCamera)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
			removeTouchPad();
		}
		else if(FlxG.keys.justPressed.SPACE || touchPad.buttonX.justPressed)
		{
			if(instPlaying != curSelected && !player.playingMusic && !zoomCamera)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					FlxG.sound.list.add(vocals);
					vocals.persist = true;
					vocals.looped = true;
				}
				else if (vocals != null)
				{
					vocals.stop();
					vocals.destroy();
					vocals = null;
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				if(vocals != null)
				{
					vocals.play();
					vocals.volume = 0.8;
				}
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(player.paused);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic && !zoomCamera)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
				
				startTransitionToGame();
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1);
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
		}
		else if((controls.RESET || touchPad.buttonY.justPressed) && !player.playingMusic && !zoomCamera)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			removeTouchPad();
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		#else
		if((FlxG.keys.justPressed.CONTROL) && !player.playingMusic && !zoomCamera)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !player.playingMusic && !zoomCamera)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				Mods.currentModDirectory = songs[curSelected].folder;
				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				if (PlayState.SONG.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
					FlxG.sound.list.add(vocals);
					vocals.persist = true;
					vocals.looped = true;
				}
				else if (vocals != null)
				{
					vocals.stop();
					vocals.destroy();
					vocals = null;
				}

				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
				if(vocals != null)
				{
					vocals.play();
					vocals.volume = 0.8;
				}
				instPlaying = curSelected;

				player.playingMusic = true;
				player.curTime = 0;
				player.switchPlayMusic();
			}
			else if (instPlaying == curSelected && player.playingMusic)
			{
				player.pauseOrResume(player.paused);
			}
		}
		else if (controls.ACCEPT && !player.playingMusic && !zoomCamera)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));
			
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
				
				startTransitionToGame();
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1);
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
		}
		else if((controls.RESET) && !player.playingMusic && !zoomCamera)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		#end

		updateTexts(elapsed);
		super.update(elapsed);
	}

	function startTransitionToGame()
	{
		var centerY:Float = FlxG.height / 2;
		
		for (item in grpSongs.members)
		{
			if (item != null && item.visible && item.exists)
			{
				var targetY:Float = centerY + ((item.targetY - curSelected) * 80);
				
				if (item.targetY < curSelected)
				{
					FlxTween.tween(item, {y: targetY - 150, alpha: 0}, 0.5, {ease: FlxEase.quartIn});
				}
				else if (item.targetY > curSelected)
				{
					FlxTween.tween(item, {y: targetY + 150, alpha: 0}, 0.5, {ease: FlxEase.quartIn});
				}
				else
				{
					FlxTween.tween(item.scale, {x: 1.2, y: 1.2}, 0.3, {ease: FlxEase.quartOut});
					FlxTween.tween(item, {alpha: 0}, 0.5, {ease: FlxEase.quartIn, startDelay: 0.2});
				}
			}
		}
		
		for (icon in iconArray)
		{
			if (icon != null && icon.visible && icon.exists)
			{
				FlxTween.tween(icon, {alpha: 0}, 0.4, {ease: FlxEase.quartOut});
			}
		}
		
		FlxTween.tween(scoreText, {alpha: 0}, 0.3);
		FlxTween.tween(scoreBG, {alpha: 0}, 0.3);
		FlxTween.tween(bottomText, {alpha: 0}, 0.3);
		FlxTween.tween(bottomBG, {alpha: 0}, 0.3);
		
		FlxTween.tween(blackBarsLeft, {x: 0, alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		FlxTween.tween(blackBarsRight, {x: FlxG.width - blackBarsRight.width, alpha: 1}, 0.5, {ease: FlxEase.quartOut});
		
		zoomCamera = true;
		FlxG.camera.zoom = 1;
		
		FlxTween.tween(bg, {alpha: 0}, 0.6, {
			ease: FlxEase.quartIn,
			onComplete: function(twn:FlxTween) {
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
				destroyFreeplayVocals();
				FlxG.camera.zoom = 1;
				#if (MODS_ALLOWED && DISCORD_ALLOWED)
				DiscordClient.loadModRPC();
				#end
			}
		});
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		diffText.text = "";

		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color   颜色(bg, 1, bg.color   颜色, intendedColor, {colorTween = FlxTween。颜色（bg, 1, bg）color, interdedcolor, {
				onComplete: 不完整:函数(twn:FlxTween) {function   函数(twn:FlxTween) {
					colorTween =    =空;null   零;
				}
			});
		}

		for   为 （i in   在 0…iconArray.length）for (i   我 in   在 0...iconArray.length)
		{
			iconArray[i].iconArray   α[我]。alpha = 0.6;alpha = 0.6;
		}

		iconArray[curSelected].iconArray   α [curSelected]。Alpha = 1；alpha = 1;

		for   为 （grpsong .members中的项）for (item   项 in   在 grpSongs.members)
		{
			item.alpha   α = 0.6;
			如果项目。targetY == curSelected)if   如果 (item.targetY == curSelected)
				item.alpha   α = 1;
		}
		
		Mods.插件。currentModDirectory = songs[curSelected].folder   文件夹；currentModDirectory = songs[curSelected].folder   文件夹;
		PlayState.PlayState。storyWeek = songs[curSelected].week；storyWeek = songs[curSelected].week   周;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty；var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list   列表.indexOf(lastDifficultyName);
		if   如果(savedDiff != null   零 && !lastList.contains(savedDiff) && Difficulty.list   列表.contains   包含(savedDiff))if   如果(savedDiff != null   零 && !lastList.contains(savedDiff) && Difficulty.list   列表.contains   包含(savedDiff))
			curDifficulty = Math.cur   轮难度= Math.round   轮马克斯(0,Difficulty.list   列表.indexOf (savedDiff)));round(Math.max   马克斯(0, Difficulty.list.indexOf(savedDiff)));
		   if   其他（lastDiff > -1）else if   如果(lastDiff > -1)
			curDifficulty = lastDiff;cur难度= lastDiff；
		else   其他 if   如果(Difficulty.list   列表.contains(Difficulty.getDefault()))
			curDifficulty = Math.cur   轮难度= Math.round   轮马克斯(0,Difficulty.defaultList.indexOf (Difficulty.getDefault ())));round(Math.max   马克斯(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		   其他else
			curDifficulty =    cur难度= 0；0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	内联私有函数_updateSongLastDifficulty（）inline private   私人 function   函数 _updateSongLastDifficulty()
	{
		songs[curSelected].歌[curSelected]。lastDifficulty = Difficulty.getString(curDifficulty)；lastDifficulty = Difficulty.getString(curDifficulty);
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];var _lastVisibles:Array<Int> = [];
	公共函数updatetext （elapsed:Float = 0.0   公共）public function   函数 updateTexts(elapsed   运行:Float = 0.0)
	{
		lerpSelected = FlxMath.lerpSelected = FlxMath。lerp（curSelected, lpselected, Math）Exp (-elapsed * 9.6))；lerp(curSelected, lerpSelected, Math.exp   经验值(-elapsed * 9.6));
		   for   为 （i in   在 _lastvisible）for (i   我 in   在 _lastVisibles)
		{
			grpSongs.grpSongs   成员.members   成员[我]。可见= grpsong .members   成员[i]。Active = false   假；members[i].visible   可见 = grpSongs.members   成员[i].active   活跃的 = false   假;
			iconArray[i].iconArray   可见[我]。可见= iconArray[i]。Active = false   假；visible = iconArray[i].active   活跃的 = false   假;
		}
		_lastVisibles = [];   _lastVisible = []；

		var centerY:Float = FlxG.height   高度 / 2;
		var min   最小值:Int = Math.round   轮(马克斯(0,Math.min(歌曲。length, lerpSelected - _drawDistance))；var min:Int = Math.round   轮(Math.max   马克斯(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max   马克斯:Int = Math.round   轮马克斯(0,Math.min   最小值(歌曲。长度，lerpSelected _drawDistance)))；var max:Int = Math.round   轮(Math.max   马克斯(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		   For （i in   为 min…max）for (i in   在 min...max)
		{
			var item   项：字母表= grpsong .members   成员[i]；var item:Alphabet = grpSongs.members   成员[i];
			item.项   可见。可见=项目。Active = true   真正的；visible = item.active   活跃的 = true   真正的;
			item.项。x = FlxG。宽度/ 2 -项目。宽度/ 2；x = FlxG.width   宽度 / 2 - item.width   宽度 / 2;
			item.项。y = centerY （(item.)）targetY - lerpSelected) * 80)；y = centerY + ((item.targetY - lerpSelected) * 80);
			
			var icon   图标:HealthIcon = conarray [i];var icon   图标:HealthIcon = iconArray[i];
			icon.图   可见标。可见=图标。Active = true   真正的；visible = icon.active   活跃的 = true   真正的;
			icon.图标。X =物品。x项目。宽度/ 2 -图标。宽度/ 2；x = item.x + item.width   宽度 / 2 - icon.width   宽度 / 2;
			icon.图标。Y =物品。y 60;y = item.y + 60;
			_lastVisibles.   _lastVisibles   推.push   推(我);push(i);
		}
	}

	override 重写函数destroy()：无效function destroy():Void
	{
		super.destroy   摧毁();

		FlxG.autoPause = ClientPrefs.data   数据.autoPause;
		如果(! FlxG.sound   声音.music.playing)if   如果 (!FlxG.sound   声音.music.playing)
			FlxG.FlxG.sound   声音.playMusic (Paths.music   音乐 (freakyMenu”));sound.playMusic(Paths.music   音乐('freakyMenu'   “freakyMenu”));
	}	
}

class   类   类SongMetadata SongMetadata
{
	public   公共 var songName:String = "；public var songName:String = "";   ""
	public var week:Int = 0；public var week:Int = 0;
	public var songCharacter:String = "   公共；public var songCharacter:String = "";
	public   公共 var color   颜色:Int = -7179779；public var color   颜色:Int = -7179779;
	public   公共 var folder   文件夹:String = "；public var folder:String = "";
	公共var last难度：字符串= null；public var lastDifficulty:String = null;

	public function new（song:String, week:Int, song character:String, color:Int）public function new(song:String, week:Int, songCharacter:String, color:Int)
	{   公共
		   这一点。songName =歌曲；this.songName = song;
		   这一点。Week =周；this.week = week;
		这一点。songCharacter = songCharacter；this.songCharacter = songCharacter;
		   这一点。Color =颜色；this.color = color;
		this.folder = Mods.currentModDirectory;
		如果这一点。文件夹== null)这个。文件夹= "   文件夹；if(this.folder   文件夹 == null   零) this.folder   文件夹 = '';
	}
}
