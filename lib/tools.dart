List<String> generateClassroomList() {
  List<String> classroomList = [];
  for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 10; j++) {
      classroomList.add('$i-$j');
    }
  }
  return classroomList;
}
