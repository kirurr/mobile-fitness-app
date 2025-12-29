import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/storage.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';

class UserSubscriptionsScreen extends StatefulWidget {
  const UserSubscriptionsScreen({super.key});

  @override
  State<UserSubscriptionsScreen> createState() => _UserSubscriptionsScreenState();
}

class _UserSubscriptionsScreenState extends State<UserSubscriptionsScreen> {
  static const List<int> _monthOptions = [1, 3, 6, 12];

  bool _submitting = false;
  List<Subscription> _subscriptionsCache = [];
  int? _userId;
  List<Subscription> _initialSubscriptions = [];
  List<UserSubscription> _initialUserSubscriptions = [];
  bool _initialLoaded = false;
  bool _userIdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialData());
  }

  Future<void> _loadUserId() async {
    final userIdStr = await SecureStorageService().getUserId();
    final userId = int.tryParse(userIdStr ?? '');
    if (!mounted) return;
    setState(() {
      _userId = userId;
      _userIdLoaded = true;
    });
  }

  Future<void> _loadInitialData() async {
    final deps = DependencyScope.of(context);
    final subscriptions = await deps.subscriptionRepository.getLocalSubscriptions();
    final userSubscriptions =
        await deps.userSubscriptionRepository.getLocalUserSubscriptions();
    if (!mounted) return;
    setState(() {
      _initialSubscriptions = subscriptions;
      _initialUserSubscriptions = userSubscriptions;
      _subscriptionsCache = subscriptions;
      _initialLoaded = true;
    });
  }

  DateTime _addMonths(DateTime date, int months) {
    final int targetMonth = date.month + months;
    final int year = date.year + ((targetMonth - 1) ~/ 12);
    final int month = ((targetMonth - 1) % 12) + 1;
    final lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;
    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  bool _isSubscriptionActive(UserSubscription sub, DateTime nowUtc) {
    final start = DateTime.tryParse(sub.startDate);
    final end = DateTime.tryParse(sub.endDate);
    if (start == null || end == null) return false;
    final startUtc = start.toUtc();
    final endUtc = end.toUtc();
    if (nowUtc.isBefore(startUtc)) return false;
    if (nowUtc.isAfter(endUtc)) return false;
    return true;
  }

  String _formatDateTime(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  Future<void> _handleCreate(
    Subscription subscription,
    int months,
    List<UserSubscription> userSubscriptions,
  ) async {
    if (_submitting) return;

    final userId = _userId;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please sign in again.')),
      );
      return;
    }

    final nowUtc = DateTime.now().toUtc();
    final alreadyActive = userSubscriptions.any((sub) {
      final linkedId = sub.subscription.value?.id;
      return sub.userId == userId &&
          !sub.pendingDelete &&
          linkedId == subscription.id &&
          _isSubscriptionActive(sub, nowUtc);
    });
    if (alreadyActive) {
      return;
    }

    final startDate = DateTime.now();
    final endDate = _addMonths(startDate, months);

    final subPayload = UserSubscriptionPayloadDTO(
      userId: userId,
      subscriptionId: subscription.id,
      startDate: startDate.toIso8601String(),
      endDate: endDate.toIso8601String(),
    );

    final paymentPayload = UserPaymentPayloadDTO(
      userId: userId,
      amount: subscription.monthlyCost * months,
    );

    if (!mounted) return;
    setState(() => _submitting = true);

    try {
      final deps = DependencyScope.of(context);
      await deps.userSubscriptionRepository.create(subPayload);
      await deps.userPaymentRepository.create(paymentPayload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Created ${subscription.name} for $months month(s)',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create subscription: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _showPurchaseSheet(
    Subscription subscription,
    List<UserSubscription> userSubscriptions,
  ) async {
    int selectedMonths = _monthOptions.first;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Purchase ${subscription.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose duration',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _monthOptions
                        .map(
                          (months) => ChoiceChip(
                            label: Text(
                              '$months month${months > 1 ? 's' : ''}',
                            ),
                            selected: selectedMonths == months,
                            onSelected: (_) {
                              setSheetState(() => selectedMonths = months);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting
                          ? null
                          : () async {
                              await _handleCreate(
                                subscription,
                                selectedMonths,
                                userSubscriptions,
                              );
                              if (!context.mounted) return;
                              Navigator.of(context).pop();
                            },
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  UserSubscription? _activeSubscriptionFor(
    List<UserSubscription> items,
    int? userId,
    int subscriptionId,
  ) {
    if (userId == null) return null;
    final nowUtc = DateTime.now().toUtc();
    for (final sub in items) {
      if (sub.userId != userId || sub.pendingDelete) continue;
      final linkedId = sub.subscription.value?.id;
      if (linkedId != subscriptionId) continue;
      if (_isSubscriptionActive(sub, nowUtc)) return sub;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialLoaded || !_userIdLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final repo = DependencyScope.of(context).subscriptionRepository;
    final userSubscriptionRepo =
        DependencyScope.of(context).userSubscriptionRepository;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Subscriptions'),
      ),
      body: StreamBuilder<List<UserSubscription>>(
                stream: userSubscriptionRepo.watchUserSubscriptions(),
                initialData: _initialUserSubscriptions,
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasError) {
                    return Center(child: Text('Error: ${userSnapshot.error}'));
                  }

                  final userSubscriptions = userSnapshot.data ?? const [];

                  return StreamBuilder<List<Subscription>>(
                    stream: repo.watchSubscriptions(),
                    initialData: _initialSubscriptions,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final subscriptions =
                          snapshot.data ?? _subscriptionsCache;
                      if (snapshot.hasData) {
                        _subscriptionsCache = subscriptions;
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subscriptions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (subscriptions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'No subscriptions available. Please sync data first.',
                                ),
                              )
                            else
                              Column(
                                children: subscriptions
                                    .map(
                                      (sub) {
                                        final activeSub = _activeSubscriptionFor(
                                          userSubscriptions,
                                          _userId,
                                          sub.id,
                                        );
                                        final priceText =
                                            '\$${sub.monthlyCost} / month';
                                        return Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  sub.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  priceText,
                                                  style: const TextStyle(
                                                    fontSize: 26,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                if (activeSub != null) ...[
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: OutlinedButton(
                                                      onPressed: _submitting
                                                          ? null
                                                          : () async {
                                                              setState(
                                                                () =>
                                                                    _submitting =
                                                                        true,
                                                              );
                                                              try {
                                                                await userSubscriptionRepo
                                                                    .delete(
                                                                      activeSub.id,
                                                                    );
                                                              } finally {
                                                                if (mounted) {
                                                                  setState(
                                                                    () =>
                                                                        _submitting =
                                                                            false,
                                                                  );
                                                                }
                                                              }
                                                            },
                                                      child: const Text(
                                                        'Cancel subscription',
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Paid until ${_formatDateTime(activeSub.endDate)}',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                                ] else ...[
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed:
                                                          _submitting
                                                              ? null
                                                              : () =>
                                                                  _showPurchaseSheet(
                                                                    sub,
                                                                    userSubscriptions,
                                                                  ),
                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Theme.of(context)
                                                                    .colorScheme
                                                                    .primary,
                                                            foregroundColor:
                                                                Colors.black,
                                                          ),
                                                      child: const Text(
                                                        'Purchase',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                    .toList(),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
