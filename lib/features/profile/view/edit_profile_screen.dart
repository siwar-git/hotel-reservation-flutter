import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hajz_sejours/core/app_colors.dart';
import 'package:hajz_sejours/core/app_strings.dart';
import 'package:hajz_sejours/core/text_styles.dart';
import 'package:hajz_sejours/features/profile/controller/profile_controller.dart';
import 'package:hajz_sejours/features/profile/model/avatar_data.dart';
import 'package:hajz_sejours/features/profile/model/user_model.dart';
import 'package:hajz_sejours/features/profile/view/AvatarSelectionPage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;
  final int clientId;

  const EditProfilePage({
    super.key,
    required this.user,
    required this.clientId,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  String? _selectedAvatarId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _surnameController = TextEditingController(text: widget.user.surname);
    _countryController = TextEditingController(text: widget.user.country);
    _phoneController = TextEditingController(text: widget.user.phone);
    _birthdateController = TextEditingController(text: widget.user.birthdate);
    _selectedAvatarId = widget.user.avatarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _selectAvatar() async {
    final Avatar? selectedAvatar = await Get.to(
      () => const AvatarSelectionPage(),
    );
    if (selectedAvatar != null && mounted) {
      setState(() {
        _selectedAvatarId = selectedAvatar.id;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.editProfile, style: TextStyles.appBarTitle),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nameController,
                  label: AppStrings.name,
                  validator:
                      (value) => value!.isEmpty ? AppStrings.nameError : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _surnameController,
                  label: AppStrings.surname,
                  validator:
                      (value) =>
                          value!.isEmpty ? AppStrings.surnameError : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _countryController,
                  label: AppStrings.country,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _phoneController,
                  label: AppStrings.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _birthdateController,
                  label: AppStrings.birthdate,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 30),
                _buildSaveButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final avatar =
        _selectedAvatarId != null
            ? AvatarData.getById(_selectedAvatarId!)
            : null;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              avatar != null
                  ? AssetImage(avatar.path)
                  : const AssetImage('assets/default_avatar.png'),
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _selectAvatar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text('Choisir un avatar', style: TextStyles.buttonText),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          // Validation de l'avatar
          if (_selectedAvatarId == null || _selectedAvatarId!.isEmpty) {
            Get.snackbar('Erreur', 'Veuillez sélectionner un avatar');
            return;
          }

          final updatedUser = UserModel(
            name: _nameController.text,
            surname: _surnameController.text,
            email: widget.user.email,
            country: _countryController.text,
            phone: _phoneController.text,
            birthdate: _birthdateController.text,
            avatarId: _selectedAvatarId!,
            points: widget.user.points,
          );

          print('Saving with avatar: ${updatedUser.avatarId}');
          Get.back(result: updatedUser);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(AppStrings.save, style: TextStyles.buttonText),
    );
  }
}
