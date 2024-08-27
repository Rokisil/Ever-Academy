// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ContinuousLearning {
    // Struct to represent a student
    struct Student {
        string name;
        uint256 achievementsCount;
        uint256 totalPoints;
        mapping(uint256 => Achievement) achievements;
    }

    // Struct to represent an achievement
    struct Achievement {
        string courseName;
        uint256 points;
        uint256 timestamp;
    }

    // Mapping from student address to Student
    mapping(address => Student) private students;

    // Event to track new achievements
    event AchievementAdded(address indexed student, uint256 id, string courseName, uint256 points);

    // Modifier to check if a student is registered
    modifier isRegistered() {
        require(bytes(students[msg.sender].name).length > 0, "Student not registered.");
        _;
    }

    // Function to register a new student
    function registerStudent(string calldata _name) external {
        require(bytes(_name).length > 0, "Name is required.");
        require(bytes(students[msg.sender].name).length == 0, "Student already registered.");

        students[msg.sender].name = _name;
        students[msg.sender].achievementsCount = 0;
        students[msg.sender].totalPoints = 0;
    }

    // Function to add an achievement for a student
    function addAchievement(string calldata _courseName, uint256 _points) external isRegistered {
        require(bytes(_courseName).length > 0, "Course name is required.");
        require(_points > 0, "Points must be greater than 0.");

        Student storage student = students[msg.sender];
        uint256 achievementId = student.achievementsCount;

        student.achievements[achievementId] = Achievement({
            courseName: _courseName,
            points: _points,
            timestamp: block.timestamp
        });

        student.achievementsCount++;
        student.totalPoints += _points;

        emit AchievementAdded(msg.sender, achievementId, _courseName, _points);
    }

    // Function to get a student's total points
    function getTotalPoints() external view isRegistered returns (uint256) {
        return students[msg.sender].totalPoints;
    }

    // Function to get a student's achievement by ID
    function getAchievement(uint256 _id) external view isRegistered returns (string memory, uint256, uint256) {
        require(_id < students[msg.sender].achievementsCount, "Achievement does not exist.");

        Achievement memory achievement = students[msg.sender].achievements[_id];
        return (achievement.courseName, achievement.points, achievement.timestamp);
    }

    // Function to get the student's details
    function getStudentDetails(address _studentAddress) external view returns (string memory, uint256, uint256) {
        Student storage student = students[_studentAddress];
        require(bytes(student.name).length > 0, "Student not registered.");

        return (student.name, student.achievementsCount, student.totalPoints);
    }
}