import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:captcha_plugin_flutter/captcha_plugin_flutter.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';
import '../../utils/hank_auth_manager.dart';
import '../../models/hank_user_model.dart';
import '../common/hank_local_web_page.dart';

/// HankLoginPage: Login/Registerview
/// withZogoLivedifferentiatedlayoutmatch：lightpurple+whitecolorhometheme、cardstyletablesingle、roundedinputfield
/// flow：email+verificationcodeLogin → SaveToken → getuseaccountinfo → Back
/// API：POST /api/livespeed/auth/send-verify（sendverificationcode）
///       POST /api/livespeed/auth/login（Login）
///       GET /api/livespeed/member（getuseaccountinfo）
class HankLoginPage extends StatefulWidget {
  const HankLoginPage({Key? key}) : super(key: key);

  @override
  State<HankLoginPage> createState() => _HankLoginPageState();
}

class _HankLoginPageState extends State<HankLoginPage> {
  /// emailinputcontroller - TextEditingControllertype，listenemailinputfieldcontent
  final TextEditingController _emailController = TextEditingController();

  /// verificationcodeinputcontroller - TextEditingControllertype，listenverificationcodeinputfieldcontent
  final TextEditingController _codeController = TextEditingController();

  /// whethersameagreeagreement - booltype，truemeansalreadycheckselectTerms of ServicewithPrivacy Policy
  bool _isAgree = false;

  /// whetheractiveinLogin - booltype，truemeansLoginrequestIn Progress，preventduplicateSubmit
  bool _isLoading = false;

  /// whetheractiveinsendverificationcode - booltype，truemeanssendverificationcoderequestIn Progress
  bool _isSendingCode = false;

  /// countdownremainingsecondscount - inttype，0meansnotincountdown，>0whenbuttonnotcantap
  int _countdown = 0;

  /// countdownsetwhenindicator - Timer?type，useexpirypropertyrefreshcountdownsecondscount，pagedestroywhenneedcancel
  Timer? _countdownTimer;

  /// webcaptchacaptchapersonbotverificationinsertiteminstance - CaptchaPluginFluttertype，usecallstartslideblock/click verification
  final CaptchaPluginFlutter _captchaPlugin = CaptchaPluginFlutter();

