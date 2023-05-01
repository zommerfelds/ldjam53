import LdtkProject.Ldtk;
import h2d.Anim;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Graphics;
import h2d.Interactive;
import h2d.Object;
import h2d.SpriteBatch;
import h2d.Text;
import h2d.Tile;
import h2d.col.Point;
import h2d.filter.Glow;
import h2d.filter.Shader;
import haxe.Timer;
import hxd.Rand;
import hxd.Res;
import motion.easing.Sine;

enum ResType {
	Res1;
	Res2;
	Res3;
	Res4;
}

class Cannon extends Bitmap {
	public var timeSinceLastFired:Float = 0.0;
	public final res:ResType;

	public function new(x:Float, y:Float, rotation:Float, res:ResType, ?parent:Object) {
		super(Tiles.TILE_CANNON, parent);
		this.x = x;
		this.y = y;
		this.rotation = rotation;
		this.res = res;
		filter = new Glow(0xffffff, 1, 5, 0.6, 1, true);
	}
}

class FlyingRes extends BatchElement {
	public final vel:Point;
	public var timeAlive:Float = 0.0;
	public final res:ResType;

	public function new(x:Float, y:Float, vel:Point, res:ResType, ?parent:Object) {
		super(Tiles.resTile(res));
		this.x = x;
		this.y = y;
		this.vel = vel;
		this.res = res;
		Tiles.spriteBatch.add(this);
	}
}

class BlackHole extends Object {
	public function new(x:Float, y:Float, ?parent:Object) {
		super(parent);
		new Anim([Tiles.TILE_HOLE_FRAME1, Tiles.TILE_HOLE_FRAME2, Tiles.TILE_HOLE_FRAME3], 15, this);
		this.x = x;
		this.y = y;

		final interactive = new Interactive(32, 32, this);
		interactive.x = -16;
		interactive.y = -16;
		interactive.onPush = e -> {
			getScene().startCapture(e2 -> {
				if (e2.kind == ERelease) {
					getScene().stopCapture();
					return;
				}
				if (e2.relX < 0 || e2.relX > PlayView.GAME_WIDTH || e2.relY < 0 || e2.relY > PlayView.GAME_HEIGHT)
					return;
				final point = new Point(e2.relX, e2.relY);
				for (p in PlayView.planets) {
					if (point.distance(Utils.toPoint(p)) < 20) {
						return;
					}
				}
				for (c in PlayView.cannons) {
					if (point.distance(Utils.toPoint(c)) < 20) {
						return;
					}
				}
				this.x = e2.relX;
				this.y = e2.relY;
			});
		};
		filter = new Glow(0xa5baec, 1, 5, 0.6, 1, true);
	}
}

class Planet extends Bitmap {
	public final res:ResType;
	public var deliveryProgress = 0.0;

	public function new(x:Float, y:Float, res:ResType, ?parent:Object) {
		super(Tiles.TILE_PLANET, parent);
		this.x = x;
		this.y = y;
		this.res = res;

		final bubble = new Bitmap(Tiles.TILE_SPEECH_BUBBLE, this);
		bubble.x = 8;
		bubble.y = -8;

		final res = new Bitmap(Tiles.resTile(res), bubble);
		res.x = 1;
		res.y = -1;

		filter = new Glow(0x69ff96, 1, 5, 0.6, 1, true);

		bubble.scale(0);
		function tween() {
			return Utils.tween(bubble, 0.7, {
				x: 16,
				y: -16,
				scaleX: 1,
				scaleY: 1
			}, false).ease(Sine.easeIn).onComplete(() -> {
				Utils.tween(bubble, 0.7, {
					x: 8,
					y: -8,
					scaleX: 0,
					scaleY: 0
				}, false)
					.ease(Sine.easeIn)
					.delay(2.0)
					.onComplete(() -> tween().delay(2.0));
			});
		}
		tween();
	}
}

