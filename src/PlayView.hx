import LdtkProject.Ldtk;
import h2d.Graphics;
import h2d.TileGroup;
import h2d.SpriteBatch;
import h2d.col.Point;
import h2d.Interactive;
import h2d.Scene;
import h2d.Object;
import h2d.Anim;
import h2d.Tile;
import hxd.Res;
import h2d.Bitmap;

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
	}
}

class FlyingRes extends BatchElement {
	public final vel:Point;
	public var timeAlive:Float = 0.0;

	public function new(x:Float, y:Float, vel:Point, res:ResType, ?parent:Object) {
		super(Tiles.resTile(res));
		this.x = x;
		this.y = y;
		this.vel = vel;
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
				this.x = e2.relX;
				this.y = e2.relY;
			});
		};
	}
}

class Planet extends Bitmap {
	public final res:ResType;

	public function new(x:Float, y:Float, res:ResType, ?parent:Object) {
		super(Tiles.TILE_PLANET, parent);
		this.x = x;
		this.y = y;
		this.res = res;

		final bubble = new Bitmap(Tiles.TILE_SPEECH_BUBBLE, this);
		bubble.x = 16;
		bubble.y = -16;

		final res = new Bitmap(Tiles.resTile(res), bubble);
		res.x = 1;
		res.y = -1;
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
	public static final GAME_WIDTH = 352;
	public static final GAME_HEIGHT = 352;

	final cannons:Array<Cannon> = [];
	final blackHoles:Array<BlackHole> = [];
	var flyingRes:Array<FlyingRes> = [];
	final planets:Array<Planet> = [];
	final nebulas:Array<Nebula> = [];
	final ldtkLevel:LdtkProject.LdtkProject_Level;

	final level:Int;

	public function new(level:Int) {
		super();
		this.level = level;
		this.ldtkLevel = Ldtk.proj.levels[level];
	}

	override function init() {
		this.scaleMode = LetterBox(GAME_WIDTH, GAME_HEIGHT);
		new Bitmap(Tile.fromColor(0x322b2b, GAME_WIDTH, GAME_HEIGHT), this);

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

		final letterBox = new Graphics(this);
		letterBox.beginFill(0x000000);
		letterBox.drawRect(0, -100, GAME_WIDTH, 100);
		letterBox.drawRect(0, GAME_HEIGHT, GAME_WIDTH, GAME_HEIGHT + 100);
		letterBox.drawRect(-100, 0, 100, GAME_HEIGHT);
		letterBox.drawRect(GAME_WIDTH, 0, 100, GAME_HEIGHT);

		addEventListener(onEvent);
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EPush:
			default:
		}
	}

	override function update(dt:Float) {
		updateCannons(dt);
		updateFlyingRes(dt);
		updateNebula(dt);
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
