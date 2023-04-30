import h3d.shader.ScreenShader;

class StarsShader extends ScreenShader {
	static var SRC = {
		// Based on https://www.shadertoy.com/view/flcSz2
		@param var texture:Sampler2D;
		@param var time:Float;
		function rand(st:Vec2):Float {
			final r = fract(sin(st) * 2.7644437);
			return fract(r.y * 276.44437 + r.x);
		}
		function p(st:Vec2):Float {
			final r = rand(floor(st));
			return 0.01 + smoothstep(0.995, 1.0, r) * max(0.0, sin(r * 34433.0 + time));
		}
		function avg(st:Vec2, a:Float):Vec3 {
			final A = vec2(0.0, a);
			final COLOR = vec3(0.1, 0.0, 0.2);
			return COLOR * (p(st) + p(st + A) + p(st + A.yx) + p(st - A) + p(st - A.yx));
		}
		function stars(st:Vec2):Vec3 {
			final color = vec3(0.0);
			var i = 5;
			while (i > 0) {
				color += mix(color, avg(st, i), 1.5);
				i--;
			}
			return color + p(st);
		}
		function fragment() {
			final st = output.position.xy;
			st *= 512.0 / 2;

			pixelColor = vec4(stars(st), 1.0);
		}
	}
}
