import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {getMessaging} from "firebase-admin/messaging";
import {getFirestore} from "firebase-admin/firestore";

/**
 * Helper: fetch FCM tokens for a student and send a notification.
 * Returns early if the student has no registered tokens.
 * Cleans up stale/invalid tokens automatically.
 */
async function sendNotificationToStudent(
  db: FirebaseFirestore.Firestore,
  studentId: string,
  notification: {title: string; body: string},
  data: Record<string, string>
): Promise<void> {
  const tokensSnap = await db
    .collection("students")
    .doc(studentId)
    .collection("tokens")
    .get();

  const tokens = tokensSnap.docs.map((doc) => doc.data().token as string);
  if (tokens.length === 0) return;

  const response = await getMessaging().sendEachForMulticast({
    tokens,
    notification,
    data,
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
            .doc(studentId)
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
}

/**
 * Format a Firestore Timestamp or date-like value into a readable string.
 */
function formatDepartureTime(
  departure: FirebaseFirestore.Timestamp | {_seconds: number} | undefined
): string {
  if (!departure) return "";

  let date: Date;
  if ("toDate" in departure && typeof departure.toDate === "function") {
    date = departure.toDate();
  } else if ("_seconds" in departure) {
    date = new Date(departure._seconds * 1000);
  } else {
    return "";
  }

  return date.toLocaleString("en-US", {
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
}

/**
 * Triggered when a joinRequest document is updated.
 * If the status changed to 'accepted', sends FCM notifications to both
 * the requester ("Your request was accepted") and the poster ("Someone
 * joined your ride").
 */
export const onRequestAccepted = onDocumentUpdated(
  "joinRequests/{requestId}",
  async (event) => {
    const beforeSnap = event.data?.before;
    const afterSnap = event.data?.after;
    if (!beforeSnap || !afterSnap) return;

    const beforeData = beforeSnap.data();
    const afterData = afterSnap.data();

    // Only proceed if status changed TO 'accepted'.
    if (
      beforeData.status === "accepted" ||
      afterData.status !== "accepted"
    ) {
      return;
    }

    const requesterId: string = afterData.requesterId;
    const requesterName: string = afterData.requesterName;
    const rideId: string = afterData.rideId;

    const db = getFirestore();

    // Fetch ride document for context (poster info, route, time).
    const rideDoc = await db.collection("rides").doc(rideId).get();
    if (!rideDoc.exists) return;

    const rideData = rideDoc.data();
    const posterId: string = rideData?.posterId ?? "";
    const posterName: string = rideData?.posterName ?? "Someone";

    // Ride addresses are stored as nested maps (origin.address,
    // destination.address) by the Flutter RideRepository.
    const originAddress: string =
      rideData?.origin?.address ?? rideData?.originAddress ?? "";
    const destinationAddress: string =
      rideData?.destination?.address ?? rideData?.destinationAddress ?? "";

    const formattedTime = formatDepartureTime(rideData?.departureTime);

    const routeLabel = originAddress && destinationAddress
      ? `${originAddress} -> ${destinationAddress}`
      : "your ride";
    const bodyForRequester = formattedTime
      ? `${routeLabel}, ${formattedTime}`
      : routeLabel;

    const notificationData = {
      type: "ride_match",
      rideId,
    };

    // Notify the requester that their request was accepted.
    await sendNotificationToStudent(
      db,
      requesterId,
      {
        title: `${posterName} accepted your ride request`,
        body: bodyForRequester,
      },
      notificationData
    );

    // Notify the poster that someone joined their ride.
    if (posterId) {
      await sendNotificationToStudent(
        db,
        posterId,
        {
          title: `${requesterName} joined your ride`,
          body: routeLabel,
        },
        notificationData
      );
    }
  }
);
