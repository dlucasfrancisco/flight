# Flight Challenge

Flight challenge which aims to group users into a flight depending on
different variables like if they belong to a group or if they have
a Window preference.

The time spent in total in the Challenge was of `4h` approximately, so
the final solution is incomplete.

## Requirements

- `Docker`: 17.12.0-ce or +
- `Docker Compose`: 1.14 or +

## Summary Docker commands

In order to run the integration test which will produce the exercise output run:

- make integration-test

## All Docker commands

- Clean workspace and containers

    make clean

- Build application

    make build

- Unit tests application

    make tests

- Integration tests application

    make integration-tests

- Build docker image

    make build
    
- Deploy Service

    make deploy

## TODO - Incomplete steps

[ ] Microservice is sorting passengers by window preference and group, now they need to be assigned to each Row of the flight.
[ ] More Integration tests need to be put in place.
[ ] More testing around functions
[ ] 