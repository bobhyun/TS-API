/**
 * Example 15: WebSocket - Recording Data Export
 *
 * Demonstrates recording data backup/export via WebSocket.
 *
 * Endpoint:
 *   ws://host:port/wsapi/v1/export?ch=1&timeBegin=...&timeEnd=...
 *
 * Auth:
 *   Header: Authorization: Bearer {accessToken}  (primary)
 *   Header: X-API-Key: {apiKey}                  (alternative)
 *   Query:  ?token={accessToken}                 (browser fallback)
 *   Query:  ?apikey={apiKey}                     (browser fallback)
 *
 * Flow:
 *   Client ──connect──> Server
 *   Client <──ready──── Server   { stage:"ready", task:{id}, channel:{...} }
 *   Client <──fileEnd── Server   { stage:"fileEnd", channel:{file:{download}} }
 *   Client ──{cmd:"next"}──> Server
 *   Client <──end────── Server   { stage:"end" }
 *   (on error) Client <──error── Server   { stage:"error", message }
 *   (to cancel) Client ──{cmd:"cancel"}──> Server
 *
 * REQUIRES: npm install ws
 */

const WebSocket = require('ws');
const { WS_URL, NVR_API_KEY } = require('./config');

function sleep(ms) { return new Promise((r) => setTimeout(r, ms)); }

async function main() {
  if (!NVR_API_KEY) {
    console.error('NVR_API_KEY environment variable is required');
    process.exit(1);
  }

  // Time range: yesterday 00:00 ~ 00:10
  const yesterday = new Date(Date.now() - 86400000);
  const dateStr = yesterday.toISOString().split('T')[0];
  const timeBegin = `${dateStr}T00:00:00`;
  const timeEnd = `${dateStr}T00:10:00`;

  console.log('=== WebSocket Recording Export ===');
  console.log(`  Channel: 1,  ${timeBegin} ~ ${timeEnd}`);

  const url = `${WS_URL}/wsapi/v1/export?ch=1&timeBegin=${timeBegin}&timeEnd=${timeEnd}`;
  // Browser: use ?apikey=${NVR_API_KEY} (no custom headers in browser WebSocket)

  try {
    const ws = new WebSocket(url, {
      headers: { 'X-API-Key': NVR_API_KEY },
      rejectUnauthorized: false,
    });
    let taskId = null;

    ws.on('open', () => {
      console.log('  Connected');
    });

    ws.on('message', (data) => {
      const msg = JSON.parse(data.toString());

      switch (msg.stage) {
        case 'ready':
          // Check status code (code:-1 = no recording in range)
          if (msg.status?.code && msg.status.code !== 0) {
            console.log(`  Ready - Error: ${msg.status.message || JSON.stringify(msg)}`);
            ws.close();
            break;
          }
          taskId = msg.task?.id;
          console.log(`  Ready - Task ID: ${taskId}`);
          break;

        case 'fileEnd': {
          // download: [{fileName, src}, ...]
          const downloads = msg.channel?.file?.download || [];
          const src = downloads[0]?.src || 'N/A';
          console.log(`  File ready: ${src}`);
          if (taskId) {
            ws.send(JSON.stringify({ task: taskId, cmd: 'next' }));
          }
          break;
        }
        case 'end':
          console.log('  Export complete!');
          ws.close();
          break;

        case 'error':
          console.log(`  Error: ${msg.message || JSON.stringify(msg)}`);
          ws.close();
          break;

        default:
          console.log(`  [${msg.stage}] ${JSON.stringify(msg)}`);
      }
    });

    ws.on('error', (err) => {
      console.log(`  Error: ${err.message}`);
    });

    ws.on('close', () => {
      console.log('  Disconnected');
    });

    // Timeout after 60 seconds
    await sleep(60000);
    if (ws.readyState === WebSocket.OPEN) {
      console.log('  Timeout - cancelling...');
      if (taskId) {
        ws.send(JSON.stringify({ task: taskId, cmd: 'cancel' }));
      }
      await sleep(1000);
      ws.close();
    }

  } catch (err) {
    console.log(`  Failed: ${err.message}`);
  }

}

main().catch(console.error);
