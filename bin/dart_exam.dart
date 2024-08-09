import 'dart:convert';
import 'dart:io';

// Đọc dữ liệu từ file JSON
Map<String, dynamic> readData(String path) {
  var file = File(path);
  var jsonString = file.readAsStringSync();
  return jsonDecode(jsonString);
}

// Ghi dữ liệu vào file JSON
void writeData(String path, Map<String, dynamic> data) {
  var file = File(path);
  var jsonString = jsonEncode(data);
  file.writeAsStringSync(jsonString);
}

// Hiển thị toàn bộ sinh viên
void displayAllStudents(String filePath) {
  var data = readData(filePath);
  for (var student in data['students']) {
    print('ID: ${student['id']}, Name: ${student['name']}');
    for (var subject in student['subjects']) {
      print('  Subject: ${subject['name']}');
      print('  Scores: ${subject['scores']}');
    }
  }
}

// Thêm sinh viên
void addStudent(String filePath) {
  print('Nhập ID sinh viên:');
  int id = int.parse(stdin.readLineSync()!);

  print('Nhập tên sinh viên:');
  String name = stdin.readLineSync()!;

  print('Nhập số lượng môn học:');
  int subjectCount = int.parse(stdin.readLineSync()!);

  List<Map<String, dynamic>> subjects = [];
  for (int i = 0; i < subjectCount; i++) {
    print('Nhập tên môn học $i:');
    String subjectName = stdin.readLineSync()!;

    print('Nhập số lượng điểm cho môn học $subjectName:');
    int scoreCount = int.parse(stdin.readLineSync()!);

    List<int> scores = [];
    for (int j = 0; j < scoreCount; j++) {
      print('Nhập điểm $j cho môn học $subjectName:');
      scores.add(int.parse(stdin.readLineSync()!));
    }

    subjects.add({
      'name': subjectName,
      'scores': scores,
    });
  }

  var data = readData(filePath);
  var newStudent = {
    'id': id,
    'name': name,
    'subjects': subjects,
  };
  data['students'].add(newStudent);
  writeData(filePath, data);
}

// Sửa thông tin sinh viên
void editStudent(String filePath) {
  print('Nhập ID sinh viên cần sửa:');
  int id = int.parse(stdin.readLineSync()!);

  var data = readData(filePath);
  for (var student in data['students']) {
    if (student['id'] == id) {
      print('Nhập tên mới (để bỏ qua, nhấn Enter):');
      String? newName = stdin.readLineSync();
      if (newName != null && newName.isNotEmpty) {
        student['name'] = newName;
      }

      print('Bạn có muốn chỉnh sửa môn học không? (y/n)');
      String? editSubjects = stdin.readLineSync();
      if (editSubjects != null && editSubjects.toLowerCase() == 'y') {
        print('Bạn muốn (1) thêm môn học mới, (2) sửa môn học hiện tại, hay (3) xóa môn học?');
        String? choice = stdin.readLineSync();

        if (choice == '1') {
          // Thêm môn học mới
          print('Nhập tên môn học mới:');
          String subjectName = stdin.readLineSync()!;

          print('Nhập số lượng điểm cho môn học $subjectName:');
          int scoreCount = int.parse(stdin.readLineSync()!);

          List<int> scores = [];
          for (int j = 0; j < scoreCount; j++) {
            print('Nhập điểm $j cho môn học $subjectName:');
            scores.add(int.parse(stdin.readLineSync()!));
          }

          student['subjects'].add({
            'name': subjectName,
            'scores': scores,
          });
        } else if (choice == '2') {
          // Sửa môn học hiện tại
          print('Nhập tên môn học cần sửa:');
          String subjectName = stdin.readLineSync()!;

          for (var subject in student['subjects']) {
            if (subject['name'] == subjectName) {
              print('Nhập số lượng điểm mới:');
              int scoreCount = int.parse(stdin.readLineSync()!);

              List<int> scores = [];
              for (int j = 0; j < scoreCount; j++) {
                print('Nhập điểm $j cho môn học $subjectName:');
                scores.add(int.parse(stdin.readLineSync()!));
              }

              subject['scores'] = scores;
            }
          }
        } else if (choice == '3') {
          // Xóa môn học
          print('Nhập tên môn học cần xóa:');
          String subjectName = stdin.readLineSync()!;

          student['subjects'].removeWhere((subject) => subject['name'] == subjectName);
        }
      }

      writeData(filePath, data);
      return;
    }
  }
  print('Sinh viên với ID $id không tìm thấy.');
}

// Tìm kiếm sinh viên theo Tên hoặc ID
void searchStudent(String filePath) {
  print('Nhập ID sinh viên để tìm kiếm (hoặc bỏ qua để tìm theo tên):');
  String? idInput = stdin.readLineSync();
  int? id = idInput != null && idInput.isNotEmpty ? int.parse(idInput) : null;

  print('Nhập tên sinh viên để tìm kiếm (hoặc bỏ qua nếu đã nhập ID):');
  String? name = stdin.readLineSync();

  var data = readData(filePath);
  for (var student in data['students']) {
    if ((id != null && student['id'] == id) || (name != null && student['name'] == name)) {
      print('Found student: ID: ${student['id']}, Name: ${student['name']}');
      for (var subject in student['subjects']) {
        print('  Subject: ${subject['name']}');
        print('  Scores: ${subject['scores']}');
      }
      return;
    }
  }
  print('Không tìm thấy sinh viên nào.');
}

// Hiển thị sinh viên có điểm thi môn cao nhất
void displayTopStudents(String filePath) {
  print('Nhập tên môn học để tìm sinh viên có điểm cao nhất:');
  String subjectName = stdin.readLineSync()!;

  var data = readData(filePath);
  List<Map<String, dynamic>> topStudents = [];
  int highestScore = 0;

  for (var student in data['students']) {
    for (var subject in student['subjects']) {
      if (subject['name'] == subjectName) {
        var maxScore = subject['scores'].reduce((a, b) => a > b ? a : b);
        if (maxScore > highestScore) {
          highestScore = maxScore;
          topStudents = [student];
        } else if (maxScore == highestScore) {
          topStudents.add(student);
        }
      }
    }
  }

  print('Top students in $subjectName with score $highestScore:');
  for (var student in topStudents) {
    print('ID: ${student['id']}, Name: ${student['name']}');
  }
}

void main() {
  String filePath = 'bin/Student.json';

  while (true) {
    print('Chọn chức năng:');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên theo Tên hoặc ID');
    print('5. Hiển thị sinh viên có điểm thi môn cao nhất');
    print('6. Thoát');

    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        displayAllStudents(filePath);
        break;
      case '2':
        addStudent(filePath);
        break;
      case '3':
        editStudent(filePath);
        break;
      case '4':
        searchStudent(filePath);
        break;
      case '5':
        displayTopStudents(filePath);
        break;
      case '6':
        print('Thoát chương trình.');
        return;
      default:
        print('Lựa chọn không hợp lệ, vui lòng chọn lại.');
    }
  }
}
