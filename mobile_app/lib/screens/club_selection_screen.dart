import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/club_theme.dart';
import '../data/models/club_model.dart';
import '../features/club/bloc/club_bloc.dart';
import '../features/club/bloc/club_event.dart';
import '../features/club/bloc/club_state.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/bloc/auth_event.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_button.dart';

class ClubSelectionScreen extends StatefulWidget {
  const ClubSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ClubSelectionScreen> createState() => _ClubSelectionScreenState();
}

class _ClubSelectionScreenState extends State<ClubSelectionScreen> {
  String? selectedClubId;
  String? selectedClubName;

  @override
  void initState() {
    super.initState();
    // Load clubs from API
    context.read<ClubBloc>().add(const LoadAllClubs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推しクラブを選択'),
        elevation: 0,
      ),
      body: BlocConsumer<ClubBloc, ClubState>(
        listener: (context, state) {
          if (state is ClubLoaded) {
            // Update AuthBloc with new club ID
            context.read<AuthBloc>().add(
              AuthClubUpdated(clubId: state.clubId),
            );

            // Club successfully changed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.clubName}に変更しました'),
                backgroundColor: state.theme.primaryColor,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is ClubError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ClubLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ClubError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClubBloc>().add(const LoadAllClubs());
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            );
          }

          if (state is! ClubListLoaded) {
            return const Center(
              child: Text('クラブ一覧を読み込んでいます...'),
            );
          }

          final clubs = state.clubs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: clubs.length,
                  itemBuilder: (context, index) {
                    final club = clubs[index];
                    final isSelected = selectedClubId == club.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildClubCard(
                        club: club,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            selectedClubId = club.id;
                            selectedClubName = club.name;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              // Bottom button
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomButton(
                  text: '決定',
                  variant: ButtonVariant.solid,
                  width: double.infinity,
                  onPressed:
                      selectedClubId != null && selectedClubName != null
                          ? () {
                              context.read<ClubBloc>().add(
                                    ChangeFavoriteClub(
                                      clubId: selectedClubId!,
                                      clubName: selectedClubName!,
                                    ),
                                  );
                            }
                          : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClubCard({
    required ClubModel club,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Try to get theme from club name, fallback to default
    final theme = ClubTheme.getThemeByName(club.name);

    return CustomCard(
      onTap: onTap,
      border: isSelected
          ? Border.all(color: theme.primaryColor, width: 3)
          : Border.all(color: Colors.grey.shade300),
      child: Row(
        children: [
          // Club color indicator
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: theme.gradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // Club name and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? theme.primaryColor : Colors.black87,
                  ),
                ),
                if (club.memberCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${club.memberCount}人のサポーター',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Selection indicator
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: theme.primaryColor,
              size: 24,
            ),
        ],
      ),
    );
  }
}
