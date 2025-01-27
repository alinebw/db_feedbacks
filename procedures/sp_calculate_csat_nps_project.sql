-- Calculates CSAT and NPS for projects

DELIMITER //

CREATE PROCEDURE sp_calculate_csat_nps_project ()
BEGIN

    -- Update csat_project and nps_project
    UPDATE projects p
    SET 
        csat_project = (
            SELECT AVG(f.csat_feedback)
            FROM tasklists t
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE t.id_project = p.id_project
        ),
        nps_project = (
            SELECT AVG(f.nps_feedback)
            FROM tasklists t
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE t.id_project = p.id_project
        );

END //

DELIMITER ;

