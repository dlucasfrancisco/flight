package model

import (
	"sort"
	"fmt"
)

// Input source struct which represents the input file information
type BoardingFlight struct {
	Seats int
	Rows int
	GroupsOfPassengers[] GroupOfPassengers
}

func (p Passenger) String() string {
	return fmt.Sprintf("%v", p.Id)
}

// Passengers struct which represent a person with certain requirements
type Passenger struct{
	WindowPreference bool
	Id string
}

// GroupsOfPassengers struct which represents a group of passengers (Usually a row)
type GroupOfPassengers struct{
	Passengers []Passenger
	WindowPreferenceCounter int
}

func (g GroupOfPassengers) String() string {
	return fmt.Sprintf("%v", g.Passengers)
}

// By is the type of a "less" function that defines the ordering of its GroupOfPassengers arguments.
type By func(g1, g2 *GroupOfPassengers) bool

// Sort is a method on the function type, By, that sorts the argument slice according to the function.
func (by By) Sort(groupOfPassengers []GroupOfPassengers) {
	ps := &groupOfPassengersSorter{
		groupOfPassengers: groupOfPassengers,
		by:      by, // The Sort method's receiver is the function (closure) that defines the sort order.
	}
	sort.Sort(ps)
}

// groupOfPassengersSorter joins a By function and a slice of GroupOfPassengers to be sorted.
type groupOfPassengersSorter struct {
	groupOfPassengers []GroupOfPassengers
	by      func(p1, p2 *GroupOfPassengers) bool // Closure used in the Less method.
}

// Len is part of sort.Interface.
func (s *groupOfPassengersSorter) Len() int {
	return len(s.groupOfPassengers)
}

// Swap is part of sort.Interface.
func (s *groupOfPassengersSorter) Swap(i, j int) {
	s.groupOfPassengers[i], s.groupOfPassengers[j] = s.groupOfPassengers[j], s.groupOfPassengers[i]
}

// Less is part of sort.Interface. It is implemented by calling the "by" closure in the sorter.
func (s *groupOfPassengersSorter) Less(i, j int) bool {
	return s.by(&s.groupOfPassengers[i], &s.groupOfPassengers[j])
}


///////

// Output source struct which represents the output file information
type RowDistribution struct {
	SeatsAvailable int
	Passengers []Passenger
}

func NewRowDistribution(seatsAvailable int) RowDistribution {
	return RowDistribution{ SeatsAvailable: seatsAvailable }
}