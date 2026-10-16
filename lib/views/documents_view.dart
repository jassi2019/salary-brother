import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/documents_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_sizes.dart';
import '../utils/app_text_styles.dart';
import '../widgets/journey_scaffold.dart';
import '../widgets/primary_button.dart';

/// Step 5 — the documents the CRM asks for.
///
/// Opens in selfie mode when the CRM's step is `selfie_upload`, and in
/// general mode for the five other upload events.
class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return JourneyScaffold(
      title: controller.isSelfie ? 'Selfie' : 'Documents',
      step: 5,
      totalSteps: 5,
      footer: Obx(
        () => PrimaryButton(
          label: controller.isSelfie ? 'Upload selfie' : 'Upload documents',
          isLoading: controller.isSubmitting.value,
          onPressed: controller.isComplete ? controller.submit : null,
        ),
      ),
      children: [
        Text(
          controller.isSelfie ? 'Take a selfie' : 'Add your documents',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 10),
        Text(
          controller.isSelfie
              ? 'A clear photo of your face, to match against your PAN.'
              : 'Photos are fine — they only need to be readable.',
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: AppSizes.xxl),
        Obx(
          () => Column(
            children: [
              for (final doc in controller.required) ...[
                _DocTile(doc: doc),
                const SizedBox(height: AppSizes.m),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSizes.s),
        Obx(
          () => Text(
            '${controller.capturedCount} of '
            '${controller.required.length} added',
            style: AppTextStyles.small,
          ),
        ),
      ],
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.doc});

  final RequiredDoc doc;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DocumentsController>();

    return Obx(() {
      final file = controller.files[doc.docType];
      final captured = file != null;

      return Container(
        padding: const EdgeInsets.all(AppSizes.m),
        decoration: BoxDecoration(
          color: captured ? AppColors.successSurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
          border: Border.all(
            color: captured ? AppColors.success : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // A thumbnail once taken, so the customer can see what they sent.
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 56,
                height: 56,
                child: captured
                    ? Image.file(file, fit: BoxFit.cover)
                    : Container(
                        color: AppColors.white,
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 22,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyBold,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    captured ? 'Added' : doc.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.small.copyWith(
                      color: captured ? AppColors.success : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s),
            if (captured)
              IconButton(
                onPressed: () => controller.remove(doc),
                tooltip: 'Remove ${doc.title}',
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.muted,
                ),
              )
            else
              _addButton(context, controller),
          ],
        ),
      );
    });
  }

  Widget _addButton(BuildContext context, DocumentsController controller) {
    // The selfie must be a live photo; the rest can come from the gallery,
    // since a bank statement is often already saved on the phone.
    if (controller.isSelfie) {
      return TextButton(
        onPressed: () => controller.capture(doc),
        child: const Text('Take'),
      );
    }

    return TextButton(
      onPressed: () => _chooseSource(context, controller),
      child: const Text('Add'),
    );
  }

  Future<void> _chooseSource(
    BuildContext context,
    DocumentsController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.s),
            Text(doc.title, style: AppTextStyles.h3),
            const SizedBox(height: AppSizes.s),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.primary,
              ),
              title: const Text('Take a photo', style: AppTextStyles.bodyBold),
              onTap: () {
                Navigator.of(sheetContext).pop();
                controller.capture(doc);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.primary,
              ),
              title: const Text(
                'Choose from gallery',
                style: AppTextStyles.bodyBold,
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                controller.capture(doc, fromGallery: true);
              },
            ),
            const SizedBox(height: AppSizes.s),
          ],
        ),
      ),
    );
  }
}
