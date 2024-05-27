// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Define an interface for interacting with the DistributeCredentials contract
interface IDistributeCredentials {
    // Function declaration to fetch credential data by studentId
    function getCredentials(uint256 studentId) external view returns (
        address studentAddress, 
        string memory studentName, 
        string memory institution, 
        string memory qualification, 
        string memory dateIssued, 
        bytes32 signature
    );
}

// Smart contract for verifying academic credentials
contract CredentialVerification {
    // Store the address of the DistributeCredentials contract for cross-contract calls
    address public distributeCredentialsContract;

    // Define a struct to hold detailed information about a credential
    struct Credential {
        uint256 studentId;         // ID of the student
        string studentName;        // Name of the student
        string institution;        // Institution that issued the credential
        string qualification;      // Qualification awarded
        string dateIssued;         // Date the credential was issued
        string additionalData;     // Any additional data
        bytes32 signature;         // Cryptographic signature for verifying authenticity
    }

    // Private mapping of student ID to their Credential struct
    mapping(uint256 => Credential) private credentials;
    // Mapping to check if an address is registered as an employer
    mapping(address => bool) public isEmployer;
    // Mapping of student ID to their Ethereum address
    mapping(uint256 => address) public studentAddresses;
    // Nested mapping to handle permissions for employers to access specific student credentials
    mapping(uint256 => mapping(address => bool)) public permissions;

    // Event to signal a verification result
    event VerificationResult(address employer, bool isVerified, string message);
    // Event triggered when an employer requests permission to access credentials
    event PermissionRequested(uint256 studentId, address employer);
    // Event triggered when permission is granted to an employer
    event PermissionGranted(uint256 studentId, address employer);
    // Event triggered when permission is denied to an employer
    event PermissionDenied(uint256 studentId, address employer);

    // Constructor to initialise the contract with the address of DistributeCredentials
    constructor(address _distributeCredentialsContract) {
        distributeCredentialsContract = _distributeCredentialsContract;
    }

    // Modifier to restrict function access to authorised employers only
    modifier onlyEmployer() {
        require(isEmployer[msg.sender], "Caller is not an authorised employer");
        _;
    }

    // Function to add an employer's address to the registry
    function addEmployer(address employer) public {
        require(!isEmployer[employer], "Employer already authorised.");
        isEmployer[employer] = true;
    }

    // Function for employers to request permission to access a student's credential data
    function requestPermission(uint256 studentId) public onlyEmployer {
        require(credentials[studentId].studentId != 0, "Student ID is not registered."); // Ensure the credentials exist
        require(studentAddresses[studentId] != address(0), "No Ethereum address registered for this student."); // Ensure the student address is registered
        emit PermissionRequested(studentId, msg.sender); // Emit an event for the permission request
    }

    // Function for a student to grant an employer permission to access their credential data
    function grantPermission(uint256 studentId, address employer) public {
        require(msg.sender == studentAddresses[studentId], "Only the student can grant permission"); // Only the student can grant permission
        require(isEmployer[employer], "Employer is not authorised"); // Ensure the employer is registered
        permissions[studentId][employer] = true; // Grant permission
        emit PermissionGranted(studentId, employer); // Emit an event for granting permission
    }

    // Function for a student to deny or revoke an employer's permission
    function denyPermission(uint256 studentId, address employer) public {
        require(msg.sender == studentAddresses[studentId], "Only the student can deny permission"); // Only the student can deny permission
        require(isEmployer[employer], "Employer is not authorised"); // Ensure the employer is registered
        permissions[studentId][employer] = false; // Revoke permission
        emit PermissionDenied(studentId, employer); // Emit an event for denying permission
    }

    // Function to read and verify a student's credential if permission is granted
    function readCredential(uint256 studentId) public view onlyEmployer returns (string memory) {
        require(permissions[studentId][msg.sender], "Permission not granted by the student"); // Ensure permission is granted
        Credential memory cred = credentials[studentId]; // Retrieve the credentials
        return generateVerificationMessage(cred); // Generate and return the verification message
    }

    // Function to verify the integrity of the credentials using the cryptographic signature
    function verifyCredentials(uint256 studentId, bytes32 credentialHash) public view onlyEmployer returns (bool) {
        require(permissions[studentId][msg.sender], "Employer does not have permission to verify this student's credentials"); // Ensure permission is granted
        Credential memory cred = credentials[studentId]; // Retrieve the credentials
        return (cred.signature == credentialHash); // Verify the signature
    }

    // Function to receive and store credentials from the DistributeCredentials contract
    function receiveCredentials(uint256 studentId) public {
        IDistributeCredentials distributeCredentials = IDistributeCredentials(distributeCredentialsContract); // Instantiate the interface
        (address studentAddress, string memory studentName, string memory institution, string memory qualification, string memory dateIssued, bytes32 signature) = distributeCredentials.getCredentials(studentId); // Fetch credentials
        credentials[studentId] = Credential(studentId, studentName, institution, qualification, dateIssued, "", signature); // Store the credentials
        studentAddresses[studentId] = studentAddress; // Store the student address
    }

    // Function to check if credentials exist for a given student ID without exposing details
    function credentialsExist(uint256 studentId) public view returns (bool) {
        return credentials[studentId].studentId != 0; // Check existence of credentials
    }

    // Helper function to generate a formatted string displaying a credential's details
    function generateVerificationMessage(Credential memory credential) private pure returns (string memory) {
        return string(abi.encodePacked(
            "Name: ", credential.studentName,
            ", Institution: ", credential.institution,
            ", Qualification: ", credential.qualification,
            ", Date Issued: ", credential.dateIssued
        ));
    }
}
