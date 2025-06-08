import 'package:afriqueen/common/constant/constant_strings.dart';
import 'package:afriqueen/features/stories/model/stories_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class StoriesRepository {
  final FirebaseFirestore firestore;
  final cloudinary = CloudinaryPublic(
    AppStrings.cloudName,
    AppStrings.uploadPreset,
  );

  final ImagePicker _imagePicker = ImagePicker();
  StoriesRepository({FirebaseFirestore? fire})
      : firestore = fire ?? FirebaseFirestore.instance;
  //--------------------------------Image adding to cloudinary-----------------------------
  Future<String?> addStoriesImageToCloudinary() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            image.path,
            resourceType: CloudinaryResourceType.Image,
            folder: "afriqueen/stories",
            publicId: "${DateTime.now().millisecond}",
          ),
        );
        return response.secureUrl;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  //  User Stories data uploading  to  firebase
  Future<void> uploadStoriesToFirebase(StoriesModel model) async {
    final storyCollection = firestore.collection('stories');

    // Check if a story already exists for this user (assuming 'id' is unique per user)
    final querySnapshot =
        await storyCollection.where('id', isEqualTo: model.uid).get();

    if (querySnapshot.docs.isEmpty) {
      // No story exists, create a new one
      final Map<String, dynamic> data = {
        'id': model.uid,
        'containUrl': model.containUrl,
        'createdDate': model.createdDate,
        'userName': model.userName,
        'userImg': model.userImg,
      };

      await storyCollection.add(data); // .add() generates a new document
    } else {
      // Story exists, update the containUrl field
      final docId = querySnapshot.docs.first.id;

      await storyCollection.doc(docId).update({
        'containUrl': FieldValue.arrayUnion(model.containUrl),
        'createdDate': FieldValue.arrayUnion(model.createdDate),
      });
    }
  }

  Future<List<StoriesFetchModel>> fetchAllStoriesData() async {
    try {
      final snapshot = await firestore.collection('stories').get();
      print("Fetched documents: ${snapshot.docs.length}");

      return snapshot.docs.map((doc) {
        print("Parsing document: ${doc.data()}");
        return StoriesFetchModel.fromMap(doc.data());
      }).toList();
    } catch (e) {
      print("Error fetching stories: $e");
      rethrow;
    }
  }
}
