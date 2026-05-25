import 'package:chapasdk/chapasdk.dart';
import 'package:flutter/material.dart';

void launchChapaPayment({
  required BuildContext context,
  required String publicKey,
  required String currency,
  required String amount,
  required String email,
  required String firstName,
  required String lastName,
  required String phone,
  required String txRef,
  required String title,
  required String desc,
  List<String> availablePaymentMethods = const [
    'mpesa',
    'cbebirr',
    'telebirr',
    'ebirr',
  ],
  required void Function(String message, String reference, String amount)
  onPaymentFinished,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder:
          (_) => _ChapaShell(
            publicKey: publicKey,
            currency: currency,
            amount: amount,
            email: email,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
            txRef: txRef,
            title: title,
            desc: desc,
            availablePaymentMethods: availablePaymentMethods,
            onPaymentFinished: onPaymentFinished,
          ),
    ),
  );
}

class _ChapaShell extends StatelessWidget {
  final String publicKey;
  final String currency;
  final String amount;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String txRef;
  final String title;
  final String desc;
  final List<String> availablePaymentMethods;
  final void Function(String, String, String) onPaymentFinished;

  const _ChapaShell({
    required this.publicKey,
    required this.currency,
    required this.amount,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.txRef,
    required this.title,
    required this.desc,
    required this.availablePaymentMethods,
    required this.onPaymentFinished,
  });

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          // Chapa's exitPaymentPage triggered /home — pop the shell back to Go Router.
          // Must be deferred because we're currently inside a route generation callback.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: SizedBox.shrink()),
          );
        }
        // Initial '/' route — render the Chapa launcher inside the local navigator.
        return MaterialPageRoute<void>(
          builder:
              (innerCtx) => _ChapaLauncher(
                publicKey: publicKey,
                currency: currency,
                amount: amount,
                email: email,
                firstName: firstName,
                lastName: lastName,
                phone: phone,
                txRef: txRef,
                title: title,
                desc: desc,
                availablePaymentMethods: availablePaymentMethods,
                onPaymentFinished: onPaymentFinished,
              ),
        );
      },
      initialRoute: '/',
    );
  }
}

class _ChapaLauncher extends StatefulWidget {
  final String publicKey;
  final String currency;
  final String amount;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;
  final String txRef;
  final String title;
  final String desc;
  final List<String> availablePaymentMethods;
  final void Function(String, String, String) onPaymentFinished;

  const _ChapaLauncher({
    required this.publicKey,
    required this.currency,
    required this.amount,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.txRef,
    required this.title,
    required this.desc,
    required this.availablePaymentMethods,
    required this.onPaymentFinished,
  });

  @override
  State<_ChapaLauncher> createState() => _ChapaLauncherState();
}

class _ChapaLauncherState extends State<_ChapaLauncher> {
  @override
  void initState() {
    super.initState();
    // Open Chapa after the first frame so the local Navigator is fully built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Chapa.paymentParameters(
        context: context, // local Navigator's context — exitPaymentPage uses this navigator
        publicKey: widget.publicKey,
        currency: widget.currency,
        amount: widget.amount,
        email: widget.email,
        firstName: widget.firstName,
        lastName: widget.lastName,
        phone: widget.phone,
        txRef: widget.txRef,
        title: widget.title,
        desc: widget.desc,
        nativeCheckout: true,
        namedRouteFallBack: '/home', // handled by _ChapaShell's local Navigator
        showPaymentMethodsOnGridView: true,
        availablePaymentMethods: widget.availablePaymentMethods,
        onPaymentFinished: widget.onPaymentFinished,
      );
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
