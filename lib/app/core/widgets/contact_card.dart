import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/models/contact_model.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(context),
              const SizedBox(width: 16),

              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (contact.company?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
                      Text(
                        contact.company!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (contact.primaryPhone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.primaryPhone,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (contact.primaryEmail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              contact.primaryEmail,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  if (onFavoriteToggle != null)
                    IconButton(
                      onPressed: onFavoriteToggle,
                      icon: Icon(
                        contact.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: contact.isFavorite
                            ? Colors.red
                            : Theme.of(context).textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red.withValues(alpha: 0.7),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    const size = 56.0;

    if (contact.avatarPath != null && contact.avatarPath!.isNotEmpty) {
      final file = File(contact.avatarPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to initials if image fails to load
              return _buildInitialsAvatar(context, size);
            },
          ),
        );
      }
    }

    return _buildInitialsAvatar(context, size);
  }

  Widget _buildInitialsAvatar(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          contact.initials,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
