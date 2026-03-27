import {onDocumentCreated} from "firebase-functions/v2/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

/**
 * Triggered when a new message is created in a conversation.
 * Sends an FCM push notification to the recipient (not the sender)
 * and increments their unread count.
 */
export const onMessageCreated = onDocumentCreated(
  "conversations/{conversationId}/messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const messageData = snapshot.data();
    const senderId: string = messageData.senderId;
    const senderName: string = messageData.senderName;
    const text: string = messageData.text;
    const type: string = messageData.type;
    const conversationId = event.params.conversationId;

    // Skip system messages (no sender to notify about).
    if (!senderId || type === "system") return;

    const db = getFirestore();

    // Get conversation to find the recipient.
    const convDoc = await db
      .collection("conversations")
      .doc(conversationId)
      .get();

    if (!convDoc.exists) return;

    const convData = convDoc.data();
    const participantIds: string[] = convData?.participantIds ?? [];
    const recipientId = participantIds.find(
      (id: string) => id !== senderId
    );
    if (!recipientId) return;

    // Get recipient's FCM tokens.
    const tokensSnap = await db
      .collection("students")
      .doc(recipientId)
      .collection("tokens")
      .get();

    const tokens = tokensSnap.docs.map((doc) => doc.data().token as string);
    if (tokens.length === 0) return;

    // Build notification body based on message type.
    const body =
      type === "phone_shared" ? "Shared their phone number" : text;

    // Send FCM notification to all of the recipient's devices.
    const response = await getMessaging().sendEachForMulticast({
      tokens,
      notification: {
        title: senderName,
        body,
      },
      data: {
        type: "chat_message",
        conversationId,
      },
      android: {
        priority: "high",
      },
    });

    // Clean up stale tokens.
    const tokensToDelete: Promise<FirebaseFirestore.WriteResult>[] = [];
    response.responses.forEach((result, index) => {
      if (!result.success) {
        const errorCode = result.error?.code;
        if (
          errorCode === "messaging/registration-token-not-registered" ||
          errorCode === "messaging/invalid-registration-token"
        ) {
          tokensToDelete.push(
            db
              .collection("students")
              .doc(recipientId)
              .collection("tokens")
              .doc(tokensSnap.docs[index].id)
              .delete()
          );
        }
      }
    });

    if (tokensToDelete.length > 0) {
      await Promise.all(tokensToDelete);
    }

    // Increment unread count for the recipient on the conversation.
    await db
      .collection("conversations")
      .doc(conversationId)
      .update({
        [`unreadCounts.${recipientId}`]: FieldValue.increment(1),
      });
  }
);
