import { google } from 'googleapis';

const SCOPES = ['https://www.googleapis.com/auth/calendar'];

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { eventId, calendarId, updates } = req.body;

    if (!eventId || !calendarId || !updates) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    const privateKey = process.env.GOOGLE_PRIVATE_KEY;
    const clientEmail = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;

    if (!privateKey || !clientEmail) {
        return res.status(500).json({ error: 'Google Calendar credentials not configured' });
    }

    try {
        const cleanKey = (key) => {
            if (!key) return null;
            let cleaned = key.trim();
            if (!cleaned.startsWith('-')) {
                try {
                    const decoded = Buffer.from(cleaned, 'base64').toString('utf8');
                    if (decoded.includes('BEGIN PRIVATE KEY')) {
                        cleaned = decoded;
                    }
                } catch (e) { /* not base64 */ }
            }
            cleaned = cleaned.replace(/^["']|["']$/g, '');
            cleaned = cleaned.replace(/\\n/g, '\n');
            if (cleaned.includes('BEGIN PRIVATE KEY') && !cleaned.includes('\n')) {
                cleaned = cleaned
                    .replace('-----BEGIN PRIVATE KEY-----', '-----BEGIN PRIVATE KEY-----\n')
                    .replace('-----END PRIVATE KEY-----', '\n-----END PRIVATE KEY-----');
            }
            return cleaned.trim();
        };

        const auth = new google.auth.JWT(
            clientEmail,
            null,
            cleanKey(privateKey),
            SCOPES
        );

        const calendar = google.calendar({ version: 'v3', auth });

        // Get existing event
        const existingEvent = await calendar.events.get({
            calendarId: calendarId,
            eventId: eventId,
        });

        // Build updated event
        const updatedEvent = {
            ...existingEvent.data,
        };

        // Update times if provided
        if (updates.startTime) {
            updatedEvent.start = { dateTime: updates.startTime, timeZone: 'Europe/London' };
        }
        if (updates.endTime) {
            updatedEvent.end = { dateTime: updates.endTime, timeZone: 'Europe/London' };
        }

        // Update customer info and service
        if (updates.customer || updates.service) {
            const customer = updates.customer || {};
            const service = updates.service || '';

            updatedEvent.summary = `[938] ${service || 'Service'} - ${customer.name || 'Customer'}`;
            updatedEvent.description = `Service: ${service}\nPhone: ${customer.phone || ''}\nEmail: ${customer.email || ''}`;
        }

        // Update the event
        const response = await calendar.events.update({
            calendarId: calendarId,
            eventId: eventId,
            resource: updatedEvent,
        });

        return res.status(200).json({
            success: true,
            event: response.data,
            message: 'Appointment updated successfully'
        });
    } catch (error) {
        console.error('Error updating appointment:', error);
        return res.status(500).json({
            error: 'Failed to update appointment',
            details: error.message
        });
    }
}
