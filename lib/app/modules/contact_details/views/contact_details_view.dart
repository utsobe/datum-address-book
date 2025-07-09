import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/contact_model.dart';
import '../../../core/language/localization_service.dart';
import '../../../core/widgets/image_viewer.dart';
import '../controllers/contact_details_controller.dart';

class ContactDetailsView extends GetView<ContactDetailsController> {
  const ContactDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.to;

    return Scaffold(
      body: Obx(() {
        return CustomScrollView(
          slivers: [
            // App bar with hero avatar
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: IconButton(
                icon: Icon(
                  Platform.isIOS
                      ? Icons.arrow_back_ios_new_outlined
                      : Icons.arrow_back,
                  color: Colors.white,
                  // size: 50,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),

              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Obx(() => _buildAvatar(context)),
                        const SizedBox(height: 16),
                        Text(
                          controller.contact.value.displayName,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        if (controller.contact.value.company?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 4),
                          Text(
                            controller.contact.value.company!,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                Obx(
                  () => IconButton(
                    onPressed: controller.toggleFavorite,
                    icon: Icon(
                      controller.contact.value.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.white,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        Get.toNamed(
                          '/contact-form',
                          arguments: controller.contact.value,
                        );
                        break;
                      case 'delete':
                        _showDeleteDialog(context);
                        break;
                      case 'share':
                        _shareContact();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(localization.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share),
                          const SizedBox(width: 8),
                          Text(localization.share),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            localization.delete,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Quick actions
                  if (controller.contact.value.primaryPhone.isNotEmpty ||
                      controller.contact.value.primaryEmail.isNotEmpty)
                    _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Contact information
                  _buildContactInfo(context, localization),

                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    const size = 120.0;
    final currentContact = controller.contact.value;

    print('Building avatar for contact: ${currentContact.displayName}');
    print('Avatar path: ${currentContact.avatarPath}');

    if (currentContact.avatarPath != null &&
        currentContact.avatarPath!.isNotEmpty) {
      final file = File(currentContact.avatarPath!);
      print('File exists: ${file.existsSync()}');

      if (file.existsSync()) {
        return GestureDetector(
          onTap: () {
            // Open image viewer for full-screen viewing with custom transition
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ImageViewer(
                      imagePath: currentContact.avatarPath!,
                      heroTag: 'contact_avatar_${currentContact.id}',
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading avatar image: $error');
                  return _buildDefaultAvatar(size, currentContact);
                },
              ),
            ),
          ),
        );
      } else {
        print('Avatar file does not exist, showing initials');
      }
    } else {
      print('No avatar path, showing initials');
    }

    return _buildDefaultAvatar(size, currentContact);
  }

  Widget _buildDefaultAvatar(double size, Contact currentContact) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Center(
        child: Text(
          currentContact.initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <Widget>[];
    final currentContact = controller.contact.value;

    if (currentContact.primaryPhone.isNotEmpty) {
      actions.addAll([
        _buildActionButton(
          context,
          icon: Icons.call,
          label: 'Call',
          onTap: () => _makeCall(currentContact.primaryPhone),
        ),
        _buildActionButton(
          context,
          icon: Icons.message,
          label: 'Message',
          onTap: () => _sendMessage(currentContact.primaryPhone),
        ),
      ]);
    }

    if (currentContact.primaryEmail.isNotEmpty) {
      actions.add(
        _buildActionButton(
          context,
          icon: Icons.email,
          label: 'Email',
          onTap: () => _sendEmail(currentContact.primaryEmail),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: actions,
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    BuildContext context,
    LocalizationService localization,
  ) {
    final infoItems = <Widget>[];
    final currentContact = controller.contact.value;

    // Phone numbers
    if (currentContact.phone?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.phone,
          label: localization.mobile,
          value: currentContact.phone!,
          onTap: () => _makeCall(currentContact.phone!),
          onLongPress: () => _copyToClipboard(currentContact.phone!),
        ),
      );
    }

    if (currentContact.workPhone?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.work,
          label: '${localization.work} ${localization.phone}',
          value: currentContact.workPhone!,
          onTap: () => _makeCall(currentContact.workPhone!),
          onLongPress: () => _copyToClipboard(currentContact.workPhone!),
        ),
      );
    }

    // Emails
    if (currentContact.email?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.email,
          label: localization.email,
          value: currentContact.email!,
          onTap: () => _sendEmail(currentContact.email!),
          onLongPress: () => _copyToClipboard(currentContact.email!),
        ),
      );
    }

    if (currentContact.workEmail?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.business,
          label: '${localization.work} ${localization.email}',
          value: currentContact.workEmail!,
          onTap: () => _sendEmail(currentContact.workEmail!),
          onLongPress: () => _copyToClipboard(currentContact.workEmail!),
        ),
      );
    }

    // Address
    if (currentContact.address?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.location_on,
          label: localization.address,
          value: currentContact.address!,
          onTap: () => _openMap(currentContact.address!),
          onLongPress: () => _copyToClipboard(currentContact.address!),
        ),
      );
    }

    // Notes
    if (currentContact.notes?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.note,
          label: localization.notes,
          value: currentContact.notes!,
          onLongPress: () => _copyToClipboard(currentContact.notes!),
        ),
      );
    }

    if (infoItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(child: Column(children: infoItems));
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
      ),
      subtitle: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMap(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final uri = Uri.parse('https://maps.google.com/?q=$encodedAddress');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _shareContact() {
    final contact = controller.contact.value;
    final contactInfo = StringBuffer();
    contactInfo.writeln(contact.displayName);
    if (contact.company?.isNotEmpty == true) {
      contactInfo.writeln(contact.company);
    }
    if (contact.primaryPhone.isNotEmpty) {
      contactInfo.writeln('Phone: ${contact.primaryPhone}');
    }
    if (contact.primaryEmail.isNotEmpty) {
      contactInfo.writeln('Email: ${contact.primaryEmail}');
    }
    if (contact.address?.isNotEmpty == true) {
      contactInfo.writeln('Address: ${contact.address}');
    }

    // For now, just copy to clipboard. In a real app, you'd use share_plus package
    _copyToClipboard(contactInfo.toString());
    Get.snackbar(
      'Contact Shared',
      'Contact information copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final localization = LocalizationService.to;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localization.deleteContact),
        content: Text(localization.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteContact();
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(localization.delete),
          ),
        ],
      ),
    );
  }
}
