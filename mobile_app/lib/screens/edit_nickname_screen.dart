import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/auth_repository.dart';

class EditNicknameScreen extends StatefulWidget {
  const EditNicknameScreen({Key? key}) : super(key: key);

  @override
  State<EditNicknameScreen> createState() => _EditNicknameScreenState();
}

class _EditNicknameScreenState extends State<EditNicknameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _currentNickname;

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentNickname() async {
    setState(() => _isLoading = true);

    try {
      final authRepository = context.read<AuthRepository>();
      final profile = await authRepository.getProfile();

      if (mounted) {
        setState(() {
          _currentNickname = profile.nickname;
          _nicknameController.text = profile.nickname;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('読み込みに失敗しました: $e')),
            );
          }
        });
      }
    }
  }

  Future<void> _saveNickname() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newNickname = _nicknameController.text.trim();

    // Check if nickname actually changed
    if (newNickname == _currentNickname) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ニックネームは変更されていません')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authRepository = context.read<AuthRepository>();
      await authRepository.updateProfile(nickname: newNickname);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ニックネームを更新しました')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新に失敗しました: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ニックネーム変更'),
        elevation: 0,
      ),
      body: _isLoading && _currentNickname == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'ニックネームは他のユーザーに表示されます',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nickname field
                    TextFormField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(
                        labelText: 'ニックネーム',
                        hintText: '新しいニックネームを入力',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'ニックネームを入力してください';
                        }
                        if (value.trim().length < 2) {
                          return 'ニックネームは2文字以上で入力してください';
                        }
                        if (value.trim().length > 50) {
                          return 'ニックネームは50文字以内で入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveNickname,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '保存',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
