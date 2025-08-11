import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/time_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controllers = <String, TextEditingController>{};
  final _periods = const ['mañana', 'tarde', 'noche', 'madrugada'];
  final _labels = const {
    'mañana': 'Mañana',
    'tarde': 'Tarde',
    'noche': 'Noche',
    'madrugada': 'Madrug.',
  };
  // Stores canonical HH:mm times; TextFields show formatted view (12h/24h)
  final Map<String, String> _rawTimes = {};

  // Canonicalize any input to HH:mm (handles single-digit hours and AM/PM)
  String _canonicalize(String? input) => TimeUtils.canonicalizeTime(input);

  @override
  void initState() {
    super.initState();
    final prefs = context.read<AppStateProvider>().userPreferences;
    final use24h = prefs.use24hFormat;
    for (final p in _periods) {
      final rawPref = prefs.notificationTimes[p] ?? '';
      final canon = _canonicalize(rawPref);
      _rawTimes[p] = canon;
      _controllers[p] = TextEditingController(
        text: canon.isEmpty ? '' : _formatDisplayTime(canon, use24h),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // Validates HH:mm strings
  String? _validateTime(String? value) => TimeUtils.validateHHmm(value);

  String _formatDisplayTime(String hhmm, bool use24h) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    if (use24h) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  String _toHHmm(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime(AppStateProvider app, String key) async {
    final use24h = app.use24hFormat;
    final current = _rawTimes[key] ?? '08:00';
    final parts = current.split(':');
    final initial = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24h),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      final hhmm = _toHHmm(picked);
      setState(() {
        _rawTimes[key] = hhmm;
        _controllers[key]!.text = _formatDisplayTime(hhmm, use24h);
      });
    }
  }

  String? _validateOrder(Map<String, String> times) {
    int mins(String hhmm) {
      final p = hhmm.split(':');
      return (int.parse(p[0]) * 60) + int.parse(p[1]);
    }
    final morning = mins(times['mañana']!);
    final afternoon = mins(times['tarde']!);
    final evening = mins(times['noche']!);
    final night = mins(times['madrugada']!);
    // Enforce reasonable chronological flow within a day
    if (!(morning < afternoon && afternoon < evening && evening <= night)) {
      return 'El orden debe ser Mañana < Tarde < Noche <= Madrugada';
    }
    return null;
  }

  Future<void> _saveTimes(AppStateProvider app) async {
    final times = Map<String, String>.from(_rawTimes);
    // Normalize to canonical HH:mm before validation/saving
    for (final p in _periods) {
      times[p] = _canonicalize(times[p]);
    }
    // Validate canonical HH:mm values
    for (final p in _periods) {
      final v = times[p] ?? '';
      final err = _validateTime(v);
      if (err != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_labels[p]}: $err')),
          );
        }
        return;
      }
    }
    final orderErr = _validateOrder(times);
    if (orderErr != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(orderErr)),
        );
      }
      return;
    }
    await app.updateNotificationTimes(times);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Horarios guardados')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración'), centerTitle: true),
      body: Consumer2<AppStateProvider, ThemeProvider>(
        builder: (context, app, theme, _) {
          final prefs = app.userPreferences;
          // Ensure displayed text reflects the current format preference
          for (final p in _periods) {
            final raw = _rawTimes[p] ?? prefs.notificationTimes[p] ?? '';
            final canon = _canonicalize(raw);
            _rawTimes[p] = canon;
            final display = canon.isEmpty ? '' : _formatDisplayTime(canon, app.use24hFormat);
            if (_controllers[p]!.text != display) {
              _controllers[p]!.text = display;
            }
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'General',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Habilitar notificaciones'),
                      value: prefs.notificationsEnabled,
                      onChanged: (v) => app.toggleNotifications(v),
                      secondary: const Icon(Icons.notifications_active_outlined),
                    ),
                    const Divider(height: 0),
                    SwitchListTile(
                      title: const Text('Formato de hora 24h'),
                      subtitle: Text(app.use24hFormat ? '24h' : '12h AM/PM'),
                      value: app.use24hFormat,
                      onChanged: (v) => app.setUse24hFormat(v),
                      secondary: const Icon(Icons.access_time),
                    ),
                    const Divider(height: 0),
                    SwitchListTile(
                      title: const Text('Modo oscuro'),
                      value: theme.isDarkMode,
                      onChanged: (_) => theme.toggleTheme(),
                      secondary: const Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Horarios diarios',
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('Selecciona horas para cada periodo'),
                        subtitle: Text('Consejo: toca una hora para cambiarla'),
                        leading: Icon(Icons.schedule),
                      ),
                      const Divider(height: 0),
                      ..._periods.map((p) => _timeTile(app, p)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Builder(
                              builder: (ctx) {
                                return OutlinedButton.icon(
                                  icon: const Icon(Icons.restore),
                                  onPressed: () async {
                                    final messenger = ScaffoldMessenger.of(ctx);
                                    await app.resetNotificationTimesToDefault();
                                    final defaults = app.userPreferences.notificationTimes;
                                    if (!mounted) return;
                                    setState(() {
                                      for (final p in _periods) {
                                        _rawTimes[p] = _canonicalize(defaults[p] ?? '');
                                        _controllers[p]!.text = _rawTimes[p]!.isEmpty
                                            ? ''
                                            : _formatDisplayTime(_rawTimes[p]!, app.use24hFormat);
                                      }
                                    });
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Horarios restablecidos')),
                                    );
                                  },
                                  label: const Text('Restablecer'),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    foregroundColor: Theme.of(context).brightness == Brightness.light
                                        ? Colors.red[700]
                                        : Theme.of(context).colorScheme.primary,
                                    side: BorderSide(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? Colors.red[700]!
                                          : Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined),
                              onPressed: () => _saveTimes(app),
                              label: const Text('Guardar'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 40),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Builder(
                builder: (ctx) {
                  final messenger = ScaffoldMessenger.of(ctx);
                  final appProv = context.read<AppStateProvider>();
                  final themeProv = context.read<ThemeProvider>();
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.settings_backup_restore),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.red[700]
                          : Theme.of(context).colorScheme.errorContainer,
                      foregroundColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Theme.of(context).colorScheme.onErrorContainer,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: ctx,
                        builder: (context) => AlertDialog(
                          title: const Text('Restablecer ajustes'),
                          content: const Text(
                            'Esto restaurará todos los ajustes a sus valores estándar (notificaciones, formato de hora, horarios y tema). Tus datos no se borrarán.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Restablecer'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await appProv.resetAllSettingsToDefault();
                        await themeProv.setDarkMode(false);
                        if (!mounted) return;
                        setState(() {
                          for (final p in _periods) {
                            final raw = appProv.userPreferences.notificationTimes[p] ?? '';
                            final canon = _canonicalize(raw);
                            _rawTimes[p] = canon;
                            _controllers[p]!.text = canon.isEmpty
                                ? ''
                                : _formatDisplayTime(canon, appProv.use24hFormat);
                          }
                        });
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Ajustes restablecidos a estándar')),
                        );
                      }
                    },
                    label: const Text('Restablecer ajustes'),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _timeTile(AppStateProvider app, String key) {
    final inputWidth = app.use24hFormat ? 110.0 : 140.0;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: const Icon(Icons.access_time),
          title: Text(
            _labels[key] ?? key,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: SizedBox(
            width: inputWidth,
            child: TextField(
              controller: _controllers[key],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'HH:mm / AM·PM',
              ),
              textAlign: TextAlign.center,
              readOnly: true,
              onTap: () => _pickTime(app, key),
            ),
          ),
        ),
        const Divider(height: 0),
      ],
    );
  }
}
