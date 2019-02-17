import 'dart:async';

import 'package:flutter/material.dart';

import '../bloc/bloc.dart';
import '../widgets/button.dart';
import '../widgets/theme.dart';
import '../widgets/victim_name.dart';
import 'kill_warning.dart';
import 'players.dart';

class MainScreen extends StatelessWidget {
  MainScreen(this.game);

  final Game game;

  void _showGames(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => GamesSelector()
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Align(
            child: InkWell(
              onTap: () => _showGames(context),
              child: CircleAvatar(
                backgroundImage: NetworkImage(Bloc.of(context).accountPhotoUrl),
                radius: 24,
              ),
            ),
          ),
          SizedBox(width: 8)
        ],
      ),
      body: SafeArea(
        child: game.state == GameState.notStartedYet
          ? PreparationContent(game: game)
          : ActiveContent(game: game)
      ),
    );
  }
}

class GamesSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: Bloc.of(context).allGames.map((game) {
          return ListTile(
            leading: CircleAvatar(child: Text(game.code)),
            title: Text(game.name),
            subtitle: Text(game.code),
            onTap: () {
              Bloc.of(context).currentGame = game;
            },
            trailing: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Bloc.of(context).removeGame(game),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PreparationContent extends StatelessWidget {
  PreparationContent({
    @required this.game
  });
  
  final Game game;

  Future<void> _startGame(BuildContext context) {
    return Bloc.of(context).startGame();
  }

  Future<Game> _joinGame(BuildContext context) {
    return Bloc.of(context).joinGame(code: game.code);
  }

  @override
  Widget build(BuildContext context) {
    print('Building the preparation content.');
    final theme = MyTheme.of(context);

    final items = <Widget>[
      Spacer(),
      Text(game.code, style: theme.headerText),
      SizedBox(height: 8),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Share this code with other people\nto let them join.",
          textAlign: TextAlign.center,
          style: theme.bodyText,
        ),
      ),
    ];

    if (game.isCreator) {
      items.addAll([
        SizedBox(height: 16),
        Button(
          text: 'Start the game',
          onPressed: () => _startGame(context),
          onSuccess: (result) {
            print(result);
          },
        )
      ]);
    }

    if (!game.isPlayer) {
      items.addAll([
        SizedBox(height: 16),
        Button(
          text: 'Join the game',
          onPressed: () => _joinGame(context),
          onSuccess: (game) => print('Joined the game.'),
        ),
      ]);
    }

    items.addAll([
      Spacer(),
      InkResponse(
        onTap: () {
          print('Showing all the players');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PlayersScreen(game)
          ));
        },
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text('all players'.toUpperCase()),
        ),
      ),
    ]);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items
      )
    );
  }
}



class ActiveContent extends StatelessWidget {
  ActiveContent({
    @required this.game
  });
  
  final Game game;


  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Spacer(flex: 2),
    ];

    print('Victim is ${game.victim}');
    if (game.victim != null || true) {
      items.addAll([
        VictimName(name: game.victim?.name ?? 'some victim'),
        Button(
          text: 'Victim killed',
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => KillWarning(game)
            ));
          },
        ),
        SizedBox(height: 8),
        Button(
          text: 'More actions',
          isRaised: false,
          onPressed: () {},
        ),
      ]);
    }

    items.addAll([
      Spacer(),
      Divider(height: 1),
      Statistics(rank: 2, killedByUser: 2, alive: 5, total: 13),
    ]);

    return Column(children: items);
  }
}


class Statistics extends StatelessWidget {
  Statistics({
    @required this.rank,
    @required this.killedByUser,
    @required this.alive,
    @required this.total,
  });

  final int rank;
  final int killedByUser;
  final int alive;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Spacer(),
        _buildItem('#$rank', 'rank', () {}),
        Spacer(flex: 2),
        _buildItem('$killedByUser', 'killed by you', () {}),
        Spacer(flex: 2),
        _buildItem('$alive/$total', 'still alive', () {}),
        Spacer(),
      ],
    );
  }

  Widget _buildItem(String number, String text, VoidCallback onTap) {
    return InkResponse(
      highlightShape: BoxShape.rectangle,
      containedInkWell: true,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(height: 16),
          Text(number,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 8),
          Text(text, style: TextStyle(color: Colors.white)),
          SizedBox(height: 16),
        ],
      )
    );
  }
}