class Nebula extends BatchElement {
	public function new(x:Float, y:Float, ?parent:Object) {
		super(Tiles.randNebula());
		this.x = x;
		this.y = y;
		this.rotation = Math.random() * Math.PI * 2;
		Tiles.spriteBatch.add(this);

		final backgound = new BatchElement(t);
		backgound.x = x;
		backgound.y = y;
		backgound.scale = 1.2;
		backgound.rotation = Math.random() * Math.PI * 2;
		backgound.alpha = 0.3;
		Tiles.spriteBatch.add(backgound);
	}
}

class Tiles {
	public static var TILE_RES1:Tile;
	public static var TILE_RES2:Tile;
	public static var TILE_RES3:Tile;
	public static var TILE_RES4:Tile;
	public static var TILE_PLANET:Tile;
	public static var TILE_SPEECH_BUBBLE:Tile;
	public static var TILE_CANNON:Tile;
	public static var TILE_HOLE_FRAME1:Tile;
	public static var TILE_HOLE_FRAME2:Tile;
	public static var TILE_HOLE_FRAME3:Tile;
	public static var TILE_NEBULA1:Tile;
	public static var TILE_NEBULA2:Tile;

	public static var spriteBatch:SpriteBatch;

	public static function init(parent) {
		final tiles = Res.tiles.toTile();
		spriteBatch = new SpriteBatch(tiles, parent);
		spriteBatch.hasRotationScale = true;

		TILE_RES1 = tiles.sub(0, 0, 8, 8, -4, -4);
		TILE_RES2 = tiles.sub(0, 8, 8, 8, -4, -4);
		TILE_RES3 = tiles.sub(8, 0, 8, 8, -4, -4);
		TILE_RES4 = tiles.sub(8, 8, 8, 8, -4, -4);
		TILE_PLANET = tiles.sub(16, 0, 16, 16, -8, -8);
		TILE_SPEECH_BUBBLE = tiles.sub(0, 16, 16, 16, -8, -8);
		TILE_CANNON = tiles.sub(32, 0, 16, 16, -8, -8);
		TILE_HOLE_FRAME1 = tiles.sub(48 + 32 * 0, 0, 32, 32, -16, -16);
		TILE_HOLE_FRAME2 = tiles.sub(48 + 32 * 1, 0, 32, 32, -16, -16);
		TILE_HOLE_FRAME3 = tiles.sub(48 + 32 * 2, 0, 32, 32, -16, -16);
		TILE_NEBULA1 = tiles.sub(16, 16, 16, 16, -8, -8);
		TILE_NEBULA2 = tiles.sub(32, 16, 16, 16, -8, -8);
	}

	public static function resTile(res:ResType):Tile {
		return switch (res) {
			case Res1: Tiles.TILE_RES1;
			case Res2: Tiles.TILE_RES2;
			case Res3: Tiles.TILE_RES3;
			case Res4: Tiles.TILE_RES4;
		};
	}

	public static function randNebula():Tile {
		final tile = [TILE_NEBULA1, TILE_NEBULA2][Std.random(2)].clone();
		return tile;
	}
}

class PlayView extends GameState {
	public static final GAME_WIDTH = 512;
	public static final GAME_HEIGHT = 512;

	public static final cannons:Array<Cannon> = [];
	final blackHoles:Array<BlackHole> = [];
	var flyingRes:Array<FlyingRes> = [];
	public static final planets:Array<Planet> = [];
	final nebulas:Array<Nebula> = [];
	final ldtkLevel:LdtkProject.LdtkProject_Level;
	final starsShader = new StarsShader();

	final level:Int;
	var progressText:Text;
	var progressFlow:Flow;
	var complete = false;

	public function new(level:Int) {
		super();
		this.level = level;
		this.ldtkLevel = Ldtk.proj.levels[level];
	}

