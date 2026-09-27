precision highp float;

/** @resolution */
uniform vec2 u_resolution;

/** @mouse */
uniform vec2 u_mouse;

/**
 * Shape: 0 circle, 1 square, 2 triangle, 3 hexagon, 4 diamond, 5 cross,
 * 6 star, 7 ring, 8 stripes, 9 checkerboard, 10 zigzag.
 * @label Shape
 * @default 0
 * @range 0, 10
 */
uniform int u_shape;

/**
 * Size of each tile, in pixels.
 * @label Tile Size
 * @default 64
 * @range 4, 200
 */
uniform float u_cellSize;

/**
 * How much of each tile the shape fills.
 * @label Shape Fill
 * @default 0.7
 * @range 0, 1
 */
uniform float u_shapeFill;

/**
 * Outline thickness. 0 = solid filled shape.
 * @label Outline Width
 * @default 0
 * @range 0, 20
 */
uniform float u_strokeWidth;

/**
 * Rotation of the whole pattern, in degrees.
 * @label Rotation
 * @default 0
 * @range 0, 360
 */
uniform float u_rotation;

/**
 * Offset every other row for a brick layout. 0 = off, 1 = on.
 * @label Stagger Rows
 * @default 0
 * @range 0, 1
 */
uniform int u_stagger;

/**
 * Spacing between shapes. 0 = shapes touch.
 * @label Spacing
 * @default 0.1
 * @range 0, 0.9
 */
uniform float u_gap;

/**
 * @label Background Color
 * @color
 * @default #1a1a2e
 */
uniform vec3 u_background;

/**
 * @label Shape Color
 * @color
 * @default #e2e2e2
 */
uniform vec3 u_shapeColor;

/**
 * How far the mouse glow reaches, in pixels. 0 = off.
 * @label Glow Radius
 * @default 0
 * @range 0, 500
 */
uniform float u_highlightRadius;

/**
 * How much bigger shapes get near the mouse.
 * @label Hover Scale
 * @default 1.8
 * @range 1, 5
 */
uniform float u_highlightSize;

/**
 * How far shapes are pushed away from the mouse, in pixels.
 * @label Repulsion
 * @default 0
 * @range 0, 200
 */
uniform float u_repulsion;

/**
 * @label Glow Color
 * @color
 * @default #ff5e8a
 */
uniform vec3 u_highlightColor;

#define PI 3.14159265359

float sdCircle(vec2 p, float r) {
  return length(p) - r;
}

