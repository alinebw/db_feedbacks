-- Calculates CSAT and NPS for customers

DELIMITER //

CREATE PROCEDURE sp_calculate_csat_nps_customer ()
BEGIN

    -- Update csat_customer and nps_customer
    UPDATE customers c
    SET 
        csat_customer = (
            SELECT AVG(f.csat_feedback)
            FROM customers_projects cp
            JOIN projects p ON cp.id_project = p.id_project
            JOIN tasklists t ON p.id_project = t.id_project
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE cp.id_customer = c.id_customer
        ),
        nps_customer = (
            SELECT AVG(f.nps_feedback)
            FROM customers_projects cp
            JOIN projects p ON cp.id_project = p.id_project
            JOIN tasklists t ON p.id_project = t.id_project
            JOIN feedbacks f ON t.id_tasklist = f.id_tasklist
            WHERE cp.id_customer = c.id_customer
        );

END //

DELIMITER ;

