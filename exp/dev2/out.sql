-----------------------------------------------
-- Export file for user ORA_VER              --
-- Created by kravchav on 08.10.10, 17:44:26 --
-----------------------------------------------

spool out.log

prompt
prompt Creating table OVC_CHANGE_OBJECT
prompt ================================
prompt
@@ovc_change_object.tab
prompt
prompt Creating table OVC_CHANGE_SOURCE
prompt ================================
prompt
@@ovc_change_source.tab
prompt
prompt Creating table OVC_DBLINK
prompt =========================
prompt
@@ovc_dblink.tab
prompt
prompt Creating table OVC_ERROR_LOG
prompt ============================
prompt
@@ovc_error_log.tab
prompt
prompt Creating table OVC_EVENT_DB
prompt ===========================
prompt
@@ovc_event_db.tab
prompt
prompt Creating table OVC_FILTER_TEMPLATE
prompt ==================================
prompt
@@ovc_filter_template.tab
prompt
prompt Creating table OVC_PROJECT
prompt ==========================
prompt
@@ovc_project.tab
prompt
prompt Creating table OVC_REVISION_TEMPLATE
prompt ====================================
prompt
@@ovc_revision_template.tab
prompt
prompt Creating table OVC_FILTER_SET
prompt =============================
prompt
@@ovc_filter_set.tab
prompt
prompt Creating table OVC_LOCK_OBJECT
prompt ==============================
prompt
@@ovc_lock_object.tab
prompt
prompt Creating table OVC_NAVIGATION
prompt =============================
prompt
@@ovc_navigation.tab
prompt
prompt Creating table OVC_OBJECT_TYPE
prompt ==============================
prompt
@@ovc_object_type.tab
prompt
prompt Creating table OVC_PROJECT_OBJECT
prompt =================================
prompt
@@ovc_project_object.tab
prompt
prompt Creating table OVC_REGISTRY_PATH
prompt ================================
prompt
@@ovc_registry_path.tab
prompt
prompt Creating table OVC_REGISTRY
prompt ===========================
prompt
@@ovc_registry.tab
prompt
prompt Creating table OVC_REVISION
prompt ===========================
prompt
@@ovc_revision.tab
prompt
prompt Creating table PLSQL_PROFILER_RUNS
prompt ==================================
prompt
@@plsql_profiler_runs.tab
prompt
prompt Creating table PLSQL_PROFILER_UNITS
prompt ===================================
prompt
@@plsql_profiler_units.tab
prompt
prompt Creating table PLSQL_PROFILER_DATA
prompt ==================================
prompt
@@plsql_profiler_data.tab
prompt
prompt Creating sequence OVC_CHANGE_OBJECT_SEQ
prompt =======================================
prompt
@@ovc_change_object_seq.seq
prompt
prompt Creating sequence OVC_CHANGE_SOURCE_SEQ
prompt =======================================
prompt
@@ovc_change_source_seq.seq
prompt
prompt Creating sequence OVC_DBLINK_SEQ
prompt ================================
prompt
@@ovc_dblink_seq.seq
prompt
prompt Creating sequence OVC_ERROR_LOG_SEQ
prompt ===================================
prompt
@@ovc_error_log_seq.seq
prompt
prompt Creating sequence OVC_EVENT_DB_SEQ
prompt ==================================
prompt
@@ovc_event_db_seq.seq
prompt
prompt Creating sequence OVC_FILTER_SEQ
prompt ================================
prompt
@@ovc_filter_seq.seq
prompt
prompt Creating sequence OVC_FILTER_SET_SEQ
prompt ====================================
prompt
@@ovc_filter_set_seq.seq
prompt
prompt Creating sequence OVC_LOCK_OBJECT_SEQ
prompt =====================================
prompt
@@ovc_lock_object_seq.seq
prompt
prompt Creating sequence OVC_MODIFY_TYPE_SEQ
prompt =====================================
prompt
@@ovc_modify_type_seq.seq
prompt
prompt Creating sequence OVC_NAVIGATION_SEQ
prompt ====================================
prompt
@@ovc_navigation_seq.seq
prompt
prompt Creating sequence OVC_OBJECT_TYPE_SEQ
prompt =====================================
prompt
@@ovc_object_type_seq.seq
prompt
prompt Creating sequence OVC_OPTIONS_SEQ
prompt =================================
prompt
@@ovc_options_seq.seq
prompt
prompt Creating sequence OVC_PROJECT_OBJECT_SEQ
prompt ========================================
prompt
@@ovc_project_object_seq.seq
prompt
prompt Creating sequence OVC_PROJECT_SEQ
prompt =================================
prompt
@@ovc_project_seq.seq
prompt
prompt Creating sequence OVC_REGISTRY_PATH_SEQ
prompt =======================================
prompt
@@ovc_registry_path_seq.seq
prompt
prompt Creating sequence OVC_REVISION_SEQ
prompt ==================================
prompt
@@ovc_revision_seq.seq
prompt
prompt Creating sequence OVC_REVISION_TEMPLATE_SEQ
prompt ===========================================
prompt
@@ovc_revision_template_seq.seq
prompt
prompt Creating sequence OVC_SCHEMA_SEQ
prompt ================================
prompt
@@ovc_schema_seq.seq
prompt
prompt Creating sequence PLSQL_PROFILER_RUNNUMBER
prompt ==========================================
prompt
@@plsql_profiler_runnumber.seq
prompt
prompt Creating package P_OVC_DBOBJECT
prompt ===============================
prompt
@@p_ovc_dbobject.pck
prompt
prompt Creating type T_SOURCE_LINE
prompt ===========================
prompt
@@t_source_line.tps
prompt
prompt Creating type T_SOURCE_TABLE
prompt ============================
prompt
@@t_source_table.tps
prompt
prompt Creating package P_OVC_DIFF
prompt ===========================
prompt
@@p_ovc_diff.pck
prompt
prompt Creating package P_OVC_ENGINE
prompt =============================
prompt
@@p_ovc_engine.pck
prompt
prompt Creating package P_OVC_EXCEPTION
prompt ================================
prompt
@@p_ovc_exception.pck
prompt
prompt Creating package P_OVC_FILTER
prompt =============================
prompt
@@p_ovc_filter.pck
prompt
prompt Creating package P_OVC_GATEWAY
prompt ==============================
prompt
@@p_ovc_gateway.pck
prompt
prompt Creating package P_OVC_HTTP
prompt ===========================
prompt
@@p_ovc_http.pck
prompt
prompt Creating package P_OVC_LOCK
prompt ===========================
prompt
@@p_ovc_lock.pck
prompt
prompt Creating package P_OVC_PROJECT
prompt ==============================
prompt
@@p_ovc_project.pck
prompt
prompt Creating package P_OVC_REGISTRY
prompt ===============================
prompt
@@p_ovc_registry.pck
prompt
prompt Creating package P_OVC_REVISION
prompt ===============================
prompt
@@p_ovc_revision.pck
prompt
prompt Creating package P_OVC_SOURCE
prompt =============================
prompt
@@p_ovc_source.pck
prompt
prompt Creating package P_OVC_STR_UTILS
prompt ================================
prompt
@@p_ovc_str_utils.pck
prompt
prompt Creating package P_OVC_UTILITY
prompt ==============================
prompt
@@p_ovc_utility.pck
prompt
prompt Creating function CORRECT_INN
prompt =============================
prompt
@@correct_inn.fnc
prompt
prompt Creating function E5
prompt ====================
prompt
@@e5.fnc
prompt
prompt Creating trigger TR_OVC_ON_OBJ_CHANGE
prompt =====================================
prompt
@@tr_ovc_on_obj_change.trg

spool off
