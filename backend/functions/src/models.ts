export type Timestamp = number;

/// A User.
export type UserId = string;
export type FirebaseAuthToken = number;
export type MessagingToken = string;

export interface User {
  authToken: FirebaseAuthToken,
  messagingToken: MessagingToken,
  name: string,
}
export function isUser(obj): boolean {
  return obj !== undefined
    && typeof obj.authToken === "string"
    && typeof obj.messagingToken === "string"
    && typeof obj.name === "string";
}

/// A player.
///
/// The term player refers to all users participating in a game. Players only
/// exist in the context and scope of games - if a user plays in two games, he
/// is represented by two distinct players.
///
/// Each player has an id (not in this class) that's used as a reference to the
/// player in backend & frontend. The player class holds:
/// * [authToken]: An authentication token that allows the player to
///   authenticate himself to the server and take actions.
/// * [name]: The name of the player. May change during the course of the game.
/// * [victim]: The id of the player's victim. If no victim is chosen, it may
///   be null.
/// * [death]: Information about how the player died. If death is null, the
///   player lives.
export type PlayerState = number;
export const PLAYER_JOINING: PlayerState = 0;
export const PLAYER_ALIVE: PlayerState = 1;
export const PLAYER_DYING: PlayerState = 2;
export const PLAYER_DEAD: PlayerState = 3;

export interface Player {
  state: PlayerState,
  kills: number,
  murderer: UserId,
  victim: UserId,
  wantsNewVictim: boolean,
  death: Death,
}
export function isPlayer(obj): boolean {
  return obj !== undefined
    && typeof obj.state === "number"
    && typeof obj.kills === "number"
    && (obj.murderer === null || typeof obj.murderer === "string")
    && (obj.victim === null || typeof obj.victim === "string")
    && typeof obj.wantsNewVictim === "boolean"
    && (obj.death === null || isDeath(obj.death));
}

/// A death.
///
/// A class that holds some information about how a player died. This class is
/// owned by the victim.
///
/// This class holds:
/// * [time]: The time of the murder.
/// * [murderer]: The id of the murderer.
/// * [lastWords]: The victim's last words.
/// * [weapon]: The murderer's weapon.
export interface Death {
  time: Timestamp,
  murderer: UserId,
  weapon: string,
  lastWords: string,
}
export function isDeath(obj): boolean {
  return obj !== undefined
    && obj !== null
    && typeof obj.time === "number"
    && typeof obj.murderer === "string"
    && typeof obj.lastWords === "string"
    && typeof obj.weapon === "string";
}

/// A game.
///
/// A class that holds some information about the game in general.
///
/// Each game has a code (not in this class) that is unique in all the games
/// that didn't end yet. The game class holds:
/// * [creator]: The creator's GoogleSignInId that allows him to authenticate
///   himself to the server and change some of the game configuration.
/// * [name]: The name of the game.
/// * [state]: The state of the game.
/// * [created]: Timestamp when the game was created.
/// * [end]: The estimated timestamp of the game's end. May be changed by the
///   creator.
export type GameCode = string;
export type GameState = number;
export const GAME_NOT_STARTED_YET: GameState = 0;
export const GAME_RUNNING: GameState = 1;
export const GAME_OVER: GameState = 2;

export interface Game {
  name: string,
  state: GameState,
  creator: UserId,
  created: Timestamp,
  end: Timestamp,
}
export function isGame(obj): boolean {
  return obj !== undefined
    && typeof obj.name === "string"
    && typeof obj.state === "number"
    && typeof obj.creator === "string"
    && typeof obj.created === "number"
    && typeof obj.end === "number";
}
