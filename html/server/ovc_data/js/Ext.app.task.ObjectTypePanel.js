/**
 * @author Kravchenko A.V.
 */

Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.ObjectTypePanel
 * @extends Ext.app.ux.TaskPanel
 *
 * Задача Object types. Панель отображает список типов объектов с которыми работает OVC.
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.objecttypepanel
 */
Ext.app.task.ObjectTypePanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'ot_grid_panel',
                layout: 'fit',
                autoScroll: false
            }],
            loadPanel: function(){
                var grid = new Ext.app.ux.FormEditGrid({
                    id: 'grid_filter',
					
					textAdd: 'Add',
					tooltipAdd: 'Add type',
    				textEdit: 'Edit',
					tooltipEdit: 'Edit type',
    				textDelete: 'Delete',
					tooltipDelete: 'Delete type',
    				nameField: 'TYPE',
					objectName:'types',
					
					  viewConfig: {
                        forceFit: true
                    },
					
                    updater: {
                        insertCommand: 'p_ovc_dbobject.create_object_type',
            			updateCommand: 'p_ovc_dbobject.update_object_type',
            			deleteCommand: 'p_ovc_dbobject.delete_object_type',
						prefix: 'p_'
                    },
					store: new Ext.data.Store({
                id: 'store_objecttype',
                url: 'p_ovc_http.get_objecttype_table',
                // the return will be XML, so lets set up a reader
                reader: new Ext.data.XmlReader({
                    record: 'ROW',
                    id: 'ID',
                    totalProperty: "TOTALROWS",
                    fields: [{
                        name: 'ID',
                        type: 'int'
                    }, {
                        name: 'TYPE',
                        type: 'string'
                    }, {
                        name: 'METADATA_TYPE',
                        type: 'string'
                    }, {
                        name: 'GET_FUNCTION',
                        type: 'string'
                    }, {
                        name: 'IS_PROGRAM',
                        type: 'string'
                    }, {
                        name: 'IS_COMPARE',
                        type: 'string'
                    }, {
                        name: 'ICON',
                        type: 'string'
                    }]
                }),
            }),
            // grid columns
            columns: [{
                header: "Id",
                dataIndex: 'ID',
                width: 50,
                hidden: true,
                sortable: true
            }, {
                header: "Type",
                dataIndex: 'TYPE',
                width: 110,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: false
                })
            }, {
                header: "Metadata type",
                dataIndex: 'METADATA_TYPE',
                width: 110,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: true
                })
            }, {
                header: "Function",
                dataIndex: 'GET_FUNCTION',
                width: 300,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: true
                })
            }, {
                header: "Program",
                dataIndex: 'IS_PROGRAM',
                width: 50,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: false
                })
            }, {
                header: "Compare",
                dataIndex: 'IS_COMPARE',
                width: 50,
                sortable: true,
                editor: new Ext.form.TextField({
                    allowBlank: false
                })
            }, {
                header: "Icon",
                dataIndex: 'ICON',
                width: 80,
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
                this.getComponent('ot_grid_panel').add(grid);
            }
            
        });
        Ext.app.task.ObjectTypePanel.superclass.initComponent.apply(this, arguments);
    }
    
});

Ext.reg("task.objecttypepanel", Ext.app.task.ObjectTypePanel);
