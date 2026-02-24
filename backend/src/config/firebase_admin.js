const admin = require('firebase-admin');

let firebaseInitialized = false;

const getFirebaseAuth = () => {
  if (firebaseInitialized) return admin.auth();

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error(
      'Firebase Admin is not configured. Set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, and FIREBASE_PRIVATE_KEY.'
    );
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey,
    }),
  });

  firebaseInitialized = true;
  return admin.auth();
};

const verifyFirebaseIdToken = async (idToken) => {
  const auth = getFirebaseAuth();
  return auth.verifyIdToken(idToken);
};

module.exports = {
  verifyFirebaseIdToken,
};
