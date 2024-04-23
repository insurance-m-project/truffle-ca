// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract MedicalRecord {
    // 세부 내역
    struct TreatmentDetail {
        string category;
        string date;
        string treatCode;
        string description;
        uint256 price;
        uint256 oop;
        uint256 pcc;
        uint256 foop;
        uint256 nonReimbursement;
    }
    // 접수 기록
    struct MedicalRecordData {
        string name;
        string RRN;
        string KCD;
        string date;
        string receiptNumber;
        uint256 totalOop;
        uint256 totalPcc;
        uint256 totalFoop;
        uint256 nonReimbursement;
        TreatmentDetail[] treatDetails;
        uint256 treatDetailsCount;
    }

    // 속성
    string private constant DEFAULT_KCD = "J09"; // Default KCD value
    string private constant DEFAULT_owner = "0x584553326f444c7B849483FEB32E8DB5c1Fe0689";
    mapping(string => MedicalRecordData) private medicalRecords;
    uint256 public medicalRecordsCount;
    string[] private medicalRecordKeys;
    mapping(string => address) private recordOwners; // Store record owners

    // 이벤트 반환 구조체
    event MedicalRecordSet(
        string name,
        string RRN,
        string KCD,
        string date,
        string receiptNumber,
        uint256 totalOop,
        uint256 totalPcc,
        uint256 totalFoop,
        uint256 nonReimbursement,
        TreatmentDetail[] treatDetails
    );

    // 메소드
    // 새로운 접수 기록 저장
    function addMedicalRecord(
        string memory _name,
        string memory _RRN,
        string memory _KCD,
        string memory _date,
        string memory _receiptNumber,
        uint256 _totalOop,
        uint256 _totalPcc,
        uint256 _totalFoop,
        uint256 _nonReimbursement,
        TreatmentDetail[] memory _treatDetails
    ) public {
        require(keccak256(bytes(_KCD)) == keccak256(bytes(DEFAULT_KCD)), "KCD does not match");
        require(bytes(medicalRecords[_receiptNumber].name).length == 0, "Receipt number already exists");

        MedicalRecordData storage record = medicalRecords[_receiptNumber];
        record.name = _name;
        record.RRN = _RRN;
        record.KCD = _KCD;
        record.date = _date;
        record.receiptNumber = _receiptNumber;
        record.totalOop = _totalOop;
        record.totalPcc = _totalPcc;
        record.totalFoop = _totalFoop;
        record.nonReimbursement = _nonReimbursement;

        for (uint256 i = 0; i < _treatDetails.length; i++) {
            record.treatDetails.push(_treatDetails[i]);
        }
        record.treatDetailsCount = _treatDetails.length;

        medicalRecordKeys.push(_receiptNumber);
        medicalRecordsCount++;
        recordOwners[_receiptNumber] = msg.sender;

        emit MedicalRecordSet(_name, _RRN, _KCD, _date, _receiptNumber, _totalOop, _totalPcc, _totalFoop, _nonReimbursement, _treatDetails);
    }

    // 영수 번호 기준 조회
    function getMedicalRecord(string memory _receiptNumber) public view returns (MedicalRecordData memory) {
        return medicalRecords[_receiptNumber];
    }

    // 모든 접수 기록 조회
    function getMedicalRecords() public view returns (MedicalRecordData[] memory) {
        MedicalRecordData[] memory records = new MedicalRecordData[](medicalRecordsCount);
        for (uint256 i = 0; i < medicalRecordKeys.length; i++) {
            records[i] = medicalRecords[medicalRecordKeys[i]];
        }
        return records;
    }

    // 모든 접수 기록 페이징 처리, 
    function getPagedMedicalRecords(uint256 page, uint256 pageSize, uint256 curCount) public view returns (MedicalRecordData[] memory) {
        if (pageSize == 0 || page == 0) {
            return new MedicalRecordData[](0);
        }

        if ((page - 1) * pageSize >= curCount) {
            return new MedicalRecordData[](0);
        }

        uint256 startIndex = curCount - (page - 1) * pageSize - 1;
        uint256 endIndex = startIndex >= (pageSize - 1) ? startIndex - (pageSize - 1) : 0;

        uint256 count = startIndex - endIndex + 1;
        MedicalRecordData[] memory pageRecords = new MedicalRecordData[](count);
        for (uint256 i = 0; i < count; i++) {
            pageRecords[i] = medicalRecords[medicalRecordKeys[startIndex - i]];
        }
        return pageRecords;
    }

    // 접수 기록 삭제
    function deleteMedicalRecord(string memory _receiptNumber, string memory _sender) public {
        require(bytes(medicalRecords[_receiptNumber].name).length != 0, "No record found to delete.");
        require(isOwner(_sender), "Unauthorized access.");

        delete medicalRecords[_receiptNumber];
        removeKey(_receiptNumber);
    }

    // key값 삭제
    function removeKey(string memory _receiptNumber) private {
        uint256 index = findIndex(_receiptNumber);
        if (index < medicalRecordKeys.length - 1) {
            medicalRecordKeys[index] = medicalRecordKeys[medicalRecordKeys.length - 1];
        }
        medicalRecordKeys.pop();
        medicalRecordsCount--;
    }

    // key값 위치 확인
    function findIndex(string memory _receiptNumber) private view returns (uint256) {
        for (uint256 i = 0; i < medicalRecordKeys.length; i++) {
            if (keccak256(bytes(medicalRecordKeys[i])) == keccak256(bytes(_receiptNumber))) {
                return i;
            }
        }
        revert("Receipt number not found.");
    }

    // 권한 확인
    function isOwner(string memory _sender) public view returns (bool) {
	return keccak256(bytes(_sender)) == keccak256(bytes(DEFAULT_owner));
    }
}

