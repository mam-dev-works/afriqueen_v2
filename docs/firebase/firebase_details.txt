Firebase Services Used
1. Authentication 
2. Firestore Database 
3. cloudinary.com storage 

This is the main thing: 
all Collections name   
1. blocks 
2. chats
3. event_requests
4. events 
5. gifts_sent 
6. likes 
7. messages 
8. profile_views 
9. reports 
10. stories 
11. stories_likes 
12. user 
13. users 

Collection details  name   
1. blocks 
    docid(Htb5FQe1UqZITiyCozxh)
    each docs have: 
    1. blockedUserId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2"
    2. blockerId "VK93eqyqoNUGZG4iw1CHavCpMU62"
    3. timestamp: November 27, 2025 at 8:50:08 PM UTC+5:45
2. chats collection has fields and subcollection called 'messages'.
    docid: 03D91kjVx8TkjpAJcS4X
    each doc id of chats has a collection called 'messages' which has a doc id (def4c55b-e59d-4db6-896c-a61f6182b9de"
(string) like this and other fields like: 
audioDuration: null(null)
audioUrl: null(null)
content: "test"(string)
duration: null (null)
id: "def4c55b-e59d-4db6-896c-a61f6182b9de" (string)
imageUrl: null(null)
isRead: false (boolean)
isUploaded: true (boolean)
receiverId: "O3AI0G1ZHyWHY04zaCR1QSyHH2X2" (string)
senderId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
tempId: null (null)
timestamp: November 26, 2025 at 10:43:13 PM UTC+5:45 (timestamp)
type:"MessageType.text"

this chats has other fields like: 
isDeclined: false (boolean)
isRequest: true (boolean)
lastMessage: "test" (string)
lastMessageSenderId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
lastMessageTime: November 26, 2025 at 10:43:13 PM UTC+5:45 (timestamp)
participantInfo (map):
1st map of participantInfo: 0NH6Eohe1FbTuW9uT2HgAUwlgTH2 (map)
id: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
name: "" (string)
photoUrl: null (null)
2nd map of participantInfo: O3AI0G1ZHyWHY04zaCR1QSyHH2X2 (map)
id: "O3AI0G1ZHyWHY04zaCR1QSyHH2X2"(string)
name: "" (string)
photoUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1753631167/afriqueen/images/1753631166016_0.jpg" (string)
participants (array)
0 array of participants: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
1 array of participants: "O3AI0G1ZHyWHY04zaCR1QSyHH2X2" (string)

unreadCount (map):
1st map of unreadCount: 0NH6Eohe1FbTuW9uT2HgAUwlgTH2: 0(number)
2nd map of unreadCount: O3AI0G1ZHyWHY04zaCR1QSyHH2X2: 0 (number)

3. 'event_requests' collection
collection has a docid and the following field inside each doc id: 
createdAt: December 13, 2025 at 11:24:50 PM UTC+5:45 (timestamp)
eventCreatorId: "mT1yNbqpXSOba7CwFRTGYrg2slu1" (string)
eventId: "ma7t2NfSJxsHyRUjySVR" (string)
eventTitle: "plage" (string)
message: "ffvvb" (string)
requesterId: "2lvZPNOM2fcrO4xwGosyooJQcgI2" (string)
requesterName: "chhb" (string)
requesterPhotoUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765627515/afriqueen/images/1765627501534_0.jpg"
(string)
status: "ACCEPTED" (string)
updatedAt: December 13, 2025 at 11:25:11 PM UTC+5:45

4. 'events' collection:
 each events has the following a unique doc id: DbRRQR4Mb9J5XO5OTmpi and inside each events doc it has following fields and a 'participants' subcollections
costCovered: true (boolean)
createdAt: December 13, 2025 at 9:09:02 PM UTC+5:45 (timestamp)
creatorId: "2lvZPNOM2fcrO4xwGosyooJQcgI2" (string)
date: December 13, 2025 at 4:45:00 AM UTC+5:45 (timestamp)
description: "" (string)
imageUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765639430/afriqueen/events/event_1765639429158.jpg"
(string)
location: "ggg" (string)
maxParticipants: null (null)
status: "DUO" (string)
title: "ghh" (string)
updatedAt: December 13, 2025 at 9:09:02 PM UTC+5:45 '

this events has 'participants' sub collection which has following fields in each docs: 
joinedAt: December 13, 2025 at 11:26:10 PM UTC+5:45 (timestamp)
userId: "mT1yNbqpXSOba7CwFRTGYrg2slu1" (string)
userName: "koala" (string)
userPhotoUrl:"https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765646632/afriqueen/images/1765646631975_0.jpg"
(string)

5. gifts_sent collection has following fields: 
the docs in gifts_sent has following fields: 
giftName: "Bouquet" (string)
giftType: "bouquet" (string)
message: null (null)
recipientAge: 61 (number)
recipientId: "mT1yNbqpXSOba7CwFRTGYrg2slu1" (string)
recipientName: "koala" (string)
recipientPhotoUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765646632/afriqueen/images/1765646631975_0.jpg"
(string)
senderAge: 15 (number)
senderId: "2lvZPNOM2fcrO4xwGosyooJQcgI2" (string)
senderName: "chhb" (string)
senderPhotoUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765627515/afriqueen/images/1765627501534_0.jpg"
(string)
sentAt: December 13, 2025 at 11:14:46 PM UTC+5:45

6. likes collection has following fields: 
each likes docs have following fields: 
likedUserId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
likerId: "8xztkwY1hrfktakZeqZwFLnHTcy2" (string)
timestamp: December 8, 2025 at 11:38:31 PM UTC+5:45

7. messages collection has following fields:
each messages has the following docs: 
chatId: "xQQKAq8eiyJ3cEtqGBpi" (string)
content: "helli" (string)
isRead: false (boolean)
senderId: "xLqz5zULOjT0xUEXWEQOKnX37tv2" (string)
timestamp: June 12, 2025 at 3:26:40 PM UTC+5:45 (timestamp)

8. profile_views collection has following fields: 
profile_views doc have following fields: 
firstViewedAt: November 26, 2025 at 10:43:33 PM UTC+5:45 (timestamp)
lastViewedAt: November 26, 2025 at 10:43:33 PM UTC+5:45 (timestamp)
viewCount: 2 (number)
viewedId: "1Ns9MKji4qgKMdmivWBlDm9Tnjk2" (string)
viewerId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2"

9. reports collection has following  fields:
category: "reportCategoryFakeProfile" (string)
context: "profile" (string)
description: "sgsgsgscvsvsvsgsggsgsgsgsgsgsgsgs" (string)
reportedUserId: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
reporterId: "VK93eqyqoNUGZG4iw1CHavCpMU62" (string)
timestamp: November 27, 2025 at 8:50:08 PM UTC+5:45

10. stories collection has following fields: 
createdDate: January 20, 2026 at 2:49:02 PM UTC+5:45 (timestamp)
imageUrl: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1768899840/afriqueen/stories/1768899837158.jpg"
(string)
text: "thg" (string)
uid: "u3otDBx1M8cVU85wy6stCJFQzOF3" (string)
userImg: ""(string)
userName: "Jeevan Koiri" 

11. stories_likes has following fields:
likedStoryId: "YkXQrBdkUtDVe11bCIoW" (string)
likedUserId: "EH7FULoksAVdTOOVa9BAU9m49Ks1" (string)
timestamp: December 9, 2025 at 1:22:32 AM UTC+5:45

12. user collection has following fields and two other subcollections called 'archive' and 'gifts'
age: 27 (number)
alcohol: 0 (number)
city: "Paris" (string)
country: "France" (string)
createdDate: December 8, 2025 at 10:49:14 PM UTC+5:45 (timestamp)
description: "" (string)
dob: November 5, 1998 at 4:45:00 AM UTC+5:45 (timestamp)
educationLevels (array):
0: "Bac" (string) email: "trainingpro4321-para@yahoo.fr" (string)
ethnicOrigins (array):
0: "Africaine" (string)
flaws (array):
0: "Perfectionniste" (string)
1: "Sensible" (string)
gender: "Femme" (string)
hasAnimals: 0 (number)
hasChildren: 0 (number)
height: 166 (number)
hobbies (array):
0: "Sport" (string)
1: "Musique" (string)
id: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2" (string)
isActive: true (boolean)
isElite: false (boolean)
isPremium: false (boolean)
languages (array):
0: "Français" (string)
lastActive: December 8, 2025 at 10:49:14 PM UTC+5:45 (timestamp)
mainInterests (array)
0: "Discuter" (string)
name: "Marie" (string)
orientation: "Hétéro" (string)
passions (array):
0: "Lecture" (string)
1: "Photographie" (string)

photos(array):
0: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765213447/afriqueen/images/1765213445039_0.png"
(string)
1: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765213449/afriqueen/images/1765213447869_1.png"
(string)
2: "https://res.cloudinary.com/dv4p4ll3u/image/upload/v1765213452/afriqueen/images/1765213450522_2.png"
(string)
pseudo: "Marie" (string)
qualities (array):
0: "Autonome" (string)
1: "Créative" (string)
relationshipStatus: "Célibataire" (string)
religions (array):
0: "Catholique" (string)
searchDescription: "Je suis sympa" (string)
secondaryInterests (array):
0: "Flirt" (string)
silhouette: 0 (number)
smoking: 0 (number)
snoring: 2 (number)
wantsChildren: 0 (number)
whatLookingFor: "Faire des rencontres" (string)
whatNotWant: "Je n'aime pas les hypocrites" 

subcollection 'archive' has one document named 'main'  document:
archiveId (array):
0: "Abka5ePkfjcMKl6HPKCbmuKXmXj2" (string)
id: "0NH6Eohe1FbTuW9uT2HgAUwlgTH2"

subcollection 'gifts' has following docs name:
bague
bouquet 
chiot 
chocolat
coeur
donut 
papillon
pizza
rose 
sac 
trophee
vetement

each of these above docs have following fields: 
createdAt: December 8, 2025 at 11:00:06 PM UTC+5:45 (timestamp)
isPremium: false (boolean)
lastRechargeTime: December 8, 2025 at 11:00:06 PM UTC+5:45 (timestamp)
remainingCount: 1 (number)
updatedAt: December 8, 2025 at 11:00:06 PM UTC+5:45 (timestamp)




13. 'users' collection of user with s: users collection: 
 users collection has documents with unique document id, and has following 'gifts' sub-collection which has the following documents name: 
 bague 
 bouquet 
 chiot 
 chocolat
 coeur
 donut 
 papillon
 pizza 
 rose 
 sac 
 trophea
 vetement 

Collection Relationships
user → stories (uid reference)
user → likes (likerId/likedUserId reference)
user → chats (participants array)
chats → messages (subcollection)
events → participants (subcollection)
events → event_requests (eventId reference)

 The Firebase Authentication methods are 
 Enabled Providers: 
 1. Email/Password 
 2. Google  
 

 cloudinary.com storage
   - Cloud name: "tbistaxmok1" (from code)
   - Upload preset: "q8cbytay" (from code)
   - Folders used:
     * afriqueen/images (profile photos)
     * afriqueen/stories (story images)
     * afriqueen/events (event images)


Firestore Security Rules
Basic rules structure:
- Public read access to user profiles
- Authenticated users can write their own data
- Private collections (chats, likes, favorites) restricted to participants