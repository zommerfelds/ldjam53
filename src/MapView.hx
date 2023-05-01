import LdtkProject.Ldtk;
import h2d.Flow;
import h2d.Interactive;
import h2d.SpriteBatch;
import h2d.Text;
import h2d.Tile;
import hxd.Rand;
import hxd.Res;
import motion.easing.Cubic;

class MapView extends GameState {
	override function init() {
		this.scaleMode = LetterBox(512, 512);

		final title = new Text(hxd.res.DefaultFont.get(), this);
		title.text = "B.H.M.D.S."; // - Black Hole Manipulation Delivery System";
		title.textAlign = Center;
		title.scale(5);
		title.x = 256;
		title.y = 50;
		final subtitle = new Text(hxd.res.DefaultFont.get(), this);
		subtitle.text = "Black Hole Manipulation Delivery System";
		subtitle.textAlign = Center;
		subtitle.scale(1.073);
		subtitle.x = 256;
		subtitle.y = 120;

		final version = new Text(hxd.res.DefaultFont.get(), this);
		version.text = "version: " + hxd.Res.version.entry.getText();
		version.textAlign = Center;
		version.scale(0.7);
		version.x = 256;
		version.y = 480;

		final unlockedLvl = App.getUnlockedLevel();
		if (unlockedLvl == 8) {
			final complete = new Text(hxd.res.DefaultFont.get(), this);
			complete.text = "Congratulations for beating the game!";
			complete.textAlign = Center;
			complete.textColor = 0x86adb9;
			complete.x = 256;
			complete.y = 410;
			Utils.tween(complete, 2.0, {scaleX: 1.2, scaleY: 1.2})
				.ease(Cubic.easeInOut)
				.reflect()
				.repeat();
		}

		{
			final f = new Flow(this);
			f.padding = 5;
			f.paddingTop = 1;
			f.backgroundTile = Tile.fromColor(0x494949);
			f.verticalAlign = Middle;
			f.horizontalAlign = Middle;
			f.enableInteractive = true;
			f.interactive.onClick = e -> {
				HerbalTeaApp.toggleFullScreen();
			}
			f.interactive.cursor = Button;
			final t = new Text(hxd.res.DefaultFont.get(), f);
			t.text = "Toggle fullscreen";
		}
		{
			final f = new Flow(this);
			f.x = 120;
			f.padding = 5;
			f.paddingTop = 1;
			f.backgroundTile = Tile.fromColor(0x494949);
			f.verticalAlign = Middle;
			f.horizontalAlign = Middle;
			f.enableInteractive = true;
			f.interactive.onClick = e -> {
				App.music.volume = 1 - App.music.volume;
			}
			f.interactive.cursor = Button;
			final t = new Text(hxd.res.DefaultFont.get(), f);
			t.text = "Toggle music";
		}

		final sprites = new SpriteBatch(null, this);

		var x = 120;
		var y = 200;
		for (level in Ldtk.proj.levels) {
			final unlocked = unlockedLvl >= level.arrayIndex;

			final e = new BatchElement(Res.galaxy.toTile());
			final rand = new Rand(level.arrayIndex);
			e.r = rand.rand() + 0.5;
			e.g = rand.rand() + 0.5;
			e.b = rand.rand() + 0.5;
			e.a = unlocked ? 1.0 : 0.4;
			e.x = x;
			e.y = y;
			sprites.add(e);
			final label = new Text(hxd.res.DefaultFont.get(), this);
			label.text = "Galaxy " + (level.arrayIndex + 1);
			label.textAlign = Center;
			label.x = x + 32;
			label.y = y + 50;
			label.alpha = unlocked ? 1.0 : 0.4;

			if (unlocked) {
				final i = new Interactive(64, 70, this);
				i.x = x;
				i.y = y;
				i.onClick = e -> {
					App.instance.switchState(new PlayView(level.arrayIndex));
				}
			}

			x += 70;
			if (x > 350) {
				y += 100;
				x = 120;
			}
		}
	}
}
