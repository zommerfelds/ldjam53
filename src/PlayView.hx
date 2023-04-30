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

	public function new(x:Float, y:Float, rotation:Float, res:ResType, ?parent) {
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

	public function new(x:Float, y:Float, vel:Point, res:ResType, ?parent) {
		final tile = switch (res) {
			case Res1: Tiles.TILE_RES1;
			case Res2: Tiles.TILE_RES1;
			case Res3: Tiles.TILE_RES1;
			case Res4: Tiles.TILE_RES1;
		}
		super(tile);
		this.x = x;
		this.y = y;
		this.vel = vel;
		Tiles.spriteBatch.add(this);
	}
}

class BlackHole extends Object {
	public function new(x:Float, y:Float, ?parent) {
		super(parent);
		final anim = new Anim([Tiles.TILE_HOLE_FRAME1, Tiles.TILE_HOLE_FRAME2, Tiles.TILE_HOLE_FRAME3], 15, this);
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
				this.x = e2.relX;
				this.y = e2.relY;
			});
		};
	}
}

class Tiles {
	public static var TILE_RES1:Tile;
	public static var TILE_RES2:Tile;
	public static var TILE_RES3:Tile;
	public static var TILE_RES4:Tile;
	public static var TILE_PLANET:Tile;
	public static var TILE_CANNON:Tile;
	public static var TILE_HOLE_FRAME1:Tile;
	public static var TILE_HOLE_FRAME2:Tile;
	public static var TILE_HOLE_FRAME3:Tile;

	public static var spriteBatch:SpriteBatch;

	public static function init(parent) {
		final tiles = Res.tiles.toTile();
		spriteBatch = new SpriteBatch(tiles, parent);
		TILE_RES1 = tiles.sub(0, 0, 8, 8, -4, -4);
		TILE_RES2 = tiles.sub(0, 8, 8, 8, -4, -4);
		TILE_RES3 = tiles.sub(8, 0, 8, 8, -4, -4);
		TILE_RES4 = tiles.sub(8, 8, 8, 8, -4, -4);
		TILE_PLANET = tiles.sub(16, 0, 16, 16, -8, -8);
		TILE_CANNON = tiles.sub(32, 0, 16, 16, -8, -8);
		TILE_HOLE_FRAME1 = tiles.sub(48 + 32 * 0, 0, 32, 32, -16, -16);
		TILE_HOLE_FRAME2 = tiles.sub(48 + 32 * 1, 0, 32, 32, -16, -16);
		TILE_HOLE_FRAME3 = tiles.sub(48 + 32 * 2, 0, 32, 32, -16, -16);
	}
}

class PlayView extends GameState {
	static final GAME_WIDTH = 256;
	static final GAME_HEIGHT = 256;

	final cannons:Array<Cannon> = [];
	final blackHoles:Array<BlackHole> = [];
	var flyingRes:Array<FlyingRes> = [];

	override function init() {
		this.scaleMode = LetterBox(GAME_WIDTH, GAME_HEIGHT);
		new Bitmap(Tile.fromColor(0x322b2b, GAME_WIDTH, GAME_HEIGHT), this);

		Tiles.init(this);

		cannons.push(new Cannon(40, 30, 0.5, Res1, this));

		blackHoles.push(new BlackHole(100, 100, this));
		blackHoles.push(new BlackHole(90, 150, this));

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
		final MARGIN = 20;
		var removed = false;
		for (res in flyingRes) {
			res.timeAlive += dt;
			res.alpha = hxd.Math.clamp(5 - res.timeAlive * 0.5);
			final pos = new Point(res.x, res.y);
			for (blackHole in blackHoles) {
				final b = new Point(blackHole.x, blackHole.y);
				final d = b.sub(pos);
				final g = d.normalized().multiply(10000.0 / d.length());
				res.vel.x = res.vel.x + g.x * dt;
				res.vel.y = res.vel.y + g.y * dt;
			}
			res.x += res.vel.x * dt;
			res.y += res.vel.y * dt;
			if (res.x < -MARGIN || res.x > GAME_WIDTH + MARGIN || res.y < -MARGIN || res.y > GAME_HEIGHT + MARGIN || res.alpha <= 0.0) {
				res.remove();
				removed = true;
			}
		}
		if (removed) {
			flyingRes = flyingRes.filter(r -> r.batch != null);
		}
	}

	function fire(cannon:Cannon) {
		final START_VEL = 80.0;
		cannon.timeSinceLastFired = 0;
		final dir = Utils.direction(cannon.rotation);
		final pos = new Point(cannon.x, cannon.y).add(dir.multiply(8));
		flyingRes.push(new FlyingRes(pos.x, pos.y, dir.multiply(START_VEL), cannon.res, this));
	}
}
