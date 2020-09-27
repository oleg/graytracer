package figure

import (
	"github.com/oleg/graytracer/multid"
	"github.com/oleg/graytracer/oned"
)

func ViewTransform(from, to oned.Point, up oned.Vector) multid.Matrix {
	forward := to.SubtractPoint(from).Normalize()
	left := forward.Cross(up.Normalize())
	trueUp := left.Cross(forward)

	orientation := multid.Matrix{
		{left.X, left.Y, left.Z, 0},
		{trueUp.X, trueUp.Y, trueUp.Z, 0},
		{-forward.X, -forward.Y, -forward.Z, 0},
		{0, 0, 0, 1},
	}
	translation := multid.Translation(-from.X, -from.Y, -from.Z)
	return orientation.Multiply(translation)
}
