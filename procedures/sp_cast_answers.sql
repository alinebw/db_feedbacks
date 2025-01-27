-- Procedure to cast answers from the view questions_answers

DELIMITER //

CREATE PROCEDURE sp_cast_answers (
    IN p_id_deliverable VARCHAR(45)
)
BEGIN
    DECLARE v_csat_consultant DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_csat_event DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_nps DECIMAL(5, 2) DEFAULT NULL;
    DECLARE v_nps_status ENUM('PROMOTER', 'NEUTRAL', 'DETRACTOR');
    DECLARE v_csat_content_option VARCHAR(20) DEFAULT NULL;
    DECLARE v_csat_content_online_option VARCHAR(20) DEFAULT NULL;
    DECLARE v_platform_accessible VARCHAR(3) DEFAULT NULL;
    DECLARE v_feedback_type VARCHAR(20) DEFAULT NULL;
    DECLARE v_mandatory_comment TEXT DEFAULT ''; -- Default value is empty
    DECLARE v_optional_comment TEXT DEFAULT NULL;
    DECLARE v_respondent_name VARCHAR(100) DEFAULT NULL;

    -- Retrieves values from the view
    SELECT 
        MAX(CASE WHEN ref = 'csat_consultant' THEN CAST(answer_value AS DECIMAL(5, 2)) END),
        MAX(CASE WHEN ref = 'csat_event' THEN CAST(answer_value AS DECIMAL(5, 2)) END),
        MAX(CASE WHEN ref = 'nps' THEN CAST(answer_value AS DECIMAL(5, 2)) END),
        MAX(CASE WHEN ref = 'csat_content' THEN answer_text END),
        MAX(CASE WHEN ref = 'csat_content_online' THEN answer_text END),
        MAX(CASE WHEN ref = '01JEY4V92D0W6B7Z8B85P4PJPD' THEN CAST(answer_value AS DECIMAL(5, 2)) END),
        MAX(CASE WHEN ref = 'mandatory_comment' THEN answer_text END),
        MAX(CASE WHEN ref = 'optional_comment' THEN answer_text END),
        MAX(CASE WHEN ref = 'name' THEN answer_text END)
    INTO 
        v_csat_consultant, 
        v_csat_event, 
        v_nps, 
        v_csat_content_option,
        v_csat_content_online_option,
        v_platform_accessible, 
        v_mandatory_comment, 
        v_optional_comment, 
        v_respondent_name
    FROM vw_questions_answers
    WHERE id_deliverable = p_id_deliverable;

    -- Maps the platform_accessible response
    IF v_platform_accessible = 1 THEN
        SET v_platform_accessible = 'Yes';
    ELSEIF v_platform_accessible = 0 THEN
        SET v_platform_accessible = 'No';
    ELSE
        SET v_platform_accessible = NULL; -- For error or invalid responses
    END IF;

    -- Determines the feedback type
    IF v_platform_accessible IS NOT NULL THEN
        SET v_feedback_type = 'Online';
    ELSE
        SET v_feedback_type = 'In-person';
    END IF;

    -- Determines the NPS status
    IF v_nps >= 9 THEN
        SET v_nps_status = 'PROMOTER';
    ELSEIF v_nps BETWEEN 7 AND 8 THEN
        SET v_nps_status = 'NEUTRAL';
    ELSEIF v_nps <= 6 THEN
        SET v_nps_status = 'DETRACTOR';
    ELSE
        SET v_nps_status = NULL; -- For error cases
    END IF;

    -- Updates the values in the deliverables table
    UPDATE deliverables
    SET
        csat_consultant = v_csat_consultant,
        csat_event = v_csat_event,
        nps = v_nps,
        nps_status = v_nps_status,
        csat_content_option = IF(v_platform_accessible IS NULL, v_csat_content_option, NULL),
        csat_content_online_option = IF(v_platform_accessible IS NOT NULL, v_csat_content_online_option, NULL),
        platform_accessible = v_platform_accessible,
        feedback_type = v_feedback_type,
        mandatory_comment = v_mandatory_comment,
        optional_comment = v_optional_comment,
        respondent_name = v_respondent_name
    WHERE id_deliverable = p_id_deliverable;

END //

DELIMITER ;
