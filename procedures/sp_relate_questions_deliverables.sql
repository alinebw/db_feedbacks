-- Procedure to relate questions and deliverables

DELIMITER //

CREATE PROCEDURE sp_relate_questions_deliverables (
    IN p_id_deliverable VARCHAR(45)
)
BEGIN
    -- Inserts unique relationships between questions and deliverables
    INSERT IGNORE INTO questions_deliverables (id_question, id_deliverable)
    SELECT DISTINCT q.id_question, d.id_deliverable
    FROM questions q
    JOIN deliverables d 
        ON d.id_feedback = q.id_feedback
    WHERE d.id_deliverable = p_id_deliverable;
END //

DELIMITER ;
