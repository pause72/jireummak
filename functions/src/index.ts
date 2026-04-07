import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import axios from "axios";

admin.initializeApp();

// ── 소셜 로그인 커스텀 토큰 발급 ─────────────────────────────
//
// POST body: { provider: "naver" | "kakao", accessToken: string }
// Response:  { firebaseToken: string }
//
export const socialLogin = functions.https.onRequest(async (req, res) => {
  res.set("Access-Control-Allow-Origin", "*");
  if (req.method === "OPTIONS") {
    res.set("Access-Control-Allow-Methods", "POST");
    res.set("Access-Control-Allow-Headers", "Content-Type");
    res.status(204).send("");
    return;
  }

  if (req.method !== "POST") {
    res.status(405).json({ error: "Method not allowed" });
    return;
  }

  const { provider, accessToken } = req.body as {
    provider: "naver" | "kakao";
    accessToken: string;
  };

  if (!provider || !accessToken) {
    res.status(400).json({ error: "provider and accessToken are required" });
    return;
  }

  try {
    let uid: string;
    let email: string | undefined;
    let displayName: string | undefined;
    let photoURL: string | undefined;

    if (provider === "naver") {
      // 네이버 사용자 정보 조회
      const response = await axios.get("https://openapi.naver.com/v1/nid/me", {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      const profile = response.data.response;
      uid = `naver:${profile.id}`;
      email = profile.email;
      displayName = profile.name ?? profile.nickname;
      photoURL = profile.profile_image;
    } else if (provider === "kakao") {
      // 카카오 사용자 정보 조회
      const response = await axios.get("https://kapi.kakao.com/v2/user/me", {
        headers: { Authorization: `Bearer ${accessToken}` },
      });
      const profile = response.data;
      uid = `kakao:${profile.id}`;
      email = profile.kakao_account?.email;
      displayName =
        profile.kakao_account?.profile?.nickname ?? profile.properties?.nickname;
      photoURL =
        profile.kakao_account?.profile?.profile_image_url ??
        profile.properties?.profile_image;
    } else {
      res.status(400).json({ error: "Unknown provider" });
      return;
    }

    // Firestore에 사용자 정보 저장/갱신
    await admin.firestore().doc(`users/${uid}`).set(
      {
        provider,
        email: email ?? null,
        displayName: displayName ?? null,
        photoURL: photoURL ?? null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Firebase 커스텀 토큰 발급
    const firebaseToken = await admin.auth().createCustomToken(uid, {
      provider,
      email: email ?? null,
      displayName: displayName ?? null,
    });

    res.status(200).json({ firebaseToken });
  } catch (e) {
    functions.logger.error("socialLogin error", e);
    res.status(500).json({ error: "Internal server error" });
  }
});
