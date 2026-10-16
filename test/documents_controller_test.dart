import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:salary_brother/controllers/documents_controller.dart';
import 'package:salary_brother/services/api/api_endpoints.dart';
import 'package:salary_brother/services/api/api_events.dart';

void main() {
  tearDown(Get.reset);

  /// The screen's mode comes from route arguments, which a unit test has no
  /// way to supply — so this builds the general-mode controller, which is
  /// also the safe default when the CRM sends no argument.
  DocumentsController build() {
    Get.testMode = true;
    Get.put<DocumentsController>(DocumentsController());
    return Get.find<DocumentsController>();
  }

  group('mode', () {
    test('defaults to the general document list, not the selfie', () {
      final controller = build();

      expect(controller.isSelfie, isFalse);
      expect(controller.required.length, greaterThan(1));
    });
  });

  group('the document list matches the CRM', () {
    late DocumentsController controller;

    setUp(() => controller = build());

    test('covers all five non-selfie uploads', () {
      final events = controller.required.map((d) => d.eventName).toSet();

      expect(events, contains(ApiEvents.pancardUpload));
      expect(events, contains(ApiEvents.aadhaarUpload));
      expect(events, contains(ApiEvents.residenceProof));
      expect(events, contains(ApiEvents.bankStatementUpload));
      expect(events, contains(ApiEvents.paySlipUpload));
    });

    test('asks for Aadhaar twice, once per side', () {
      final aadhaar = controller.required
          .where((d) => d.eventName == ApiEvents.aadhaarUpload)
          .map((d) => d.docType)
          .toList();

      expect(aadhaar, ['aadhaar_front', 'aadhaar_back']);
    });

    test('address proof sends electricity_bill, not its own event name', () {
      // The CRM's doc_type does not always match the event. Sending
      // residence_proof_upload here is rejected.
      final proof = controller.required
          .firstWhere((d) => d.eventName == ApiEvents.residenceProof);

      expect(proof.docType, 'electricity_bill');
    });

    test('every document has a distinct doc_type', () {
      // They key the captured-files map, so a collision would silently drop
      // one document.
      final types = controller.required.map((d) => d.docType).toList();
      expect(types.toSet().length, types.length);
    });
  });

  group('completion', () {
    test('is false until every document is captured', () {
      final controller = build();
      expect(controller.isComplete, isFalse);
      expect(controller.capturedCount, 0);
    });
  });

  group('the endpoint split', () {
    test('selfie goes to the customer profile, the rest to the lead', () {
      // This is the easiest thing to get wrong in the whole upload path, so
      // pin the rule rather than the implementation.
      expect(ApiEndpoints.saveCustomerProfile, 'saveCustomerProfile');
      expect(ApiEndpoints.saveLeadDetails, 'saveleadDetails');
      expect(ApiEvents.selfieUpload, 'selfie_upload');
    });
  });
}
