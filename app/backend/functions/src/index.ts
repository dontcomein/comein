import admin = require("firebase-admin");
import * as functions from "firebase-functions";

admin.initializeApp();

// Create user's document
export const createUser = functions.auth.user().onCreate(async (user) => {
  return admin.firestore().collection("users").doc(user.uid).set({
    inbox: {},
    rooms: {},
    blockedUsers: {},
    friends: {},
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
    .onCreate(async (snap, context) => {
      const room = snap.data();
      if (!room.owner) {
        throw new functions.https.HttpsError(
            "unauthenticated",
            "User not logged in"
        );
      }
      const uid = room.owner.uid;
      const ref = admin.firestore().collection("users").doc(uid);
      const user = await admin.auth().getUser(uid);
      // add user to roommates
      room.roommates[uid] = {
        "role": "Role.admin",
        "displayName": user.displayName,
        "email": user.email,
        "photoURL": user.photoURL,
        "uid": user.uid,
      };
      admin.firestore().doc(`rooms/${context.params.roomId}`).update(room);
      return admin.firestore().runTransaction(async (t) => {
        const doc = await t.get(ref);
        const rooms = doc.data()?.rooms;
        rooms[context.params.roomId] = {
          "name": room.name,
          "number": room.number,
          "sendDate": admin.database.ServerValue.TIMESTAMP,
          "roommates": room.roommates,
        };
        t.update(doc.ref, {rooms: rooms});
      });
    });

// Put room in desired user's inbox
export const shareRoom = functions.https.onCall(async (data, context) => {
  functions.logger.info("shareRoom called");
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
  const docRef = admin.firestore().doc(`rooms/${data.uid}/`);
  await admin.firestore().runTransaction(async (t) => {
    const room = await t.get(docRef);
    const roommates = room.get("roommates");
    roommates[recipient.uid] = {
      "role": data.role ?? "viewer",
      "displayName": recipient.displayName ?? null,
      "email": recipient.email,
      "photoURL": recipient.photoURL ?? null,
      "uid": recipient.uid,
    };
    t.update(docRef, {roommates: roommates});
  });
  const userDocRef = admin.firestore().doc(`users/${recipient.uid}`);
  let tokens:string[] = [];
  const returnVal = await admin.firestore().runTransaction(async (t) => {
    const userDoc = await t.get(userDocRef);
    functions.logger.debug("on document: " + userDoc.id);
    functions.logger.debug("userDocRef: " + userDocRef);
    const newRooms = userDoc.get("rooms");
    functions.logger.debug(String(newRooms));

    // save the fcm tokens to send to
    tokens = userDoc?.data()?.FCMtokens;
    // const blocked = doc?.data()?.blockedUsers;
    // allow send if not blocked and not in inbox and not already shared
    // allowSend = blocked[sender.uid] == null && newRooms[data.uid] == null &&
    // doc?.data()?.events[data.uid] == null;
    functions.logger.debug("data: " + JSON.stringify(data));
    newRooms[data.uid] = data.room;
    functions.logger.debug("added room: " + newRooms[data.uid].name);
    functions.logger.debug("len(rooms):" + newRooms.size);
    t.update(userDocRef, {rooms: newRooms});
  });
  const notification = {
    title: "New Room",
    body: `${sender.displayName ?? "Unknown"} shared "${data.name}" with you`,
  };
  admin.messaging().sendMulticast({
    tokens: tokens,
    notification: notification,
  }); // send notifications
  return returnVal;
});

/*
expects:
data {
  notifyFriends int (1 = true, 0 = false)
  roomUid string
  stateName string
  roomName string
}

if notifyFriends, find all friends tokens + notify
else find roomates tokens and notify

add to user document
map<uid, Friend>
Friend {
  displayName string
  email string
  uid string
  photoURL string
}
*/
export const notifyState = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User not logged in"
    );
  }
  const sender = await admin
      .auth()
      .getUser(context.auth.uid);
  const myUid = sender.uid;
  const notifyUIDs:string[] = [];
  const roomDocRef = admin.firestore().doc(`rooms/${data.roomUid}`);
  await admin.firestore().runTransaction(async (t) => {
    const roomDoc = await t.get(roomDocRef);
    const roommates = roomDoc.get("roommates");
    const roomatesMap = new Map(Object.entries(roommates));
    functions.logger.debug("roommates: " + JSON.stringify(roommates));
    for (const [uid, _] of roomatesMap) {
      if (uid != myUid) notifyUIDs.push(uid);
    }
  });
  if (data.notifyFriends == 1) {
    const userDocRef = admin.firestore().doc(`users/${context.auth.uid}`);
    await admin.firestore().runTransaction(async (t) => {
      const userDoc = await t.get(userDocRef);
      const friends = userDoc.get("friends");
      const friendsMap = new Map(Object.entries(friends));
      for (const [uid, _] of friendsMap) {
        if (notifyUIDs.indexOf(uid) == -1) notifyUIDs.push(uid);
      }
    });
  }
  functions.logger.debug("notifyUIDs: " + JSON.stringify(notifyUIDs));
  for (const nuid of notifyUIDs) {
    const friendDocRef = admin.firestore().doc(`users/${nuid}`);
    await admin.firestore().runTransaction(async (t) => {
      const friendDoc = await t.get(friendDocRef);
      const fcmTokens = friendDoc.get("FCMtokens");
      functions.logger.debug("fcmTokens for " + nuid + " " +
          JSON.stringify(fcmTokens));
      const notification = {
        title: `Room ${data.roomName} State Changed`,
        body: `${sender.displayName ?? "Unknown"} started ${data.stateName}`,
      };
      // check if there are any tokens before sending
      if ((fcmTokens as Array<number>).length != 0) {
        admin.messaging().sendMulticast({
          tokens: fcmTokens,
          notification: notification,
        });
      }
    });
  }
  return true;
});

export const addFriend = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "User not logged in"
    );
  }
  const sender = await admin.auth().getUser(context.auth?.uid);
  const recipient = await admin.auth().getUserByEmail(data.email);
  if (sender.uid == recipient.uid) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Cannot friend yourself"
    );
  }
  const userDocRef = admin.firestore().doc(`users/${sender.uid}`);
  const friendDocRef = admin.firestore().doc(`users/${recipient.uid}`);
  return admin.firestore().runTransaction(async (t) => {
    const userDoc = await t.get(userDocRef);
    const friendDoc = await t.get(friendDocRef);
    const friends = userDoc.get("friends");
    friends[recipient.uid] = {
      "displayName": recipient.displayName ?? null,
      "email": recipient.email,
      "photoURL": recipient.photoURL ?? null,
      "uid": recipient.uid,
    };
    t.update(userDocRef, {friends: friends});
    const friendFriends = friendDoc.get("friends");
    friendFriends[sender.uid] = {
      "displayName": sender.displayName ?? null,
      "email": sender.email,
      "photoURL": sender.photoURL ?? null,
      "uid": sender.uid,
    };
    t.update(friendDocRef, {friends: friendFriends});
  });
});
