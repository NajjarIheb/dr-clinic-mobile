import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/vital.dart';
import '../models/clinical_note.dart';

class PdfService {
  /// Generates and previews/prints an official medical prescription
  static Future<void> printPrescription({
    required Doctor doctor,
    required Patient patient,
    required List<Prescription> prescriptions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.blue800, width: 2),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Dr. ${doctor.firstName} ${doctor.lastName}',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          doctor.specialty,
                          style: const pw.TextStyle(
                            fontSize: 13,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.Text(
                          'Licence No: ${doctor.licenseNumber}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DR.CLINIC HEALTHCARE',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.Text('Phone: ${doctor.phone}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text('Email: ${doctor.email}',
                            style: const pw.TextStyle(fontSize: 10)),
                        pw.Text(
                          'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Patient Information Box
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Patient Name: ${patient.fullName}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Gender / Age: ${patient.gender}, ${patient.age} years (DOB: ${DateFormat('yyyy-MM-dd').format(patient.dob)})',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Blood Type: ${patient.bloodType.isNotEmpty ? patient.bloodType : 'N/A'}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          'Known Allergies: ${patient.allergies.isNotEmpty ? patient.allergies : 'None Reported'}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: patient.allergies.isNotEmpty
                                ? PdfColors.red800
                                : PdfColors.black,
                            fontWeight: patient.allergies.isNotEmpty
                                ? pw.FontWeight.bold
                                : pw.FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),

              // Rx Symbol
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    '℞',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(width: 8),
                  pw.Text(
                    'MEDICAL PRESCRIPTION',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 12),

              // Medication Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue800,
                ),
                cellHeight: 28,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerLeft,
                },
                headers: ['Medication', 'Dosage', 'Frequency', 'Qty / Refills', 'Instructions'],
                data: prescriptions.map((rx) {
                  return [
                    rx.medicationName,
                    rx.dosage,
                    rx.frequency,
                    '${rx.quantity} (Refills: ${rx.refills})',
                    rx.notes.isNotEmpty ? rx.notes : 'Take as directed',
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // Signature Line & Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Important Notice:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'This prescription is valid for 30 days from date of issue.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Please consult your pharmacist for drug interactions.',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        width: 180,
                        height: 1,
                        color: PdfColors.grey600,
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'Dr. ${doctor.firstName} ${doctor.lastName}, MD',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Authorized Physician Signature & Stamp',
                        style: const pw.TextStyle(
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Center(
                child: pw.Text(
                  'Generated securely by Dr.Clinic Medical Practice Management EMR',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Prescription_${patient.lastName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Generates and previews a complete Patient Medical Chart PDF
  static Future<void> printPatientChart({
    required Doctor doctor,
    required Patient patient,
    required List<Vital> vitals,
    required List<ClinicalNote> notes,
    required List<Prescription> prescriptions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('PATIENT CLINICAL SUMMARY',
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900)),
                    pw.Text('Dr.Clinic EMR Record',
                        style: const pw.TextStyle(
                            fontSize: 11, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Physician: Dr. ${doctor.fullName}',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Generated: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                        style: const pw.TextStyle(
                            fontSize: 9, color: PdfColors.grey600)),
                  ],
                ),
              ],
            ),
            pw.Divider(color: PdfColors.blue800, thickness: 1.5),
            pw.SizedBox(height: 10),

            // Demographics
            pw.Text('Patient Demographics',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800)),
            pw.SizedBox(height: 6),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Name: ${patient.fullName}  |  Gender: ${patient.gender}  |  Age: ${patient.age} yrs'),
                  pw.Text('DOB: ${DateFormat('yyyy-MM-dd').format(patient.dob)}  |  Phone: ${patient.phone}  |  Email: ${patient.email}'),
                  pw.Text('Blood Type: ${patient.bloodType.isNotEmpty ? patient.bloodType : 'Unknown'}  |  Allergies: ${patient.allergies.isNotEmpty ? patient.allergies : 'None recorded'}'),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Vitals
            pw.Text('Recent Vitals & Biometrics',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800)),
            pw.SizedBox(height: 6),
            if (vitals.isEmpty)
              pw.Text('No vitals on record.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headers: ['Date', 'BP (mmHg)', 'Heart Rate', 'Temp (°C)', 'Weight (kg)', 'BMI'],
                data: vitals.take(5).map((v) => [
                  DateFormat('yyyy-MM-dd').format(v.recordedAt),
                  v.bp,
                  '${v.heartRate} bpm',
                  '${v.temperature}°C',
                  '${v.weight} kg',
                  v.bmi.toStringAsFixed(1),
                ]).toList(),
              ),
            pw.SizedBox(height: 16),

            // Prescriptions
            pw.Text('Prescription History',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800)),
            pw.SizedBox(height: 6),
            if (prescriptions.isEmpty)
              pw.Text('No prescriptions on record.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headers: ['Medication', 'Dosage', 'Frequency', 'Status', 'Start Date'],
                data: prescriptions.map((p) => [
                  p.medicationName,
                  p.dosage,
                  p.frequency,
                  p.status,
                  DateFormat('yyyy-MM-dd').format(p.startDate),
                ]).toList(),
              ),
            pw.SizedBox(height: 16),

            // Clinical Notes
            pw.Text('Clinical Consultation Notes (SOAP)',
                style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue800)),
            pw.SizedBox(height: 6),
            if (notes.isEmpty)
              pw.Text('No clinical notes recorded.', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600))
            else
              ...notes.take(4).map((n) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${DateFormat('yyyy-MM-dd').format(n.createdAt)} - Dx: ${n.diagnosisCode}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text('Subjective: ${n.subjective}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Objective: ${n.objective}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Assessment: ${n.assessment}', style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Plan: ${n.plan}', style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
              )),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Medical_Chart_${patient.lastName}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
