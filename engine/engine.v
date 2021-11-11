module engine

import gg

pub struct Point2D {
pub mut:
	x f32
	y f32
}

pub struct Vec2D {
pub mut:
	x f32
	y f32
}

pub struct Rect {
	gg.Rect
}

pub fn (r Rect) to_bounding() (Point2D, Point2D) {
	return Point2D{r.x, r.y}, Point2D{r.x + r.width, r.y + r.height}
}

pub fn (r Rect) overlaps(test Rect) bool {
	l1, r1 := r.to_bounding()
	l2, r2 := test.to_bounding()

	if l1.x == r1.x || l1.y == r1.y || l2.x == r2.x || l2.y == r2.y {
		return false
	}

	if l1.x <= r2.x && r1.x >= l2.x && l1.y <= r2.y && r1.y >= l2.y {
		return true
	}
	return false
}

pub fn new_rect(x f32, y f32, w f32, h f32) Rect {
	return Rect{
		x: x
		y: y
		width: w
		height: h
	}
}

pub type BoundingShape = Rect | gg.Rect

pub fn overlap(s1 BoundingShape, s2 BoundingShape) bool {
	match s1 {
		Rect {
			match s2 {
				Rect {
					return s1.overlaps(s2)
				}
				else {
					return false
				}
			}
		}
		else {
			return false
		}
	}
	return false
}

pub interface ObjectCollider {
	bounding_shape BoundingShape
	is_collider() bool
}

pub fn (o ObjectCollider) bounds() BoundingShape {
	return o.bounding_shape
}

pub struct GameObjectEmbed {
pub:
	id int
pub mut:
	forces   []Vec2D
	gg       &gg.Context
	impulse  Vec2D
	position Point2D
	size     gg.Size
}

pub interface GameObject {
	id int
	draw()
mut:
	gg &gg.Context
	forces []Vec2D
	position Point2D
	size gg.Size
	update()
}

pub fn (mut g GameObject) impulse(impulse Vec2D) {
	g.forces << impulse
}

pub fn (mut g GameObject) rmv_impulse(impulse Vec2D, n int) {
	mut ndxs := []int{cap: 10}
	for i, val in g.forces {
		if val.x == impulse.x && val.y == impulse.y {
			ndxs << i
		}

		if ndxs.len == n {
			break
		}
	}

	for i in ndxs {
		g.forces.delete(i)
	}
}

pub fn (mut g GameObject) clear_forces() {
	g.forces.clear()
}

pub fn (g GameObject) net_impulse() Vec2D {
	mut net_impulse := Vec2D{}

	for force in g.forces {
		net_impulse.x += force.x
		net_impulse.y += force.y
	}

	return net_impulse
}

pub fn (g GameObject) str() string {
	impulse := g.net_impulse()
	return 'GmObj #$g.id: imp($impulse.x,$impulse.y) pos($g.position.x,$g.position.y) size($g.size.width, $g.size.height)'
}

pub interface Kinematic {
	GameObject
	ObjectCollider
}
