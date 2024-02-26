-- Tạo 1 database mới để lưu các file upload để xử lý cho final project --
CREATE DATABASE BI40_Final

-- Kiểm tra dữ liệu --
SELECT *
FROM Ontop_General_Records;

-- Trích từ file record ra thành một file csv mới trích ra tổng doanh thu và chi phí theo từng dự án --
WITH Cost AS (                                          -- Bảng này để trích Chi Phí theo dự án --
    SELECT Internal_Code,
    ROUND(SUM(Amount),2) AS Project_Cost
FROM Ontop_General_Records
WHERE Record_Type = 'COS'
GROUP BY Internal_Code
)
,
Revenue AS (                                            -- Bảng này để trích Doanh thu theo dự án --
    SELECT MAX(DATE) AS Date,                           -- Chọn Min và mỗi dự án có thể trả nhiều lần, nhưng sẽ chọn ngày nhận Balance từ khách để chốt ngày dự án --        Customer_ID,
        Internal_Code,
        ROUND(SUM(Amount),2) AS Project_Revenue
FROM Ontop_General_Records
WHERE Record_Type = 'REV'
GROUP BY Internal_Code, Customer_ID
)
,
Total AS (SELECT R.*, C.Project_Cost                    -- Bảng này để trích Ghép 02 bảng Revenue và Cost --
FROM Revenue AS R
JOIN Cost AS C
ON C.Internal_Code = R.Internal_Code
)
SELECT *,
    ROUND(Project_Revenue - Project_Cost,2) AS Project_Profit       -- Tạo thêm cột Profit--
INTO Ontop_Order_Details                             -- Lưu thành 1 bảng mới --
FROM Total

-- Kiểm tra bảng mới và download --
SELECT *
FROM [dbo].[Ontop_Order_Details];

-- Download và lưu dưới tên "Ontop_Order_Details"--




-- Trích từ bảng "Ontop_General_Records" thêm 1 bảng tính Salary rồi ghép với bảng Staff_Detail để lấy theo Staff_ID--
WITH Salary AS (
    SELECT DATE,
        PAYEE,
        SUM(Amount) AS Salary
FROM Ontop_General_Records
WHERE Record_Type = 'SAL'
GROUP BY DATE, PAYEE
)
SELECT S.DATE, SD.Staff_ID AS Staff_Name, 
    PAYEE, S. Salary
INTO Ontop_Salary
FROM Salary AS S
JOIN Ontop_Staff_Details AS SD
ON SD.Team_Member = S.PAYEE

--Check bảng Salary mới tạo--
SELECT *
FROM Ontop_Salary


--Download và lưu dưới tên Ontop_Salary--