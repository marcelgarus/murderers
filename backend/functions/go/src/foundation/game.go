package foundation

import (
	"time"
)

// GameCode is a string that uniquely identifies a game.
type GameCode = string

// Game represents a game session.
type Game struct {
	Code    GameCode
	Name    string
	State   GameState
	Creator User
	Created time.Time
	End     time.Time
	Joining []Player
}

// GameState represents the state of a game.
type GameState = int

const (
	// GameNotStartedYet indicates that the game didn't start yet.
	GameNotStartedYet = GameState(iota)

	// GameRunning indicates that the game is currently running.
	GameRunning = GameState(iota)

	// GameOver indicates that the game is over.
	GameOver = GameState(iota)
)
