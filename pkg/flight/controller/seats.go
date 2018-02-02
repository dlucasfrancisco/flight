package controller

import (
	. "github.com/flight/pkg/flight/model"
	"math"
)

type Service interface {
	AssignSeats() ([]GroupOfPassengers)
}

type distributionService struct {
	BoardingFlight BoardingFlight
	RowsDistribution []RowDistribution
}

func NewFlight(b BoardingFlight, r []RowDistribution) Service {
	return &distributionService{BoardingFlight: b, RowsDistribution: r}
}

func (d *distributionService) AssignSeats() []GroupOfPassengers {
	// Closures that order the GroupOfPassengers structure.
	numberOfPlacesAndWindowSorter := func(g1, g2 *GroupOfPassengers) bool {
		// TODO - Review this metric
		s1 := float64(len(g1.Passengers)) - 0.25 * float64(g1.WindowPreferenceCounter)
		s2 := float64(len(g2.Passengers)) - 0.25 * float64(g2.WindowPreferenceCounter)
		return -s1 < s2
	}

	By(numberOfPlacesAndWindowSorter).Sort(d.BoardingFlight.GroupsOfPassengers)


	return d.BoardingFlight.GroupsOfPassengers
}

func getGroupSuccess(groupOfPassenger GroupOfPassengers, rowDistribution RowDistribution) float64 {

	var score = 0

	if len(groupOfPassenger.Passengers) <= rowDistribution.SeatsAvailable {
		score = score + len(groupOfPassenger.Passengers)
	} else {
		score = score + ( rowDistribution.SeatsAvailable - len(groupOfPassenger.Passengers) )
	}

	percentage := ( score * 100 ) / len(groupOfPassenger.Passengers)

	return math.Abs(float64(percentage))
}
