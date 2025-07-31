import 'package:flutter/foundation.dart';
import 'package:resend_client/resend_client.dart';
import 'dart:io' show Platform;

void main() async {
  // Initialize the Resend client with your API key
  final client = ResendClient(apiKey: 're_xxxxxxxxx');

  // Create an email with attachments
  final email = EmailRequest(
    to: ['delivered@resend.dev'],
    from: 'Acme <onboarding@resend.dev>',
    subject: 'Receipt for your payment',
    html: '<p>Thanks for the payment</p>',
    text: 'Thanks for the payment',
    attachments: [
      // URL-based attachment
      EmailAttachment(
        path: 'https://resend.com/static/sample/invoice.pdf',
        filename: 'invoice.pdf',
      ),
      // Local file attachment (not supported on web)
      if (!kIsWeb)
        await EmailAttachment.fromLocalFile(
          'path/to/local/invoice.txt',
          filename: 'invoice.txt',
        ),
      // Direct Base64 content attachment
      EmailAttachment(
        content: 'UmVzZW5kIGF0dGFjaG1lbnQgZXhhbXBsZS4gTmljZSBqb2Igc2VuZGluZyB0aGUgZW1haWwh%',
        filename: 'example.txt',
      ),
    ],
  );

  try {
    // Send a single email
    var response = await client.sendEmail(email);
    print('Email sent: $response');

    // Schedule an email
    final scheduledEmail = EmailRequest(
      to: ['delivered@resend.dev'],
      from: 'Acme <onboarding@resend.dev>',
      subject: 'Hello World',
      html: '<p>Scheduled email!</p>',
      scheduledAt: '2024-08-20T11:52:01.858Z',
    );
    response = await client.scheduleEmail(scheduledEmail);
    final emailId = response['id'] as String;
    print('Email scheduled: $response');

    // Reschedule email
    response = await client.rescheduleEmail(
      emailId: emailId,
      scheduledAt: 'in 1 min',
    );
    print('Email rescheduled: $response');

    // Retrieve email
    response = await client.retrieveEmail(emailId);
    print('Email retrieved: $response');

    // Cancel scheduled email
    response = await client.cancelEmail(emailId);
    print('Email canceled: $response');

    // Send batch emails
    final batchEmails = [
      EmailRequest(
        to: ['foo@gmail.com'],
        from: 'Acme <onboarding@resend.dev>',
        subject: 'Hello World',
        html: '<h1>It works!</h1>',
      ),
      EmailRequest(
        to: ['bar@outlook.com'],
        from: 'Acme <onboarding@resend.dev>',
        subject: 'World Hello',
        html: '<p>It works!</p>',
      ),
    ];
    response = await client.sendBatchEmails(batchEmails);
    print('Batch emails sent: $response');
  } catch (e) {
    print('Error: $e');
  } finally {
    // Clean up resources
    client.dispose();
  }
}