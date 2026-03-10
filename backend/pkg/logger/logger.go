package logger

import (
	"fmt"
	"log"
	"os"
	"time"
)

// Logger levels
const (
	LevelDebug = "DEBUG"
	LevelInfo  = "INFO"
	LevelWarn  = "WARN"
	LevelError = "ERROR"
)

// Logger is a simple structured logger
type Logger struct {
	prefix string
}

// New creates a new logger instance
func New(prefix string) *Logger {
	return &Logger{prefix: prefix}
}

// Default logger instance
var defaultLogger = New("RideLog")

func (l *Logger) log(level, message string, args ...interface{}) {
	timestamp := time.Now().Format("2006-01-02 15:04:05")
	prefix := fmt.Sprintf("[%s] [%s] [%s]", timestamp, level, l.prefix)

	if len(args) > 0 {
		message = fmt.Sprintf(message, args...)
	}

	log.Printf("%s %s", prefix, message)
}

// Debug logs debug messages
func (l *Logger) Debug(message string, args ...interface{}) {
	l.log(LevelDebug, message, args...)
}

// Info logs info messages
func (l *Logger) Info(message string, args ...interface{}) {
	l.log(LevelInfo, message, args...)
}

// Warn logs warning messages
func (l *Logger) Warn(message string, args ...interface{}) {
	l.log(LevelWarn, message, args...)
}

// Error logs error messages
func (l *Logger) Error(message string, args ...interface{}) {
	l.log(LevelError, message, args...)
}

// Fatal logs fatal errors and exits
func (l *Logger) Fatal(message string, args ...interface{}) {
	l.log(LevelError, message, args...)
	os.Exit(1)
}

// Package-level functions using default logger

// Debug logs debug messages
func Debug(message string, args ...interface{}) {
	defaultLogger.Debug(message, args...)
}

// Info logs info messages
func Info(message string, args ...interface{}) {
	defaultLogger.Info(message, args...)
}

// Warn logs warning messages
func Warn(message string, args ...interface{}) {
	defaultLogger.Warn(message, args...)
}

// Error logs error messages
func Error(message string, args ...interface{}) {
	defaultLogger.Error(message, args...)
}

// Fatal logs fatal errors and exits
func Fatal(message string, args ...interface{}) {
	defaultLogger.Fatal(message, args...)
}
