package et

import (
	"fmt"
	"os"

	"syscall"

	"github.com/spf13/cobra"
	"github.com/spf13/viper"
	"github.com/flight/cmd/cli/et/constants"
	"github.com/flight/cmd/cli/et/flight"
)

var RootCmd = &cobra.Command{
	Use:   "flight",
	Short: "flight seats distribution command line",
	PersistentPreRun: func(cmd *cobra.Command, args []string) {
		viper.AutomaticEnv()
	},
	Run: func(cmd *cobra.Command, args []string) {
		cmd.Help()
		syscall.Exit(1)
	},
}

func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	RootCmd.PersistentFlags().StringP(constants.FILE_PATH_ARG, constants.FILE_PATH_FLAG, "", constants.FILE_PATH_USAGE)

	viper.BindPFlags(RootCmd.PersistentFlags())

	RootCmd.AddCommand(flight.Cmd)

}
