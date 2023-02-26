import admin = require("firebase-admin");
import * as functions from "firebase-functions";

// Create user's document
export const createUser = functions.auth.user().onCreate(async (user) => {
  return admin.firestore().collection("users").doc(user.uid).set({
    inbox: {},
    rooms: {},
    blockedUsers: {},
    FCMtokens: [],
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});

// Delete user's document
export const deleteUser = functions.auth.user().onDelete(async (user) => {
  return admin.firestore().collection("users").doc(user.uid).delete();
});

// Add room to user's rooms
export const createRoom = functions.firestore
    .document("rooms/{roomId}")
    .onCreate((snap, context) => {
      const room = snap.data();
      if (context.auth == null) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User not logged in"
        );
      }
      const uid = context.auth?.uid;
      const ref = admin.firestore().collection("users").doc(uid);
      return admin.firestore().runTransaction(async (t) => {
        const doc = await t.get(ref);
        const ownedRooms = doc.data()?.ownedRooms;
        ownedRooms[context.params.roomId] = {
          "name": room.name,
          "sendDate": admin.database.ServerValue.TIMESTAMP,
          "roommates": room.roommates,
        };
        t.update(doc.ref, {ownedRooms: ownedRooms});
      });
    });

// Put room in desired user's inbox
export const shareRoom = functions.https.onCall(async (data, context) => {
  if (!context.auth) { // if not authenticated
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User not logged in"
    );
  }
  const sender = await admin
      .auth()
      .getUser(context.auth.uid);
  const recipient = await admin
      .auth()
      .getUserByEmail(data.email)
      .catch(() => {
        return null;
      });
  if (recipient == null) { // if recipient doesn't exist
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Requested user does not exist"
    );
  }
  if (sender.uid == recipient.uid) { // if sender and recipient are the same
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Cannot send an event to yourself"
    );
  }
  let allowSend = true;
  const docRef = admin.firestore().doc(`rooms/${data.uid}/`);
  await admin.firestore().runTransaction(async (t) => {
    const room = await t.get(docRef);
    const roommates = room.get("roommates");
    allowSend = roommates[sender.uid].role == "admin";
    if (!allowSend) {
      throw new functions.https.HttpsError(
          "permission-denied",
          "You do not have admin access to this document"
      );
    }
    roommates[recipient.uid] = {
      "role": data.role ?? "viewer",
      "displayName": recipient.displayName ?? null,
      "email": recipient.email,
      "photoURL": recipient.photoURL ?? null,
    };
    t.update(docRef, {roommates: roommates});
  });
  const meta = {
    "uid": data.uid,
    "name": data.name,
    "author": data.author,
    "sender": {
      "uid": sender.uid,
      "displayName": sender.displayName ?? null,
      "email": sender.email,
      "photoURL": sender.photoURL ?? null,
    },
    "sendTime": admin.firestore.FieldValue.serverTimestamp(),
    "eventKey": data.eventKey,
  };
  const ref = admin.firestore().collection("users").doc(recipient.uid);
  let tokens:string[] = [];
  const returnVal = await admin.firestore().runTransaction(async (t) => {
    const doc = await t.get(ref);
    const newInbox = doc?.data()?.inbox;
    // save the fcm tokens to send to
    tokens = doc?.data()?.FCMtokens;
    const blocked = doc?.data()?.blockedUsers;
    // allow send if not blocked and not in inbox and not already shared
    allowSend = blocked[sender.uid] == null && newInbox[data.uid] == null &&
      doc?.data()?.events[data.uid] == null;
    if (allowSend) newInbox[data.uid] = meta;
    else {
      throw new functions.https.HttpsError(
          "permission-denied",
          "Unable to send event"
      );
    }
    t.update(ref, {inbox: newInbox});
  });
  const notification = {
    title: "New Event",
    body: `${sender.displayName ?? "Unknown"} shared "${meta.name}" with you`,
  };
  admin.messaging().sendMulticast({
    tokens: tokens,
    notification: notification,
  }); // send notifications
  return returnVal;
});
