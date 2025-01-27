-- Updates data in the feedbacks table

DELIMITER //

CREATE PROCEDURE sp_update_feedbacks (
    IN p_id_feedback VARCHAR(45)
)
BEGIN
    DECLARE v_total_deliverables INT DEFAULT 0;
    DECLARE v_total_promoters INT DEFAULT 0;
    DECLARE v_total_neutrals INT DEFAULT 0;
    DECLARE v_total_detractors INT DEFAULT 0;
    DECLARE v_percent_promoters DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_percent_neutrals DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_percent_detractors DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_nps_feedback DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_feedback_type VARCHAR(45) DEFAULT NULL;
    DECLARE v_csat_consultant DECIMAL(5, 2) DEFAULT NULL;

    DECLARE v_response_a INT DEFAULT 0;
    DECLARE v_response_b INT DEFAULT 0;
    DECLARE v_response_c INT DEFAULT 0;
    DECLARE v_response_d INT DEFAULT 0;

    DECLARE v_response_a_online INT DEFAULT 0;
    DECLARE v_response_b_online INT DEFAULT 0;
    DECLARE v_response_c_online INT DEFAULT 0;
    DECLARE v_response_d_online INT DEFAULT 0;

    DECLARE v_response_yes_online INT DEFAULT 0;
    DECLARE v_response_no_online INT DEFAULT 0;

    -- Calculates the total number of deliverables
    SELECT COUNT(*)
    INTO v_total_deliverables
    FROM deliverables
    WHERE id_feedback = p_id_feedback;
    
    -- Calculates the average CSAT for the consultant
    SELECT AVG(csat_consultant)
    INTO v_csat_consultant
    FROM deliverables
    WHERE id_feedback = p_id_feedback;

    -- Calculates promoters, neutrals, and detractors
    SELECT 
        SUM(CASE WHEN nps_status = 'PROMOTER' THEN 1 ELSE 0 END),
        SUM(CASE WHEN nps_status = 'NEUTRAL' THEN 1 ELSE 0 END),
        SUM(CASE WHEN nps_status = 'DETRACTOR' THEN 1 ELSE 0 END)
    INTO 
        v_total_promoters, v_total_neutrals, v_total_detractors
    FROM deliverables
    WHERE id_feedback = p_id_feedback;

    -- Calculates percentages and NPS
    SET v_percent_promoters = (v_total_promoters / v_total_deliverables) * 100;
    SET v_percent_neutrals = (v_total_neutrals / v_total_deliverables) * 100;
    SET v_percent_detractors = (v_total_detractors / v_total_deliverables) * 100;
    SET v_nps_feedback = v_percent_promoters - v_percent_detractors;

    -- Calculates response percentages for in-person feedback
    SELECT 
        SUM(CASE WHEN csat_content_option = 'Completely' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_option = 'Partially' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_option = 'Have doubts' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_option = 'No' THEN 1 ELSE 0 END)
    INTO 
        v_response_a, v_response_b, v_response_c, v_response_d
    FROM deliverables
    WHERE id_feedback = p_id_feedback;

    -- Calculates response percentages for online feedback
    SELECT 
        SUM(CASE WHEN csat_content_online_option = 'Completely' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_online_option = 'Partially' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_online_option = 'Have doubts' THEN 1 ELSE 0 END),
        SUM(CASE WHEN csat_content_online_option = 'No' THEN 1 ELSE 0 END),
        SUM(CASE WHEN platform_accessible = 'Yes' THEN 1 ELSE 0 END),
        SUM(CASE WHEN platform_accessible = 'No' THEN 1 ELSE 0 END)
    INTO 
        v_response_a_online, v_response_b_online, v_response_c_online, v_response_d_online,
        v_response_yes_online, v_response_no_online
    FROM deliverables
    WHERE id_feedback = p_id_feedback;

    -- Determines the feedback type
    SELECT GROUP_CONCAT(DISTINCT feedback_type ORDER BY feedback_type ASC SEPARATOR ', ')
    INTO v_feedback_type
    FROM deliverables
    WHERE id_feedback = p_id_feedback;

    -- Updates the feedbacks table
    UPDATE feedbacks
    SET
        total_items = v_total_deliverables,
        csat_consultant = v_csat_consultant,
        percent_promoters = v_percent_promoters,
        percent_neutrals = v_percent_neutrals,
        percent_detractors = v_percent_detractors,
        nps_feedback = v_nps_feedback,
        type_feedback = v_feedback_type,
        response_a = (v_response_a / v_total_deliverables) * 100,
        response_b = (v_response_b / v_total_deliverables) * 100,
        response_c = (v_response_c / v_total_deliverables) * 100,
        response_d = (v_response_d / v_total_deliverables) * 100,
        response_a_online = (v_response_a_online / v_total_deliverables) * 100,
        response_b_online = (v_response_b_online / v_total_deliverables) * 100,
        response_c_online = (v_response_c_online / v_total_deliverables) * 100,
        response_d_online = (v_response_d_online / v_total_deliverables) * 100,
        response_yes_online = (v_response_yes_online / v_total_deliverables) * 100,
        response_no_online = (v_response_no_online / v_total_deliverables) * 100
    WHERE id_feedback = p_id_feedback;

END //

DELIMITER ;
