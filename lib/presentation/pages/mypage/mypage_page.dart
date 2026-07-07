import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'address_search_page.dart';

class MyPageSettings {
  final String name;
  final String phone;
  final String address;
  final String detailAddress;
  final String deliveryRequest;
  final String deliveryRequestCustom;
  final String paymentMethod;
  final String cardNumber;
  final String cardExpiry;
  final String payAppId;

  const MyPageSettings({
    this.name = '',
    this.phone = '',
    this.address = '',
    this.detailAddress = '',
    this.deliveryRequest = '문 앞에 놓아주세요',
    this.deliveryRequestCustom = '',
    this.paymentMethod = '신용카드',
    this.cardNumber = '',
    this.cardExpiry = '',
    this.payAppId = '',
  });

  String get fullAddress => detailAddress.isNotEmpty
      ? '$address $detailAddress'
      : address;

  String get actualDeliveryRequest =>
      deliveryRequest == '기타' ? deliveryRequestCustom : deliveryRequest;

  MyPageSettings copyWith({
    String? name,
    String? phone,
    String? address,
    String? detailAddress,
    String? deliveryRequest,
    String? deliveryRequestCustom,
    String? paymentMethod,
    String? cardNumber,
    String? cardExpiry,
    String? payAppId,
  }) {
    return MyPageSettings(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      detailAddress: detailAddress ?? this.detailAddress,
      deliveryRequest: deliveryRequest ?? this.deliveryRequest,
      deliveryRequestCustom:
          deliveryRequestCustom ?? this.deliveryRequestCustom,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      payAppId: payAppId ?? this.payAppId,
    );
  }
}

final myPageSettingsProvider =
    NotifierProvider<MyPageSettingsNotifier, MyPageSettings>(
        MyPageSettingsNotifier.new);

class MyPageSettingsNotifier extends Notifier<MyPageSettings> {
  @override
  MyPageSettings build() => const MyPageSettings();

  void update(MyPageSettings settings) => state = settings;
}

class MyPage extends ConsumerStatefulWidget {
  const MyPage({super.key});

  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _deliveryCustomController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _payAppIdController = TextEditingController();
  final _detailAddressController = TextEditingController();

  final _deliveryRequests = [
    '문 앞에 놓아주세요',
    '경비실에 맡겨주세요',
    '직접 받겠습니다',
    '택배함에 넣어주세요',
    '기타',
  ];

  final _cardPayments = ['신용카드', '체크카드'];
  final _payAppPayments = ['카카오페이', '네이버페이', '토스페이'];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(myPageSettingsProvider);
    _nameController.text = settings.name;
    _phoneController.text = settings.phone;
    _addressController.text = settings.address;
    _detailAddressController.text = settings.detailAddress;
    _deliveryCustomController.text = settings.deliveryRequestCustom;
    _cardNumberController.text = settings.cardNumber;
    _cardExpiryController.text = settings.cardExpiry;
    _payAppIdController.text = settings.payAppId;

