import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/address_book_controller.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/widgets/contact_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/search_bar_widget.dart';

class AddressBookView extends GetView<AddressBookController> {
  const AddressBookView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.to;

    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appName),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: controller.searchController,
              hintText: localization.searchContacts,
              onClear: controller.clearSearch,
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      context,
                      localization.allContacts,
                      0,
                      controller.selectedTab.value == 0,
                      controller.totalContacts,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      context,
                      localization.favorites,
                      1,
                      controller.selectedTab.value == 1,
                      controller.totalFavorites,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Contacts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredContacts.isEmpty) {
                return EmptyState(
                  icon: Icons.contacts_outlined,
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'No contacts found'
                      : localization.noContacts,
                  subtitle: controller.searchQuery.value.isNotEmpty
                      ? 'Try adjusting your search'
                      : 'Add your first contact to get started',
                  actionText: localization.addContact,
                  onAction: () => Get.toNamed('/contact-form'),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadContacts,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: controller.filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = controller.filteredContacts[index];
                    return ContactCard(
                      contact: contact,
                      onTap: () =>
                          Get.toNamed('/contact-details', arguments: contact),
                      onFavoriteToggle: () =>
                          controller.toggleFavorite(contact),
                      onDelete: () async {
                        final shouldDelete = await controller
                            .showDeleteConfirmation(contact);
                        if (shouldDelete) {
                          await controller.deleteContact(contact);
                        }
                      },
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/contact-form'),
        icon: const Icon(Icons.person_add),
        label: Text(localization.addContact),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String title,
    int index,
    bool isSelected,
    int count,
  ) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
