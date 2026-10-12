import 'package:flutter/material.dart';

import 'pokemon.dart';
import 'pokemon_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final PokemonService _service = PokemonService();
  late Future<List<PokemonSummary>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = _service.fetchPokemonList();
  }

  void _retry() {
    setState(() {
      _pokemonFuture = _service.fetchPokemonList();
    });
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
  title: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('The Belt'),
      Text(
        'Automatic updates • StreamBuilder',
        style: TextStyle(fontSize: 12),
      ),
    ],
  ),
),
      body: FutureBuilder<List<PokemonSummary>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Loading Pokémon...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.wifi_off,
              title: 'Could not load Pokémon',
              message: snapshot.error.toString().replaceFirst('Exception: ', ''),
              buttonLabel: 'Retry',
              onPressed: _retry,
            );
          }

          final pokemon = snapshot.data ?? [];
          if (pokemon.isEmpty) {
            return _MessageState(
              icon: Icons.inbox_outlined,
              title: 'No Pokémon found',
              message: 'The API returned an empty list.',
              buttonLabel: 'Try again',
              onPressed: _retry,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _retry(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: pokemon.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final item = pokemon[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${item.id ?? index + 1}'),
                    ),
                    title: Text(item.formattedName),
                    subtitle: Text('Pokédex ID: ${item.id ?? 'Unknown'}'),
                    trailing: const Icon(Icons.catching_pokemon),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
