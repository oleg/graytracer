package oned

import (
	"github.com/stretchr/testify/assert"
	"testing"
)

//todo move to separate package?
const delta = 0.000009

//todo move to test file?
func AssertEqualInDelta(t *testing.T, expected, actual Vector) {
	assert.InDeltaMapValues(t, vectorToMap(expected), vectorToMap(actual), delta)
}
func vectorToMap(v Vector) map[string]float64 {
	return map[string]float64{"X": v.X, "Y": v.Y, "Z": v.Z}
}

//todo move to test file?
func AssertColorEqualInDelta(t *testing.T, expected, actual Color) {
	assert.InDeltaMapValues(t, colorToMap(expected), colorToMap(actual), delta)
}
func colorToMap(v Color) map[string]float64 {
	return map[string]float64{"R": v.R(), "G": v.G(), "B": v.B()}
}
