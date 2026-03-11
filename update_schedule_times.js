import { createClient } from '@supabase/supabase-js';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Simple .env parser to avoid 'dotenv' dependency
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(__dirname, '.env');

let env = {};
if (fs.existsSync(envPath)) {
    const content = fs.readFileSync(envPath, 'utf-8');
    content.split('\n').forEach(line => {
        const match = line.match(/^([^=]+)=(.*)$/);
        if (match) {
            const key = match[1].trim();
            const value = match[2].trim().replace(/^["']|["']$/g, ''); // Remove quotes
            env[key] = value;
        }
    });
}

const supabaseUrl = env.VITE_SUPABASE_URL;
const supabaseKey = env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
    console.error('Error: Could not find VITE_SUPABASE_URL or VITE_SUPABASE_ANON_KEY in .env file.');
    console.log('Parsed env keys:', Object.keys(env));
    process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function updateTimes() {
    console.log('Starting schedule time update...');

    const updates = [
        { period: 1, time: '08:15 - 09:00' },
        { period: 2, time: '09:10 - 09:55' },
        { period: 3, time: '10:05 - 10:50' },
        { period: 4, time: '11:10 - 11:55' },
        { period: 5, time: '12:05 - 12:50' },
        { period: 6, time: '13:00 - 13:45' },
        { period: 7, time: '13:55 - 14:40' },
        { period: 8, time: '14:50 - 15:35' },
    ];

    for (const update of updates) {
        const { error } = await supabase
            .from('schedules')
            .update({ time: update.time })
            .eq('period', update.period);

        if (error) {
            console.error(`Failed to update period ${update.period}:`, error);
        } else {
            console.log(`Updated period ${update.period} to ${update.time}`);
        }
    }
    console.log('Done! Now refresh the page.');
}

updateTimes();
