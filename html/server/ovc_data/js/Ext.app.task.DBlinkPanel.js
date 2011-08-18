/**
 * @author Kravchenko A.V.
 */
Ext.ns('Ext.app.task');
/**
 * @class Ext.app.task.DBLinkPanel
 * @extends Ext.app.ux.TaskPanel
 *
 *	Задача DB links. Панель отображает список БД которыми можно управлять с помощюь OVC
 *
 *
 * @constructor
 * @param {Object} config The config object
 * @xtype task.dblinkpanel
 */
Ext.app.task.DBLinkPanel = Ext.extend(Ext.app.ux.TaskPanel, {
    initComponent: function(){
        Ext.apply(this, {
            margins: '0 0 0 0',
            layout: 'border',
            closable: true,
            items: [{
                xtype: 'panel',
                region: 'center',
                border: false,
                id: 'dbl_grid_panel',
                layout: 'fit',
                autoScroll: false
            }],
            loadPanel: function(){
                var grid = new Ext.app.ux.FormEditGrid({
                    id: 'grid_dblink',
                    
                    textAdd: 'Add',
					tooltipAdd: 'Add link',
    				textEdit: 'Edit',
					tooltipEdit: 'Edit link',
    				textDelete: 'Delete',
					tooltipDelete: 'Delete link',
                    nameField: 'ID',
                    objectName: 'links',
                    
                    updater: {
                        insertCommand: 'p_ovc_gateway.create_dblink',
                        updateCommand: 'p_ovc_gateway.update_dblink',
                        deleteCommand: 'p_ovc_gateway.delete_dblink',
                        prefix: 'p_'
                    },
                    store: new Ext.data.Store({
                        id: 'store_dblink',
                        url: 'p_ovc_http.get_dblink_table',
                        
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
                                defaultValue: ''
                            }, {
                                name: 'DESCRIPTION',
                                type: 'string',
                                defaultValue: ''
                            }, {
                                name: 'TYPE',
                                type: 'string',
                                defaultValue: ''
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
                        header: "Description",
                        dataIndex: 'DESCRIPTION',
                        width: 60,
                        sortable: true,
                        editor: new Ext.form.TextField({
                            allowBlank: true
                        })
                    }, {
                        header: "Type",
                        dataIndex: 'TYPE',
                        width: 60,
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
                this.getComponent('dbl_grid_panel').add(grid);
            }
            
        });
        Ext.app.task.DBLinkPanel.superclass.initComponent.apply(this, arguments);
    }
    
});

Ext.reg("task.dblinkpanel", Ext.app.task.DBLinkPanel);
