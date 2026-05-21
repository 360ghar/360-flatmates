// Supabase Edge Function: send-notification
// Sends push notifications via Firebase Cloud Messaging HTTP v1 API.
//
// Environment variables required (set via `supabase secrets set`):
//   FIREBASE_PROJECT_ID         — Firebase project ID
//   FIREBASE_SERVICE_ACCOUNT_JSON — Full JSON of the Firebase service account key
//
// Expected request body (POST JSON):
// {
//   "user_id":  "uuid",           // required — target user
//   "title":    "string",         // required
//   "body":     "string",         // required
//   "deep_link": "string",        // optional — route to open on tap
//   "image_url": "string",        // optional — rich notification image
//   "data":     { ... }           // optional — extra key-value pairs
// }

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface NotificationPayload {
  user_id: string
  title: string
  body: string
  deep_link?: string
  image_url?: string
  data?: Record<string, unknown>
}

async function getAccessToken(serviceAccountJson: string): Promise<string> {
  const serviceAccount = JSON.parse(serviceAccountJson)
  const now = Math.floor(Date.now() / 1000)
  const expiry = now + 3600

  const header = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')

  const claimSet = btoa(
    JSON.stringify({
      iss: serviceAccount.client_email,
      scope: 'https://www.googleapis.com/auth/firebase.messaging',
      aud: 'https://oauth2.googleapis.com/token',
      iat: now,
      exp: expiry,
    })
  )
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')

  // Sign the JWT
  const key = await crypto.subtle.importKey(
    'pkcs8',
    str2ab(atob(serviceAccount.private_key.replace(/-----[^-]+-----/g, '').trim())),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signatureInput = new TextEncoder().encode(`${header}.${claimSet}`)
  const signature = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, signatureInput)
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '')

  const jwt = `${header}.${claimSet}.${signatureB64}`

  const tokenResponse = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  })

  const tokenData = await tokenResponse.json()
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`)
  }
  return tokenData.access_token
}

function str2ab(str: string): ArrayBuffer {
  const buf = new ArrayBuffer(str.length)
  const bufView = new Uint8Array(buf)
  for (let i = 0; i < str.length; i++) {
    bufView[i] = str.charCodeAt(i)
  }
  return buf
}

serve(async (req) => {
  // Only allow POST
  if (req.method !== 'POST') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 })
  }

  try {
    const payload: NotificationPayload = await req.json()

    // Validate required fields
    if (!payload.user_id || !payload.title || !payload.body) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: user_id, title, body' }),
        { status: 400 }
      )
    }

    // Get env vars
    const projectId = Deno.env.get('FIREBASE_PROJECT_ID')
    const serviceAccountJson = Deno.env.get('FIREBASE_SERVICE_ACCOUNT_JSON')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!projectId || !serviceAccountJson || !supabaseUrl || !supabaseServiceKey) {
      console.error('Missing required environment variables')
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { status: 500 }
      )
    }

    // Fetch device tokens for the target user
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const { data: tokens, error: tokenError } = await supabase
      .from('device_tokens')
      .select('fcm_token, platform')
      .eq('user_id', payload.user_id)

    if (tokenError) {
      console.error('Failed to fetch device tokens:', tokenError)
      return new Response(
        JSON.stringify({ error: 'Failed to fetch device tokens' }),
        { status: 500 }
      )
    }

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ success: true, sent: 0, message: 'No device tokens found for user' }),
        { status: 200 }
      )
    }

    // Get FCM access token
    const accessToken = await getAccessToken(serviceAccountJson)

    // Build the FCM message data
    const messageData: Record<string, string> = {
      ...(payload.data as Record<string, string> ?? {}),
    }
    if (payload.deep_link) {
      messageData['route'] = payload.deep_link
    }

    // Send to each device token
    let successCount = 0
    let failureCount = 0
    const invalidTokens: string[] = []

    for (const device of tokens) {
      const fcmMessage: Record<string, unknown> = {
        message: {
          token: device.fcm_token,
          notification: {
            title: payload.title,
            body: payload.body,
          },
          data: Object.keys(messageData).length > 0 ? messageData : undefined,
          android: {
            notification: {
              channel_id: 'flatmates_messages',
              default_sound: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1,
              },
            },
          },
        },
      }

      if (payload.image_url) {
        (fcmMessage.message as Record<string, unknown>).android = {
          ...(fcmMessage.message as Record<string, unknown>).android,
          notification: {
            ...((fcmMessage.message as Record<string, Record<string, unknown>>).android?.notification as Record<string, unknown> ?? {}),
            image: payload.image_url,
          },
        }
        ;(fcmMessage.message as Record<string, unknown>).apns = {
          ...(fcmMessage.message as Record<string, unknown>).apns,
          'fcm_options': {
            image: payload.image_url,
          },
        }
      }

      try {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
          {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${accessToken}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(fcmMessage),
          }
        )

        if (response.ok) {
          successCount++
        } else {
          const errorBody = await response.text()
          console.error(`FCM send failed for token ${device.fcm_token.slice(0, 10)}...: ${errorBody}`)

          // UNREGISTERED tokens should be cleaned up
          if (response.status === 404 || errorBody.includes('UNREGISTERED') || errorBody.includes('InvalidRegistration')) {
            invalidTokens.push(device.fcm_token)
          }
          failureCount++
        }
      } catch (sendError) {
        console.error(`FCM send error for token ${device.fcm_token.slice(0, 10)}...:`, sendError)
        failureCount++
      }
    }

    // Clean up invalid tokens
    if (invalidTokens.length > 0) {
      const { error: deleteError } = await supabase
        .from('device_tokens')
        .delete()
        .in('fcm_token', invalidTokens)

      if (deleteError) {
        console.error('Failed to clean up invalid tokens:', deleteError)
      }
    }

    console.log(`Notification sent to user ${payload.user_id}: ${successCount} success, ${failureCount} failed`)

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        failed: failureCount,
        cleaned_up: invalidTokens.length,
      }),
      { status: 200 }
    )
  } catch (error) {
    console.error('send-notification error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500 }
    )
  }
})
