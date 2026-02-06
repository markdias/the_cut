import { google } from 'googleapis';

const SCOPES = ['https://www.googleapis.com/auth/calendar'];

export default async function handler(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    const { eventId, calendarId } = req.body;

    if (!eventId || !calendarId) {
        return res.status(400).json({ error: 'Missing eventId or calendarId' });
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

        await calendar.events.delete({
            calendarId: calendarId,
            eventId: eventId,
        });

        return res.status(200).json({
            success: true,
            message: 'Appointment deleted successfully'
        });
    } catch (error) {
        console.error('Error deleting appointment:', error);
        return res.status(500).json({
            error: 'Failed to delete appointment',
            details: error.message
        });
    }
}
