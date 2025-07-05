const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyLevelUp = onDocumentUpdated("users/{userId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const userId = event.params.userId;

  if (before.level !== after.level) {
    const newLevel = after.level;

    const payload = {
      notification: {
        title: "🎉 Level Up!",
        body: `You've reached level ${newLevel}! Keep reading!`,
      },
      data: {
        level: newLevel.toString(),
      },
    };

    const fcmToken = after.fcmToken;
    if (!fcmToken) {
      console.log(`No FCM token for user ${userId}`);
      return;
    }

    try {
      const response = await admin.messaging().sendToDevice(fcmToken, payload);
      console.log("Notification sent:", response);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  }
});