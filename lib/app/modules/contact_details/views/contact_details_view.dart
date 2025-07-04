import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/contact_model.dart';
import '../../../core/services/localization_service.dart';
import '../controllers/contact_details_controller.dart';

class ContactDetailsView extends GetView<ContactDetailsController> {
  final Contact contact;

  const ContactDetailsView({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.to;

    // Initialize controller with contact
    Get.put(ContactDetailsController(contact));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with hero avatar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
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
                      _buildAvatar(context),
                      const SizedBox(height: 16),
                      Text(
                        contact.displayName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      if (contact.company?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          contact.company!,
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
                      Get.toNamed('/contact-form', arguments: contact);
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
                if (contact.primaryPhone.isNotEmpty ||
                    contact.primaryEmail.isNotEmpty)
                  _buildQuickActions(context),

                const SizedBox(height: 24),

                // Contact information
                _buildContactInfo(context, localization),

                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    const size = 120.0;

    if (contact.avatarPath != null && contact.avatarPath!.isNotEmpty) {
      final file = File(contact.avatarPath!);
      if (file.existsSync()) {
        return Container(
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
            ),
          ),
        );
      }
    }

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
          contact.initials,
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

    if (contact.primaryPhone.isNotEmpty) {
      actions.addAll([
        _buildActionButton(
          context,
          icon: Icons.call,
          label: 'Call',
          onTap: () => _makeCall(contact.primaryPhone),
        ),
        _buildActionButton(
          context,
          icon: Icons.message,
          label: 'Message',
          onTap: () => _sendMessage(contact.primaryPhone),
        ),
      ]);
    }

    if (contact.primaryEmail.isNotEmpty) {
      actions.add(
        _buildActionButton(
          context,
          icon: Icons.email,
          label: 'Email',
          onTap: () => _sendEmail(contact.primaryEmail),
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

    // Phone numbers
    if (contact.phone?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.phone,
          label: localization.mobile,
          value: contact.phone!,
          onTap: () => _makeCall(contact.phone!),
          onLongPress: () => _copyToClipboard(contact.phone!),
        ),
      );
    }

    if (contact.workPhone?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.work,
          label: '${localization.work} ${localization.phone}',
          value: contact.workPhone!,
          onTap: () => _makeCall(contact.workPhone!),
          onLongPress: () => _copyToClipboard(contact.workPhone!),
        ),
      );
    }

    // Emails
    if (contact.email?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.email,
          label: localization.email,
          value: contact.email!,
          onTap: () => _sendEmail(contact.email!),
          onLongPress: () => _copyToClipboard(contact.email!),
        ),
      );
    }

    if (contact.workEmail?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.business,
          label: '${localization.work} ${localization.email}',
          value: contact.workEmail!,
          onTap: () => _sendEmail(contact.workEmail!),
          onLongPress: () => _copyToClipboard(contact.workEmail!),
        ),
      );
    }

    // Address
    if (contact.address?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.location_on,
          label: localization.address,
          value: contact.address!,
          onTap: () => _openMap(contact.address!),
          onLongPress: () => _copyToClipboard(contact.address!),
        ),
      );
    }

    // Notes
    if (contact.notes?.isNotEmpty == true) {
      infoItems.add(
        _buildInfoItem(
          context,
          icon: Icons.note,
          label: localization.notes,
          value: contact.notes!,
          onLongPress: () => _copyToClipboard(contact.notes!),
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
