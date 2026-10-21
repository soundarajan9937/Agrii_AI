import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),

      // ==========================================
      // APP BAR
      // ==========================================
      appBar: AppBar(
        title: const Text(
          'My Earnings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),

      // ==========================================
      // BODY
      // ==========================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // =====================================
            // TOTAL EARNINGS
            // =====================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6D00), Color(0xFFFFAB40)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 45,
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Total Earnings',
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  SizedBox(height: 5),

                  Text(
                    '₹18,500',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =====================================
            // SUMMARY
            // =====================================
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: "Today's Earnings",
                    amount: '₹2,500',
                    icon: Icons.today,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _summaryCard(
                    title: 'This Month',
                    amount: '₹12,800',
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // =====================================
            // RECENT TRANSACTIONS TITLE
            // =====================================
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            // =====================================
            // TRANSACTIONS
            // =====================================
            _transaction(
              product: 'Rice - 50 Kg',
              customer: 'Customer 1',
              amount: '₹2,200',
              date: 'Today',
            ),

            _transaction(
              product: 'Tomato - 20 Kg',
              customer: 'Customer 2',
              amount: '₹1,800',
              date: 'Yesterday',
            ),

            _transaction(
              product: 'Coconut - 50 Nos',
              customer: 'Customer 3',
              amount: '₹3,500',
              date: '25 July',
            ),

            _transaction(
              product: 'Mango - 30 Kg',
              customer: 'Customer 4',
              amount: '₹4,200',
              date: '23 July',
            ),

            const SizedBox(height: 20),

            // =====================================
            // INFORMATION
            // =====================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(15),
              ),

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Your earnings will be updated automatically when customers complete their orders.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SUMMARY CARD
  // ==========================================

  static Widget _summaryCard({
    required String title,
    required String amount,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.orange, size: 30),

          const SizedBox(height: 10),

          Text(
            amount,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TRANSACTION CARD
  // ==========================================

  static Widget _transaction({
    required String product,
    required String customer,
    required String amount,
    required String date,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),

      elevation: 1,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),

        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF3E0),

          child: Icon(Icons.shopping_bag, color: Colors.orange),
        ),

        title: Text(
          product,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text('$customer • $date'),

        trailing: Text(
          amount,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
