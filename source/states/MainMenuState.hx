package states;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';
	public static var curSelected:Int = 0;
	
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'options'
	];
	
	var bg:FlxSprite;
	var camFollow:FlxObject;
	var blackBars:FlxSprite;
	
	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();
		
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);
		#end
		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		persistentUpdate = persistentDraw = true;
		
		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);
		
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		
		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.scale.set(0.8, 0.8);
			menuItem.updateHitbox();
			menuItems.add(menuItem);
			
			menuItem.scrollFactor.set(0, 0);
			menuItem.screenCenter(X);
		}
		
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		
		blackBars = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackBars.alpha = 0;
		blackBars.scrollFactor.set();
		add(blackBars);
		
		changeItem();
		
		#if ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			Achievements.unlock('friday_night_play');
		#if MODS_ALLOWED
		Achievements.reloadList();
		#end
		#end
		
		#if mobile
		addTouchPad("UP_DOWN", "A_B_E");
		#end
		
		super.create();
		FlxG.camera.follow(camFollow, null, 9);
	}
	
	var selectedSomethin:Bool = false;
	var hoverTweens:Array<FlxTween> = [];
	
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}
		
		if (!selectedSomethin)
		{
			for (i in 0...menuItems.length)
			{
				var item = menuItems.members[i];
				if (i == curSelected)
				{
					if (item.scale.x < 1.1)
					{
						if (hoverTweens[i] != null) hoverTweens[i].cancel();
						hoverTweens[i] = FlxTween.tween(item.scale, {x: 1.1, y: 1.1}, 0.3, {ease: FlxEase.quartOut});
					}
				}
				else
				{
					if (item.scale.x > 0.8)
					{
						if   如果 (hoverTweens[i] != null   零) hoverTweens[i].cancel   取消();
						hoverTweens[i] = FlxTween.tween(item.scale, {x: 0.8, y: 0.8}, 0.3, {ease: FlxEase.quartOut});
					}
				}
			}
			
			if (controls.UI_UP_P)
				changeItem(-1);
			if (controls.UI_DOWN_P)
				changeItem(1);
			if (controls.BACK)
			{
				selectedSomethin = true;   selectedSomethin = true   真正的；
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}
			
			#if mobile
			if (controls.ACCEPT)   如果(controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));FlxG.sound   声音.play (Paths.sound   声音 (confirmMenu”));
				selectedSomethin = true;   selectedSomethin = true   真正的；
				startTransition();
			}
			else if (controls.justPressed('debug_1') || touchPad.buttonE.justPressed)否则if（控制）。touchpad .button .justPressed （'debug_1'）
			{
				selectedSomethin = true;   selectedSomethin = true   真正的；
				MusicBeatState.switchState(new MasterEditorMenu());MusicBeatState。switchState (new   新 MasterEditorMenu ());
			}
			#else   其他#
			if (controls.ACCEPT)   如果(controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));FlxG.sound   声音.play (Paths.sound   声音 (confirmMenu”));
				selectedSomethin = true;   selectedSomethin = true   真正的；
				startTransition();
			}
			else if (controls.justPressed('debug_1'))else   其他 if   如果 （controls.justPressed('debug_1')）
			{
				selectedSomethin = true;   selectedSomethin = true   真正的；
				MusicBeatState.switchState(new MasterEditorMenu());MusicBeatState。switchState (new   新 MasterEditorMenu ());
			}
			#end   #结束
		}
		super.update(elapsed);   super.update   更新(运行);
	}
	
	function startTransition()startTransition()函数
	{
		var selectedItem = menuItems.members[curSelected];
		FlxTween.tween(selectedItem.scale, {x: 1.5, y: 1.5}, 0.4, {ease: FlxEase.quartOut});FlxTween.tween(设置selectedItem。规模,{x: 1.5, y: 1.5}, 0.4,{缓解:FlxEase.quartOut});
		FlxTween.tween(selectedItem, {alpha: 0}, 0.5, {ease: FlxEase.quartIn, startDelay: 0.2});FlxTween。tween(selectedItem, {alpha   α: 0}, 0.5, {ease: FlxEase；quartIn, startDelay: 0.2})；
		
		for (i in 0...menuItems.length)for   为 （i in   在 0…menuItems.length）
		{
			if (i   我 == curSelected) continue;if   如果 （i == curSelected）继续；
			FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.3, {ease: FlxEase.quadOut});FlxTween.tween(菜单项。成员[i]， {alpha: 0}, 0.3, {ease: FlxEase.quadOut})；
		}
		
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {新FlxTimer().start(0.5, function   函数(tmr:FlxTimer) {
			FlxTween.tween(blackBars, {alpha: 1}, 0.3, {FlxTween。tween(blackBars， {alpha: 1}， 0.3， {
				ease: FlxEase.quartIn,   缓解:FlxEase.quartIn,
				onComplete: function(twn:FlxTween) {不完整:函数(twn:FlxTween) {
					switch (optionShit[curSelected])开关(optionShit [curSelected])
					{
						case 'story_mode':   例“story_mode”:
							MusicBeatState.switchState(new StoryMenuState());MusicBeatState .switchState StoryMenuState()(纽约);
						case 'freeplay':   例“拘谨”:
							MusicBeatState.switchState(new FreeplayState());MusicBeatState。switchState(新FreeplayState ());
						case 'credits':   例“学分”:
							MusicBeatState.switchState(new CreditsState());MusicBeatState。switchState(新CreditsState ());
						case 'options':   例“选项”:
							MusicBeatState.switchState(new OptionsState());MusicBeatState .switchState OptionsState()(纽约);
							OptionsState.onPlayState = false;OptionsState。onPlayState = false   假；
							if (PlayState.SONG != null)如果(PlayState。首歌!= null   零)
							{
								PlayState.SONG.arrowSkin = null;PlayState.SONG.arrowSkin = null   零；
								PlayState.SONG.splashSkin = null;PlayState.SONG.splashSkin = null   零；
								PlayState.stageUI = 'normal';PlayState。stageUI = 'normal'；
							}
					}
				}
			});
		});
	}
	
	function changeItem(huh:Int = 0)函数changeItem（huh:Int = 0）
	{
		FlxG.sound   声音.play(Paths.sound('scrollMenu'));FlxG.sound   声音.play (Paths.sound   声音 (scrollMenu”));
		
		var oldItem = menuItems.members[curSelected];
		oldItem.animation.play('idle');oldItem.animation.play(“闲置”);
		
		curSelected += huh;   curSelected = huh；
		if (curSelected >= menuItems.length) curSelected = 0;如果（curSelected >= menuItems.）长度)curSelected = 0；
		if (curSelected < 0) curSelected = menuItems.length - 1;如果（curSelected < 0） curSelected =菜单项。长度- 1；
		
		var newItem = menuItems.members[curSelected];
		newItem.animation.play('selected');newItem.animation.play(“选择”);
		newItem.centerOffsets();
		newItem.screenCenter(X);
		
		camFollow.setPosition(newItem.getGraphicMidpoint().x,camFollow.setPosition (newItem.getGraphicMidpoint()方式,
			newItem.getGraphicMidpoint().y - (menuItems.length > 4 ? menuItems.length * 8 : 0));newItem.getGraphicMidpoint () .y -(菜单项。长度4 ？menuItems .长度* 8:0))；
	}
}
