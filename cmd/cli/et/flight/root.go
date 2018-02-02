package flight

import (
	"github.com/spf13/cobra"
	"syscall"
	"github.com/spf13/viper"
	"errors"
	"fmt"
	"encoding/csv"
	"io"
	"os"
	"strconv"
	"github.com/flight/pkg/flight/model"
	"strings"
	"regexp"
)

var Cmd = &cobra.Command{
	Use:   "distribution",
	Short: "Manage clusters",
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
		syscall.Exit(1)
	},
}

func verifyRequiredFlags(flags ...string) error {
	for _, flag := range flags {
		if viper.GetString(flag) == "" {
			return errors.New(flag + " flag is required")
		}
	}
	return nil
}

// parseRequestFile transform input file into two dimensional array
func parseRequestFile(path string) ([][]string, error) {

	file, err := os.Open(path)
	if err != nil {
		fmt.Println("Error:", err)
		return nil, err
	}

	defer file.Close()
	reader := csv.NewReader(file)
	reader.Comma = ' '
	values := [][]string{}

	for {

		record, err := reader.Read()

		if err == io.EOF {
			break
		} else if err, ok := err.(*csv.ParseError); ok && err.Err != csv.ErrFieldCount {
			fmt.Println("Error:", err)
			return nil, err
		}

		values = append(values, record)
	}

	fmt.Printf("Input records: %v\n", values)

	return values, nil
}

// validateInput validates the current distribution input. Current checks:
// Check if flight has no people or less than a minimum value (len 2)
// Check if flight has more passengers than Seats per Row
// Check if flight has a group bigger than the number of seats on a row
func validateInput(values [][]string) error {
	if len(values) < 2 {
		return errors.New(fmt.Sprintf("Input file has invalid len: %v", len(values)))
	}

	if len(values[0]) < 2 {
		return errors.New(fmt.Sprintf("Input file has invalid flight spec: %v", values[0]))
	}

	seats, err := strconv.Atoi(values[0][0])
	if err != nil {
		return errors.New(fmt.Sprintf("Input file has incorrect input of seats: %v", seats))
	}

	rows, err := strconv.Atoi(values[0][1])
	if err != nil {
		return errors.New(fmt.Sprintf("Input file has incorrect input of seats: %v", rows))
	}


	maxPeople := rows * seats
	actualPeople := countPeople(values)
	
	if actualPeople > maxPeople {
		return errors.New(fmt.Sprintf("Input file has more people: %v, than what the max specified: %v", actualPeople, maxPeople))
	}

	fmt.Printf("Number of max people: %v\n", maxPeople)
	fmt.Printf("Number of actual people: %v\n", actualPeople)


	return nil
}

// countPeople count number of people assigned in the flight
func countPeople(values [][]string) int {

	var counter int

	for i := 1; i < len(values); i++ {
		counter = counter + len(values[i])
	}

	return counter
}

// transformIntoInputModel transforms raw array into BoardingFlight model
func transformIntoInputModel(values [][]string) model.BoardingFlight {
	var response model.BoardingFlight

	response.Seats, _ = strconv.Atoi(values[0][0])
	response.Rows, _ = strconv.Atoi(values[0][1])

	preferences := remove(values, 0)

	response.GroupsOfPassengers = getGroupsOfPassengers(preferences)

	return response

}

// generateGroupOfPassengers will create the group of passengers according to its preferences
func getGroupsOfPassengers(preferences [][]string) []model.GroupOfPassengers {

	var response []model.GroupOfPassengers
	re := regexp.MustCompile("[0-9]+")

	for i := 0; i < len(preferences); i++ {

		var singleGroupOfPassengers model.GroupOfPassengers

		for j := 0; j < len(preferences[i]); j++ {

			passenger := model.Passenger { WindowPreference: false, Id: re.FindAllString(preferences[i][j], -1)[0] }

			if strings.Contains(preferences[i][j], "W") {
				passenger.WindowPreference = true
				singleGroupOfPassengers.WindowPreferenceCounter ++
			}

			singleGroupOfPassengers.Passengers = append(singleGroupOfPassengers.Passengers, passenger)
		}

		response = append(response, singleGroupOfPassengers)
	}

	return response

}

// remove deletes a given index of an slice keeping the order
func remove(slice [][]string, s int) [][]string {
	return append(slice[:s], slice[s+1:]...)
}

