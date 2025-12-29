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

  int? _selectedSubscriptionId;
  int _selectedMonths = _monthOptions.first;
  bool _submitting = false;
  List<Subscription> _subscriptionsCache = [];
  int? _userId;
  List<Subscription> _initialSubscriptions = [];
  List<UserSubscription> _initialUserSubscriptions = [];

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

  List<UserSubscription> _activeSubscriptionsForUser(
    List<UserSubscription> items,
    int? userId,
  ) {
    if (userId == null) return const [];
    final nowUtc = DateTime.now().toUtc();
    return items
        .where(
          (sub) =>
              sub.userId == userId &&
              !sub.pendingDelete &&
              _isSubscriptionActive(sub, nowUtc),
        )
        .toList();
  }

  Future<void> _handleCreate(
    List<Subscription> subscriptions,
    List<UserSubscription> userSubscriptions,
  ) async {
    if (_submitting) return;

    final subscription = subscriptions.firstWhere(
      (sub) => sub.id == _selectedSubscriptionId,
      orElse: () => Subscription(id: -1, name: '', monthlyCost: 0),
    );

    if (subscription.id == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subscription')),
      );
      return;
    }

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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription already active.')),
      );
      return;
    }

    final startDate = DateTime.now();
    final endDate = _addMonths(startDate, _selectedMonths);

    final subPayload = UserSubscriptionPayloadDTO(
      userId: userId,
      subscriptionId: subscription.id,
      startDate: startDate.toIso8601String(),
      endDate: endDate.toIso8601String(),
    );

    final paymentPayload = UserPaymentPayloadDTO(
      userId: userId,
      amount: subscription.monthlyCost * _selectedMonths,
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
            'Created ${subscription.name} for $_selectedMonths month(s) and logged payment.',
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

  @override
  Widget build(BuildContext context) {
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
                  final activeSubscriptions = _activeSubscriptionsForUser(
                    userSubscriptions,
                    _userId,
                  );

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

                      final activeIds = activeSubscriptions
                          .map((sub) => sub.subscription.value?.id)
                          .whereType<int>()
                          .toSet();
                      final selectedIsActive =
                          _selectedSubscriptionId != null &&
                          activeIds.contains(_selectedSubscriptionId);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Active subscriptions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (activeSubscriptions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('No active subscriptions.'),
                              )
                            else
                              Column(
                                children: activeSubscriptions
                                    .map(
                                      (sub) => Card(
                                        child: ListTile(
                                          title: Text(
                                            sub.subscription.value?.name ?? '-',
                                          ),
                                          subtitle: Text(
                                            'Start: ${sub.startDate}  End: ${sub.endDate}',
                                          ),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed:
                                                _submitting
                                                    ? null
                                                    : () async {
                                                      setState(
                                                        () => _submitting = true,
                                                      );
                                                      try {
                                                        await userSubscriptionRepo
                                                            .delete(sub.id);
                                                      } finally {
                                                        if (mounted) {
                                                          setState(
                                                            () => _submitting = false,
                                                          );
                                                        }
                                                      }
                                                    },
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            const SizedBox(height: 16),
                            const Text(
                              'Choose a subscription and duration to create a user subscription.',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: subscriptions
                                    .map(
                                      (sub) {
                                        final isActive = activeIds.contains(
                                          sub.id,
                                        );
                                        return Card(
                                          child: ListTile(
                                            leading: Icon(
                                              _selectedSubscriptionId == sub.id
                                                  ? Icons.radio_button_checked
                                                  : Icons.radio_button_unchecked,
                                            ),
                                            title: Text(sub.name),
                                            subtitle: Text(
                                              isActive
                                                  ? 'Active'
                                                  : 'Monthly cost: ${sub.monthlyCost}',
                                            ),
                                            onTap:
                                                isActive
                                                    ? null
                                                    : () => setState(
                                                      () =>
                                                          _selectedSubscriptionId =
                                                              sub.id,
                                                    ),
                                          ),
                                        );
                                      },
                                    )
                                    .toList(),
                              ),
                            const SizedBox(height: 16),
                            const Text(
                              'Duration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                                      selected: _selectedMonths == months,
                                      onSelected: (_) => setState(
                                        () => _selectedMonths = months,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 24),
                            if (selectedIsActive)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(
                                  'Subscription already active.',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    subscriptions.isEmpty ||
                                            _submitting ||
                                            selectedIsActive
                                        ? null
                                        : () => _handleCreate(
                                          subscriptions,
                                          userSubscriptions,
                                        ),
                                child:
                                    _submitting
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text('Create'),
                              ),
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
