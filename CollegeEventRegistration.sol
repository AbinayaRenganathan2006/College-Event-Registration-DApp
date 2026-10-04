// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CollegeEventRegistration {
    address public admin;

    struct Event {
        uint256 id;
        string name;
        string date;
        uint256 capacity;
        uint256 registeredCount;
        bool active;
    }

    struct Registration {
        string studentName;
        string rollNumber;
        string email;
        uint256 eventId;
        uint256 registeredAt;
    }

    uint256 public eventCount;
    mapping(uint256 => Event) public events;
    mapping(uint256 => mapping(address => Registration)) public registrations;
    mapping(uint256 => mapping(address => bool)) public isRegistered;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function createEvent(
        string memory _name,
        string memory _date,
        uint256 _capacity
    ) public onlyAdmin {
        require(_capacity > 0, "Capacity must be greater than zero");
        eventCount++;
        events[eventCount] = Event(
            eventCount, _name, _date, _capacity, 0, true
        );
    }

    function registerForEvent(
        uint256 _eventId,
        string memory _studentName,
        string memory _rollNumber,
        string memory _email
    ) public {
        require(_eventId > 0 && _eventId <= eventCount, "Invalid event");
        require(events[_eventId].active, "Event is not active");
        require(!isRegistered[_eventId][msg.sender], "Student already registered");
        require(
            events[_eventId].registeredCount < events[_eventId].capacity,
            "Event is full"
        );

        registrations[_eventId][msg.sender] = Registration(
            _studentName,
            _rollNumber,
            _email,
            _eventId,
            block.timestamp
        );

        isRegistered[_eventId][msg.sender] = true;
        events[_eventId].registeredCount++;
    }

    function getRegistration(uint256 _eventId, address _student)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            uint256,
            uint256
        )
    {
        require(isRegistered[_eventId][_student], "Student is not registered");
        Registration memory r = registrations[_eventId][_student];

        return (
            r.studentName,
            r.rollNumber,
            r.email,
            r.eventId,
            r.registeredAt
        );
    }

    function getEvent(uint256 _eventId)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint256,
            uint256,
            bool
        )
    {
        Event memory e = events[_eventId];

        return (
            e.id,
            e.name,
            e.date,
            e.capacity,
            e.registeredCount,
            e.active
        );
    }

    function closeEvent(uint256 _eventId) public onlyAdmin {
        require(_eventId > 0 && _eventId <= eventCount, "Invalid event");
        events[_eventId].active = false;
    }
}
