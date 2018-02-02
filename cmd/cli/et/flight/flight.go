package flight

import (
	"fmt"
	"syscall"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/flight/cmd/cli/et/constants"
	"github.com/flight/pkg/flight/controller"
	"github.com/flight/pkg/flight/model"
)

func init() {
	Cmd.AddCommand(createCmd)
}

var createCmd = &cobra.Command{
	Use:   "generate",
	Short: "Generate new seat distribution",
	Run:   createCmdFunc,
}

func createCmdFunc(cmd *cobra.Command, args []string) {
	if err := verifyRequiredFlags(constants.FILE_PATH_ARG); err != nil {
		fmt.Println(constants.ERROR_PREFIX, err)
		cmd.Help()
		syscall.Exit(1)
	}

	values, err := parseRequestFile(viper.GetString(constants.FILE_PATH_ARG))
	if err != nil {
		fmt.Println(constants.ERROR_PREFIX, err)
		syscall.Exit(1)
	}

	err = validateInput(values)
	if err != nil {
		fmt.Println(constants.ERROR_PREFIX, err)
		syscall.Exit(1)
	}

	// Generate initial boarding flight
	boardingFlight := transformIntoInputModel(values)

	// Generate initial output distribution
	var rowDistribution []model.RowDistribution
	for i := 0; i < boardingFlight.Rows; i++ {
		rowDistribution = append(rowDistribution, model.NewRowDistribution(boardingFlight.Seats))
	}

	response := controller.NewFlight(boardingFlight, rowDistribution).AssignSeats()

	fmt.Printf("Seats distribution generated: %v", response)
}
