import 'package:flutter/material.dart';
import 'package:mobile_fitness_app/app/dependency_scope.dart';
import 'package:mobile_fitness_app/app/storage.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';

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

  Future<void> _handleCreate(List<Subscription> subscriptions) async {
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

    final userIdStr = await SecureStorageService().getUserId();
    final userId = int.tryParse(userIdStr ?? '');
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please sign in again.')),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Subscriptions'),
      ),
      body: StreamBuilder<List<Subscription>>(
        stream: repo.watchSubscriptions(),
        builder: (context, snapshot) {
          final waiting = snapshot.connectionState == ConnectionState.waiting;
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final subscriptions = snapshot.data ?? _subscriptionsCache;
          if (snapshot.hasData) {
            _subscriptionsCache = subscriptions;
          }

          if (waiting && subscriptions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose a subscription and duration to create a user subscription.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (subscriptions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No subscriptions available. Please sync data first.'),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: subscriptions
                        .map(
                          (sub) => Card(
                            child: ListTile(
                              leading: Icon(
                                _selectedSubscriptionId == sub.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                              ),
                              title: Text(sub.name),
                              subtitle: Text('Monthly cost: ${sub.monthlyCost}'),
                              onTap: () => setState(() => _selectedSubscriptionId = sub.id),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Duration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _monthOptions
                      .map(
                        (months) => ChoiceChip(
                          label: Text('$months month${months > 1 ? 's' : ''}'),
                          selected: _selectedMonths == months,
                          onSelected: (_) => setState(() => _selectedMonths = months),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        subscriptions.isEmpty || _submitting ? null : () => _handleCreate(subscriptions),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
