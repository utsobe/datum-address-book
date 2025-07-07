import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contact_form_controller.dart';
import '../../../core/language/localization_service.dart';
import '../../../core/widgets/avatar_picker.dart';

class ContactFormView extends GetView<ContactFormController> {
  const ContactFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.to;

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditing.value
                ? localization.editContact
                : localization.addContact,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.saveContact,
              child: Text(localization.save),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Required fields note
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fields marked with * are required',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Avatar section
                Center(
                  child: AvatarPicker(
                    avatarPath: controller.avatarPath.value,
                    onImageSelected: controller.setAvatarPath,
                    onImageRemoved: controller.removeAvatar,
                  ),
                ),

                const SizedBox(height: 32),

                // Name section
                _buildSectionHeader(context, 'Name', Icons.person),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.firstNameController,
                        decoration: InputDecoration(
                          labelText: '${localization.firstName} *',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return localization.requiredField;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: controller.lastNameController,
                        decoration: InputDecoration(
                          labelText: '${localization.lastName} *',
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return localization.requiredField;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Contact information
                _buildSectionHeader(
                  context,
                  'Contact Information',
                  Icons.contact_phone,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.phoneController,
                  decoration: InputDecoration(
                    labelText: '${localization.phone} *',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return localization.requiredField;
                    }
                    // Basic phone validation - at least 7 digits
                    final digitsOnly = value!.replaceAll(RegExp(r'[^\d]'), '');
                    if (digitsOnly.length < 7) {
                      return localization.invalidPhone;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.emailController,
                  decoration: InputDecoration(
                    labelText: '${localization.email} *',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return localization.requiredField;
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value!)) {
                      return localization.invalidEmail;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.workPhoneController,
                  decoration: InputDecoration(
                    labelText: '${localization.work} ${localization.phone}',
                    prefixIcon: const Icon(Icons.work_outline),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.workEmailController,
                  decoration: InputDecoration(
                    labelText: '${localization.work} ${localization.email}',
                    prefixIcon: const Icon(Icons.business_center_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 24),

                // Company & Address
                _buildSectionHeader(
                  context,
                  'Additional Information',
                  Icons.info_outline,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.companyController,
                  decoration: InputDecoration(
                    labelText: localization.company,
                    prefixIcon: const Icon(Icons.business_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.addressController,
                  decoration: InputDecoration(
                    labelText: '${localization.address} *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return localization.requiredField;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: controller.notesController,
                  decoration: InputDecoration(
                    labelText: localization.notes,
                    prefixIcon: const Icon(Icons.note_outlined),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
