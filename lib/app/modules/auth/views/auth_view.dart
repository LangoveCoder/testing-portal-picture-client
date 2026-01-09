import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_constants.dart';

class AuthView extends GetView<AuthController> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool obscurePassword = true.obs;

  AuthView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              
              // Modern Header
              _buildModernHeader(context),
              
              SizedBox(height: 40),
              
              // Login Form
              _buildLoginForm(context),
              
              SizedBox(height: 30),
              
              // Footer
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Column(
      children: [
        // App Icon
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B),
                const Color(0xFF334155),
                AppColors.primary,
              ],
              stops: [0.0, 0.6, 1.0],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            size: 48,
            color: Colors.white,
          ),
        ),

        SizedBox(height: 24),

        // App Title
        Text(
          AppConstants.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.getTextPrimary(context),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 8),

        Text(
          'Attendance Management System',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.getTextSecondary(context),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.getShadow(context).withOpacity(0.5),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.login_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operator Login',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimary(context),
                    ),
                  ),
                  Text(
                    'Enter your credentials to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 32),

          // Email Field
          _buildInputField(
            context: context,
            label: 'Email Address',
            controller: emailController,
            hintText: 'Enter your email address',
            prefixIcon: Icons.email_outlined,
            textCapitalization: TextCapitalization.none,
          ),

          SizedBox(height: 24),

          // Password Field
          Obx(() => _buildInputField(
                context: context,
                label: 'Password',
                controller: passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: obscurePassword.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.getTextMuted(context),
                    size: 20,
                  ),
                  onPressed: () {
                    obscurePassword.value = !obscurePassword.value;
                  },
                ),
                onSubmitted: (value) => _login(),
              )),

          SizedBox(height: 32),

          // Login Button
          Obx(() => Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.getTextPrimary(context),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.getInputBackground(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.getBorder(context),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            textCapitalization: textCapitalization,
            onSubmitted: onSubmitted,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.getTextPrimary(context),
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.getTextMuted(context),
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              prefixIcon: Container(
                padding: EdgeInsets.all(12),
                child: Icon(
                  prefixIcon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.getBorder(context),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.copyright_rounded,
                color: AppColors.getTextSecondary(context),
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Powered by Nadeem Baloch and Anthropic',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.getTextSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _login() {
    controller.authenticateOperator(
      emailController.text,
      passwordController.text,
    );
  }
}