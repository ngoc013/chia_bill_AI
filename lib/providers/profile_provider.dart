import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import '../core/constants/app_constants.dart';
import '../models/user_profile_model.dart';

class UserProfileNotifier extends Notifier<UserBankProfile?> {
  Box get _settings_Box => Hive.box(AppConstants.settingsBox);
  @override
  UserBankProfile? build() {
    final savedData = _settings_Box.get('user_bank_profile');
    if(savedData != null && savedData is Map) {
      return UserBankProfile.fromMap(Map<dynamic,dynamic>.from(savedData));
    }
    return null;
  }

  Future<void> saveProfile(UserBankProfile profile) async{
    await _settings_Box.put('user_bank_profile',profile.toMap());
    state = profile;
  }
}

final userProfileNotifier =
  NotifierProvider<UserProfileNotifier,UserBankProfile?>((){
    return UserProfileNotifier();
  });

  class FriendsNotifier extends Notifier<List<FriendModel>>{
    Box get _contactsBox => Hive.box(AppConstants.contactsBox);
    @override
    List<FriendModel> build() {
      final savedList = _contactsBox.get('friends_list');
      if(savedList!= null && savedList is List ){
        return savedList.map((item)=>FriendModel.fromMap(Map<dynamic,dynamic>.from(item))).toList();
      }
      return [];
    }

    Future<void> addFriend(String name) async {
      final trimmedName = name.trim();
      if(trimmedName.isEmpty) return;
      final newFriend =FriendModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name:trimmedName,
      );
      final updatedList =[...state,newFriend];
      await _saveToHive(updatedList);
      state =updatedList;
    }

    Future<void> removeFriend(String id) async {
      final updatedList = state.where((friend)=>friend.id !=id).toList();
      await _saveToHive(updatedList);
      state = updatedList;
    }

    Future<void> _saveToHive(List<FriendModel> list) async {
      final mappedList= list.map((friend)=>friend.toMap()).toList();
      await _contactsBox.put('friends_list',mappedList);
    }
  }

  final friendsProvider = NotifierProvider<FriendsNotifier,List<FriendModel>>((){
    return FriendsNotifier();
  });
