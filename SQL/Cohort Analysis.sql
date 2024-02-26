-- upload file RFM_final và Ontop_General_Records_cleaned vừa mới làm trên Python --
SELECT *
FROM RFM_final

SELECT *
FROM Ontop_General_Records_cleaned


-- join 02 bảng này lại rồi tạo thành 1 bảng mới Ontop_General_Records_Ranking--
SELECT RFM.Segment, GRC.*
INTO Ontop_General_Records_Ranking
FROM Ontop_General_Records_cleaned AS GRC
JOIN RFM_final AS RFM
ON RFM.Payee_ID = GRC.Payee_ID

SELECT *
FROM Ontop_General_Records_Ranking;

-- bắt đầu từ bảng Ontop_General_Records_Ranking, build file Cohort cho nhóm khách chính: Champions và Loyal --
WITH min_quarter AS (                                   -- Bảng này để build Min_quarter của từng khách hàng trong nhóm --
    SELECT Segment,
        Payee_ID,
        MIN(DATEDIFF(QUARTER,'2019/07/01',DATE)) AS min_order_quarter
    FROM Ontop_General_Records_Ranking
    WHERE Segment = 'Champions' OR Segment = 'Loyal'
    GROUP BY Payee_ID, Segment
)
,
distinct_quarter AS (                                   -- Bảng này để build các quarter có đơn từ khách --
    SELECT DISTINCT Payee_ID,            
        Segment,
        DATEDIFF(QUARTER,'2019/07/01',DATE) AS Order_Quater
    FROM Ontop_General_Records_Ranking
    WHERE Segment = 'Champions' OR Segment = 'Loyal'
)
,
Final_Raw AS (
    SELECT a.Payee_ID,
        a.min_order_quarter,
        b.Order_Quater,
        b.Order_Quater - a.min_order_quarter AS quar_diff
    FROM min_quarter AS a
    LEFT JOIN distinct_quarter AS b
    ON a.Payee_ID = b.Payee_ID
)
SELECT  
    (CASE
        WHEN min_order_quarter= 0 THEN REPLACE(min_order_quarter , 0, 'Q3_2019') 
        WHEN min_order_quarter= 1 THEN REPLACE(min_order_quarter , 1, 'Q4_2019')
        WHEN min_order_quarter= 2 THEN REPLACE(min_order_quarter , 2, 'Q1_2020')
        WHEN min_order_quarter= 3 THEN REPLACE(min_order_quarter , 3, 'Q2_2020')
        WHEN min_order_quarter= 4 THEN REPLACE(min_order_quarter , 4, 'Q3_2020')
        WHEN min_order_quarter= 5 THEN REPLACE(min_order_quarter , 5, 'Q4_2020')
        WHEN min_order_quarter= 6 THEN REPLACE(min_order_quarter , 6, 'Q1_2021')
        WHEN min_order_quarter= 7 THEN REPLACE(min_order_quarter , 7, 'Q2_2021')
        WHEN min_order_quarter= 8 THEN REPLACE(min_order_quarter , 8, 'Q3_2021') 
        WHEN min_order_quarter= 9 THEN REPLACE(min_order_quarter , 09, 'Q4_2021') 
        WHEN min_order_quarter= 10 THEN REPLACE(min_order_quarter , 10, 'Q1_2022')
        WHEN min_order_quarter= 11 THEN REPLACE(min_order_quarter , 11, 'Q2_2022')
        WHEN min_order_quarter= 12 THEN REPLACE(min_order_quarter , 12, 'Q3_2022')
        WHEN min_order_quarter= 13 THEN REPLACE(min_order_quarter , 13, 'Q4_2022')  
    END) as Quarter_Number,
    COUNT(DISTINCT Payee_ID) AS Total_Payee,
    COUNT(CASE WHEN quar_diff = 1 THEN Payee_ID END) AS Quarter_1,
    COUNT(CASE WHEN quar_diff = 2 THEN Payee_ID END) AS Quarter_2,
    COUNT(CASE WHEN quar_diff = 3 THEN Payee_ID END) AS Quarter_3,
    COUNT(CASE WHEN quar_diff = 4 THEN Payee_ID END) AS Quarter_4,
    COUNT(CASE WHEN quar_diff = 5 THEN Payee_ID END) AS Quarter_5,
    COUNT(CASE WHEN quar_diff = 6 THEN Payee_ID END) AS Quarter_6,
    COUNT(CASE WHEN quar_diff = 7 THEN Payee_ID END) AS Quarter_7,
    COUNT(CASE WHEN quar_diff = 8 THEN Payee_ID END) AS Quarter_8,
    COUNT(CASE WHEN quar_diff = 9 THEN Payee_ID END) AS Quarter_9,
    COUNT(CASE WHEN quar_diff = 10 THEN Payee_ID END) AS Quarter_10,
    COUNT(CASE WHEN quar_diff = 11 THEN Payee_ID END) AS Quarter_11,
    COUNT(CASE WHEN quar_diff = 12 THEN Payee_ID END) AS Quarter_12,
    COUNT(CASE WHEN quar_diff = 13 THEN Payee_ID END) AS Quarter_13
INTO Ontop_Cohort
FROM Final_Raw
GROUP BY min_order_quarter
ORDER BY min_order_quarter ASC

SELECT *
FROM Ontop_Cohort