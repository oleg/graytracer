package ddddf

import (
	"github.com/oleg/raytracer-go/geom"
	"github.com/oleg/raytracer-go/mat"
	"math"
)

type Plane struct {
	mat.PhysicalObject
}

//todo remove
func MakePlane() Plane {
	return Plane{mat.NewPhysicalObject(geom.IdentityMatrix(), mat.DefaultMaterial())}
}

//todo remove?
func NewPlane(transform *geom.Matrix, material *mat.Material) Plane {
	return Plane{mat.NewPhysicalObject(transform, material)}
}

func (p Plane) Intersect(ray Ray) Inters {
	if math.Abs(ray.Direction.Y) < geom.Delta {
		return nil //is it ok or Inters{}?
	}
	t := -ray.Origin.Y / ray.Direction.Y
	return Inters{Inter{t, p}}
}

func (p Plane) NormalAt(geom.Point) geom.Vector {
	return geom.Vector{X: 0, Y: 1, Z: 0}
}
