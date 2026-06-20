# ZOOM vs GOOGLE MEET - ANALYSE ARCHITECTURALE COMPLÈTE

## 1️⃣ ARCHITECTURE ZOOM

### Core Infrastructure:
- **Signaling**: Custom proprietary protocol (port 8801, 8802, 8803, 8804)
- **Media Transport**: RTMP/RTP over UDP (optimized for low latency)
- **SFU Model**: Selective Forwarding Unit (each participant connects to 1 server, not mesh)
- **Codec**: VP9, H.264, OpusCodec
- **Bandwidth Optimization**: Adaptive bitrate (100kbps - 4Mbps video)
- **Server Topology**: Global CDN with regional data centers
- **Encryption**: TLS 1.2+, AES-256 for media

### Scalability:
- **Max Participants**: 300 on screen, 10,000 webinar mode
- **Connection Model**: Central SFU (not peer-to-peer)
- **Load Balancing**: Geographic routing (best latency)
- **Database**: Redis for session state, Cassandra for recordings

### Screen Sharing Implementation:
```
1. Screen Capture (native OS APIs):
   - Windows: DXGI (DirectX)
   - macOS: ScreenCaptureKit
   - iOS: ReplayKit
   - Android: MediaProjection API

2. Encoding:
   - VP9 codec (license-free)
   - 30fps @ 1920x1080
   - 1-5 Mbps bitrate

3. Transport:
   - Separate RTP stream from main video
   - Priority: Screen > Gallery > Speaker
   - Latency: <500ms to all participants

4. Features:
   - Annotation (draw on screen)
   - Spotlight (pin to all screens)
   - Blur (hide sensitive data)
```

### Recording:
- **Cloud**: AWS S3 + transcoding (MP4/M4A)
- **Local**: File storage on host device
- **Transcription**: Automatic speech-to-text (real-time)
- **Storage**: Infinite cloud (paid), 1GB local per month

---

## 2️⃣ ARCHITECTURE GOOGLE MEET

### Core Infrastructure:
- **Signaling**: WebRTC SDP (Session Description Protocol) over HTTPS
- **Media Transport**: WebRTC (ICE, STUN, TURN)
- **SFU Model**: Google's custom SFU (similar to Zoom)
- **Codec**: VP9, H.264, Opus
- **Bandwidth**: 100kbps - 2.5Mbps adaptive
- **Server**: Google Cloud Platform (global presence)
- **Encryption**: DTLS-SRTP for media

### Scalability:
- **Max Participants**: 150 standard, 10,000 webinar
- **Connection Model**: Central SFU
- **Load Balancing**: GCP Anycast
- **Database**: Firestore for metadata, Cloud Storage for recordings

### Screen Sharing:
```
1. Capture:
   - Chrome extension (getDisplayMedia API)
   - Browser native tab/window/monitor
   - 60fps option

2. Encoding:
   - VP8/VP9
   - Dynamic resolution (up to 4K)
   - Adaptive bitrate: 500kbps - 8Mbps

3. Transport:
   - WebRTC DataChannel for control
   - Separate video stream
   - Latency: ~200-300ms (optimized)

4. Features:
   - Tiling (see shared screen + participants)
   - Focus mode
   - Blur background
   - Timer for scheduled sharing
```

### Recording:
- **Cloud**: Google Drive (auto)
- **Formats**: MP4, WebM
- **Transcription**: Auto-generated (English priority)
- **Retention**: 30-day trash, then permanent

---

## 3️⃣ SCALABILITY COMPARISON (1000+ PARTICIPANTS)

| Feature | Zoom | Google Meet | CRUX Plan |
|---------|------|-------------|-----------|
| **Max Direct** | 300 | 150 | 50 (Agora) + 1000 (Jitsi) |
| **SFU Type** | Proprietary | WebRTC-based | Hybrid (Agora+Jitsi) |
| **Latency** | 50-150ms | 100-200ms | 100-300ms |
| **Bandwidth/User** | 2.5Mbps | 2.5Mbps | 1.5-3Mbps |
| **Screen Share Latency** | <500ms | 200-300ms | 500-1000ms |
| **Encoding** | Hardware (NVIDIA) | Software | Software (FFmpeg) |
| **Firewall NAT** | Optimized | WebRTC TURN | TURN relay |

