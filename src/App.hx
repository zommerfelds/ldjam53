import LdtkProject.Ldtk;

class App extends HerbalTeaApp {
	public static var instance:App;

	static function main() {
		instance = new App();
	}

	override function onload() {
		Ldtk.validate();

		final params = new js.html.URLSearchParams(js.Browser.window.location.search);
		final view = switch (params.get("start")) {
			case "play":
				final levelIndex = params.get("level") == null ? 0 : Std.parseInt(params.get("level"));
				new PlayView(levelIndex);
			case "map" | null:
				new MapView();
			case x: throw 'invavid "start" query param "$x"';
		}

		switchState(view);
	}

	// TODO: move this to HerbalTeaApp
	public static function getUnlockedLevel():Int {
		return hxd.Save.load({unlockedLevel: 0}).unlockedLevel;
	}

	public static function setUnlockedLevel(level:Int) {
		hxd.Save.save({unlockedLevel: level});
	}
}
