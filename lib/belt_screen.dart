import 'dart:async';

import 'package:flutter/material.dart';

import 'pokemon_service.dart';

class BeltScreen extends StatefulWidget {
  const BeltScreen({super.key});

  @override
  State<BeltScreen> createState() => _BeltScreenState();
}

class _BeltScreenState extends State<BeltScreen> {
  final PokemonService _service = PokemonService();
  late Stream<PokemonUpdate> _updates;

  @override
  void initState() {
    super.initState();
    // Keep one stream instance; it fetches a new Pokémon every five seconds.
    _updates = pokemonUpdateStream(_service);
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
      body: StreamBuilder<PokemonUpdate>(
        stream: _updates,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Waiting for the first Pokémon...'),
                ],
              ),
            );
          }

          if (snapshot.hasError && !snapshot.hasData) {
            return _StreamError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() {
                _updates = pokemonUpdateStream(_service);
              }),
            );
          }

          final update = snapshot.data;
          if (update == null) {
            return const Center(child: Text('Waiting for Pokémon data...'));
          }

          if (update.hasError) {
            return _StreamError(
              message: update.errorMessage ?? 'An unknown error occurred.',
              onRetry: () => setState(() {
                _updates = pokemonUpdateStream(_service);
              }),
            );
          }

          final pokemon = update.pokemon!;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LIVE ROTATION',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 16),
                      if (pokemon.imageUrl != null)
                        Image.network(
                          pokemon.imageUrl!,
                          height: 180,
                          width: 180,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.catching_pokemon,
                            size: 120,
                          ),
                        )
                      else
                        const Icon(Icons.catching_pokemon, size: 120),
                      const SizedBox(height: 12),
                      Text(
                        '#${pokemon.id} ${pokemon.formattedName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        children: pokemon.types
                            .map((type) => Chip(label: Text(type.toUpperCase())))
                            .toList(),
                      ),
                      const Divider(height: 28),
                      Text('Height: ${pokemon.height / 10} m'),
                      Text('Weight: ${pokemon.weight / 10} kg'),
                      const SizedBox(height: 12),
                      const Text(
                        'This card updates automatically every five seconds.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StreamError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StreamError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'Update failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text(
              'The stream will keep trying on its next update.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart updates'),
            ),
          ],
        ),
      ),
    );
  }
}