---

## 4️⃣ ZOOM SCREEN SHARING - DETAILED FLOW

```
HOST (macOS/Windows):
┌──────────────────────────────────┐
│ 1. startScreenShare()            │ → OS: ScreenCaptureKit / DXGI
├──────────────────────────────────┤
│ 2. Capture frame (30fps)         │ → 1920x1080 raw pixel data
├──────────────────────────────────┤
│ 3. VP9 Encoder (NVIDIA if avail) │ → Bitrate: 2-4 Mbps
├──────────────────────────────────┤
│ 4. Send to Zoom SFU              │ → UDP port 8801-8804
├──────────────────────────────────┤
│ 5. SFU broadcasts to N clients   │ → Parallel streams
└──────────────────────────────────┘

PARTICIPANTS (ANY DEVICE):
┌──────────────────────────────────┐
│ 1. Receive RTP stream (VP9)      │ ← From SFU
├──────────────────────────────────┤
│ 2. VP9 decoder (hardware/soft)   │ → Raw frames
├──────────────────────────────────┤
│ 3. Render on UI thread           │ → OpenGL/Metal
├──────────────────────────────────┤
│ 4. Sync with audio (A/V sync)    │ → <50ms drift acceptable
└──────────────────────────────────┘

LATENCY BREAKDOWN:
Capture (2ms) + Encode (8ms) + Network (100ms) + Decode (5ms) + Render (3ms) = ~120ms
```

---

## 5️⃣ GOOGLE MEET SCREEN SHARING - DETAILED FLOW

```
HOST (Any browser):
┌──────────────────────────────────┐
│ 1. getDisplayMedia() promise     │ → User selects window/tab/monitor
├──────────────────────────────────┤
│ 2. MediaStream object captured   │ → Canvas/Tab/Window stream
├──────────────────────────────────┤
│ 3. RTCPeerConnection config      │ → STUN/TURN servers
├──────────────────────────────────┤
│ 4. addTrack(screenStream)        │ → VP8/VP9 encoder (browser)
├──────────────────────────────────┤
│ 5. Send SDP offer to Google SFU  │ → ICE candidate gathering
├──────────────────────────────────┤
│ 6. Receive SDP answer            │ → Connection established
├──────────────────────────────────┤
│ 7. Screen stream flows           │ → RTP/RTCP over UDP
└──────────────────────────────────┘

PARTICIPANTS (Browser):
┌──────────────────────────────────┐
│ 1. Receive remote screen track   │ ← WebRTC ontrack event
├──────────────────────────────────┤
│ 2. Attach to <video> element     │ → Auto-decode (browser codec)
├──────────────────────────────────┤
│ 3. Display in tiling layout      │ → CSS grid or custom renderer
└──────────────────────────────────┘

LATENCY BREAKDOWN:
Capture (1ms) + Encode (5ms) + ICE (20ms) + Network (150ms) + Decode (5ms) + Render (2ms) = ~180ms
```

---

## 6️⃣ CRUX HYBRID ARCHITECTURE (1000+ READY)

```
                    ┌─────────────────┐
                    │  Meeting Server  │
                    │  (Firebase)      │
                    └────────┬──────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         ≤ 50 users    50-300 users   300-1000+ users
              │              │              │
         ┌────▼────┐   ┌────▼────┐   ┌────▼────────┐
         │  Agora  │   │  Agora  │   │  Jitsi SFU  │
         │  (SFU)  │   │  Mesh   │   │  (WebRTC)   │
         └─────────┘   └─────────┘   └─────────────┘
         Latency:      Latency:      Latency:
         50-100ms      100-200ms     200-500ms
         Cost: Low     Cost: Med     Cost: High

ROUTING LOGIC:
if participants <= 50:
  → Use Agora SFU (lowest latency + cost)
elif participants <= 300:
  → Use Agora SFU + optimized bitrate
else:
  → Migrate to Jitsi (handles 1000+)
  → Enable SFU mode (not P2P)
```

---

## 7️⃣ SCREEN SHARING IMPLEMENTATION FOR CRUX

