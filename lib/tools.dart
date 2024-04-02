List<String> generateClassroomList() {
  List<String> classroomList = [];
  for (int i = 1; i <= 3; i++) {
    for (int j = 1; j <= 10; j++) {
      classroomList.add('$i-$j');
    }
  }
  return classroomList;
}

bool checkDay(int index, int subIndex) {
  if (index != 0 || subIndex == 0) {
    return false;
  }
  // 1: 월, 2: 화, 3: 수, 4: 목, 5: 금
  DateTime now = DateTime.now();
  int day = now.weekday;
  if (subIndex == day) return true;

  return false;
}