float sdBox(vec2 p, float r) {
  vec2 d = abs(p) - vec2(r);
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

float sdTriangle(vec2 p, float r) {
  p.y -= r * 0.15;
  float k = sqrt(3.0);
  p.x = abs(p.x) - r;
  p.y = p.y + r / k;
  if (p.x + k * p.y > 0.0) {
    p = vec2(p.x - k * p.y, -k * p.x - p.y) / 2.0;
  }
  p.x -= clamp(p.x, -2.0 * r, 0.0);
  return -length(p) * sign(p.y);
}

float sdHexagon(vec2 p, float r) {
  vec2 q = abs(p);
  return max(dot(q, normalize(vec2(1.0, sqrt(3.0)))), q.x) - r;
}

float sdDiamond(vec2 p, float r) {
  vec2 q = abs(p);
  return (q.x + q.y - r * 1.41421) / 1.41421;
}

float sdCross(vec2 p, float r) {
  vec2 q = abs(p);
  float arm = r * 0.3;
  vec2 d1 = q - vec2(r, arm);
  vec2 d2 = q - vec2(arm, r);
  float b1 = length(max(d1, 0.0)) + min(max(d1.x, d1.y), 0.0);
  float b2 = length(max(d2, 0.0)) + min(max(d2.x, d2.y), 0.0);
  return min(b1, b2);
}

float sdStar(vec2 p, float r) {
  float an = PI / 5.0;
  float en = PI / 2.6;
  vec2 acs = vec2(cos(an), sin(an));
  vec2 ecs = vec2(cos(en), sin(en));
  float bn = mod(atan(p.x, p.y), 2.0 * an) - an;
  p = length(p) * vec2(cos(bn), abs(sin(bn)));
  p -= r * acs;
  p += ecs * clamp(-dot(p, ecs), 0.0, r * acs.y / ecs.y);
  return length(p) * sign(p.x);
}

float sdRing(vec2 p, float r) {
  return abs(length(p) - r * 0.7) - r * 0.2;
}

float sdf(vec2 p, float r) {
  if (u_shape == 1) return sdBox(p, r);
  if (u_shape == 2) return sdTriangle(p, r);
  if (u_shape == 3) return sdHexagon(p, r);
  if (u_shape == 4) return sdDiamond(p, r);
  if (u_shape == 5) return sdCross(p, r);
  if (u_shape == 6) return sdStar(p, r);
  if (u_shape == 7) return sdRing(p, r);
  return sdCircle(p, r);
}

vec2 rotatePoint(vec2 p) {
  float a = radians(u_rotation);
  float ca = cos(a);
  float sa = sin(a);
  vec2 c = u_resolution * 0.5;
  p -= c;
  return vec2(p.x * ca + p.y * sa, -p.x * sa + p.y * ca) + c;
}

vec2 cellCenter(vec2 cellId, float cell) {
  vec2 center = (cellId + 0.5) * cell;
  if (u_stagger != 0 && mod(cellId.y, 2.0) > 0.5) {
    center.x += cell * 0.5;
  }
  return center;
}

float fill(float d) {
  if (u_strokeWidth > 0.0) {
    return 1.0 - smoothstep(u_strokeWidth * 0.5 - 1.0, u_strokeWidth * 0.5 + 1.0, abs(d));
  }
  return 1.0 - smoothstep(-1.0, 1.0, d);
}

vec3 paint(float coverage, float glow) {
  return mix(u_background, mix(u_shapeColor, u_highlightColor, glow), coverage);
}

float pointerGlow() {
  if (u_highlightRadius <= 0.0) {
    return 0.0;
  }
  return 1.0 - smoothstep(0.0, u_highlightRadius, distance(gl_FragCoord.xy, u_mouse));
}

void main() {
  float cell = max(u_cellSize, 4.0);
  vec2 pos = rotatePoint(gl_FragCoord.xy);
  float thickness = clamp(u_shapeFill, 0.01, 1.0) * (1.0 - clamp(u_gap, 0.0, 0.9));

  if (u_shape == 8 || u_shape == 10) {
    float span = u_shape == 10 ? cell * 2.0 : cell;
    float wave = u_shape == 10 ? pos.y + sin(pos.x * PI / cell) * cell * 0.5 : pos.y;
    float f = fract(wave / span);
    float edge = 1.0 / span;
    float lo = 0.5 - thickness * 0.5;
    float hi = 0.5 + thickness * 0.5;
    float stripe = smoothstep(lo - edge, lo, f) - smoothstep(hi, hi + edge, f);
    if (u_shape == 8 && u_strokeWidth > 0.0) {
      float sw = u_strokeWidth / span;
      stripe -= smoothstep(lo + sw - edge, lo + sw, f) - smoothstep(hi - sw, hi - sw + edge, f);
    }
    gl_FragColor = vec4(paint(stripe, pointerGlow()), 1.0);
    return;
  }

  if (u_shape == 9) {
    vec2 id = floor(pos / cell);
    gl_FragColor = vec4(paint(mod(id.x + id.y, 2.0), pointerGlow()), 1.0);
    return;
  }

  float radius = cell * 0.5 * thickness;

  if (u_highlightRadius > 0.0) {
    vec2 mousePos = rotatePoint(u_mouse);
    vec2 baseCell = floor(pos / cell);
    float bestShape = 0.0;
    float bestGlow = 0.0;
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        vec2 center = cellCenter(baseCell + vec2(float(dx), float(dy)), cell);
        vec2 toMouse = center - mousePos;
        float falloff = 1.0 - smoothstep(0.0, u_highlightRadius, length(toMouse));
        vec2 displaced = center + toMouse * (u_repulsion / u_highlightRadius) * falloff;
        float g = 1.0 - smoothstep(0.0, u_highlightRadius, distance(displaced, mousePos));
        float s = fill(sdf(pos - displaced, radius * mix(1.0, u_highlightSize, g)));
        if (s > bestShape) {
          bestShape = s;
          bestGlow = g;
        }
      }
    }
    gl_FragColor = vec4(paint(bestShape, bestGlow), 1.0);
    return;
  }

  vec2 cellCoord = pos / cell;
  if (u_stagger != 0 && mod(floor(cellCoord.y), 2.0) > 0.5) {
    cellCoord.x -= 0.5;
  }
  vec2 p = (fract(cellCoord) - 0.5) * cell;
  gl_FragColor = vec4(paint(fill(sdf(p, radius)), 0.0), 1.0);
}
