import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupRequestProvider with ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  String? userId; // Benutzer-ID kann jetzt null sein
  List<Map<String, dynamic>> _groupDetails = [];

  // GroupRequestProvider(this.userId) { _getUserGroups(); }  // Konstruktor entfernen

  List<Map<String, dynamic>> get groupDetails => _groupDetails;

  // Neue Methode hinzufügen, um die Benutzer-ID zu setzen und Gruppeninformationen zu holen
  void setUserId(String id) {
    userId = id;
    getUserGroups();
  }

  Future<void> getUserGroups() async {
    if (userId == null) return;

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('groups')
        .get();

    List<String> groupIds = snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>?)?['groupId'] as String?)
        .whereType<String>()
        .toList();

    _groupDetails = await _getGroupDetails(groupIds);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> _getGroupDetails(List<String> groupIds) async {
    List<Map<String, dynamic>> groupDetails = [];

    for (String groupId in groupIds) {
      DocumentSnapshot groupSnapshot = await _firestore.collection('groups').doc(groupId).get();
      if (groupSnapshot.data() != null) {
        Map<String, dynamic> groupData = groupSnapshot.data()! as Map<String, dynamic>;
        groupData['member'] = groupData['member'] as List<dynamic>;
        groupData['groupId'] = groupId;  // Add the groupId here
        groupDetails.add(groupData);
        print(groupData['groupName'] as String,);
      } else {
        print('Keine Daten für Gruppe mit ID: $groupId');
      }

    }

    return groupDetails;
  }
}
