import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/revenuecat_service.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPlanIndex = 0;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Monthly',
      'price': '\$1.99',
      'period': '/month',
      'description': 'Billed monthly',
      'savings': '',
    },
    {
      'title': 'Lifetime',
      'price': '\$2.99',
      'period': 'one-time',
      'description': 'Pay once, own forever',
      'savings': 'Best Value',
    },
  ];

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.block,
      'title': 'Remove All Ads',
      'description': 'Enjoy reading without any interruptions',
    },
    // {
    //   'icon': Icons.location_on,
    //   'title': 'Unlimited Locations',
    //   'description': 'Track weather for unlimited cities',
    // },
    {
      'icon': Icons.star,
      'title': 'Premium Features',
      'description': 'Access all premium reading tools',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    bool result = await RevenueCatService().fetchPackages(
      fallbackPrices: [],
    );
    if (result == true) {
      setState(() {
        _plans[0]['price'] = RevenueCatService().prices[0];
        _plans[1]['price'] = RevenueCatService().prices[1];
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromARGB(255, 27, 34, 46), Color.fromARGB(255, 48, 52, 59), Color.fromARGB(255, 16, 19, 24)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Premium Icon with animation
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 60,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 32),
                // Loading indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                // Loading text
                Text(
                  'Loading premium plans...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return AnimatedOpacity(
      opacity: _isLoading ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 0),
                  _buildPremiumIcon(),
                  const SizedBox(height: 12),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const SizedBox(height: 12),
                  _buildFeaturesList(),
                  const SizedBox(height: 12),
                  _buildPricingPlans(),
                  const SizedBox(height: 12),
                  _buildSubscribeButton(),
                  _buildRestoreButton(),
                  const SizedBox(height: 8),
                  _buildTermsText(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40),
          const Text(
            'Remove Ads',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: const Icon(Icons.workspace_premium, size: 40, color: Colors.amber),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Remove Ads & Go Premium',
      style: TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enjoy ad-free reading and premium features',
      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeaturesList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: _features
            .map(
              (feature) => _FeatureItem(
                icon: feature['icon'] as IconData,
                title: feature['title'] as String,
                description: feature['description'] as String,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPricingPlans() {
    return Column(
      children: List.generate(
        _plans.length,
        (index) => _PlanCard(
          plan: _plans[index],
          isSelected: _selectedPlanIndex == index,
          onTap: () {
            setState(() {
              _selectedPlanIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          PurchaseResult purchaseResult = await RevenueCatService().purchase(
            _selectedPlanIndex,
          );
          if (purchaseResult.success && mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Purchase has been successful',
                  textAlign: TextAlign.center,
                ),
                backgroundColor: const Color(0xFF81C784),
                duration: const Duration(seconds: 2),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  purchaseResult.error ?? "Purchase failed",
                  textAlign: TextAlign.center,
                ),
                backgroundColor: const Color(0xFF81C784),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 82, 91, 95), Color.fromARGB(255, 114, 116, 119)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Text(
            'Subscribe Now',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: () async {
        RestoreResult restoreResult = await RevenueCatService().restore();
        // print(restoreResult.hasActiveSubscriptions);
        if (restoreResult.hasActiveSubscriptions) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Restoring purchases...',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Color(0xFF4FC3F7),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Text(
        'Restore Purchase',
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Auto-renew notice
          if (_plans[_selectedPlanIndex]['title'] == 'Monthly')
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Subscription automatically renews unless auto-renew is turned off at least 24 hours before the end of the current period.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Terms and Privacy with clickable links
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'By subscribing, you agree to our ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openTermsOfUse();
                },
                child: Text(
                  'Terms of Use',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _openPrivacyPolicy();
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openTermsOfUse() {
    const url = 'https://sites.google.com/view/tachiyomi-terms/home';
    _launchURL(url, 'Terms of Use');
  }

  void _openPrivacyPolicy() {
    const url = 'https://sites.google.com/view/tachiyomi-novel/home';
    _launchURL(url, 'Privacy Policy');
  }

  Future<void> _launchURL(String url, String title) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open $title'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening $title: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF81C784), size: 24),
        ],
      ),
    );
  }
}

// Plan Card Widget
class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    Colors.white.withOpacity(0.35),
                    Colors.white.withOpacity(0.25),
                  ]
                : [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                _buildRadioButton(),
                const SizedBox(width: 16),
                Expanded(child: _buildPlanDetails()),
                _buildPriceSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        color: isSelected ? Colors.white : Colors.transparent,
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2196F3),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildPlanDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              plan['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (plan['savings'].toString().isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan['savings'],
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          plan['description'],
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          plan['price'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          plan['period'],
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }
}
