import ballerina/http;


// Resource Structure
// /grades/students
//     POST - add a new student given student details in the expected JSON format

//     /studentID
//          GET     - get results of the student given studentID 
//          PUT     - update the student given the studentID
//          DELETE  - delete the student record given teh studentID

// Define a type to represent the student data
type Student record {
    string studentId;
    string name;
    string grade;
};

// Create an in-memory map to store student data # because connecting a database is not the focus of this assignment
map<Student> studentDB = {};

// Define the service
service /grades on new http:Listener(8080) {

    // Create a new student
    resource function post students(http:Caller caller, http:Request req) returns error? {
        json|error payload = req.getJsonPayload();
        if payload is json {
            Student newStudent = check payload.cloneWithType(Student);
            studentDB[newStudent.studentId] = newStudent;
            check caller->respond("Student added successfully");
        } else {
            http:Response res = new;
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload("Invalid JSON payload");
            check caller->respond(res);
        }
    }

    // Retrieve a student's grade
    resource function get students/[string studentId](http:Caller caller) returns error? {
        Student? student = studentDB[studentId];
        if student is Student {
            check caller->respond(student);
        } else {
            http:Response res = new;
            res.statusCode = http:STATUS_NOT_FOUND;
            res.setPayload("Student not found");
            check caller->respond(res);
        }
    }

    // Update an existing student's grade
    resource function put students/[string studentId](http:Caller caller, http:Request req) returns error? {
        json|error payload = req.getJsonPayload();
        if payload is json {
            Student updatedStudent = check payload.cloneWithType(Student);
            studentDB[studentId] = updatedStudent;
            check caller->respond("Student updated successfully");
        } else {
            http:Response res = new;
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload("Invalid JSON payload");
            check caller->respond(res);
        }
    }

    // Delete a student's grade
    resource function delete students/[string studentId](http:Caller caller) returns error? {
        if studentDB.hasKey(studentId) {
            _ = studentDB.remove(studentId); 
            check caller->respond("Student deleted successfully");
        } else {
            http:Response res = new;
            res.statusCode = http:STATUS_NOT_FOUND;
            res.setPayload("Student not found");
            check caller->respond(res);
        }
    }
}
