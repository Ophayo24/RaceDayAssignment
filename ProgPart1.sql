IF DB_ID('RaceDayDB') IS NULL
BEGIN
    CREATE DATABASE RaceDayDB;
END;

USE RaceDayDB;

-- this is so the script can be tested repeatedly.
DROP TABLE IF EXISTS Results;
DROP TABLE IF EXISTS Enrolments;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS EventRoutes;
DROP TABLE IF EXISTS Events;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL DEFAULT 'Participant',
    Phone NVARCHAR(20) NULL,
    ProfilePictureUrl NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT CK_Users_Role CHECK (Role IN ('Organiser', 'Participant'))
);

CREATE TABLE Events
(
    EventId INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserId INT NOT NULL,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NOT NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,
    BannerImageUrl NVARCHAR(500) NULL,
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserId) REFERENCES Users(UserId),
    CONSTRAINT CK_Events_Distance CHECK (DistanceKm > 0),
    CONSTRAINT CK_Events_EventType CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);

CREATE TABLE Categories
(
    CategoryId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    MinAge INT NULL,
    MaxAge INT NULL,
    CategoryDistanceKm DECIMAL(6,2) NULL,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventId) REFERENCES Events(EventId),
    CONSTRAINT CK_Categories_MinAge CHECK (MinAge IS NULL OR MinAge >= 0),
    CONSTRAINT CK_Categories_MaxAge CHECK (MaxAge IS NULL OR MaxAge >= 0),
    CONSTRAINT CK_Categories_AgeRange CHECK (MaxAge IS NULL OR MinAge IS NULL OR MaxAge >= MinAge),
    CONSTRAINT CK_Categories_Distance CHECK (CategoryDistanceKm IS NULL OR CategoryDistanceKm > 0),
    CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventId, CategoryName)
);

CREATE TABLE Enrolments
(
    EnrolmentId INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantId INT NOT NULL,
    EventId INT NOT NULL,
    CategoryId INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Status NVARCHAR(20) NOT NULL DEFAULT 'Confirmed',
    CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantId) REFERENCES Users(UserId),
    CONSTRAINT FK_Enrolments_Event FOREIGN KEY (EventId) REFERENCES Events(EventId),
    CONSTRAINT FK_Enrolments_Category FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId),
    CONSTRAINT CK_Enrolments_Status CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantId, EventId)
);

CREATE TABLE Results
(
    ResultId INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentId INT NOT NULL UNIQUE,
    FinishTime TIME(0) NOT NULL,
    FinishingPosition INT NOT NULL,
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentId) REFERENCES Enrolments(EnrolmentId),
    CONSTRAINT CK_Results_Position CHECK (FinishingPosition > 0)
);

CREATE TABLE EventRoutes
(
    RouteId INT IDENTITY(1,1) PRIMARY KEY,
    EventId INT NOT NULL UNIQUE,
    RouteName NVARCHAR(150) NOT NULL,
    RouteDescription NVARCHAR(1000) NOT NULL,
    RouteUrl NVARCHAR(500) NULL,
    CONSTRAINT FK_EventRoutes_Events FOREIGN KEY (EventId) REFERENCES Events(EventId)
);

INSERT INTO Users
    (FirstName, LastName, Email, PasswordHash, Role, Phone)
VALUES
    ('Thabo', 'Mokoena', 'thabo.organiser@raceday.co.za', 'HASHED_PASSWORD_001', 'Organiser', '0711111111'),
    ('Lerato', 'Dlamini', 'lerato.organiser@raceday.co.za', 'HASHED_PASSWORD_002', 'Organiser', '0722222222'),
    ('Sipho', 'Nkosi', 'sipho.participant@raceday.co.za', 'HASHED_PASSWORD_003', 'Participant', '0733333333'),
    ('Ayanda', 'Mthembu', 'ayanda.participant@raceday.co.za', 'HASHED_PASSWORD_004', 'Participant', '0744444444');

INSERT INTO Events
    (OrganiserId, Name, Description, EventDate, Location, DistanceKm, EventType, BannerImageUrl)
VALUES
    (1, 'Johannesburg City Run', 'A community road running event through Johannesburg.', '2026-10-18', 'Johannesburg, Gauteng', 10.00, 'Run', NULL),
    (1, 'Soweto Charity Walk', 'A charity walking event supporting local community initiatives.', '2026-11-01', 'Soweto, Gauteng', 5.00, 'Walk', NULL),
    (2, 'Pretoria Cycle Challenge', 'A road cycling event for recreational and competitive cyclists.', '2026-11-15', 'Pretoria, Gauteng', 21.00, 'Cycle', NULL);

INSERT INTO Categories
    (EventId, CategoryName, MinAge, MaxAge, CategoryDistanceKm)
VALUES
    (1, 'Junior', 16, 19, 10.00),
    (1, 'Senior', 20, 39, 10.00),
    (1, 'Veteran', 40, NULL, 10.00),
    (2, 'Junior', 16, 19, 5.00),
    (2, 'Senior', 20, 39, 5.00),
    (2, 'Veteran', 40, NULL, 5.00),
    (3, 'Open', 18, NULL, 21.00),
    (3, 'Veteran', 40, NULL, 21.00);

INSERT INTO EventRoutes
    (EventId, RouteName, RouteDescription, RouteUrl)
VALUES
    (1, 'City 10K Route', '10 km road route through central Johannesburg.', NULL),
    (2, 'Soweto 5K Route', '5 km community walk route through Soweto.', NULL),
    (3, 'Pretoria 21K Cycle Route', '21 km cycling route around Pretoria.', NULL);

INSERT INTO Enrolments
    (ParticipantId, EventId, CategoryId, Status)
VALUES
    (3, 1, 2, 'Confirmed'),
    (4, 1, 2, 'Confirmed'),
    (3, 2, 5, 'Confirmed'),
    (4, 3, 7, 'Pending');

INSERT INTO Results
    (EnrolmentId, FinishTime, FinishingPosition)
VALUES
    (1, '00:52:34', 47),
    (2, '00:58:12', 68);

SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM EventRoutes;
SELECT * FROM Enrolments;
SELECT * FROM Results;