package main

import (
	_ "embed"
	"math/rand"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/sirupsen/logrus"
)

func main() {
	log := logrus.New()
	log.Out = os.Stdout
	log.Formatter = &logrus.JSONFormatter{}
	log.Level = logrus.InfoLevel

	dictionary := strings.Split(content, "\n")

	running := true

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM) //nolint

	go func() {
		<-c

		running = false
	}()

	for running {
		currentIndex := rand.Intn(len(dictionary)) //nolint: gosec

		log.Info(dictionary[currentIndex])

		time.Sleep(1 * time.Second)
	}
}

//go:embed content.txt
var content string
