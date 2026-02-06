This project is a flutter project. It contains the bloc architecture. The bloc related information about the whole project is present in csv format in  "/home/jeevan-koiri/dev/afriqueen_v3/afriqueen12092025-001/afriqueen/docs/bloc/Cheat Sheet Bloc - Bloc Cheat Sheet .csv" file. 

These are the library it is using. 
 some notable libraries are: bloc, equatable, getx, flutter_screenutil, get_storage and firebase_database, and is using res_cloudinary for storage of all the files not using the firebase_storage. 

you can find the firebase collections and fields at the ../docs/firebase/firebase_details.md file that i made it in txt format and converted the extension to md. 
 
riverpod is not being used throughout the project. 


It has screen_utils. 
It has app_translations in french. in folder ../localization/language/en_us.dart and ../fr_fr.dart
and another file called ../localization/tranlastions/app_translation.dart and is using getx translation. 

I want to do the test driven development. ../test folder is the one where test is written. 

I am currently fixing the bugs. I will give one bug at a time and we need to fix it using test 

For bug fixing consider using bloc_test, mockito package for making this test driven bug fixing possible. 

product docs is available at ../docs/product/*.md files 


