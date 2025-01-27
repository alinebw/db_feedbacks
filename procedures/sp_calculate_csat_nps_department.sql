-- Calculates CSAT and NPS for departments

DELIMITER //

CREATE PROCEDURE sp_calculate_csat_nps_department ()
BEGIN

    -- Update csat_department and nps_department
    UPDATE departments d
    SET 
        csat_department = (
            SELECT AVG(f.csat_feedback)
            FROM projects p
            JOIN tasklists t ON p.id_project = t.id_project
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE p.name_department = d.name_department
        ),
        nps_department = (
            SELECT AVG(f.nps_feedback)
            FROM projects p
            JOIN tasklists t ON p.id_project = t.id_project
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE p.name_department = d.name_department
        );

END //

DELIMITER ;

