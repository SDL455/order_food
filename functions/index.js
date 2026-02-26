/**
 * Cloud Functions for Order Food App
 *
 * Triggers:
 * 1. onOrderCreated — sends FCM push to the shop admin when a new order is placed
 * 2. onOrderStatusChanged — sends FCM push to the customer when order status changes
 * 3. onChatMessageCreated — sends FCM push when customer chats with admin (and vice versa)
 *
 * Deploy: firebase deploy --only functions
 * Requires: Firebase Blaze plan
 */

const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

/**
 * Trigger: New order created
 * → Send push notification to the shop admin
 */
exports.onOrderCreated = onDocumentCreated("orders/{orderId}", async (event) => {
  const order = event.data.data();
  const orderId = event.params.orderId;

  try {
    // Get the shop to find the admin's UID
    const shopDoc = await db.collection("shops").doc(order.shopId).get();
    if (!shopDoc.exists) return;

    const adminUid = shopDoc.data().ownerUid;

    // Get admin's FCM tokens
    const adminDoc = await db.collection("users").doc(adminUid).get();
    if (!adminDoc.exists) return;

    const tokens = adminDoc.data().fcmTokens || [];
    if (tokens.length === 0) return;

    // Send notification
    const message = {
      notification: {
        title: "🆕 New Order!",
        body: `Order #${orderId.substring(0, 8)} — $${order.total.toFixed(2)}`,
      },
      data: {
        type: "order",
        orderId: orderId,
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(message);
    console.log(`Sent new order notification: ${response.successCount} success, ${response.failureCount} failure`);

    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          invalidTokens.push(tokens[idx]);
        }
      });
      if (invalidTokens.length > 0) {
        const { FieldValue } = require("firebase-admin/firestore");
        await db.collection("users").doc(adminUid).update({
          fcmTokens: FieldValue.arrayRemove(invalidTokens),
        });
      }
    }
  } catch (error) {
    console.error("Error sending new order notification:", error);
  }
});

/**
 * Trigger: Order status updated
 * → Send push notification to the customer
 */
exports.onOrderStatusChanged = onDocumentUpdated("orders/{orderId}", async (event) => {
  const beforeData = event.data.before.data();
  const afterData = event.data.after.data();
  const orderId = event.params.orderId;

  // Only trigger if status actually changed
  if (beforeData.status === afterData.status) return;

  try {
    // Get customer's FCM tokens
    const customerDoc = await db.collection("users").doc(afterData.customerUid).get();
    if (!customerDoc.exists) return;

    const tokens = customerDoc.data().fcmTokens || [];
    if (tokens.length === 0) return;

    const statusMessages = {
      accepted: "Your order has been accepted! 🎉",
      cooking: "Your food is being prepared! 🍳",
      delivering: "Your order is on the way! 🚗",
      done: "Your order has been delivered! ✅",
      canceled: "Your order has been canceled. ❌",
    };

    const body = statusMessages[afterData.status] || `Order status: ${afterData.status}`;

    const message = {
      notification: {
        title: `Order #${orderId.substring(0, 8)} Update`,
        body: body,
      },
      data: {
        type: "order",
        orderId: orderId,
        status: afterData.status,
      },
      tokens: tokens,
    };

    const response = await messaging.sendEachForMulticast(message);
    console.log(`Sent status update notification: ${response.successCount} success`);

    // Clean up invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          invalidTokens.push(tokens[idx]);
        }
      });
      if (invalidTokens.length > 0) {
        const { FieldValue } = require("firebase-admin/firestore");
        await db.collection("users").doc(afterData.customerUid).update({
          fcmTokens: FieldValue.arrayRemove(invalidTokens),
        });
      }
    }
  } catch (error) {
    console.error("Error sending status update notification:", error);
  }
});

/**
 * Trigger: New message in chat
 * → Send push notification to the receiver (customer or admin)
 */
exports.onChatMessageCreated = onDocumentCreated(
  "chats/{chatId}/messages/{messageId}",
  async (event) => {
    const message = event.data.data();
    const chatId = event.params.chatId;

    const toUid = message.toUid;
    if (!toUid) return;

    try {
      const receiverDoc = await db.collection("users").doc(toUid).get();
      if (!receiverDoc.exists) return;

      const tokens = receiverDoc.data().fcmTokens || [];
      if (tokens.length === 0) return;

      const isImage = message.type === "image" && message.imageUrl;
      const body = isImage
        ? "📷 ຮູບພາບ"
        : (message.text || "").substring(0, 80);

      const msg = {
        notification: {
          title: "💬 ຂໍ້ຄວາມໃໝ່",
          body: body || "ມີຂໍ້ຄວາມໃໝ່",
        },
        data: {
          type: "chat",
          chatId: chatId,
        },
        tokens: tokens,
      };

      const response = await messaging.sendEachForMulticast(msg);
      console.log(
        `Sent chat notification: ${response.successCount} success, ${response.failureCount} failure`
      );

      if (response.failureCount > 0) {
        const invalidTokens = [];
        response.responses.forEach((resp, idx) => {
          if (!resp.success) invalidTokens.push(tokens[idx]);
        });
        if (invalidTokens.length > 0) {
          const { FieldValue } = require("firebase-admin/firestore");
          await db.collection("users").doc(toUid).update({
            fcmTokens: FieldValue.arrayRemove(invalidTokens),
          });
        }
      }
    } catch (error) {
      console.error("Error sending chat notification:", error);
    }
  }
);
