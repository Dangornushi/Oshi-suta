# 優先度 LOW: フォーム管理の共通化

## 🎯 目的
Flutterモバイルアプリのスクリーンで繰り返されているフォーム管理ロジック（TextEditingController、バリデーション、ローディング状態など）を共通化し、コードの重複を削減する。

## 📊 現在の問題

複数のスクリーンで同じフォーム管理パターンが繰り返されている:

```dart
// login_screen.dart, edit_email_screen.dart など

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // バリデーション、送信処理など...
}
```

**重複箇所**:
- `login_screen.dart`
- `edit_email_screen.dart`
- `edit_password_screen.dart`
- `edit_nickname_screen.dart`

## 📋 実装手順

### ステップ1: フォーム管理Mixinを作成

`mobile_app/lib/core/mixins/form_mixin.dart` を新規作成:

```dart
import 'package:flutter/material.dart';

/// フォーム管理Mixin
///
/// TextEditingControllerの自動管理と共通バリデーション機能を提供
mixin FormMixin<T extends StatefulWidget> on State<T> {
  final _controllers = <String, TextEditingController>{};
  final _obscureStates = <String, ValueNotifier<bool>>{};

  /// フォームキー
  final formKey = GlobalKey<FormState>();

  /// TextEditingControllerを取得（存在しなければ作成）
  TextEditingController getController(String name) {
    return _controllers.putIfAbsent(name, () => TextEditingController());
  }

  /// パスワード表示/非表示の状態を取得
  ValueNotifier<bool> getObscureState(String name, {bool initialValue = true}) {
    return _obscureStates.putIfAbsent(
      name,
      () => ValueNotifier<bool>(initialValue),
    );
  }

  /// パスワード表示/非表示をトグル
  void toggleObscure(String name) {
    final state = getObscureState(name);
    state.value = !state.value;
  }

  /// フォームをバリデート
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// 全てのコントローラーをクリア
  void clearAllControllers() {
    for (var controller in _controllers.values) {
      controller.clear();
    }
  }

  /// 特定のコントローラーの値を取得
  String getControllerText(String name) {
    return getController(name).text.trim();
  }

  /// 特定のコントローラーに値を設定
  void setControllerText(String name, String value) {
    getController(name).text = value;
  }

  @override
  void dispose() {
    // 全てのコントローラーを破棄
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    // 全てのValueNotifierを破棄
    for (var notifier in _obscureStates.values) {
      notifier.dispose();
    }
    _obscureStates.clear();

    super.dispose();
  }
}

/// ローディング状態管理Mixin
mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  /// ローディング状態を設定
  void setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  /// ローディング中に非同期処理を実行
  Future<void> withLoading(Future<void> Function() operation) async {
    setLoading(true);
    try {
      await operation();
    } finally {
      setLoading(false);
    }
  }
}
```

### ステップ2: 共通バリデーターを作成

`mobile_app/lib/core/validators/form_validators.dart` を新規作成:

```dart
/// フォームバリデーター
class FormValidators {
  /// メールアドレスバリデーター
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return '有効なメールアドレスを入力してください';
    }

    return null;
  }

  /// パスワードバリデーター
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'パスワードを入力してください';
    }

    if (value.length < minLength) {
      return 'パスワードは${minLength}文字以上にしてください';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'パスワードには大文字を含めてください';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'パスワードには小文字を含めてください';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'パスワードには数字を含めてください';
    }

    return null;
  }

  /// 必須フィールドバリデーター
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'この項目'}を入力してください';
    }
    return null;
  }

  /// ニックネームバリデーター
  static String? nickname(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'ニックネームを入力してください';
    }

    if (value.trim().length < 2) {
      return 'ニックネームは2文字以上にしてください';
    }

    if (value.trim().length > 20) {
      return 'ニックネームは20文字以内にしてください';
    }

    return null;
  }

  /// 確認パスワードバリデーター
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '確認用パスワードを入力してください';
      }

      if (value != originalPassword) {
        return 'パスワードが一致しません';
      }

      return null;
    };
  }

  /// 最小文字数バリデーター
  static String? Function(String?) minLength(int min, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // 他のバリデーターに任せる
      }

      if (value.length < min) {
        return '${fieldName ?? 'この項目'}は${min}文字以上にしてください';
      }

      return null;
    };
  }

  /// 最大文字数バリデーター
  static String? Function(String?) maxLength(int max, {String? fieldName}) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }

      if (value.length > max) {
        return '${fieldName ?? 'この項目'}は${max}文字以内にしてください';
      }

      return null;
    };
  }

  /// 複数のバリデーターを組み合わせる
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (var validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
```

### ステップ3: LoginScreenをリファクタリング

`mobile_app/lib/screens/login_screen.dart` を修正:

**修正前** (約150行):
```dart
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // ログイン処理
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        context.read<AuthBloc>().add(
          AuthLoginRequested(
            request: LoginRequest(
              email: email,
              password: password,
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: 'パスワード',
                suffixIcon: IconButton(
                  icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading ? CircularProgressIndicator() : Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**修正後** (約80行、47%削減):
```dart
import '../core/mixins/form_mixin.dart';
import '../core/validators/form_validators.dart';

