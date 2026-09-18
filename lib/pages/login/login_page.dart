import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:captcha_plugin_flutter/captcha_plugin_flutter.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';
import '../../utils/hank_auth_manager.dart';
import '../../models/hank_user_model.dart';
import '../common/hank_local_web_page.dart';

/// HankLoginPage: 登录/注册界面
/// 与ZogoLive差异化布局：浅紫色+白色主题、卡片式表单、圆角输入框
/// 流程：邮箱+验证码登录 → 保存Token → 获取用户信息 → 返回
/// 接口：POST /api/livespeed/auth/send-verify（发送验证码）
///       POST /api/livespeed/auth/login（登录）
///       GET /api/livespeed/member（获取用户信息）
class HankLoginPage extends StatefulWidget {
  const HankLoginPage({Key? key}) : super(key: key);

  @override
  State<HankLoginPage> createState() => _HankLoginPageState();
}

class _HankLoginPageState extends State<HankLoginPage> {
  /// 邮箱输入控制器 - TextEditingController类型，监听邮箱输入框内容
  final TextEditingController _emailController = TextEditingController();

  /// 验证码输入控制器 - TextEditingController类型，监听验证码输入框内容
  final TextEditingController _codeController = TextEditingController();

  /// 是否同意协议 - bool类型，true表示已勾选服务条款与隐私政策
  bool _isAgree = false;

  /// 是否正在登录 - bool类型，true表示登录请求进行中，防止重复提交
  bool _isLoading = false;

  /// 是否正在发送验证码 - bool类型，true表示发送验证码请求进行中
  bool _isSendingCode = false;

  /// 倒计时剩余秒数 - int类型，0表示未在倒计时，>0时按钮不可点击
  int _countdown = 0;

  /// 倒计时定时器 - Timer?类型，用于周期性刷新倒计时秒数，页面销毁时需cancel
  Timer? _countdownTimer;

  /// 网易易盾人机验证插件实例 - CaptchaPluginFlutter类型，用于调起滑块/点选验证
  final CaptchaPluginFlutter _captchaPlugin = CaptchaPluginFlutter();

