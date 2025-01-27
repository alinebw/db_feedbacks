-- Converts response_avg or response_avg_online to CSAT from 1 to 5
-- Calculates csat_feedback based on csat_content

DELIMITER //

CREATE PROCEDURE sp_calculate_csat_feedback ()
BEGIN

    -- Update csat_content based on response_avg or response_avg_online
    UPDATE feedbacks
    SET csat_content = CASE
        WHEN response_avg IS NOT NULL THEN
            CASE
                WHEN response_avg <= 25 THEN 1
                WHEN response_avg > 25 AND response_avg <= 50 THEN 2
                WHEN response_avg > 50 AND response_avg <= 75 THEN 3
                WHEN response_avg > 75 AND response_avg <= 90 THEN 4
                ELSE 5
            END
        WHEN response_avg_online IS NOT NULL THEN
            CASE
                WHEN response_avg_online <= 25 THEN 1
                WHEN response_avg_online > 25 AND response_avg_online <= 50 THEN 2
                WHEN response_avg_online > 50 AND response_avg_online <= 75 THEN 3
                WHEN response_avg_online > 75 AND response_avg_online <= 90 THEN 4
                ELSE 5
            END
        ELSE NULL
    END;

    -- Calculate csat_feedback as the average of csat_consultant and csat_content
    UPDATE feedbacks
    SET csat_feedback = (csat_consultant + csat_content) / 2
    WHERE csat_consultant IS NOT NULL AND csat_content IS NOT NULL;

END //

DELIMITER ;

