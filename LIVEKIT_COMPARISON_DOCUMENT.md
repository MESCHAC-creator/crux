# Agora vs Jitsi vs LiveKit - Which Should CRUX Use?

## 📊 COMPARISON TABLE

| Aspect | Agora | Jitsi | LiveKit |
|--------|-------|-------|---------|
| **Type** | Proprietary SFU | Open-source SFU | Open-source SFU |
| **Max Users** | 300 | 1000+ | 10,000+ |
| **Latency** | 50-100ms | 200-500ms | 100-200ms |
| **Cost** | $0.002-0.010/min/user | Free (self-hosted) | Free (self-hosted) |
| **Setup** | SDK only | Self-host or SDK | Self-host or SDK |
| **Scalability** | Medium | High | Very High |
| **Recording** | Native | Native | Native |
| **Screen Share** | Native | Native | Native |
| **Quality** | Excellent | Good | Very Good |
| **Support** | Excellent | Community | Community |
| **Open Source** | No | Yes | Yes |
| **Can Self-Host** | No | Yes | Yes |

---

## 🎯 CURRENT CRUX SETUP

```
CRUX Uses HYBRID:
├─ Agora (≤300 participants)
│  ├ Lower latency (50-100ms)
│  ├ Better reliability
│  └ Better quality for small meetings
│
└─ Jitsi (300-1000+ participants)
   ├ Open-source (can self-host)
   ├ Handles large conferences
   └ Free to run yourself
```

**Why this hybrid?**
- Small meetings: Use Agora for best quality
- Large meetings: Use Jitsi for scalability
- Best of both worlds!

---

## 🔄 IF YOU WANT TO USE LIVEKIT INSTEAD:

### Pros:
✅ Open-source (full control)  
✅ Self-hostable (no vendor lock-in)  
✅ Better latency than Jitsi (100-200ms vs 200-500ms)  
✅ Very scalable (10,000+)  
✅ Modern WebRTC implementation  
✅ Good documentation  
✅ Active community  

### Cons:
❌ Smaller community than Agora  
❌ Less battle-tested at massive scale  
❌ Requires self-hosting infrastructure  
❌ No native recording (need external service)  

---

## 🚀 MIGRATION PATH (If you want LiveKit)

### Step 1: Replace Agora SFU with LiveKit
```dart
// OLD (Agora)
final agoraEngine = createAgoraRtcEngine();

// NEW (LiveKit)
final liveKit = LiveKitService();
await liveKit.connect(
  url: 'wss://livekit.your-domain.com',
  token: generatedToken,
  participantName: userName,
);
```

### Step 2: Keep Jitsi for Large Conferences
```dart
// Jitsi still handles 300-1000+ meetings
if (participantCount <= 300) {
  // Use LiveKit
} else {
  // Use Jitsi
}
```

### Step 3: Update Services
```
lib/services/
├── livekit_service.dart                    (NEW)
├── jitsi_service.dart                      (KEEP)
└── scalability_service.dart                (UPDATE routing logic)
```

---

## 💰 COST COMPARISON (1000-person 1-hour meeting)

### Current CRUX (Agora + Jitsi):
```
Agora:  $2 (if used, charged per minute)
Jitsi:  $0 (self-hosted) or $100 (managed)
AWS Recording: $50
Total: ~$50-150
```

### If Using LiveKit Only:
```
LiveKit: $0 (self-hosted) or $50-100 (managed)
Recording: $50 (external service)
Total: ~$50-150 (similar cost)
```

**Difference**: LiveKit requires YOUR infrastructure to self-host

---

## ⚙️ INFRASTRUCTURE REQUIREMENTS

### Agora + Jitsi (Current):
- No servers needed
- Agora handles infrastructure
- Jitsi: Optional self-host or use jitsi.org free

### LiveKit Only:
```
Required to self-host:
├─ LiveKit Server (Linux VM)
├─ TURN Server (for NAT traversal)
├─ Redis (for state management)
├─ Recording Service (optional, for cloud recording)
└─ Load Balancer (if scaling to 1000+)

Estimated Cost:
├─ 1x Server: $50-100/month
├─ 2x TURN: $20-50/month
├─ Redis: $10-20/month
└─ Recording: $0-50/month
= $80-220/month baseline
```

---

## 🎓 MY RECOMMENDATION

### Use CURRENT Setup (Agora + Jitsi) IF:
✅ You want **managed infrastructure**  
✅ You prefer **zero ops overhead**  
✅ You want **enterprise support** (Agora)  
✅ You don't want to manage servers  
✅ Cost per meeting isn't critical  

### Switch to LiveKit IF:
✅ You want **full control**  
✅ You have **DevOps capability**  
✅ You want **open-source everything**  
✅ You're comfortable **self-hosting**  
✅ You need **massive scale** (10,000+)  

---

## 🔧 TECHNICAL COMPARISON

### Recording
```
Agora:   ✅ Built-in cloud recording
Jitsi:   ✅ Built-in recording
LiveKit: ⚠️  Requires external service (e.g., AWS MediaLive)
```

### Screen Sharing
```
Agora:   ✅ Native, low latency
Jitsi:   ✅ Native, moderate latency
LiveKit: ✅ Native, low latency
```

### Bandwidth Optimization
```
Agora:   ✅ Adaptive bitrate (proprietary algorithm)
Jitsi:   ⚠️  Basic adaptive bitrate
LiveKit: ✅ Adaptive bitrate (Dynacast)
```

### Latency (p99)
```
Agora:   50-100ms   ⭐ Best
LiveKit: 100-200ms  ⭐ Very good
Jitsi:   200-500ms  ⭐ Good
```

---

## 📝 IF YOU WANT TO SWITCH: HERE'S THE PLAN

1. **Keep current CRUX as-is** for GitHub release
2. **Create branch**: `feature/livekit-integration`
3. **Replace Agora** with LiveKit
4. **Keep Jitsi** for large conferences
5. **Test thoroughly** before releasing as v1.1.0

---

## ✅ FINAL ANSWER

**CRUX is currently using: AGORA + JITSI (Hybrid)**

This is the RIGHT choice because:
- ✅ Managed infrastructure (no ops needed)
- ✅ Enterprise-grade quality
- ✅ Scalability to 1000+ (via Jitsi)
- ✅ Open-source for large meetings (Jitsi)
- ✅ Best latency for small meetings (Agora)

**LiveKit is a GREAT alternative** if you want:
- Self-hosted open-source everything
- More control over infrastructure
- No vendor lock-in

---

## 🎯 FOR NOW:

**Push the CURRENT setup to GitHub** (Agora + Jitsi)

This is production-ready and battle-tested.

Later versions can explore LiveKit if needed.

---

**Summary**: CRUX uses Agora + Jitsi, not LiveKit. But LiveKit is a solid alternative if you want to self-host everything!
