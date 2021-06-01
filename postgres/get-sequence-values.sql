 
 
 select format('select ''%s.%s'', %s.last_value from %s.%s union all ', sequence_schema,sequence_name,sequence_name,sequence_schema, sequence_name) from information_schema.sequences;
 
 
 select 'valuation.valuation_id_seq' sequence_name, valuation_id_seq.last_value from valuation.valuation_id_seq union all
 select 'products.pir_reference', pir_reference.last_value from products.pir_reference union all
 select 'products.prr_order_det_seq', prr_order_det_seq.last_value from products.prr_order_det_seq union all
 select 'extract_ato.ato_sbr_seq', ato_sbr_seq.last_value from extract_ato.ato_sbr_seq union all
 select 'sct_spatial.road_staging_ogc_fid_seq', road_staging_ogc_fid_seq.last_value from sct_spatial.road_staging_ogc_fid_seq union all
 select 'sct_spatial.valuation_cadastre_staging_ogc_fid_seq', valuation_cadastre_staging_ogc_fid_seq.last_value from sct_spatial.valuation_cadastre_staging_ogc_fid_seq union all
 select 'report_admin.lssa_invoice_seq', lssa_invoice_seq.last_value from report_admin.lssa_invoice_seq union all
 select 'finance.elec_lodgement_invoice_seq', elec_lodgement_invoice_seq.last_value from finance.elec_lodgement_invoice_seq union all
 select 'finance.invoice_order_seq', invoice_order_seq.last_value from finance.invoice_order_seq union all
 select 'finance.lodgement_invoice_seq', lodgement_invoice_seq.last_value from finance.lodgement_invoice_seq union all
 select 'finance.product_invoice_seq', product_invoice_seq.last_value from finance.product_invoice_seq union all
 select 'finance.receipt_seq', receipt_seq.last_value from finance.receipt_seq union all
 select 'finance.ref_invoice_seq', ref_invoice_seq.last_value from finance.ref_invoice_seq union all
 select 'finance.vendor_seq', vendor_seq.last_value from finance.vendor_seq union all
 select 'finance.lssa_product_invoice_seq', lssa_product_invoice_seq.last_value from finance.lssa_product_invoice_seq union all
 select 'workflow.act_evt_log_seq', act_evt_log_seq.last_value from workflow.act_evt_log_seq union all
 select 'extract_sth.extract_run_id', extract_run_id.last_value from extract_sth.extract_run_id union all
 select 'extract_sth.extract_sth_id', extract_sth_id.last_value from extract_sth.extract_sth_id union all
 select 'core.anonymiser_public_id_sequence', anonymiser_public_id_sequence.last_value from core.anonymiser_public_id_sequence union all
 select 'core.anonymiser_sequence', anonymiser_sequence.last_value from core.anonymiser_sequence union all
 select 'core.audit_id', audit_id.last_value from core.audit_id union all
 select 'core.ilis_id', ilis_id.last_value from core.ilis_id union all
 select 'core.hibernate_sequence', hibernate_sequence.last_value from core.hibernate_sequence union all
 select 'services.batch_job_execution_seq', batch_job_execution_seq.last_value from services.batch_job_execution_seq union all
 select 'services.batch_job_seq', batch_job_seq.last_value from services.batch_job_seq union all
 select 'services.batch_job_unique_name_seq', batch_job_unique_name_seq.last_value from services.batch_job_unique_name_seq union all
 select 'services.batch_step_execution_seq', batch_step_execution_seq.last_value from services.batch_step_execution_seq union all
 select 'services.job_queue_id_seq', job_queue_id_seq.last_value from services.job_queue_id_seq union all
 select 'services.job_queue_seq', job_queue_seq.last_value from services.job_queue_seq union all
 select 'services.notices_generation_id_seq', notices_generation_id_seq.last_value from services.notices_generation_id_seq union all
 select 'services.table_changes_id_seq', table_changes_id_seq.last_value from services.table_changes_id_seq union all
 select 'logging.i3_message_seq', i3_message_seq.last_value from logging.i3_message_seq union all
 select 'logging.i3_request_id', i3_request_id.last_value from logging.i3_request_id union all
 select 'accounts.organisation_id_seq', organisation_id_seq.last_value from accounts.organisation_id_seq union all
 select 'titling.cp_seq', cp_seq.last_value from titling.cp_seq union all
 select 'titling.dealing_no_seq', dealing_no_seq.last_value from titling.dealing_no_seq union all
 select 'titling.dp_seq', dp_seq.last_value from titling.dp_seq union all
 select 'titling.duplicate_title_batch_seq', duplicate_title_batch_seq.last_value from titling.duplicate_title_batch_seq union all
 select 'titling.fp_seq', fp_seq.last_value from titling.fp_seq union all
 select 'titling.gnu_process_track_id', gnu_process_track_id.last_value from titling.gnu_process_track_id union all
 select 'titling.gro_no_seq', gro_no_seq.last_value from titling.gro_no_seq union all
 select 'titling.old_dealing_app_no_seq', old_dealing_app_no_seq.last_value from titling.old_dealing_app_no_seq union all
 select 'titling.owner_num_a_seq', owner_num_a_seq.last_value from titling.owner_num_a_seq union all
 select 'titling.owner_num_c_seq', owner_num_c_seq.last_value from titling.owner_num_c_seq union all
 select 'titling.owner_num_g_seq', owner_num_g_seq.last_value from titling.owner_num_g_seq union all
 select 'titling.owner_num_p_seq', owner_num_p_seq.last_value from titling.owner_num_p_seq union all
 select 'titling.par_id_seq', par_id_seq.last_value from titling.par_id_seq union all
 select 'titling.priority_notice_seq', priority_notice_seq.last_value from titling.priority_notice_seq union all
 select 'titling.sp_seq', sp_seq.last_value from titling.sp_seq union all
 select 'titling.stitleno_seq', stitleno_seq.last_value from titling.stitleno_seq union all
 select 'titling.suppression_applicant_seq', suppression_applicant_seq.last_value from titling.suppression_applicant_seq union all
 select 'titling.vol_fol_seq', vol_fol_seq.last_value from titling.vol_fol_seq union all
 select 'nec.iseq$$_102141', iseq$$_102141.last_value from nec.iseq$$_102141 union all
 select 'nec.nec_agent_code_seq', nec_agent_code_seq.last_value from nec.nec_agent_code_seq union all
 select 'titling.sdocno_seq', sdocno_seq.last_value from titling.sdocno_seq;