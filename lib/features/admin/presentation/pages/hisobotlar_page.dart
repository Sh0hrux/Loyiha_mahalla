import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../ariza/presentation/providers/ariza_provider.dart';
import '../../../muammo/presentation/providers/muammo_provider.dart';
import '../../../navbat/presentation/providers/navbat_provider.dart';
import '../../../elon/presentation/providers/elon_provider.dart';
import '../../data/services/pdf_service.dart';

class HisobotlarPage extends ConsumerStatefulWidget {
  const HisobotlarPage({super.key});

  @override
  ConsumerState<HisobotlarPage> createState() => _HisobotlarPageState();
}

class _HisobotlarPageState extends ConsumerState<HisobotlarPage> {
  DateTime? selectedMonth;
  String selectedFilter = 'all'; // 'all', 'month'

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final arizalarAsync = ref.watch(allArizalarProvider);
    final muammolarAsync = ref.watch(allMuammolarProvider);
    final navbatlarAsync = ref.watch(allNavbatlarProvider);
    final elonlarAsync = ref.watch(allElonlarProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Hisobotlar va Tahlil',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.filter_list_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Filtr',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Filter Chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChip(
                                label: 'Barchasi',
                                isSelected: selectedFilter == 'all',
                                onTap: () {
                                  setState(() {
                                    selectedFilter = 'all';
                                  });
                                },
                              ),
                              _FilterChip(
                                label: 'Oylik',
                                isSelected: selectedFilter == 'month',
                                onTap: () {
                                  setState(() {
                                    selectedFilter = 'month';
                                  });
                                },
                              ),
                            ],
                          ),

                          // Month Selector (if month filter is selected)
                          if (selectedFilter == 'month') ...[
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectMonth(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        selectedMonth != null
                                            ? DateFormat('MMMM yyyy', 'uz')
                                                .format(selectedMonth!)
                                            : 'Oyni tanlang',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics based on filter
                    _buildStatistics(
                      arizalarAsync,
                      muammolarAsync,
                      navbatlarAsync,
                      elonlarAsync,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      locale: const Locale('uz', 'UZ'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedMonth = picked;
      });
    }
  }

  bool _isInSelectedMonth(DateTime date) {
    if (selectedFilter != 'month' || selectedMonth == null) return true;
    return date.year == selectedMonth!.year &&
        date.month == selectedMonth!.month;
  }

  Future<void> _exportToPdf(
    AsyncValue arizalarAsync,
    AsyncValue muammolarAsync,
    AsyncValue navbatlarAsync,
    AsyncValue elonlarAsync,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await arizalarAsync.when(
        data: (arizalar) async {
          await muammolarAsync.when(
            data: (muammolar) async {
              await navbatlarAsync.when(
                data: (navbatlar) async {
                  await elonlarAsync.when(
                    data: (elonlar) async {
                      // Filter data
                      final filteredArizalar = arizalar
                          .where((item) => _isInSelectedMonth(item.createdAt))
                          .toList();
                      final filteredMuammolar = muammolar
                          .where((item) => _isInSelectedMonth(item.createdAt))
                          .toList();
                      final filteredNavbatlar = navbatlar
                          .where((item) => _isInSelectedMonth(item.createdAt))
                          .toList();
                      final filteredElonlar = elonlar
                          .where((item) => _isInSelectedMonth(item.createdAt))
                          .toList();

                      // Prepare status data
                      final Map<String, int> arizalarStatus = {
                        'yuborildi': filteredArizalar
                            .where((a) => a.status == 'yuborildi')
                            .length,
                        'ko\'rilmoqda': filteredArizalar
                            .where((a) => a.status == 'ko\'rilmoqda')
                            .length,
                        'bajarildi': filteredArizalar
                            .where((a) => a.status == 'bajarildi')
                            .length,
                        'rad_etildi': filteredArizalar
                            .where((a) => a.status == 'rad_etildi')
                            .length,
                      };

                      final Map<String, int> muammolarStatus = {
                        'yuborildi': filteredMuammolar
                            .where((m) => m.status == 'yuborildi')
                            .length,
                        'ko\'rilmoqda': filteredMuammolar
                            .where((m) => m.status == 'ko\'rilmoqda')
                            .length,
                        'hal_qilindi': filteredMuammolar
                            .where((m) => m.status == 'hal_qilindi')
                            .length,
                        'rad_etildi': filteredMuammolar
                            .where((m) => m.status == 'rad_etildi')
                            .length,
                      };

                      final Map<String, int> navbatlarStatus = {
                        'kutilmoqda': filteredNavbatlar
                            .where((n) => n.status == 'kutilmoqda')
                            .length,
                        'tasdiqlandi': filteredNavbatlar
                            .where((n) => n.status == 'tasdiqlandi')
                            .length,
                        'tugallandi': filteredNavbatlar
                            .where((n) => n.status == 'tugallandi')
                            .length,
                        'bekor_qilindi': filteredNavbatlar
                            .where((n) => n.status == 'bekor_qilindi')
                            .length,
                      };

                      // Generate PDF
                      await PdfService.generateHisobotPdf(
                        title: 'Hisobotlar va Tahlil',
                        selectedMonth: selectedFilter == 'month'
                            ? selectedMonth
                            : null,
                        arizalarCount: filteredArizalar.length,
                        muammolarCount: filteredMuammolar.length,
                        navbatlarCount: filteredNavbatlar.length,
                        elonlarCount: filteredElonlar.length,
                        arizalarStatus: arizalarStatus,
                        muammolarStatus: muammolarStatus,
                        navbatlarStatus: navbatlarStatus,
                      );

                      if (mounted) {
                        Navigator.pop(context); // Close loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('PDF muvaffaqiyatli yaratildi'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    loading: () {},
                    error: (_, __) {},
                  );
                },
                loading: () {},
                error: (_, __) {},
              );
            },
            loading: () {},
            error: (_, __) {},
          );
        },
        loading: () {},
        error: (_, __) {},
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatistics(
    AsyncValue arizalarAsync,
    AsyncValue muammolarAsync,
    AsyncValue navbatlarAsync,
    AsyncValue elonlarAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Umumiy Statistika
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assessment_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedFilter == 'month' && selectedMonth != null
                      ? '${DateFormat('MMMM yyyy', 'uz').format(selectedMonth!)} - Statistika'
                      : 'Umumiy Statistika',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Statistics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.95,
          children: [
            _StatCard(
              icon: Icons.description_outlined,
              title: 'Arizalar',
              count: arizalarAsync.when(
                data: (list) {
                  final filtered = list.where((item) => _isInSelectedMonth(item.createdAt)).toList();
                  return filtered.length.toString();
                },
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: const Color(0xFF4F46E5),
            ),
            _StatCard(
              icon: Icons.report_problem_outlined,
              title: 'Muammolar',
              count: muammolarAsync.when(
                data: (list) {
                  final filtered = list.where((item) => _isInSelectedMonth(item.createdAt)).toList();
                  return filtered.length.toString();
                },
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: const Color(0xFFDC2626),
            ),
            _StatCard(
              icon: Icons.event_available_outlined,
              title: 'Navbatlar',
              count: navbatlarAsync.when(
                data: (list) {
                  final filtered = list.where((item) => _isInSelectedMonth(item.createdAt)).toList();
                  return filtered.length.toString();
                },
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: const Color(0xFF059669),
            ),
            _StatCard(
              icon: Icons.campaign_outlined,
              title: 'E\'lonlar',
              count: elonlarAsync.when(
                data: (list) {
                  final filtered = list.where((item) => _isInSelectedMonth(item.createdAt)).toList();
                  return filtered.length.toString();
                },
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Status bo'yicha Arizalar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Status bo\'yicha Arizalar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        arizalarAsync.when(
          data: (arizalar) {
            final filtered = arizalar.where((item) => _isInSelectedMonth(item.createdAt)).toList();
            final yuborildi = filtered.where((a) => a.status == 'yuborildi').length;
            final korilmoqda = filtered.where((a) => a.status == 'ko\'rilmoqda').length;
            final bajarildi = filtered.where((a) => a.status == 'bajarildi').length;
            final radEtildi = filtered.where((a) => a.status == 'rad_etildi').length;

            return Column(
              children: [
                _StatusRow(
                  label: 'Yuborildi',
                  count: yuborildi,
                  total: filtered.length,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Ko\'rilmoqda',
                  count: korilmoqda,
                  total: filtered.length,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Bajarildi',
                  count: bajarildi,
                  total: filtered.length,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Rad etildi',
                  count: radEtildi,
                  total: filtered.length,
                  color: Colors.red,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Xatolik yuz berdi')),
        ),

        const SizedBox(height: 32),

        // Status bo'yicha Muammolar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Status bo\'yicha Muammolar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        muammolarAsync.when(
          data: (muammolar) {
            final filtered = muammolar.where((item) => _isInSelectedMonth(item.createdAt)).toList();
            final yuborildi = filtered.where((m) => m.status == 'yuborildi').length;
            final korilmoqda = filtered.where((m) => m.status == 'ko\'rilmoqda').length;
            final halQilindi = filtered.where((m) => m.status == 'hal_qilindi').length;
            final radEtildi = filtered.where((m) => m.status == 'rad_etildi').length;

            return Column(
              children: [
                _StatusRow(
                  label: 'Yuborildi',
                  count: yuborildi,
                  total: filtered.length,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Ko\'rilmoqda',
                  count: korilmoqda,
                  total: filtered.length,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Hal qilindi',
                  count: halQilindi,
                  total: filtered.length,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Rad etildi',
                  count: radEtildi,
                  total: filtered.length,
                  color: Colors.red,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Xatolik yuz berdi')),
        ),

        const SizedBox(height: 32),

        // Navbatlar Statistikasi
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Navbatlar Statistikasi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        navbatlarAsync.when(
          data: (navbatlar) {
            final filtered = navbatlar.where((item) => _isInSelectedMonth(item.createdAt)).toList();
            final kutilmoqda = filtered.where((n) => n.status == 'kutilmoqda').length;
            final tasdiqlandi = filtered.where((n) => n.status == 'tasdiqlandi').length;
            final tugallandi = filtered.where((n) => n.status == 'tugallandi').length;
            final bekorQilindi = filtered.where((n) => n.status == 'bekor_qilindi').length;

            return Column(
              children: [
                _StatusRow(
                  label: 'Kutilmoqda',
                  count: kutilmoqda,
                  total: filtered.length,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Tasdiqlandi',
                  count: tasdiqlandi,
                  total: filtered.length,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Tugallandi',
                  count: tugallandi,
                  total: filtered.length,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: 'Bekor qilindi',
                  count: bekorQilindi,
                  total: filtered.length,
                  color: Colors.red,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Xatolik yuz berdi')),
        ),

        const SizedBox(height: 32),

        // PDF Export Button - Katta va chiroyli
        Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => _exportToPdf(
              arizalarAsync,
              muammolarAsync,
              navbatlarAsync,
              elonlarAsync,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PDF yuklash',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Hisobotni saqlash',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// Filter Chip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ta ($percentage%)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
