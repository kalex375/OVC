/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.LockPanel
 * @extends Ext.app.ux.TaskPanel
 *
 * Задача Filters. Панель отображает списокшаблонов фильтров, которые затем можно
 * использывать для отслеживания изменения в БД или для ревизий.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.filterpanel
 */
Ext.app.task.LockPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'l_grid_panel',
                layout: 'fit',
                autoScroll: false
            }],
            loadPanel: function(){
                var grid = new Ext.app.ux.FormEditGrid({
                    id: 'grid_lock',
                    
                    textAdd: 'Add',
                    tooltipAdd: 'Add lock',
                    textEdit: 'Edit',
                    tooltipEdit: 'Edit lock',
                    textDelete: 'Delete',
                    tooltipDelete: 'Delete lock',
                    nameField: 'ID',
                    objectName: 'locks',
                    
                    updater: {
                        insertCommand: 'p_ovc_filter.create_filter',
                        deleteCommand: 'p_ovc_lock.clear_lock',
                        prefix: 'p_'
                    },
					recordForm: {
                ignoreFields: {
                    ID: true,
                    LOCK_TIME: true,
                },
                disabledFields: {
                    PARAM: true,
                    TYPE: true
                }
            },
                    store: new Ext.data.Store({
                        id: 'store_lock',
                        url: 'p_ovc_http.get_lock_table',
                        
                        reader: new Ext.data.XmlReader({
                            record: 'ROW',
                            id: 'ID',
                            totalProperty: "TOTALROWS",
                            fields: [{
                                name: 'ID',
                                type: 'int'
                            }, {
                                name: 'OBJ_TYPE',
                                type: 'string'
                            }, {
                                name: 'OBJ_OWNER',
                                type: 'string'
                            }, {
                                name: 'OBJ_NAME',
                                type: 'string'
                            }, {
                                name: 'LOCK_USER',
                                type: 'string'
                            }, {
                                name: 'LOCK_TERMINAL',
                                type: 'string'
                            }, {
                                name: 'LOCK_OS_USER',
                                type: 'string'
                            }, {
                                name: 'LOCK_TIME',
                                type: 'date',
                                dateFormat: 'd.m.Y H:i:s'
                            }, {
                                name: 'IS_FULL',
                                type: 'string'
                            }, {
                                name: 'NOTE',
                                type: 'string'
                            }]
                        })
                    }),
                    columns: [{
                        header: "Id",
                        dataIndex: 'ID',
                        width: 50,
                        hidden: true,
                        sortable: true
                    }, {
                        header: "Object type",
                        dataIndex: 'OBJ_TYPE',
                        width: 150,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Object owner",
                        dataIndex: 'OBJ_OWNER',
                        width: 150,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Object name",
                        dataIndex: 'OBJ_NAME',
                        width: 150,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "User",
                        dataIndex: 'LOCK_USER',
                        width: 80,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: true
                        })
                    }, {
                        header: "Terminal",
                        dataIndex: 'LOCK_TERMINAL',
                        width: 80,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: true
                        })
                    }, {
                        header: "OS user",
                        dataIndex: 'LOCK_OS_USER',
                        width: 80,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: true
                        })
                    }, {
                        header: "Lock time",
                        dataIndex: 'LOCK_TIME',
                        width: 100,
                        sortable: true,
                        editor: new Ext.form.DateField({
                            format: 'd.m.Y H:i:s'
                        }),
                        xtype: 'datecolumn',
                        format: 'd.m.Y H:i:s'
                    },
					{
                        header: "Is full",
                        dataIndex: 'IS_FULL',
                        width: 50,
                        sortable: true,
                        editor: new Ext.app.ux.ComboBoxYN({
							allowBlank: false
                        })
                    },
					{
                        header: "Note",
                        dataIndex: 'NOTE',
                        width: 200,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: true
                        })
                    }]
                });
                
                grid.store.paramNames.start = "p_start"; //by default it is "start"	
                grid.store.paramNames.limit = "p_limit"; //by default it is "start"
                grid.store.load({
                    params: {
                        p_start: 0,
                        p_limit: 25
                    
                    }
                });
                this.getComponent('l_grid_panel').add(grid);
            }
            
        });
        Ext.app.task.LockPanel.superclass.initComponent.apply(this, arguments);
    }
    
});

Ext.reg("task.lockpanel", Ext.app.task.LockPanel);