  /// webcaptchacaptchaCodebusinessID - Stringtype，captchaafterplatformcategorydispatchVerifyCode
  static const String _captchaVerifyCode = '69d5b2ee3fec46658e01c0b45fc381af';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    _captchaPlugin.destroyCaptcha();
    super.dispose();
  }

  /// tapgetverificationcode
  /// verifyemailnonemptyafter，initiate captcha verification，verificationsuccessafterrequestsendverificationcodeAPI
  void _handleGetVerifyCode() {
    if (_countdown > 0 || _isSendingCode) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Please enteremail');
      return;
    }

    // initiate captcha verification
    _captchaPlugin.init({
      'captcha_id': _captchaVerifyCode,
      // Load failedwhen enabledusedownlevelplan，supporttapretry
      'use_default_fallback': true,
      // autodownlevelretrytimecount
      'failed_max_retry_count': 3,
      // timeoutTime（msseconds）
      'timeout': 10000,
      // tappopupoutersectionnotdisappear
      'is_touch_outside_disappear': false,
      // matchclosebuttoninbottom
      'is_close_button_bottom': true,
    });
    _captchaPlugin.showCaptcha(
      onLoaded: () {
        debugPrint('captcha onLoaded');
      },
      onSuccess: (dynamic data) {
        // verificationsuccess，gettovalidateafterrequestsendverificationcodeAPI
        debugPrint('captcha onSuccess: $data');
        final String validate = data['validate'] ?? '';
        if (validate.isNotEmpty) {
          _sendVerifyCode(validate);
        }
      },
      onError: (dynamic data) {
        // verificationfailed
        debugPrint('captcha onError: $data');
        _showSnackBar('verificationfailed，please retry');
      },
      onClose: (dynamic data) {
        // useaccountmatchclose verificationpopup
        debugPrint('captcha onClose: $data');
      },
    );
  }

  /// requestsendemailverificationcode
  /// API：POST /api/livespeed/auth/send-verify
  /// paramcount：validate - personbotverificationBackvalidate；account - email；channel - "email"；scene - "sms-login"
  /// successafterenable60secondscountdown
  Future<void> _sendVerifyCode(String validate) async {
    setState(() => _isSendingCode = true);

    try {
      final response = await HankNetworkManager().postRequest(
        '/api/livespeed/auth/send-verify',
        data: {
          'validate': validate,
          'account': _emailController.text.trim(),
          'channel': 'email',
          'scene': 'sms-login',
        },
      );

      if (response.isSuccess) {
        _showSnackBar('verificationcodealreadysend，pleasesearchreceiveemail');
        _startCountdown();
      } else {
        _showSnackBar(response.message ?? 'verificationcodesendfailed');
      }
    } catch (e) {
      _showSnackBar('Network error，please retry');
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  /// enable60secondscountdown
  /// eachsecondsrefreshremainingsecondscount，countdownexpirybetweenbuttonsetgreynotcantap，endedafterrestore
  void _startCountdown() {
    setState(() => _countdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  /// handleLogin
  /// verifyemail、verificationcode、agreementcheckselectafter，basedtimerequestLoginAPIanduseaccountinfoAPI
  /// LoginsuccessafterSaveTokenanduseaccountinfo，Backupapage
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('Please enteremail');
      return;
    }
    if (_codeController.text.isEmpty) {
      _showSnackBar('Please enterverificationcode');
      return;
    }
    if (!_isAgree) {
      _showSnackBar('pleasesameagreeTerms of ServicewithPrivacy Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // astep：calluseLoginAPI
      final loginResponse = await HankNetworkManager().postRequest(
        '/api/livespeed/auth/login',
        data: {
          'channel': 'email',
          'account': _emailController.text.trim(),
          'code': _codeController.text.trim(),
        },
      );

      if (loginResponse.isSuccess && loginResponse.data != null) {
        final refreshToken = loginResponse.data['refresh_token'] as String?;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // SaveTokenandSettingsrequestheader
          await HankAuthManager().saveToken(refreshToken);

          // step 2：requestuseaccountinfo
          final userResponse = await HankNetworkManager().getRequest(
            '/api/livespeed/member',
          );

          if (userResponse.isSuccess && userResponse.data != null) {
            // parseandSaveuseaccountinfo
            final userModel = HankUserModel.fromJson(
              userResponse.data as Map<String, dynamic>,
            );
            await HankAuthManager().saveUserInfo(userModel);

            if (mounted) {
              _showSnackBar('Loginsuccess');
              Navigator.of(context).pop(true);
            }
          } else {
            _showSnackBar(userResponse.message ?? 'getuseaccountinfofailed');
          }
        } else {
          _showSnackBar('Loginfailed：Tokenerror');
        }
      } else {
        _showSnackBar(loginResponse.message ?? 'Loginfailed');
      }
    } catch (e) {
      _showSnackBar('Network error，please retry');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// displaySnackBarhint
  /// [message] - Stringtype，hinttext
  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.violet50,
        body: Stack(
          children: [
            // backgrounddecorationcircle
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet200.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet100.withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // homecontent
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 28),
                    _buildTitleSection(),
                    const SizedBox(height: 32),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildCodeField(),
                    const SizedBox(height: 16),
                    _buildAgreementRow(),
                    const SizedBox(height: 28),
                    _buildLoginButton(),
                    const Spacer(),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// topnavbar（Backbutton + Logo）
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Backbutton
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A8B5CF6),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.chevron_left,
              color: AppColors.violet700,
              size: 18,
            ),
          ),
        ),
        // Logobadge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A8B5CF6),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.violet600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'HANKLIVE',
                style: TextStyle(
                  color: AppColors.violet700,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// titlearea（Login/Registertitle + subtitle）
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.violet600, width: 3),
            ),
          ),
          child: const Text(
            'Login / Register',
            style: TextStyle(
              color: AppColors.slate800,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'inputemailiscanLoginorRegister，enjoypitchmatch',
          style: TextStyle(
            color: AppColors.slate500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// emailinputfield（differentiated：whitecolorcard+purpleicon+lefttagitem）
  Widget _buildEmailField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.violet200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // leftpurpletagitem
          Container(
            width: 4,
            height: 24,
            margin: const EdgeInsets.only(left: 14),
            decoration: BoxDecoration(
              color: AppColors.violet400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.email_outlined, color: AppColors.violet400, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: AppColors.slate800,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Please enteremailaddress',
                hintStyle: TextStyle(
                  color: AppColors.slate400,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// verificationcodeinputfield + getverificationcodebutton
  Widget _buildCodeField() {
    return Row(
      children: [
        // verificationcodeinputfield
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.violet200),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F8B5CF6),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  margin: const EdgeInsets.only(left: 14),
                  decoration: BoxDecoration(
                    color: AppColors.violet400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.shield_outlined, color: AppColors.violet400, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      color: AppColors.slate800,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: '',
                      hintText: 'verificationcode',
                      hintStyle: TextStyle(
                        color: AppColors.slate400,
                        fontSize: 13,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // getverificationcodebutton
        GestureDetector(
          onTap: (_countdown > 0 || _isSendingCode) ? null : _handleGetVerifyCode,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _countdown > 0
                  ? AppColors.violet100
                  : AppColors.violet600,
              borderRadius: BorderRadius.circular(14),
              boxShadow: _countdown > 0
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x337C3AED),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
            ),
            child: _isSendingCode
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _countdown > 0 ? '${_countdown}s' : 'Get Code',
                    style: TextStyle(
                      color: _countdown > 0
                          ? AppColors.slate500
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  /// agreementcheckselectrow
  Widget _buildAgreementRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // checkselectfield
        GestureDetector(
          onTap: () => setState(() => _isAgree = !_isAgree),
          child: Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: _isAgree ? AppColors.violet600 : Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _isAgree ? AppColors.violet600 : AppColors.violet300,
              ),
            ),
            child: _isAgree
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        // agreement text
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAgree = !_isAgree),
            child: Text.rich(
              TextSpan(
                text: 'Ialreadyreadingandsameagree ',
                style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(color: AppColors.violet600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HankLocalWebPage(
                              assetPath:
                                  'assets/htmlSource/user-agreement.html',
                              title: 'Terms of Service',
                            ),
                          ),
                        );
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(color: AppColors.violet600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HankLocalWebPage(
                              assetPath:
                                  'assets/htmlSource/privacy-agreement.html',
                              title: 'Privacy Policy',
                            ),
                          ),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Loginbutton
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.violet600,
              AppColors.violet400,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D7C3AED),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
        ),
      ),
    );
  }

  /// bottomcopyrightinfo
  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2026 HankLive. All rights reserved.',
        style: TextStyle(
          color: AppColors.slate400,
          fontSize: 11,
        ),
      ),
    );
  }
}
