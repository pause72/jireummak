"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.socialLogin = void 0;
const admin = require("firebase-admin");
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
// refreshed: 2026-04-14
const axios_1 = require("axios");
admin.initializeApp();
// ── 소셜 로그인 커스텀 토큰 발급 ─────────────────────────────
//
// POST body: { provider: "naver" | "kakao", accessToken: string }
// Response:  { firebaseToken: string }
//
exports.socialLogin = (0, https_1.onRequest)({ region: "us-central1" }, async (req, res) => {
    var _a, _b, _c, _d, _e, _f, _g, _h, _j, _k;
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
    const { provider, accessToken } = req.body;
    if (!provider || !accessToken) {
        res.status(400).json({ error: "provider and accessToken are required" });
        return;
    }
    try {
        let uid;
        let email;
        let displayName;
        let photoURL;
        if (provider === "naver") {
            // 네이버 사용자 정보 조회
            const response = await axios_1.default.get("https://openapi.naver.com/v1/nid/me", {
                headers: { Authorization: `Bearer ${accessToken}` },
            });
            const profile = response.data.response;
            uid = `naver:${profile.id}`;
            email = profile.email;
            displayName = (_a = profile.name) !== null && _a !== void 0 ? _a : profile.nickname;
            photoURL = profile.profile_image;
        }
        else if (provider === "kakao") {
            // 카카오 사용자 정보 조회
            const response = await axios_1.default.get("https://kapi.kakao.com/v2/user/me", {
                headers: { Authorization: `Bearer ${accessToken}` },
            });
            const profile = response.data;
            uid = `kakao:${profile.id}`;
            email = (_b = profile.kakao_account) === null || _b === void 0 ? void 0 : _b.email;
            displayName =
                (_e = (_d = (_c = profile.kakao_account) === null || _c === void 0 ? void 0 : _c.profile) === null || _d === void 0 ? void 0 : _d.nickname) !== null && _e !== void 0 ? _e : (_f = profile.properties) === null || _f === void 0 ? void 0 : _f.nickname;
            photoURL =
                (_j = (_h = (_g = profile.kakao_account) === null || _g === void 0 ? void 0 : _g.profile) === null || _h === void 0 ? void 0 : _h.profile_image_url) !== null && _j !== void 0 ? _j : (_k = profile.properties) === null || _k === void 0 ? void 0 : _k.profile_image;
        }
        else {
            res.status(400).json({ error: "Unknown provider" });
            return;
        }
        // Firestore에 사용자 정보 저장/갱신
        await admin.firestore().doc(`users/${uid}`).set({
            provider,
            email: email !== null && email !== void 0 ? email : null,
            displayName: displayName !== null && displayName !== void 0 ? displayName : null,
            photoURL: photoURL !== null && photoURL !== void 0 ? photoURL : null,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        // Firebase 커스텀 토큰 발급
        const firebaseToken = await admin.auth().createCustomToken(uid, {
            provider,
            email: email !== null && email !== void 0 ? email : null,
            displayName: displayName !== null && displayName !== void 0 ? displayName : null,
        });
        res.status(200).json({ firebaseToken });
    }
    catch (e) {
        v2_1.logger.error("socialLogin error", e);
        res.status(500).json({ error: "Internal server error" });
    }
});
//# sourceMappingURL=index.js.map