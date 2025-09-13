import 'package:flutter/material.dart';
import 'package:hajz_sejours/core/routes/app_route.dart';
import 'package:hajz_sejours/features/profile/controller/profile_controller.dart';
import 'package:hajz_sejours/features/profile/model/avatar_data.dart';
import 'package:hajz_sejours/features/profile/model/user_model.dart';
import 'package:hajz_sejours/features/profile/view/edit_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  final int clientId;

  const ProfilePage({super.key, required this.clientId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      _animationController!.forward();
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      await Provider.of<ProfileController>(
        context,
        listen: false,
      ).fetchClient(widget.clientId);
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Erreur',
          'Échec du chargement du profil : $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, _) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, controller),
              SliverToBoxAdapter(child: _buildBody(controller)),
            ],
          ),
          bottomNavigationBar: _buildFooter(context),
        );
      },
    );
  }

  Widget _buildSliverAppBar(BuildContext context,
      ProfileController controller,) {
    return SliverAppBar(
      expandedHeight: 50,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false, // Disable the back arrow
      flexibleSpace: FlexibleSpaceBar(
        title: const Text("Profil", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D2180), Color(0xFF586EE9), Color(0xFF7878F0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      actions: [
        if (controller.user != null)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEditProfile(context, controller),
          ),
      ],
    );
  }

  Widget _buildBody(ProfileController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfileData,
              child: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    if (controller.user == null) {
      return const Center(child: Text("Aucune donnée disponible"));
    }

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: Column(
        children: [
          _buildProfileHeader(controller.user!),
          const SizedBox(height: 24),
          _buildUserInfoSection(controller.user!),
          const SizedBox(height: 24),
          _buildActionButtonsSection(context, controller),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Semantics(
            label: 'Avatar de ${user.name}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.amberAccent,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                _getProfileImageProvider(user) ??
                    const AssetImage('assets/default_avatar.png'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "${user.name} ${user.surname}",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          _buildPointsBadge(user.points),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(int points) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.amber, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 28),
          const SizedBox(width: 8),
          Text(
            "$points Points",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildInfoCard(
            icon: Icons.place,
            label: "Localisation",
            value: user.country.isEmpty ? "Non spécifié" : user.country,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.phone,
            label: "Téléphone",
            value: user.phone.isEmpty ? "Non spécifié" : user.phone,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.cake,
            label: "Date de naissance",
            value: user.birthdate.isEmpty ? "Non spécifié" : user.birthdate,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),

        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: Theme
                    .of(context)
                    .primaryColor,
                size: 28,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context, ProfileController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.logout,
                label: "Déconnexion",
                color: Colors.redAccent,
                onPressed: () => _logout(context),
              ),
              _buildActionButton(
                icon: Icons.lock_reset,
                label: "Mot de passe",
                color: Colors.teal,
                onPressed: () {
                  Get.toNamed(AppRoutes.changePassword, arguments: {'clientId': widget.clientId});
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.history,
                label: "Réservations",
                color: Colors.indigo,
                onPressed: () {
                  Get.toNamed(AppRoutes.reservationHistory, arguments: {'clientId': widget.clientId});
                },
              ),
              _buildActionButton(
                icon: Icons.report_problem,
                label: "Réclamation",
                color: Colors.orange,
                onPressed: () {
                  Get.toNamed(AppRoutes.reclamationForm, arguments: {'clientId': widget.clientId});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ Footer Navigation ============
  Widget _buildFooter(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme
                .of(context)
                .primaryColor,
            const Color(0xFF586EE9),
            const Color(0xFF7878F0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, spreadRadius: 2, blurRadius: 5),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildProfileIcon(context),
          _buildFooterIcon(
            context,
            Icons.notifications,
            'Notifications',
            AppRoutes.notifications,
          ),
          _buildFooterIcon(context, Icons.home, 'Accueil', AppRoutes.home),
          _buildFooterIcon(
            context,
            Icons.chat_outlined,
            'Chatbot',
            AppRoutes.chatbot,
          ),
          _buildFooterIcon(
            context,
            Icons.newspaper,
            'Actualites',
            AppRoutes.Actualites,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterIcon(BuildContext context,
      IconData icon,
      String label,
      String route,) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, route),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, color: Color(0xFFF5C506), size: 30),
          const SizedBox(height: 4),
          const Text(
            'Profil',
            style: TextStyle(color: Color(0xFFF5C506), fontSize: 12),
          ),
        ],
      ),
      onPressed: () => _navigateTo(context, AppRoutes.profile),
    );
  }

  void _navigateTo(BuildContext context, String route) {
    Get.toNamed(route, arguments: {'clientId': widget.clientId});
  }

  ImageProvider? _getProfileImageProvider(UserModel user) {
    print('Getting image for avatarId: ${user.avatarId}');
    if (user.avatarId.isNotEmpty) {
      final avatar = AvatarData.getById(user.avatarId);
      if (avatar != null) {
        print('Avatar found: ${avatar.path}');
        return AssetImage(avatar.path);
      }
    }
    print('No avatar, using default');
    return null;
  }

  Future<void> _navigateToEditProfile(BuildContext context,
      ProfileController controller,) async {
    final updatedUser = await Get.to(
          () =>
          EditProfilePage(user: controller.user!, clientId: widget.clientId),
    );

    if (updatedUser != null) {
      print('Received updated user with avatarId: ${updatedUser.avatarId}');
      final success = await controller.updateClient(
        widget.clientId,
        updatedUser,
      );

      if (success && context.mounted) {
        await controller.fetchClient(widget.clientId);
      }

      if (context.mounted) {
        Get.snackbar(
          success ? 'Succès' : 'Erreur',
          success
              ? "Profil mis à jour avec succès"
              : controller.errorMessage ?? "Erreur lors de la mise à jour",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: success ? Colors.green : Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    Get.offAllNamed(AppRoutes.login);
  }

}
