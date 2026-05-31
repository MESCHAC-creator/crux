const express = require('express');
const cors = require('cors');
const { RtcTokenBuilder, RtcRole } = require('agora-token');

const app = express();
const PORT = process.env.PORT || 8081;

const APP_ID = process.env.AGORA_APP_ID || '729bb936e5084d53897e43c58ee8e946';
const APP_CERTIFICATE = process.env.AGORA_APP_CERTIFICATE || '93fb3c3df2d840bd94da85a24115ac43';

app.use(cors());
app.use(express.json());

app.get('/ping', (req, res) => {
  res.json({ message: 'Token server running', timestamp: new Date().toISOString() });
});

// GET /rtc/:channelName/:role/uid/:uid
app.get('/rtc/:channelName/:role/uid/:uid', (req, res) => {
  const { channelName, role, uid } = req.params;
  const expireTime = parseInt(req.query.expiry || '3600', 10);

  if (!channelName) {
    return res.status(400).json({ error: 'channelName is required' });
  }

  const rtcRole = role === 'publisher' ? RtcRole.PUBLISHER : RtcRole.SUBSCRIBER;
  const currentTime = Math.floor(Date.now() / 1000);
  const privilegeExpireTime = currentTime + expireTime;

  const token = RtcTokenBuilder.buildTokenWithUid(
    APP_ID,
    APP_CERTIFICATE,
    channelName,
    parseInt(uid, 10),
    rtcRole,
    privilegeExpireTime,
    privilegeExpireTime,
  );

  return res.json({ rtcToken: token });
});

app.listen(PORT, () => {
  console.log(`Agora token server listening on port ${PORT}`);
});