  /// 网易易盾Code业务ID - String类型，易盾后台分配的VerifyCode
  static const String _captchaVerifyCode = '69d5b2ee3fec46658e01c0b45fc381af';

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    _captchaPlugin.destroyCaptcha();
    super.dispose();
  }

  /// 点击获取验证码
  /// 校验邮箱非空后，调起网易易盾人机验证，验证成功后请求发送验证码接口
  void _handleGetVerifyCode() {
    if (_countdown > 0 || _isSendingCode) return;

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('请输入邮箱');
      return;
    }

    // 调起网易易盾人机验证
    _captchaPlugin.init({
      'captcha_id': _captchaVerifyCode,
      // Load failed时启用降级方案，支持点击重试
      'use_default_fallback': true,
      // 自动降级重试次数
      'failed_max_retry_count': 3,
      // 超时时间（毫秒）
      'timeout': 10000,
      // 点击弹窗外部不消失
      'is_touch_outside_disappear': false,
      // 关闭按钮在底部
      'is_close_button_bottom': true,
    });
    _captchaPlugin.showCaptcha(
      onLoaded: () {
        debugPrint('captcha onLoaded');
      },
      onSuccess: (dynamic data) {
        // 验证成功，拿到validate后请求发送验证码接口
        debugPrint('captcha onSuccess: $data');
        final String validate = data['validate'] ?? '';
        if (validate.isNotEmpty) {
          _sendVerifyCode(validate);
        }
      },
      onError: (dynamic data) {
        // 验证失败
        debugPrint('captcha onError: $data');
        _showSnackBar('验证失败，请重试');
      },
      onClose: (dynamic data) {
        // 用户关闭验证弹窗
        debugPrint('captcha onClose: $data');
      },
    );
  }

  /// 请求发送邮箱验证码
  /// 接口：POST /api/livespeed/auth/send-verify
  /// 参数：validate - 人机验证返回的validate；account - 邮箱；channel - "email"；scene - "sms-login"
  /// 成功后开启60秒倒计时
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
        _showSnackBar('验证码已发送，请查收邮箱');
        _startCountdown();
      } else {
        _showSnackBar(response.message ?? '验证码发送失败');
      }
    } catch (e) {
      _showSnackBar('网络错误，请重试');
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  /// 开启60秒倒计时
  /// 每秒刷新剩余秒数，倒计时期间按钮置灰不可点击，结束后恢复
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

  /// 处理登录
  /// 校验邮箱、验证码、协议勾选后，依次请求登录接口和用户信息接口
  /// 登录成功后保存Token和用户信息，返回上一页
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty) {
      _showSnackBar('请输入邮箱');
      return;
    }
    if (_codeController.text.isEmpty) {
      _showSnackBar('请输入验证码');
      return;
    }
    if (!_isAgree) {
      _showSnackBar('请同意服务条款与隐私政策');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 第一步：调用登录接口
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
          // 保存Token并设置请求头
          await HankAuthManager().saveToken(refreshToken);

          // 第二步：请求用户信息
          final userResponse = await HankNetworkManager().getRequest(
            '/api/livespeed/member',
          );

          if (userResponse.isSuccess && userResponse.data != null) {
            // 解析并保存用户信息
            final userModel = HankUserModel.fromJson(
              userResponse.data as Map<String, dynamic>,
            );
            await HankAuthManager().saveUserInfo(userModel);

            if (mounted) {
              _showSnackBar('登录成功');
              Navigator.of(context).pop(true);
            }
          } else {
            _showSnackBar(userResponse.message ?? '获取用户信息失败');
          }
        } else {
          _showSnackBar('登录失败：Token异常');
        }
      } else {
        _showSnackBar(loginResponse.message ?? '登录失败');
      }
    } catch (e) {
      _showSnackBar('网络错误，请重试');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 显示SnackBar提示
  /// [message] - String类型，提示文案
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
            // 背景装饰圆
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
            // 主内容
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

  /// 顶部导航栏（返回按钮 + Logo）
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 返回按钮
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
        // Logo标识
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

  /// 标题区域（登录/注册标题 + 副标题）
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
            '登录 / 注册',
            style: TextStyle(
              color: AppColors.slate800,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '输入邮箱即可登录或注册，畅享绿茵赛事',
          style: TextStyle(
            color: AppColors.slate500,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  /// 邮箱输入框（差异化：白色卡片+紫色图标+左侧标签条）
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
          // 左侧紫色标签条
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
                hintText: '请输入邮箱地址',
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

  /// 验证码输入框 + 获取验证码按钮
  Widget _buildCodeField() {
    return Row(
      children: [
        // 验证码输入框
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
                      hintText: '验证码',
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
        // 获取验证码按钮
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
                    _countdown > 0 ? '${_countdown}s' : '获取验证码',
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

  /// 协议勾选行
  Widget _buildAgreementRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 勾选框
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
        // 协议文案
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isAgree = !_isAgree),
            child: Text.rich(
              TextSpan(
                text: '我已阅读并同意 ',
                style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                children: [
                  TextSpan(
                    text: '服务条款',
                    style: const TextStyle(color: AppColors.violet600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HankLocalWebPage(
                              assetPath:
                                  'assets/htmlSource/user-agreement.html',
                              title: '服务条款',
                            ),
                          ),
                        );
                      },
                  ),
                  const TextSpan(text: ' 和 '),
                  TextSpan(
                    text: '隐私政策',
                    style: const TextStyle(color: AppColors.violet600),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HankLocalWebPage(
                              assetPath:
                                  'assets/htmlSource/privacy-agreement.html',
                              title: '隐私政策',
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

  /// 登录按钮
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
                  '登 录',
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

  /// 底部版权信息
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
