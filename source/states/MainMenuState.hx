package states;   包;

import flixel.FlxObject;   进口flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;进口flixel.addons   插件.transition   过渡.FlxTransitionableState;
import flixel.effects.FlxFlicker;进口flixel.effects   影响.FlxFlicker;
import lime.app.Application;进口lime.app   应用程序.Application;
import states.editors.MasterEditorMenu;进口states.editors   编辑器.MasterEditorMenu;
import options.OptionsState;进口options.OptionsState;

class MainMenuState extends MusicBeatState类MainMenuState扩展MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.3';public   公共 static   静态 var psychEngineVersion:String = '0.7.3'；
	public static var curSelected:Int = 0;公共静态var curSelected:Int = 0；
	
	var menuItems:FlxTypedGroup<FlxSprite>;var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = [var optionShit:Array<String> = [
		'story_mode',   “story_mode”,
		'freeplay',   “拘谨”,
		'credits',   “信用”,
		'options'   “选项”
	];
	
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	
	override function create()   重写函数create（）
	{
		#if MODS_ALLOWED   #如果MODS_ALLOWED
		Mods.pushGlobalMods();
		#end   #结束
		Mods.loadTopMod();
		
		#if DISCORD_ALLOWED   #如果DISCORD_ALLOWED
		DiscordClient.changePresence("In the Menus", null);DiscordClient.changePresence("In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus"   "In the Menus", null   零);
		#end   #结束
		
		transIn = FlxTransitionableState.defaultTransIn;transIn = FlxTransitionableState.defaultTransIn；
		transOut = FlxTransitionableState.defaultTransOut;transOut = FlxTransitionableState.defaultTransOut；
		persistentUpdate = persistentDraw = true;坚持不懈=坚持不懈=真理;
		
		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));var bg:FlxSprite = new   新 FlxSprite(-80).loadGraphic(Paths.image   图像('menuBG'))；
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);   添加(bg);
		
		camFollow = new FlxObject(0, 0, 1, 1);camFollow = new   新 FlxObject(0,0,1,1)；
		add(camFollow);   添加(camFollow);
		
		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, 0);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;   洋红色。Visible = false   假；
		magenta.color = 0xFFfd719b;洋红色。颜色= 0xFFfd719b;
		add(magenta);   添加(红色);
		
		menuItems = new FlxTypedGroup<FlxSprite>();menuItems = new   新 FlxTypedGroup<FlxSprite>；
		add(menuItems);
		
		for (i in 0...optionShit.length)for   为 （i in   在 0…optionShit.length）
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;var offset   抵消:Float = 108 - （Math.max   马克斯(optionShit. max   马克斯)）长度，4)- 4)* 80；
			var menuItem:FlxSprite = new FlxSprite(0, (i * 140) + offset);var menuItem:FlxSprite = new   新 FlxSprite(0, (i * 140)   offset);
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);menuItem.frames   帧 =路径。getSparrowAtlas (' mainmenu / menu_ '“菜单/菜单” optionShit[我]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);menuItem.animation   动画 .addByPrefix('idle'   “闲置”, optionShit[i] " basic "   基本的；, 24)；
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);menuItem.animation   动画。addByPrefix('selected'   “选择”, optionShit[i] " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white"   " white", 24)；
			menuItem.animation.play('idle');menuItem.animation   动画.play   玩(“闲置”);
			menuItems.add(menuItem);   menuItems add (menuItem);
			
			var scr:Float = (optionShit.length - 4) * 0.135;var scr   可控硅:Float = (optionShit。长度- 4)* 0.135；
			if (optionShit.length < 6)   如果(optionShit。长度<； 6)
				scr = 0;   SCR = 0；
			menuItem.scrollFactor.set(0, scr);menuItem.scrollFactor。集(0,可控硅);
			menuItem.updateHitbox();   menuItem updateHitbox ();
			menuItem.screenCenter(X);
		}
		
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);var psychVer:FlxText = new   新 FlxText(12, FlxG。height - 44,0, "Psych Engine "   心理引擎； psychEngineVersion, 12)；
		psychVer.scrollFactor.set();
		psychVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);psychVer.setFormat("VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono", 16, FlxColor；白色，左，FlxTextBorderStyle。轮廓,FlxColor.BLACK);
		add(psychVer);
		
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);var fnfVer:FlxText = new   新 FlxText(12, FlxG.height   高度 - 24, 0, "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   "Friday Night Funkin' v"   Application.current.meta.get('version'   “版本”), 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);fnfVer.setFormat("VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono"   "VCR OSD Mono", 16, FlxColor；白色，左，FlxTextBorderStyle。轮廓,FlxColor.BLACK);
		add(fnfVer);
		
		changeItem();
		
		#if ACHIEVEMENTS_ALLOWED   #如果ACHIEVEMENTS_ALLOWED
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)if   如果 (leDate .getDay（) == 5 & leDate.getHours() >= 18）
			Achievements.unlock('friday_night_play');Achievements.unlock   解锁(“friday_night_play”);
		#if MODS_ALLOWED   #如果MODS_ALLOWED
		Achievements.reloadList();
		#end   #结束
		#end   #结束
		
		   #如果移动#if mobile
		addTouchPad("UP_DOWN", "A_B_E");
		   包;   包;#end   #结束
		
		super.create   创建();
		FlxG.FlxG.camera.follow(camFollow, null   零, 9)；camera.follow(camFollow, null   零, 9);
	}
	
	var selectedSomethin:Bool = false   假;
	
	override 重载函数更新（elapsed:Float）function update(elapsed:Float)
	{
		如果(FlxG.sound   声音   声音.music。音量<； 0.8)if   如果   如果 (FlxG.sound   声音.music.volume < 0.8)
		{
			FlxG.FlxG.sound   声音.music   音乐.volume = 0.5 * elapsed；sound.music   音乐.volume += 0.5 * elapsed;
			如果(FreeplayState。人声!= null   零)if   如果 (FreeplayState.vocals != null   零)
				FreeplayState.FreeplayState.vocals.volume = 0.5 * elapsed；vocals.volume += 0.5 * elapsed;
		}
		   包;
		   如果(!selectedSomethin)if   如果   如果 (!selectedSomethin)
		{
			   如果控件。UI_UP_P)if   如果   如果 (controls.UI_UP_P)
				changeItem(   changeItem(达到华);-1);
			   如果控件。UI_DOWN_P)if   如果   如果 (controls.UI_DOWN_P)
				changeItem(1);
			   如果(controls.BACK)if   如果   如果 (controls.BACK)
			{
				selectedSomethin =    selectedSomethin = true   真正的   真正的；true;
				FlxG.sound   声音   声音.play   玩   玩(Paths.sound   声音   声音('cancelMenu'));
				MusicBeatState.MusicBeatState。switchState(新TitleState ());switchState(new   新   新 TitleState());
			}
			
			   #如果移动#if mobile
			   如果(controls.ACCEPT)if   如果   如果 (controls.ACCEPT)
			{
				FlxG.sound   声音   声音   声音   声音.play   玩   玩   玩   玩(Paths.sound   声音   声音   声音   声音('confirmMenu'   ’confirmMenu’   ’confirmMenu’   ’confirmMenu’));FlxG.sound   声音   声音   声音   声音   声音.play   玩   玩   玩   玩   玩 (Paths.sound   声音   声音   声音   声音   声音 (confirmMenu”));   包;
				selectedSomethin = true   真正的   真正的   真正的   真正的   真正的;
				
				switch   开关   开关   开关 (optionShit[curSelected])开关(optionShit [curSelected])
				{
					Case 'story_mode'   “story_mode”   “story_mode”   “story_mode”: story_mode；case 'story_mode'   “story_mode”   “story_mode”   “story_mode”   “story_mode”:   例“story_mode”:
						MusicBeatState.switchState(new   新   新   新   新 StoryMenuState());MusicBeatState .switchState StoryMenuState()(纽约);
					case   情况下   情况下   情况下 'freeplay'   “拘谨”   “拘谨”   “拘谨”:   例“拘谨”:case   情况下   情况下   情况下 'freeplay'   “拘谨”   “拘谨”   “拘谨”   “拘谨”:   例“拘谨”:
						MusicBeatState.switchState(new   新   新   新   新 FreeplayState());MusicBeatState。switchState(新FreeplayState ());
					case   情况下   情况下   情况下 'credits'   “信用”   “信用”   “信用”:   例“学分”:case   情况下   情况下   情况下 'credits'   “信用”   “信用”   “信用”   “信用”:   例“学分”:
						MusicBeatState.switchState(new   新   新   新 CreditsState());MusicBeatState。switchState(新CreditsState ());
					case   情况下   情况下   情况下 'options'   “选项”   “选项”:   例“选项”:case   情况下   情况下 'options'   “选项”   “选项”   “选项”:   例“选项”:
						MusicBeatState.switchState(new   新   新 OptionsState());MusicBeatState .switchState OptionsState()(纽约);
						OptionsState.OptionsState。onPlayState = false   假；onPlayState = false   假。onPlayState = false   假   假;OptionsState。onPlayState = false   假   假   假；
						if   如果   如果 (PlayState.SONG != null   零   零)如果(PlayState。首歌!= null   零   零   零)
						{
							PlayState.SONG.PlayState.SONG. arrowskin = null   零；arrowSkin = null   零；arrowSkin = null   零   零;PlayState.SONG.arrowSkin = null   零   零   零；
							PlayState.SONG.PlayState.SONG. splashskin = null   零；splashSkin = null   零 null   零；splashSkin = null   零   零;PlayState.SONG.splashSkin = null   零   零   零；
							PlayState.PlayState.stageUI = 'normal'   “正常”;PlayState。stageUI = 'normal'   “正常”   “正常”；stageUI = 'normal'   “正常”   “正常”;PlayState。stageUI = 'normal'   “正常”   “正常”   “正常”；
						}
				}
				
				for   为 (i   我   我 in   在 0...menuItems.members   成员.length)
				{
					if   如果 （i == curSelected）if (i == curSelected)   if   如果 （i == curSelected）
						   继续;continue   继续;
					FlxTween.tween   渐变   渐变(menuItems.members   成员   成员[i], {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,   缓解:FlxEase.quadOut,
						onComplete: onComplete: onComplete: onComplete: function   函数（twn:FlxTween）函数（twn:FlxTween）function (twn FlxTween)function   函数(twn:FlxTween)
						{
							menuItems.members   成员   成员[i].kill   杀了();
						}
					});
				}
			}
			else   其他 if (controls.justPressed('debug_1') || touchPad.buttonE.justPressed)否则if（控制）。touchpad .button   按钮 .justPressed （'debug_1'   “debug_1”）else if   如果 (controls.justPressed('debug_1'   “debug_1”) || touchPad.buttonE.justPressed)否则if（控制）。touchpad .button   按钮   按钮 .justPressed （'debug_1'   “debug_1”   “debug_1”）
			{
				selectedSomethin = true   真正的;   selectedSomethin = true   真正的   真正的；
				MusicBeatState.MusicBeatState。switchState(new MasterEditorMenu())；switchState (new MasterEditorMenu ())；switchState(new   新 MasterEditorMenu());MusicBeatState。switchState (new   新   新 MasterEditorMenu ());
			}
			#else   其他#
			if   如果 (controls.ACCEPT)   如果(controls.ACCEPT)
			{
				FlxG.FlxG.sound   声音.play(Paths.sound('confirmMenu'));FlxG.sound   声音.play   玩 (Paths.sound   声音 (confirmMenu”));sound.play   玩(Paths.sound   声音('confirmMenu'   ’confirmMenu’));FlxG.sound   声音   声音.play   玩   玩 (Paths.sound   声音   声音 (confirmMenu”));
				selectedSomethin = true   真正的;   selectedSomethin = true   真正的   真正的；
				
				开关(optionShit [curSelected])switch   开关 (optionShit[curSelected])
				{
					   例“story_mode”:case   情况下 'story_mode'   “story_mode”:
						MusicBeatState.MusicBeatState .switchState StoryMenuState()(纽约);switchState(new   新 StoryMenuState());
					   例“拘谨”:case   情况下 'freeplay'   “拘谨”:
						MusicBeatState.MusicBeatState。switchState(新FreeplayState ());switchState(new   新 FreeplayState());
					   例“学分”:case   情况下 'credits'   “信用”:
						MusicBeatState.MusicBeatState。switchState(新CreditsState ());switchState(new   新 CreditsState());
					   例“选项”:case 'options':
						MusicBeatState.MusicBeatState .switchState OptionsState()(纽约);switchState(new OptionsState());
						OptionsState.onPlayState = OptionsState。onPlayState = false；false;
						如果(PlayState。首歌!= null)if (PlayState.SONG != null)
						{
							PlayState.SONG.arrowSkin = PlayState.SONG.arrowSkin = null；null;
							PlayState.SONG.splashSkin = PlayState.SONG.splashSkin = null；null;
							PlayState.stageUI = PlayState。stageUI = 'normal'；'normal';
						}
				}
				
				for （i我在0…menuItems.members.length）for (i   我 in 0...menuItems.members.length)
				{
					   if （i == curSelected）if (i == curSelected)
						   继续;continue;
					FlxTween.tween(menuItems.members[i], {alpha: FlxTween.tween(菜单项。成员[i]， {alpha: 0}, 0.4, {0}, 0.4, {
						ease: FlxEase.quadOut,   缓解:FlxEase.quadOut,
						onComplete: onComplete: onComplete: onComplete: function（twn:FlxTween）函数（twn:FlxTween）function (twn FlxTween)function(twn:FlxTween)
						{
							menuItems.menuItems.members[我].kill ();members[i].kill();
						}
					});
				}
			}
			else if (controls.justPressed('debug_1'))else   其他 if   如果 （controls.justPressed('debug_1'   “debug_1”)）
			{
				selectedSomethin = true;   selectedSomethin = true   真正的；
				MusicBeatState.switchState(new MasterEditorMenu());MusicBeatState。switchState (new   新 MasterEditorMenu ());
			}
			#end   #结束
		}
		super.update(elapsed);   super.update   更新(运行);
	}
	
	function changeItem(huh:Int = 0)函数changeItem（huh:Int = 0）
	{
		FlxG.sound   声音   声音.play(Paths.sound('scrollMenu'));FlxG.sound   声音.play   玩 (Paths.sound   声音 (scrollMenu”));
		menuItems.menuItems.members [curSelected] .animation.play(“闲置”);members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);
		curSelected += huh;   curSelected = huh；
		if （curSelected >= menuItems.length）if (curSelected >= menuItems.length)
			curSelected = 0;   curSelected = 0；
		if (curSelected < 0)   if   如果 （curSelected < 0）
			curSelected = menuItems.curSelected = menuItems。长度- 1；length - 1;
		menuItems.members[curSelected].animation.play('selected');
		menuItems.members   成员[curSelected].centerOffsets();
		menuItems.members   成员[curSelected].screenCenter(X);
		camFollow.camFollow.setPosition (menuItems.members   成员 [curSelected] .getGraphicMidpoint()方式,setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.menuItems   成员.members [curSelected .getGraphicMidpoint]()。Y -（菜单项）。《四》？menuItems。长度* 8:0))；members[curSelected].getGraphicMidpoint().y - (menuItems.length   长度 > 4 ? menuItems.length * 8 : 0));
	}
}