### Option 1: Agora Extension (Small Conferences ≤50)
```dart
// Agora-specific screen share
agoraEngine.startScreenCapture(
  ScreenCaptureParameters(
    captureAudio: true,
    captureVideo: true,
    videoParams: VideoEncoderConfiguration(
      orientationMode: OrientationMode.fixedPortrait,
      degradationPreference: DegradationPreference.maintainFramerate,
    ),
  ),
);
```

### Option 2: WebRTC + Jitsi (Large Conferences 50-1000)
```dart
// Use getDisplayMedia (web/desktop) via WebRTC
// Jitsi handles SFU forwarding
// Mobile: Use screenshot + timer (every 500ms)
```

### Option 3: Cloud-based (Enterprise)
```
Use AWS Chime / Twilio for professional SFU
Scales to 10,000+ easily
Cost: $0.30/participant-minute
```

---

## 8️⃣ RECORDING & TRANSCRIPTION (ZOOM-LIKE)

```
Recording Endpoint:
┌─────────────────────────────────┐
│ 1. Subscribe to video streams   │ ← All participants
├─────────────────────────────────┤
│ 2. Record each stream separately│ → /data/recordings/
├─────────────────────────────────┤
│ 3. Compose layout (gallery view)│ → FFmpeg mux
├─────────────────────────────────┤
│ 4. Encode to H.264 MP4          │ → AWS Elemental
├─────────────────────────────────┤
│ 5. Upload to S3                 │ → /bucket/meeting_id/
├─────────────────────────────────┤
│ 6. Trigger transcription        │ → AWS Transcribe API
├─────────────────────────────────┤
│ 7. Generate SRT subtitles       │ → Firestore subcollection
└─────────────────────────────────┘

Cost Estimate:
- Recording: $0.10 per participant-hour
- S3 Storage: $0.023 per GB per month
- Transcription: $0.02 per minute
- Total 100-person-1hr: ~$13
```

---

## 9️⃣ PARTICIPANT MANAGEMENT (ZOOM-LIKE)

```dart
// Host Controls
muteAll()              // Disable all mics except host
removeParticipant()    // Kick someone
promoteCoHost()        // Give permissions
lockMeeting()          // Prevent new joins
spotlightParticipant() // Pin to all screens
```

---

## 🔟 KEY DIFFERENCES & CRUX CHOICE

| Aspect | Zoom | Google Meet | CRUX |
|--------|------|-------------|------|
| **Open Source** | No | No | Yes (uses Jitsi) |
| **Cost** | $15.99/mo | Free/Paid | Free (Firebase + Jitsi) |
| **Scalability** | 300 built-in | 150 built-in | 1000+ with SFU |
| **Screen Share Quality** | Excellent (low latency) | Good | Good (depends on SFU) |
| **Recording** | Native cloud | Native GDrive | Manual S3 upload |
| **Privacy** | Questionable | Google tracks | Open source |

---

## CRUX IMPLEMENTATION ROADMAP

### ✅ Already Done:
- Meeting code (6-digit short codes)
- Chat service
- Recording service (basic)
- Participant management

### 🔧 To Implement (PRIORITY):
1. **Screen Sharing** (with Jitsi integration)
2. **1000+ Scalability** (SFU routing)
3. **Quality screen share latency** (~500ms max)
4. **Recording with multiple layouts** (gallery view)
5. **Live transcription** (Google Cloud Speech-to-Text)
6. **Waiting room + access control**
7. **Virtual backgrounds** (ML Kit segmentation)
8. **Breakout rooms** (sub-meetings)
9. **Hand raising** (with notifications)
10. **Gallery + Speaker modes** (layout switching)

---

## DECISION FOR CRUX:

### Recommended Stack:
```
Frontend:   Flutter (mobile + web)
Backend:    Firebase + Cloud Functions
Video:      Agora (≤50) + Jitsi (>50)
Recording:  FFmpeg + AWS S3
Chat:       Firestore Realtime
Auth:       Firebase Auth
Scaling:    Cloud Run (auto-scale)
Latency:    50-500ms depending on tier
Max Users:  1000+ per meeting
```

### Cost per 1000-person 1-hour meeting:
- Jitsi SFU: $0 (self-hosted) or $100 (managed)
- Recording/Encoding: $50 (AWS Elemental)
- Storage (30 days): $5
- **Total: ~$155 (one-time)**

---

## NEXT: IMPLEMENT EVERYTHING

See detailed implementation in Phase 3+
