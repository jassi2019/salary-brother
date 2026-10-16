import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api/api_endpoints.dart';
import '../services/api/api_events.dart';
import '../services/api_service.dart';
import '../services/journey_service.dart';
import '../utils/app_strings.dart';
import '../widgets/app_toast.dart';

/// One document the CRM is waiting for.
class RequiredDoc {
  const RequiredDoc({
    required this.eventName,
    required this.docType,
    required this.title,
    required this.subtitle,
  });

  /// The `event_name` this upload posts under.
  final String eventName;

  /// The CRM's own `doc_type`. It does not always match [eventName] —
  /// `residence_proof_upload` sends `electricity_bill`, and Aadhaar is sent
  /// twice, once per side.
  final String docType;

  final String title;
  final String subtitle;
}

/// Uploads the documents the CRM asks for.
///
/// Everything goes up as **base64 inside JSON**, never multipart, and the
/// endpoint splits by event: `selfie_upload` posts to `saveCustomerProfile`,
/// every other upload to `saveleadDetails`.
class DocumentsController extends GetxController {
  DocumentsController({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// True when the CRM asked for the selfie specifically, which is a
  /// one-document screen with the front camera.
  late final bool isSelfie =
      (Get.arguments as Map?)?['isSelfie'] as bool? ?? false;

  final isSubmitting = false.obs;

  /// Captured files, keyed by `doc_type`.
  final files = <String, File>{}.obs;

  /// The documents this screen is collecting.
  late final RxList<RequiredDoc> required = <RequiredDoc>[
    if (isSelfie)
      const RequiredDoc(
        eventName: ApiEvents.selfieUpload,
        // The CRM sends no doc_type for the selfie.
        docType: '',
        title: 'Your selfie',
        subtitle: 'Face the camera in good light',
      )
    else ...[
      const RequiredDoc(
        eventName: ApiEvents.pancardUpload,
        docType: 'pan_upload',
        title: 'PAN card',
        subtitle: 'A clear photo of the card',
      ),
      const RequiredDoc(
        eventName: ApiEvents.aadhaarUpload,
        docType: 'aadhaar_front',
        title: 'Aadhaar — front',
        subtitle: 'The side with your photo',
      ),
      const RequiredDoc(
        eventName: ApiEvents.aadhaarUpload,
        docType: 'aadhaar_back',
        title: 'Aadhaar — back',
        subtitle: 'The side with your address',
      ),
      const RequiredDoc(
        eventName: ApiEvents.residenceProof,
        // Not residence_proof_upload: the CRM wants this doc_type.
        docType: 'electricity_bill',
        title: 'Address proof',
        subtitle: 'A recent utility bill',
      ),
      const RequiredDoc(
        eventName: ApiEvents.bankStatementUpload,
        docType: 'bank_statement_upload',
        title: 'Bank statement',
        subtitle: 'Last three months',
      ),
      const RequiredDoc(
        eventName: ApiEvents.paySlipUpload,
        docType: 'pay_slip_upload',
        title: 'Pay slips',
        subtitle: 'Last three months',
      ),
    ],
  ].obs;

  bool get isComplete =>
      required.every((doc) => files.containsKey(doc.docType));

  int get capturedCount => files.length;

  /// Opens the camera, or the gallery for documents that are easier to pick
  /// than to photograph.
  Future<void> capture(RequiredDoc doc, {bool fromGallery = false}) async {
    try {
      final picked = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice:
            isSelfie ? CameraDevice.front : CameraDevice.rear,
        // Keeps the base64 payload to a size the CRM will accept.
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null) return;

      files[doc.docType] = File(picked.path);
    } catch (_) {
      AppToast.error('Could not open the camera. Check the app permissions.');
    }
  }

  void remove(RequiredDoc doc) => files.remove(doc.docType);

  /// Uploads each captured file in turn, then follows the CRM's next step.
  ///
  /// They go one at a time because the CRM takes one document per request.
  Future<void> submit() async {
    if (!isComplete) {
      AppToast.error('Add every document before continuing');
      return;
    }

    final profileId = await JourneyService.requireProfileId();
    if (profileId == null) return;

    isSubmitting.value = true;

    Map<String, dynamic>? lastData;
    for (final doc in required) {
      final file = files[doc.docType];
      if (file == null) continue;

      final result = await _upload(doc, file, profileId);
      if (result == null) {
        isSubmitting.value = false;
        return;
      }
      lastData = result;
    }

    isSubmitting.value = false;

    await JourneyService.rememberStep(lastData);
    JourneyService.goToStep(lastData?['next_step']?.toString());
  }

  /// Posts one document. Returns its `Data`, or null if it failed — in which
  /// case the error has already been shown.
  Future<Map<String, dynamic>?> _upload(
    RequiredDoc doc,
    File file,
    String profileId,
  ) async {
    final bytes = await file.readAsBytes();
    final extension = _extensionOf(file.path);

    final result = await ApiService.instance.post(
      // selfie_upload belongs to the customer profile; the rest to the lead.
      doc.eventName == ApiEvents.selfieUpload
          ? ApiEndpoints.saveCustomerProfile
          : ApiEndpoints.saveLeadDetails,
      event: doc.eventName,
      body: {
        'profile_id': profileId,
        'doc_type': doc.docType,
        'file_ext': extension,
        'file': base64Encode(bytes),
      },
    );

    if (await JourneyService.handleRedirect(result)) return null;

    if (!result.isSuccess) {
      AppToast.error(
        result.error ?? '${doc.title}: ${AppStrings.somethingWentWrong}',
      );
      return null;
    }

    return result.data;
  }

  /// The CRM does not accept HEIC, which iPhones produce by default; the
  /// bytes are JPEG-compatible once the picker has re-encoded them.
  String _extensionOf(String path) {
    final raw = path.split('.').last.toLowerCase();
    return raw == 'heic' || raw.isEmpty ? 'jpg' : raw;
  }
}
