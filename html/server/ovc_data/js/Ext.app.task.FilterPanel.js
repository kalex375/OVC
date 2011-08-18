/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.FilterPanel
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
Ext.app.task.FilterPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'f_grid_panel',
                layout: 'fit',
                autoScroll: false
            }],
            loadPanel: function(){
                var grid = new Ext.app.ux.FormEditGrid({
                    id: 'grid_filter',
					
					textAdd: 'Add',
					tooltipAdd: 'Add filter',
    				textEdit: 'Edit',
					tooltipEdit: 'Edit filter',
    				textDelete: 'Delete',
					tooltipDelete: 'Delete filter',
    				nameField: 'ID',
					objectName:'filters',
					
                    updater: {
                        insertCommand: 'p_ovc_filter.create_filter_template',
                        updateCommand: 'p_ovc_filter.update_filter_template',
						deleteCommand: 'p_ovc_filter.delete_filter_template',
						prefix: 'p_'
                    },
                    store: new Ext.data.Store({
                        id: 'store_filter',
                        url: 'p_ovc_http.get_filter_table',
                        
                        reader: new Ext.data.XmlReader({
                            record: 'ROW',
                            id: 'ID',
                            totalProperty: "TOTALROWS",
                            
                            fields: [{
                                name: 'ID',
                                type: 'int'
                            
                            }, {
                                name: 'NAME',
                                type: 'string',
                                defaultValue: 'Template #'
                            }, {
                                name: 'OBJ_TYPE',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'OBJ_OWNER',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'OBJ_NAME',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'MODIFY_USER',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'MODIFY_TERMINAL',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'MODIFY_OS_USER',
                                type: 'string',
                                defaultValue: '%'
                            }, {
                                name: 'IGNORE',
                                type: 'string',
                                defaultValue: 'F'
                            }]
                        })
                    }),
                    viewConfig: {
                        forceFit: true
                    },
                    columns: [{
                        header: "Id",
                        dataIndex: 'ID',
                        width: 50,
                        hidden: true,
                        sortable: true
                    }, {
                        header: "Name",
                        dataIndex: 'NAME',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Object type",
                        dataIndex: 'OBJ_TYPE',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Object owner",
                        dataIndex: 'OBJ_OWNER',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Object name",
                        dataIndex: 'OBJ_NAME',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "modify user",
                        dataIndex: 'MODIFY_USER',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Modify terminal",
                        dataIndex: 'MODIFY_TERMINAL',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Modify OS user",
                        dataIndex: 'MODIFY_OS_USER',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
                        })
                    }, {
                        header: "Ignore",
                        dataIndex: 'IGNORE',
                        width: 30,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: false
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
                this.getComponent('f_grid_panel').add(grid);
            }
            
        });
        Ext.app.task.FilterPanel.superclass.initComponent.apply(this, arguments);
    }
    
});

Ext.reg("task.filterpanel", Ext.app.task.FilterPanel);
