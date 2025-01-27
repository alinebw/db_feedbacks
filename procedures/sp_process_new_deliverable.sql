DELIMITER //

CREATE PROCEDURE sp_process_new_deliverable (
    IN p_id_deliverable VARCHAR(45)
)
BEGIN
    DECLARE invalid_data BOOL DEFAULT FALSE;

    sp_process_new_deliverable_block: BEGIN
        -- Verifies conditions related to the ID and status of the deliverable
        IF NOT EXISTS (SELECT 1 FROM deliverables WHERE id_deliverable = p_id_deliverable) THEN
            -- Logs information that there are no new deliverables
            INSERT INTO processing_logs (id_deliverable, processing_date, status, message)
            VALUES (NULL, NOW(), 'NO_DELIVERABLE', 'No new deliverables to process.');
            LEAVE sp_process_new_deliverable_block;
        ELSEIF EXISTS (SELECT 1 FROM deliverables WHERE id_deliverable = p_id_deliverable AND status = 'PROCESSED') THEN
            -- Does not execute processing but logs the event
            INSERT INTO processing_logs (id_deliverable, processing_date, status, message)
            VALUES (p_id_deliverable, NOW(), 'IGNORED', 'Deliverable already processed previously.');
            LEAVE sp_process_new_deliverable_block;
        END IF;

        -- Verifies data integrity
        SELECT 1 INTO invalid_data
        FROM deliverables
        WHERE id_deliverable = p_id_deliverable
          AND (id_feedback IS NULL OR received_date IS NULL);

        IF invalid_data THEN
            -- Logs an error if the data is invalid
            INSERT INTO processing_logs (id_deliverable, processing_date, status, message)
            VALUES (p_id_deliverable, NOW(), 'ERROR', 'Invalid or incomplete data in the deliverable.');
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Invalid or incomplete data in the deliverable.';
        END IF;

        -- Updates status to PROCESSED
        UPDATE deliverables
        SET
            processing_date = NOW(),
            status = 'PROCESSED'
        WHERE id_deliverable = p_id_deliverable;

        -- Logs success
        INSERT INTO processing_logs (id_deliverable, processing_date, status, message)
        VALUES (p_id_deliverable, NOW(), 'PROCESSED', 'Data processed successfully.');
    END sp_process_new_deliverable_block;

END //

DELIMITER ;