	override function init() {
		this.scaleMode = LetterBox(GAME_WIDTH, GAME_HEIGHT);
		final background = new Bitmap(Tile.fromColor(0x000000, GAME_WIDTH, GAME_HEIGHT), this);

		final rand = new Rand(level);
		starsShader.color.set(rand.rand() * 0.4, rand.rand() * 0.4, rand.rand() * 0.4);
		background.filter = new Shader(starsShader);

		Tiles.init(this);

		for (cannon in ldtkLevel.l_Entities.all_Cannon) {
			cannons.push(new Cannon(cannon.pixelX, cannon.pixelY, cannon.f_Angle, cannon.f_ResType, this));
		}
		for (blackHole in ldtkLevel.l_Entities.all_BlackHole) {
			blackHoles.push(new BlackHole(blackHole.pixelX, blackHole.pixelY, this));
		}
		for (planet in ldtkLevel.l_Entities.all_Planet) {
			planets.push(new Planet(planet.pixelX, planet.pixelY, planet.f_ResType, this));
		}

		for (nebula in ldtkLevel.l_IntGrid.autoTiles) {
			nebulas.push(new Nebula(nebula.renderX + 8, nebula.renderY + 8, this));
		}

		{
			final f = new Flow(this);
			f.padding = 5;
			f.paddingTop = 1;
			f.backgroundTile = Tile.fromColor(0x494949);
			f.verticalAlign = Middle;
			f.horizontalAlign = Middle;
			f.enableInteractive = true;
			f.interactive.cursor = Button;
			f.interactive.onClick = e -> {
				App.instance.switchState(new MapView());
			}
			final t = new Text(hxd.res.DefaultFont.get(), f);
			t.text = "Back";
		}
		{
			progressFlow = new Flow(this);
			progressFlow.x = 60;
			progressFlow.padding = 5;
			progressFlow.paddingTop = 1;
			progressFlow.backgroundTile = Tile.fromColor(0x334230);
			progressFlow.verticalAlign = Middle;
			progressFlow.horizontalAlign = Middle;
			progressText = new Text(hxd.res.DefaultFont.get(), progressFlow);
		}

		if (level == 0) {
			final tut = new Object(this);
			tut.alpha = 0.0;

			final t1 = new Text(hxd.res.DefaultFont.get(), tut);
			t1.text = "Click to move this black hole";
			t1.x = 300;
			t1.y = 100;
			t1.textAlign = MultilineCenter;
			t1.maxWidth = 120;

			final gr = new Graphics(tut);
			gr.lineStyle(1, 0xffffff);
			gr.moveTo(350, 140);
			gr.lineTo(348, 175);

			Utils.tween(tut, 2.0, {alpha: 1.0}).delay(4);

			final initialPos = Utils.toPoint(blackHoles[0]);

			var f = null;
			f = new FuncObject(() -> {
				if (!Utils.toPoint(blackHoles[0]).equals(initialPos)) {
					f.remove();
					Utils.tween(tut, 2.0, {alpha: 0.0});

					final tut2 = new Object(this);
					tut2.alpha = 0.0;

					final t = new Text(hxd.res.DefaultFont.get(), tut2);
					t.text = "Adjust the trajectory until all red packets can reach the planet";
					t.x = 80;
					t.y = 400;
					t.textAlign = MultilineCenter;
					t.maxWidth = 150;

					final gr = new Graphics(t);
					gr.lineStyle(1, 0xffffff);
					gr.moveTo(75, -2);
					gr.lineTo(150, -130);

					Utils.tween(tut2, 2.0, {alpha: 1.0}).delay(1);
				}
			}, gr);
		}

		// TODO: use Mask instead https://heaps.io/samples/mask.html
		final letterBox = new Graphics(this);
		letterBox.beginFill(0x000000);
		letterBox.drawRect(0, -100, GAME_WIDTH, 100);
		letterBox.drawRect(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT + 100);
		letterBox.drawRect(-100, 0, 100, GAME_HEIGHT);
		letterBox.drawRect(GAME_WIDTH, 0, 100, GAME_HEIGHT);
	}

