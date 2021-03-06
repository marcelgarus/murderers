/// Utilities.

import * as functions from 'firebase-functions';
import { Game, isGame, GameCode, UserId, Player, isPlayer, FirebaseAuthToken, User, isUser } from './models';
import { log } from 'util';
import { CODE_BAD_REQUEST, CODE_USER_NOT_FOUND, TEXT_USER_NOT_FOUND, CODE_USER_CORRUPT, TEXT_USER_CORRUPT, CODE_AUTHENTIFICATION_FAILED, TEXT_AUTHENTIFICATION_FAILED, CODE_NO_PRIVILEGES, TEXT_NO_PRIVILEGES, CODE_GAME_NOT_FOUND, TEXT_GAME_NOT_FOUND, CODE_GAME_CORRUPT, TEXT_GAME_CORRUPT, CODE_PLAYER_CORRUPT, TEXT_PLAYER_NOT_FOUND, TEXT_PLAYER_CORRUPT, CODE_PLAYER_NOT_FOUND } from './constants';

/// Generates a length-long random string using the provided chars.
export function generateRandomString(chars: string, length: number): string {
  let s: string = '';

  while (s.length < length) {
    s += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return s;
}

/// Shuffles an array in place using the Fisher-Yates algorithm.
export function shuffle(array) {
  let m = array.length, t, i;

  while (m) {
    i = Math.floor(Math.random() * m--);
    t = array[m];
    array[m] = array[i];
    array[i] = t;
  }

  return array;
}

/// Checks if the query contains all the required parameters.
/// If not, sends a response (if res is not null) and returns false.
export function queryContains(
  query,
  parameters: string[],
  res?: functions.Response
): boolean {
  for (const arg of parameters) {
    if (query[arg] === undefined || typeof query[arg] !== 'string' || query[arg] === '') {
      if (res !== null) {
        res.status(CODE_BAD_REQUEST)
          .send('Bad request. ' + arg + ' parameter missing.');
      }
      return false;
    }
  }
  return true;
}

/// Returns a Firestore reference to the user with the id.
export function userRef(
  firestore: FirebaseFirestore.Firestore,
  id: UserId
): FirebaseFirestore.DocumentReference {
  return firestore.collection('users').doc(id);
}

/// Loads a user.
export async function loadUser(
  firestore: FirebaseFirestore.Firestore,
  id: UserId,
  res: functions.Response
): Promise<User> {
  if (id === null || id === undefined || id === '') {
    if (res !== null) {
      res.status(CODE_BAD_REQUEST).send('No user id provided.');
    }
    return null;
  }

  const snapshot = await userRef(firestore, id).get();

  if (!snapshot.exists) {
    if (res !== null) {
      res.status(CODE_USER_NOT_FOUND).send(TEXT_USER_NOT_FOUND);
    }
    return null;
  }

  const data = snapshot.data();

  if (!isUser(data)) {
    if (res !== null) {
      res.status(CODE_USER_CORRUPT).send(TEXT_USER_CORRUPT);
    }
    log('Corrupt user: ' + JSON.stringify(data));
    return null;
  }

  return data as User;
}

/// Loads and verifies the user with the id.
export async function loadAndVerifyUser(
  firestore: FirebaseFirestore.Firestore,
  id: UserId,
  providedAuthToken: FirebaseAuthToken,
  res: functions.Response
): Promise<User> {
  const user: User = await loadUser(firestore, id, res);
  if (user === null) return null;

  if (user.authToken !== providedAuthToken) {
    if (res !== null) {
      res.status(CODE_AUTHENTIFICATION_FAILED)
      .send(TEXT_AUTHENTIFICATION_FAILED);
    }
    return null;
  }

  return user;
}

/// Verifies that the user is the creator of the game. 
export function verifyCreator(
  game: Game,
  userId: UserId,
  res: functions.Response
): boolean {
  if (game.creator === userId) {
    return true;
  }
  res.status(CODE_NO_PRIVILEGES).send(TEXT_NO_PRIVILEGES);
  return false;
}

/// Returns a Firestore reference to the game with the code.
export function gameRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): FirebaseFirestore.DocumentReference {
  return firestore.collection('games').doc(code);
}

/// Loads a game with the code.
/// If errors occur, they are handled and the function just returns null.
export async function loadGame(
  res: functions.Response,
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): Promise<Game> {
  if (code === null || code === undefined || code === '') {
    if (res !== null) {
      res.status(CODE_BAD_REQUEST).send('You need to provide a game code.');
    }
    return null;
  }
  
  const snapshot = await gameRef(firestore, code).get();

  if (!snapshot.exists) {
    res.status(CODE_GAME_NOT_FOUND).send(TEXT_GAME_NOT_FOUND);
    return null;
  }

  const data = snapshot.data();

  if (!isGame(data)) {
    res.status(CODE_GAME_CORRUPT).send(TEXT_GAME_CORRUPT);
    log('Corrupt game: ' + JSON.stringify(data));
    return null;
  }

  return data as Game;
}

/// Returns a Firestore reference to the collection of players of the game
/// with the code.
export function allPlayersRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode
): FirebaseFirestore.CollectionReference {
  return gameRef(firestore, code).collection('players');
}

/// Returns a Firestore reference to the player with the id.
export function playerRef(
  firestore: FirebaseFirestore.Firestore,
  code: GameCode,
  id: UserId
): FirebaseFirestore.DocumentReference {
  return allPlayersRef(firestore, code).doc(id);
}

/// Loads a player with the id of the game with the code.
/// If errors occur, they are handled and the function just returns null.
export async function loadPlayer(
  res: functions.Response,
  firestore: FirebaseFirestore.Firestore,
  code: GameCode,
  id: UserId
): Promise<Player> {
  if (id === null || id === undefined || id === '') {
    if (res !== null) {
      res.status(CODE_BAD_REQUEST).send('No player id provided.');
    }
    return null;
  }

  const snapshot = await playerRef(firestore, code, id).get();

  if (!snapshot.exists) {
    res.status(CODE_PLAYER_NOT_FOUND).send(TEXT_PLAYER_NOT_FOUND);
    log('Player with id ' + id + ' not found in game ' + code + '.');
    return null;
  }

  const data = snapshot.data();

  if (!isPlayer(data)) {
    res.status(CODE_PLAYER_CORRUPT).send(TEXT_PLAYER_CORRUPT);
    log('Corrupt player: ' + JSON.stringify(data));
    return null;
  }

  return data as Player;
}


/// Loads all player of a game with their ids.
/// If errors occur, they are handled and the function just returns null.
export async function loadPlayersAndIds(
  res: functions.Response,
  snapshotPromise: Promise<FirebaseFirestore.QuerySnapshot>
): Promise<Array<{id: string, data: Player}>> {
  const players: {id, data: Player}[] = [];
  const snapshot = await snapshotPromise;
  let success = true;

  snapshot.forEach(doc => {
    const data = doc.data();

    if (isPlayer(data)) {
      players.push({
        id: doc.id,
        data: data as Player
      });
    } else {
      res.status(CODE_PLAYER_CORRUPT).send(TEXT_PLAYER_CORRUPT);
      log('Corrupt player: ' + JSON.stringify(data));
      success = false;
    }
  });

  return success ? players : null;
}