class _LoginScreenState extends State<LoginScreen>
    with FormMixin, LoadingMixin {
  void _handleLogin() async {
    if (validateForm()) {
      await withLoading(() async {
        context.read<AuthBloc>().add(
          AuthLoginRequested(
            request: LoginRequest(
              email: getControllerText('email'),
              password: getControllerText('password'),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          children: [
            // メールアドレスフィールド
            TextFormField(
              controller: getController('email'),
              decoration: InputDecoration(labelText: 'メールアドレス'),
              validator: FormValidators.email,
              keyboardType: TextInputType.emailAddress,
            ),

            // パスワードフィールド
            ValueListenableBuilder<bool>(
              valueListenable: getObscureState('password'),
              builder: (context, obscure, child) {
                return TextFormField(
                  controller: getController('password'),
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'パスワード',
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => toggleObscure('password'),
                    ),
                  ),
                  validator: FormValidators.required,
                );
              },
            ),

            // ログインボタン
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### ステップ4: EditEmailScreenをリファクタリング

**修正後**:
```dart
class _EditEmailScreenState extends State<EditEmailScreen>
    with FormMixin, LoadingMixin {
  @override
  void initState() {
    super.initState();
    // 現在のメールアドレスを設定
    final currentEmail = context.read<AuthBloc>().state.maybeWhen(
      authenticated: (user) => user.email,
      orElse: () => '',
    );
    setControllerText('email', currentEmail);
  }

  Future<void> _handleUpdateEmail() async {
    if (validateForm()) {
      await withLoading(() async {
        context.read<AuthBloc>().add(
          AuthUpdateEmailRequested(
            request: UpdateEmailRequest(
              newEmail: getControllerText('email'),
              password: getControllerText('password'),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('メールアドレス変更')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: getController('email'),
                decoration: InputDecoration(labelText: '新しいメールアドレス'),
                validator: FormValidators.email,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: getObscureState('password'),
                builder: (context, obscure, child) {
                  return TextFormField(
                    controller: getController('password'),
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: '現在のパスワード（確認用）',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => toggleObscure('password'),
                      ),
                    ),
                    validator: FormValidators.required,
                  );
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _handleUpdateEmail,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### ステップ5: EditPasswordScreenをリファクタリング

**修正後**:
```dart
class _EditPasswordScreenState extends State<EditPasswordScreen>
    with FormMixin, LoadingMixin {
  Future<void> _handleChangePassword() async {
    if (validateForm()) {
      await withLoading(() async {
        context.read<AuthBloc>().add(
          AuthChangePasswordRequested(
            request: ChangePasswordRequest(
              currentPassword: getControllerText('current_password'),
              newPassword: getControllerText('new_password'),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('パスワード変更')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // 現在のパスワード
              ValueListenableBuilder<bool>(
                valueListenable: getObscureState('current_password'),
                builder: (context, obscure, child) {
                  return TextFormField(
                    controller: getController('current_password'),
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: '現在のパスワード',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => toggleObscure('current_password'),
                      ),
                    ),
                    validator: FormValidators.required,
                  );
                },
              ),
              SizedBox(height: 16),

              // 新しいパスワード
              ValueListenableBuilder<bool>(
                valueListenable: getObscureState('new_password'),
                builder: (context, obscure, child) {
                  return TextFormField(
                    controller: getController('new_password'),
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: '新しいパスワード',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => toggleObscure('new_password'),
                      ),
                    ),
                    validator: FormValidators.password,
                  );
                },
              ),
              SizedBox(height: 16),

              // パスワード確認
              ValueListenableBuilder<bool>(
                valueListenable: getObscureState('confirm_password'),
                builder: (context, obscure, child) {
                  return TextFormField(
                    controller: getController('confirm_password'),
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'パスワード確認',
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => toggleObscure('confirm_password'),
                      ),
                    ),
                    validator: FormValidators.confirmPassword(
                      getControllerText('new_password'),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              ElevatedButton(
                onPressed: isLoading ? null : _handleChangePassword,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('パスワードを変更'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## ✅ チェックリスト

- [ ] `lib/core/mixins/form_mixin.dart` を作成
- [ ] `lib/core/validators/form_validators.dart` を作成
- [ ] `login_screen.dart` をリファクタリング
- [ ] `edit_email_screen.dart` をリファクタリング
- [ ] `edit_password_screen.dart` をリファクタリング
- [ ] `edit_nickname_screen.dart` をリファクタリング
- [ ] 動作確認（全フォームの送信・バリデーション）
- [ ] 既存の重複コードを削除

## ⏱️ 推定作業時間

- Mixin・バリデーター作成: 2時間
- スクリーンリファクタリング: 2.5時間
- テスト・デバッグ: 1時間
- 動作確認: 30分

**合計**: 約6時間

## 📈 期待される効果

- ✅ **コード行数が約200行削減** (全スクリーン合計で40-50%削減)
- ✅ **フォーム処理の一貫性向上**
- ✅ **バリデーションロジックの再利用**
- ✅ **メモリリーク防止** (dispose自動化)
- ✅ **新規フォーム画面の実装が超簡単に**

## 🔄 Before/After比較

### Before
```dart
// 約30行のボイラープレート
final TextEditingController _emailController = TextEditingController();
final _formKey = GlobalKey<FormState>();
bool _isLoading = false;

@override
void dispose() {
  _emailController.dispose();
  super.dispose();
}

TextFormField(
  controller: _emailController,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'メールアドレスを入力してください';
    }
    return null;
  },
)
```

### After
```dart
// 約5行で完結 (83%削減!)
with FormMixin, LoadingMixin

TextFormField(
  controller: getController('email'),
  validator: FormValidators.email,
)
```

## 📚 参考資料

- [Flutter Mixins](https://dart.dev/guides/language/language-tour#adding-features-to-a-class-mixins)
- [Form Validation in Flutter](https://docs.flutter.dev/cookbook/forms/validation)
- [TextEditingController Best Practices](https://api.flutter.dev/flutter/widgets/TextEditingController-class.html)
