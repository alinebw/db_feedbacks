-- Fetch data from prod and update local tables

DELIMITER //

CREATE PROCEDURE sp_update_data_from_prod ()
BEGIN
    DECLARE v_id_feedback VARCHAR(45);
    DECLARE v_id_deliverable VARCHAR(255);
    
    -- Updates information in the feedbacks table from checklist_feedback
    UPDATE feedbacks f
    JOIN prod.checklist_feedback cf 
        ON CONVERT(cf.class_id USING utf8mb4) COLLATE utf8mb4_unicode_ci = f.id_feedback COLLATE utf8mb4_unicode_ci
        AND CONVERT(cf.class_name USING utf8mb4) COLLATE utf8mb4_unicode_ci = f.id_tasklist COLLATE utf8mb4_unicode_ci
    SET 
        f.total_participants = cf.participant_count;

    -- Inserts new projects into the projects table
    INSERT IGNORE INTO projects (id_project)
    SELECT DISTINCT 
        cf.project_id
    FROM prod.checklist_feedback cf
    JOIN deliverables d
        ON CONVERT(cf.class_id USING utf8mb4) COLLATE utf8mb4_unicode_ci = d.id_feedback COLLATE utf8mb4_unicode_ci
        AND CONVERT(cf.class_name USING utf8mb4) COLLATE utf8mb4_unicode_ci = d.id_tasklist COLLATE utf8mb4_unicode_ci
    WHERE cf.project_id IS NOT NULL;

    -- Updates information in deliverables from checklist_feedback
    UPDATE deliverables d
    JOIN prod.checklist_feedback cf 
        ON CONVERT(cf.class_id USING utf8mb4) COLLATE utf8mb4_unicode_ci = d.id_feedback COLLATE utf8mb4_unicode_ci
        AND CONVERT(cf.class_name USING utf8mb4) COLLATE utf8mb4_unicode_ci = d.id_tasklist COLLATE utf8mb4_unicode_ci
    SET 
        d.id_project = cf.project_id;

    -- Inserts new customers into the customers table
    INSERT IGNORE INTO customers (id_customer)
    SELECT DISTINCT 
        cl.id
    FROM prod.projects p
    JOIN prod.clients cl
        ON cl.id = p.client_id
    WHERE cl.id IS NOT NULL;
    
    -- Updates information in customers from the clients table
    UPDATE customers c
    JOIN prod.clients cl
        ON cl.id = c.id_customer
    SET 
        c.name_customer = CONVERT(cl.company_name USING utf8mb4) COLLATE utf8mb4_unicode_ci
    WHERE c.id_customer = cl.id;

    -- Inserts data into customers_projects from projects
    INSERT IGNORE INTO customers_projects (id_customer, id_project)
    SELECT DISTINCT 
        p.client_id, 
        p.id
    FROM prod.projects p
    JOIN customers c ON c.id_customer = p.client_id
    JOIN projects pr ON pr.id_project = p.id
    WHERE p.client_id IS NOT NULL;
    
    -- Updates information in projects from TBL_project_full
    UPDATE projects p
    JOIN prod.TBL_project_full pf
        ON CAST(pf.id AS CHAR(45)) COLLATE utf8mb4_unicode_ci = p.id_project
    SET 
        p.name_project = TRIM(CONVERT(pf.title USING utf8mb4)) COLLATE utf8mb4_unicode_ci,
        p.name_department = TRIM(CONVERT(pf.Area USING utf8mb4)) COLLATE utf8mb4_unicode_ci
    WHERE pf.id IS NOT NULL
      AND p.id_project IS NOT NULL;
      

    -- Inserts new departments into the departments table
    INSERT IGNORE INTO departments (name_department)
    SELECT DISTINCT 
        LEFT(TRIM(CONVERT(pf.Area USING utf8mb4)), 500) COLLATE utf8mb4_unicode_ci AS name_department
    FROM prod.TBL_project_full pf
    JOIN projects p
        ON CAST(pf.id AS CHAR(45)) COLLATE utf8mb4_unicode_ci = p.id_project
    WHERE pf.Area IS NOT NULL;


    -- Logs to identify the point of error
    INSERT INTO processing_logs (id_deliverable, id_feedback, status, processing_date, message)
    VALUES (v_id_deliverable, v_id_feedback, 'PROD Updated', NOW(), 'Feedback data updated from checklist_feedback table');

END //

DELIMITER ;