    // 실시간 미리보기 업데이트
    _addressController.addListener(() => setState(() {}));
    _detailAddressController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _deliveryCustomController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _payAppIdController.dispose();
    _detailAddressController.dispose();
    super.dispose();
  }

  void _save() {
    final errors = <String>[];
    final settings = ref.read(myPageSettingsProvider);
    final isCard = ['신용카드', '체크카드'].contains(settings.paymentMethod);
    final isPayApp = ['카카오페이', '네이버페이', '토스페이'].contains(settings.paymentMethod);

    // 전화번호 검사
    final phone = _phoneController.text.replaceAll('-', '');
    if (_phoneController.text.isEmpty) {
      errors.add('전화번호를 입력해주세요');
    } else if (phone.length < 10 || phone.length > 11) {
      errors.add('전화번호의 입력 형식이 올바르지 않습니다');
    }

    // 카드 결제 검사
    if (isCard) {
      final card = _cardNumberController.text.replaceAll('-', '');
      if (_cardNumberController.text.isEmpty) {
        errors.add('카드 번호를 입력해주세요');
      } else if (card.length < 16) {
        errors.add('카드 번호의 입력 형식이 올바르지 않습니다');
      }

      final expiry = _cardExpiryController.text.replaceAll('/', '');
      if (_cardExpiryController.text.isEmpty) {
        errors.add('유효기간을 입력해주세요');
      } else if (expiry.length < 4) {
        errors.add('유효기간의 입력 형식이 올바르지 않습니다');
      }
    }

    // 페이앱 검사
    if (isPayApp && settings.payAppId.isEmpty) {
      errors.add('${settings.paymentMethod} 연결이 필요해요');
    }

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: 8),
              Text('입력 오류'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(color: AppColors.error)),
                          Expanded(
                            child: Text(e,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('수정하기'),
            ),
          ],
        ),
      );
      return;
    }

    // 저장
    ref.read(myPageSettingsProvider.notifier).update(
          settings.copyWith(
            name: _nameController.text,
            phone: _phoneController.text,
            address: _addressController.text,
            detailAddress: _detailAddressController.text,
            deliveryRequestCustom: _deliveryCustomController.text,
            cardNumber: _cardNumberController.text,
            cardExpiry: _cardExpiryController.text,
            payAppId: _payAppIdController.text,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('저장됐어요! ✅'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(myPageSettingsProvider);
    final user = ref.watch(currentUserProvider);
    final isCard = _cardPayments.contains(settings.paymentMethod);
    final isPayApp = _payAppPayments.contains(settings.paymentMethod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              '저장',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 프로필
                _SectionCard(
                  title: '프로필',
                  icon: Icons.person_outline,
                  child: Column(
                    children: [
                      _InfoRow(label: '이메일', value: user?.email ?? ''),
                      const SizedBox(height: 12),
                      _InputField(
                        label: '이름',
                        controller: _nameController,
                        hint: '이름을 입력해주세요',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      _InputField(
                        label: '전화번호',
                        controller: _phoneController,
                        hint: '010-0000-0000',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        maxLength: 13,
                        helperText: '숫자만 입력하면 자동으로 형식이 맞춰져요',
                        inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            _PhoneNumberFormatter(),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 16),

                // 배송 정보
                _SectionCard(
                    title: '기본 배송 정보',
                    icon: Icons.local_shipping_outlined,
                    child: Column(
                        children: [
                        // 주소 검색 필드
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '기본 주소',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _addressController,
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      hintText: '주소 검색을 눌러주세요',
                                      prefixIcon: Icon(Icons.home_outlined, size: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AddressSearchPage(),
                                        fullscreenDialog: true,
                                      ),
                                    );
                                    if (result != null) {
                                      _addressController.text = result;
                                      // 주소 변경 시 세부 주소 초기화
                                      _detailAddressController.clear();
                                    }
                                  },
                                  icon: const Icon(Icons.search, size: 16),
                                  label: const Text('검색'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 세부 주소 (기본 주소 입력 후 표시)
                            if (_addressController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextField(
                                controller: _detailAddressController,
                                decoration: const InputDecoration(
                                  hintText: '상세 주소를 입력해주세요 (동/호수 등)',
                                  prefixIcon: Icon(Icons.apartment_outlined, size: 18),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // 전체 주소 미리보기
                              if (_detailAddressController.text.isNotEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: AppColors.primary.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle_outline,
                                          size: 14, color: AppColors.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${_addressController.text} ${_detailAddressController.text}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        _DropdownField(
                            label: '배송 요청사항',
                            value: settings.deliveryRequest,
                            items: _deliveryRequests,
                            icon: Icons.note_outlined,
                            onChanged: (value) {
                            if (value != null) {
                                ref
                                    .read(myPageSettingsProvider.notifier)
                                    .update(settings.copyWith(deliveryRequest: value));
                            }
                            },
                        ),
                        // 기타 선택 시 직접 입력
                        if (settings.deliveryRequest == '기타') ...[
                            const SizedBox(height: 12),
                            _InputField(
                            label: '직접 입력',
                            controller: _deliveryCustomController,
                            hint: '배송 요청사항을 입력해주세요',
                            icon: Icons.edit_outlined,
                            ),
                        ],
                        ],
                    ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),

                // 결제 수단
                _SectionCard(
                  title: '기본 결제 수단',
                  icon: Icons.payment_outlined,
                  child: Column(
                    children: [
                      _DropdownField(
                        label: '결제 수단',
                        value: settings.paymentMethod,
                        items: [..._cardPayments, ..._payAppPayments],
                        icon: Icons.credit_card_outlined,
                        onChanged: (value) {
                          if (value != null) {
                            ref
                                .read(myPageSettingsProvider.notifier)
                                .update(settings.copyWith(
                                    paymentMethod: value));
                          }
                        },
                      ),
                      // 카드 결제
                      if (isCard) ...[
                        const SizedBox(height: 12),
                        _InputField(
                            label: '카드 번호',
                            controller: _cardNumberController,
                            hint: '0000-0000-0000-0000',
                            icon: Icons.credit_card,
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardNumberFormatter(),
                            ],
                        ),
                        const SizedBox(height: 12),
                        _InputField(
                            label: '유효기간',
                            controller: _cardExpiryController,
                            hint: 'MM/YY',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CardExpiryFormatter(),
                            ],
                        ),
                      ],
                      // 페이 앱 연결
                      if (isPayApp) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getPayAppIcon(settings.paymentMethod),
                                color: _getPayAppColor(settings.paymentMethod),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      settings.paymentMethod,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      settings.payAppId.isNotEmpty
                                          ? '연결됨: ${settings.payAppId}'
                                          : '연결되지 않음',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: settings.payAppId.isNotEmpty
                                                ? AppColors.success
                                                : AppColors.textHint,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _showPayAppDialog(context, settings),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 13),
                                ),
                                child: Text(settings.payAppId.isNotEmpty
                                    ? '재연결'
                                    : '연결하기'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 16),

                // 계정
                _SectionCard(
                  title: '계정',
                  icon: Icons.manage_accounts_outlined,
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(authActionProvider).signOut(),
                      icon:
                          const Icon(Icons.logout, color: AppColors.error),
                      label: const Text(
                        '로그아웃',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPayAppDialog(BuildContext context, MyPageSettings settings) {
    final controller =
        TextEditingController(text: settings.payAppId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${settings.paymentMethod} 연결'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${settings.paymentMethod} 계정 이메일 또는 ID를 입력해주세요.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '이메일 또는 ID',
                prefixIcon: Icon(
                  _getPayAppIcon(settings.paymentMethod),
                  color: _getPayAppColor(settings.paymentMethod),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(myPageSettingsProvider.notifier).update(
                    settings.copyWith(payAppId: controller.text),
                  );
              _payAppIdController.text = controller.text;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('${settings.paymentMethod} 연결됐어요! ✅'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: const Text('연결하기'),
          ),
        ],
      ),
    );
  }

  IconData _getPayAppIcon(String method) {
    switch (method) {
      case '카카오페이':
        return Icons.chat_bubble_outline;
      case '네이버페이':
        return Icons.search;
      case '토스페이':
        return Icons.send_outlined;
      default:
        return Icons.payment;
    }
  }

  Color _getPayAppColor(String method) {
    switch (method) {
      case '카카오페이':
        return const Color(0xFFFFE000);
      case '네이버페이':
        return const Color(0xFF03C75A);
      case '토스페이':
        return const Color(0xFF0064FF);
      default:
        return AppColors.primary;
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : '미설정',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? helperText;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            helperText: helperText,
            counterText: '',
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Row(
                          children: [
                            Icon(icon,
                                size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(item),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// 전화번호 포매터 (010-0000-0000)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    if (digits.length > 11) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// 카드번호 포매터 (0000-0000-0000-0000)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('-', '');
    if (digits.length > 16) return oldValue;

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write('-');
      buffer.write(digits[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// 유효기간 포매터 (MM/YY)
class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;

    // 월 유효성 검사 (01~12)
    if (digits.length >= 2) {
      final month = int.tryParse(digits.substring(0, 2));
      if (month == null || month < 1 || month > 12) return oldValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}