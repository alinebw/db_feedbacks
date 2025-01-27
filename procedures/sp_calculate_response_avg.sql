-- Calculates weighted average for options in the new csat_content question format

DELIMITER //

CREATE PROCEDURE sp_calculate_response_avg ()
BEGIN
    
    -- Update response_avg (in-person) based on weighted average
    UPDATE feedbacks
    SET response_avg = FLOOR(
        (
            (response_a * 100) +
            (response_b * 75) +
            (response_c * 50) +
            (response_d * 25)
        ) / NULLIF(response_a + response_b + response_c + response_d, 0) -- Avoids division by zero
    ),
    -- Update response_avg_online (online) based on weighted average
    response_avg_online = FLOOR(
        (
            (response_a_online * 100) +
            (response_b_online * 75) +
            (response_c_online * 50) +
            (response_d_online * 25)
        ) / NULLIF(response_a_online + response_b_online + response_c_online + response_d_online, 0) -- Avoids division by zero
    );

END //

DELIMITER ;

