-- Sends data to another database

DELIMITER //

CREATE PROCEDURE sp_send_data_to_prod ()
BEGIN
   
    UPDATE prod.checklist_feedback cf
    JOIN feedbacks_db.feedbacks f
        ON CONVERT(cf.class_id USING utf8mb4) COLLATE utf8mb4_unicode_ci = f.id_feedback COLLATE utf8mb4_unicode_ci
        AND CONVERT(cf.class_name USING utf8mb4) COLLATE utf8mb4_unicode_ci = f.id_tasklist COLLATE utf8mb4_unicode_ci
    SET 
        cf.nps = CONVERT(f.nps_feedback USING latin1) COLLATE latin1_swedish_ci,
        cf.response_a = CONVERT(f.response_a USING latin1) COLLATE latin1_swedish_ci,
        cf.response_b = CONVERT(f.response_b USING latin1) COLLATE latin1_swedish_ci,
        cf.response_c = CONVERT(f.response_c USING latin1) COLLATE latin1_swedish_ci,
        cf.response_d = CONVERT(f.response_d USING latin1) COLLATE latin1_swedish_ci,
        cf.response_a_online = CONVERT(f.response_a_online USING latin1) COLLATE latin1_swedish_ci,
        cf.response_b_online = CONVERT(f.response_b_online USING latin1) COLLATE latin1_swedish_ci,
        cf.response_c_online = CONVERT(f.response_c_online USING latin1) COLLATE latin1_swedish_ci,
        cf.response_d_online = CONVERT(f.response_d_online USING latin1) COLLATE latin1_swedish_ci,
        cf.response_yes_online = CONVERT(f.response_yes_online USING latin1) COLLATE latin1_swedish_ci,
        cf.response_no_online = CONVERT(f.response_no_online USING latin1) COLLATE latin1_swedish_ci;
	
    -- Log to confirm data sending
    INSERT INTO processing_logs (id_deliverable, status, processing_date, message)
    VALUES ('N/A', 'Sent', NOW(), 'Data sent to checklist_feedback');
END //

DELIMITER ;

