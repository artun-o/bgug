import 'dart:ui';
import 'dart:math' as math;

import 'package:flame/components/component.dart';
import 'package:flame/components/resizable.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import '../data.dart';

import '../util.dart';
import '../constants.dart';
import '../mixins/has_game_ref.dart';

class Hud extends SpriteComponent with HasGameRef, Resizable {
  static const SRC_WIDTH = 220.0;
  static const SRC_HEIGHT = 32.0;

  static const SCALE = 2;

  static const WIDTH = SCALE * SRC_WIDTH;
  static const HEIGHT = SCALE * SRC_HEIGHT;

  static final bgPaint = new Paint()..color = const Color(0xFF626262);

  Rect bgRect;
  double gaugeStrength, clock;
  double meterPerPixel = 1.0;
  double maxDistance = 0.0;

  double get maxDistanceInMeters => maxDistance * this.meterPerPixel;

  Hud() : super.fromSprite(WIDTH, HEIGHT, new Sprite('hud_bg.png', width: SRC_WIDTH, height: SRC_HEIGHT));

  Position get gemPosition => new Position(x + SCALE * 141, y + SCALE * 7);

  @override
  void update(double t) {
    super.update(t);
    if (clock != null) {
      clock += t;
      double diff = clock;
      double max = Data.options.maxHoldJumpMillis.toDouble() / 1000.0;
      gaugeStrength = math.min(diff, max) / max;
    } else {
      gaugeStrength = null;
    }
  }

  @override
  void resize(Size size) {
    this.x = (size.width - WIDTH) / 2;
    this.y = 4.0;
    this.bgRect = new Rect.fromLTWH(0.0, 0.0, size.width, HEIGHT);
    this.meterPerPixel = .75 / size_tenth(size);
  }

  @override
  void render(Canvas canvas) {
    if (bgRect != null) {
      canvas.drawRect(bgRect, bgPaint);

      if (sprite.loaded()) {
        canvas.save();
        prepareCanvas(canvas);
        sprite.render(canvas, width, height);
        renderGems(canvas);
        renderCoins(canvas);
        renderDistance(canvas);
        renderGauge(canvas);
        canvas.restore();
      }
    }
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 1;

  void startGauge() {
    this.clock = 0;
  }

  void clearGauge() {
    this.clock = null;
  }

  void renderDistance(Canvas canvas) {
    const XI = SCALE * 78.0;
    const XF = SCALE * 123.0;
    const SIZE = XF - XI;
    const Y = SCALE * 10.0;
    const where = Offset(XI, Y);
    if (gameRef.player.x > maxDistance) {
      maxDistance = gameRef.player.x;
    }
    String dist = maxDistanceInMeters.toStringAsFixed(1);
    Text.render(canvas, '$dist m', where, fn: Text.center(SIZE));
  }

  void renderGems(Canvas canvas) {
    const where = Offset(SCALE * 161.0, SCALE * 10.0);
    Text.render(canvas, gameRef.points.toString(), where);
  }

  void renderCoins(Canvas canvas) {
    const where = Offset(SCALE * 200.0, SCALE * 10.0);
    Text.render(canvas, gameRef.currentCoins.toString(), where);
  }

  void renderGauge(Canvas canvas) {
    if (gaugeStrength == null) {
      return;
    }
    const COLORS = [Color(0XFF54A286), Color(0XFF10D594)];
    const MAX = 62;
    const GAUGE_X = 9;
    const GAUGE_Y = 17;
    const GAUGE_HEIGHT = 7;
    const STEP = 2;
    double s = SCALE.toDouble();
    int sizePxs = (gaugeStrength * MAX).round();
    for (int i = GAUGE_X, j = 0; i < sizePxs; i += STEP, j++) {
      Color color = COLORS[j % 2];
      canvas.drawRect(Rect.fromLTWH(s * i, s * GAUGE_Y, s * STEP, s * GAUGE_HEIGHT), new Paint()..color = color);
    }
  }
}