	override function update(dt:Float) {
		updateCannons(dt);
		updateFlyingRes(dt);
		updateNebula(dt);
		starsShader.time = Timer.stamp();
		var totalProgress = 0.0;
		for (planet in planets) {
			planet.deliveryProgress = hxd.Math.clamp(planet.deliveryProgress - dt * 0.1, 0.0, 1.1);
			totalProgress += hxd.Math.clamp(planet.deliveryProgress, 0, 1) / planets.length;
		}

		if (!complete) {
			if (totalProgress > 0.999) {
				progressText.text = "Delivery progress: 100% - Mission complete";
				complete = true;
				if (App.getUnlockedLevel() == level) {
					App.setUnlockedLevel(level + 1);
				}

				Utils.tween(progressFlow, 0.5, {scaleX: 1.2, scaleY: 1.2, x: progressFlow.x - 10})
					.ease(Sine.easeInOut)
					.reflect()
					.repeat();
			} else {
				progressText.text = "Delivery progress: " + Math.floor(totalProgress * 100) + "%";
			}
		}
	}

	function updateCannons(dt:Float) {
		for (cannon in cannons) {
			cannon.timeSinceLastFired += dt;
			if (cannon.timeSinceLastFired > 0.3) {
				fire(cannon);
			}
		}
	}

	function updateFlyingRes(dt:Float) {
		var atLeastOneRemoved = false;
		for (res in flyingRes) {
			res.timeAlive += dt;
			res.alpha = hxd.Math.clamp(6 - res.timeAlive * 0.5);
			final pos = Utils.toPoint(res);
			for (blackHole in blackHoles) {
				final b = Utils.toPoint(blackHole);
				final d = b.sub(pos);
				final g = d.normalized().multiply(10000.0 / d.length());
				res.vel.x = res.vel.x + g.x * dt;
				res.vel.y = res.vel.y + g.y * dt;
			}
			res.x += res.vel.x * dt;
			res.y += res.vel.y * dt;
			if (checkCollisions(res) || res.alpha <= 0.0) {
				res.remove();
				atLeastOneRemoved = true;
				continue;
			}
		}
		if (atLeastOneRemoved) {
			flyingRes = flyingRes.filter(r -> r.batch != null);
		}
	}

	function checkCollisions(res:FlyingRes) {
		final MARGIN = 20;
		if (res.x < -MARGIN || res.x > GAME_WIDTH + MARGIN || res.y < -MARGIN || res.y > GAME_HEIGHT + MARGIN) {
			return true;
		}
		for (hole in blackHoles) {
			if (Utils.toPoint(hole).distance(Utils.toPoint(res)) < 12) {
				return true;
			}
		}
		for (cannon in cannons) {
			if (Utils.toPoint(cannon).distance(Utils.toPoint(res)) < 11) {
				return true;
			}
		}
		for (nebula in nebulas) {
			if (Utils.toPoint(nebula).distance(Utils.toPoint(res)) < 12) {
				return true;
			}
		}
		for (planet in planets) {
			if (Utils.toPoint(planet).distance(Utils.toPoint(res)) < 10) {
				if (planet.res == res.res) {
					planet.deliveryProgress += 0.05;
				}
				return true;
			}
		}
		return false;
	}

	function fire(cannon:Cannon) {
		final START_VEL = 80.0;
		cannon.timeSinceLastFired = 0;
		final dir = Utils.direction(cannon.rotation);
		final pos = new Point(cannon.x, cannon.y).add(dir.multiply(10));
		flyingRes.push(new FlyingRes(pos.x, pos.y, dir.multiply(START_VEL), cannon.res, this));
	}

	function updateNebula(dt:Float) {
		for (nebula in nebulas) {
			nebula.alpha = hxd.Math.clamp(nebula.alpha + 0.05 * (Math.random() - 0.5), 0.5, 1.0);
		}
	}
}
