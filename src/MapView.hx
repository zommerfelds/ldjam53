import h2d.Interactive;
import hxd.Rand;
import h2d.Text;
import LdtkProject.Ldtk;
import hxd.Res;
import h2d.SpriteBatch;

class MapView extends GameState {
	override function init() {
		this.scaleMode = LetterBox(512, 512);

		final sprites = new SpriteBatch(null, this);

        final rand = new Rand(0);

        var x = 100;
        var y = 100;
		for (level in Ldtk.proj.levels) {
			final e = new BatchElement(Res.galaxy.toTile());
			e.r = rand.rand() + 0.5;
			e.g = rand.rand() + 0.5;
			e.b = rand.rand() + 0.5;
            e.x = x;
            e.y = y;
			sprites.add(e);
            final label = new Text(hxd.res.DefaultFont.get(), this);
            label.text = "Galaxy " + (level.arrayIndex + 1);
            label.textAlign = Center;
            label.x = x + 32;
            label.y = y + 50;

            final i = new Interactive(64, 70, this);
            i.x = x;
            i.y = y;
            i.onClick = e -> {
                App.instance.switchState(new PlayView(level.arrayIndex));
            }
            
            x += 70;
            if (x > 350) {
                y += 100;
                x = 100;
            }
		}
	}
}
